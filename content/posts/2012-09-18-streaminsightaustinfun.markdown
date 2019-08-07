---
layout: post
title: "StreamInsight in Azure"
date: "2012-09-18 05:21:59"
comments: false
categories: StreamInsight Azure
---

Well, the dust is starting to settle after an amazing geek-out week at the gold coast with the Mexia team. Pre-TechEd Australia 2012, we kicked off with the Mexia's "Code Camp 2.0", an opportunity for the team to come together and deep dive (hack code, whiteboard, design and discuss, present) on emerging Microsoft technologies. It was epic to say the least.

One technology that particularly excites me is **StreamInsight**.

Perhaps because my brain has become so conditioned to the existing data storage techniques (relational, normalisation, warehousing, ETL, etc...) that we regularly apply in the industry, when I first learned of StreamInsight or Complex Event Processing (CEP), it seemed such a natural and elegant fit for so many common data problems we aim to solve today.

Mark Simms eloquently sums-up stream processing with his infamous "[how many red cars in the parking lot](http://blogs.msdn.com/b/masimms/archive/2010/07/23/secundus-posting-of-sorts.aspx)" analogy, which contrasts the stream processing and relational approaches to data processing. In essence StreamInsight is a platform for observing data in flight, that provides for:

- In-memory stream processing engine.
- Connecting streaming data sources (adapters) to continuously running standing queries.
- Asking questions about temporal and relational data (windows in time, relationships in time), including dynamically chaining and composing queries.
- Extensibility for queries, operators, aggregates and data connectivity.


Imagine running StreamInsight on Azure; a highly scalable stream engine that sits out in a data centre somewhere processing millions of events, when a pattern of interest emerges, StreamInsight will spray the aggregated event of interest through an output adapter. In StreamInsight 2.1, the term adapter is no longer, instead an IObservable or IOberserver is created and bound to the LINQ query, making the API extremely clean and elegant (much like Reactive Extensions). [StreamInsight in Windows Azure](http://blogs.msdn.com/b/streaminsight/archive/2012/02/23/streaminsight-in-windows-azure-austin-february-ctp.aspx), also known as Project Austin is in CTP. Project Austin enriches the base StreamInsight platform, by providing baked in HTTP Ingress functionality that can be scaled over a number of dedicated Azure instances, and a RESTful management API for provisioning and deploying into the underlying StreamInsight engine running in Azure.


Our high level concept for code camp, was to mash up:

- StreamInsight Austin (SI running in Azure) with a single HTTP ingress endpoint. This endpoint will receive all point events, that will be correlated by a LINQ query.
- Two custom IOberservable's that will plugin to StreamInsight Austin for output sinks.
- Azure Mobile Services for generating realtime Windows Push Notifications to a Windows 8 client, based off a StreamInsight alert event.
- Azure SQL Databases for persisting calculated point event aggregates at regular intervals, for later reporting and graphing.
- A Windows 8 application that will register the Push Notification channel, and render a live tile that is red/green based on the last aggregated calculation from StreamInsight.


![Concept](/images/b/cc2design.png Concept)

A great use-case is measuring the timings (latency) between correlated events:

- The time it takes to produce a pizza from receiving the customers initial order, to the time is comes out of the oven.
- The time it takes for a tram/train to move between its stops.
- The time it takes to deliver messages between organisations.

What is fantastic about StreamInsight or CEP, is that most of the data is treated as noise, and will amplify business intelligence from this noise. There is no need to store vast amounts of data for future analytics, just react if something interesting happens. For example, a large pizza company might produce hundreds-of-thousands of pizzas in a single day, but only if the order-to-delivery pipeline is taking longer than 25 minutes, will a point of interest be raised.

These aggregated output events can be pushed out through our custom `IObserver` implementations, also known as sinks. Because we are running in Azure/Austin created the following custom Azure aware sinks:

1. An Azure SQL Databases sink, that will persist a CEP event into a SQL table, and will additionally create the necessary table schema if it does not already exist. Using the excellent micro ORM [dapper](http://code.google.com/p/dapper-dot-net/).
2. An Azure Mobile Services sink, that will persist a CEP event through the new Azure Mobile Services infrastructure. Note, the Mobile Service SDK has tight Windows 8 dependencies, making it tough for Azure VM's to leverage the same API. Fortunately Ken Egozi has put together an [experimental platform agnostic API](https://github.com/kenegozi/azure-mobile-csharp-sdk) written purely in C#, that wraps the underlying REST API.

The sink is wrapped as an observer using the `Observer.Create` static from `System.Reactive`.

    public static IObserver<PointEvent<TEvent>> CreateObserver(string connectionString, bool storeCtis)
    {
        var res = new SqlAzureSink<TEvent>(connectionString, storeCtis);
        return Observer.Create<PointEvent<TEvent>>(e => res.OnNext(e));
    }

[Dapper](http://code.google.com/p/dapper-dot-net/) makes the `OnNext` implementation almost a single line:

    public void OnNext(PointEvent<TEvent> e)
    {
        if (e.EventKind == EventKind.Cti)
        {
            return;
        }

        var entity = e.Payload;

        try
        {
            _sqlConnection.Open();
            _sqlConnection.Insert(entity);
        }
        finally
        {
            _sqlConnection.Close();
        }
    }

OK, lets walk through the running end-to-end prototype.

First up, the StreamInsight Austin infrastructure is provisioned using the provided REST API. A dedicated instance exists for hosting the HTTP ingress endpoint, and another instance for hosting the actual StreamInsight engine.

![StreamInsight Austin Azure Instances](/images/b/cc2azureinstances.png)

The point events that pass through the HTTP ingress node then wash through the StreamInsight engine, which subsequently wash over the queries that have been deployed. The first point event are converted to edge events, and the second (correlating) point event is joined to the first based on a matching MessageID.

    // Convert points to signals
    var fooEdgeEvents = 
      from e in fooPointEvents
      .AlterEventDuration(e => TimeSpan.MaxValue)
      .ClipEventDuration(fooMessagesObservable, (e1, e2) => (e1.MessageId == e2.MessageId))
      select e;

    var latencyQuery =
        from e1 in fooEdgeEvents
        join e2 in barPointEvents
        on e1.MessageId equals e2.MessageId
        select new
        {
            StoreId = e1.StoreId,
            LatencyMs = e2.Timestamp.Subtract(e1.Timestamp).Milliseconds
        };

    var averageLatencyQuery = 
        from e1 in latencyQuery
        group e1 by e1.StoreId
        into storeGroup from win in storeGroup.TumblingWindow(TimeSpan.FromSeconds(60))
        select new MessageLatency()
        {
            Id = null,
            StoreId = storeGroup.Key,
            AverageLatency = win.Avg(e => e.LatencyMs),
            DateTime = DateTime.UtcNow
        };

These query outputs are then wired up to our custom sinks (an Azure SQL Database sink and Azure Mobile Services sink):

    maximumLatencyQuery.Bind(sqlSinkForMaximumMessageLatency(targetSqlConnectionString, false)).Run();
    maximumLatencyQuery.Bind(mobileServicesSinkForMaximumMessageLatency(mobileServicesEndpointURL, mobileServicesApplicationKey, false)).Run();

Next, provision the Azure SQL Database and Azure Mobile Service using the management portal:

![Azure Provisioning](/images/b/cc2mobileservices.png)

For the MessageLatencySummaryNotification table, we register a snippet of server-side JavaScript (actually built on top of node.js) whenever a record is inserted into the table. This will generate a Windows Push Notification (WPN) for every registered channel (which has a Windows 8 consumer on the other end).

    function insert(item, user, request) {
        request.execute({
            success: function () {
                request.respond();
                sendNotifications();
            }
        });
    
        function sendNotifications() {
            var channelTable = tables.getTable('Channel');
            channelTable.read({
                success: function (channels) {
                    channels.forEach(function (channel) {
    
                        var imageSrc = 'ms-appx:///images/good.png';
    
                        if (item.maximumLatency > 800) {
                            imageSrc = 'ms-appx:///images/bad.png';
                        }
    
                        push.wns.sendTileWideImageAndText01(channel.uri, {
                            image1src: imageSrc,
                            image1alt: 'Mexia is 1337',
                            text1: 'Maximum latency across all sources is ' + item.maximumLatency + ' ms'
                        }, {
                            success: function (pushResponse) {
                                console.log("Sent push:", pushResponse);
                            }
                        });
                    });
                }
            });
        }
    }

Finally the StreamInsight application (sinks, assemblies, LINQ queries, etc) are packaged up and deployed to the Azure Austin instances that were provisioned earlier.

For an end-to-end test, an event generator spays thousands of events into the HTTP ingress endpoint running in Azure. For each entity, two point events are generated to represent some interval that is measurable (i.e. the latency).

![Event Generator](/images/b/cc2eventgen.png Event Generator)

The Windows 8 app on start will register the push notification channel, and from that point on will react to push notifications produced from Azure Mobile Services node.js eventing layer (using the above JavaScript snippet). Here are the 3 states the live tile goes through (an event is produced every 60 seconds by StreamInsight, which results in a push notification).

![Windows 8 live tile](/images/b/cc2livetile.png)

<br />


StreamInsight, together with other crazy powerful "big data" technologies that are emerging such as Hadoop, PowerPivot and SQL Server Parallel Data Warehouse, are creating opportunities in data analytics and business intelligence that have previously been unattainable. A very exciting space to be involved with now and in the future.


StreamInsight gems and resources:

- [Channel9 Hands on Labs, Demos and Presentations](http://channel9.msdn.com/Learn/Courses/SQL2008R2TrainingKit/SQL10R2UPD05)
- [StreamInsight Samples](http://streaminsight.codeplex.com/) from the product team. As of 2012-09-18, some of the samples have been refreshed that highlight working with the new `IOberservable`/`IObserver` Rx style API.
- [StreamInsight in Windows Azure](http://blogs.msdn.com/b/streaminsight/archive/2012/02/23/streaminsight-in-windows-azure-austin-february-ctp.aspx) (Austin February CTP)
- Emil Velinov's TechEd NZ talk [Streaming Data Processing in the Cloud with Windows Azure SQL StreamInsight](http://channel9.msdn.com/Events/TechEd/NewZealand/TechEd-New-Zealand-2012/AZR306)
- It's crucial to understand the [event models that StreamInsight supports](http://msdn.microsoft.com/en-us/library/ee391434.aspx); the difference between point, interval and edge event types. It possible to convert event types (e.g. point to edge, also known as point-to-signal conversion) for achieving particular join scenarios.
- Know your [event window types](http://msdn.microsoft.com/en-us/library/ee842704.aspx); e.g. your tumbling window from your snapshot window.


A **big** thank you to Dean and Mat for making this happen.

