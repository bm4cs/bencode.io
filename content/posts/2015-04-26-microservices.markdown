---
layout: post
title: "Microservices"
date: "2015-04-26 22:09:01"
comments: false
categories:
- dev
tags:
- microservices
- architecture
---

Amped by [@yaamehn](https://twitter.com/yaamehn)'s opinionated [Microservices A Reference Architecture](https://www.youtube.com/watch?v=KHqMPRA6jVI&list=LL5wCy3trg9aNEBcarsIWUEg&index=1) recent talk at the Microservices Australia Meetup, has got me thinking about the many interesting possibilities Microservices stirs up. Many useful techniques are touched on, regardless of whether actually adopting Microservices.

On the surface Microservices doesn't appear to be anything groundbreakingly new. It does however push tried-and-trued concepts (e.g. abstraction, decoupling, modularisation, continuous delivery) to extreme levels. Fused with innovations in the operations space such as containerising like [Docker](https://www.docker.com/), can lead to some very powerful outcomes; such efficient continuous delivery (on a micro scale), decoupling of domains allowing for a best of bread technlogies, and so on.

Monoliths (i.e. softare that is bundled up as a single atomic distribution) are often critised when compared with Microservices architectures, however they still continue to exhibit a number of advantages over this modern approach. For example, monoliths are free to make extensive use of in-process module communication (IPC), as opposed to facing the many challenges that come with having conversations with a myriad of distributed software systems. Although not as relevant today, Sun Microsystems' L Peter Deutsch [fallacies of distributed computing](https://blogs.oracle.com/jag/resource/Fallacies.html) coined all the way back in 1994, still rings true.

> Essentially everyone, when they first build a distributed application, makes the following eight assumptions. All prove to be false in the long run and all cause big trouble and painful learning experiences.<br /><br />
> 1. The network is reliable<br />
> 2. Latency is zero<br />
> 3. Bandwidth is infinite<br />
> 4. The network is secure<br />
> 5. Topology doesn't change<br />
> 6. There is one administrator<br />
> 7. Transport cost is zero<br />
> 8. The network is homogeneous


Anyway, below are some (random and orderless) notes from [@yaamehn](https://twitter.com/yaamehn)'s fascinating talk.




## Services

Things talking to other things. Lots of concerns such as transports, formats, serialisation, discovery and so on.

- Seriously. Just use HTTP.
- Never go full REST. The maturity model. Hypermedia can be cool, and is interesting from an academic stand point, but has no place in the real world.
- Have a standard data format. JSON API. XSD. Pick a couple.
- Specification and portal. [Swagger](http://swagger.io/). [API Blueprint](https://apiblueprint.org/). [RAML](http://raml.org/). Things like documentation and client libraries should be generated from the spec. Keeping things [DRY](http://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

> RESTful API Modeling Language (RAML) is a simple and succinct way of describing practically-RESTful APIs. It encourages reuse, enables discovery and pattern-sharing, and aims for merit-based emergence of best practices. 



### Service discovery

Use [Consul](https://www.consul.io/), [Registrator](https://github.com/gliderlabs/registrator) and DNS.

1. Discover.
2. Register. Registrator runs on all Docker hosts. When Docker container start or stop, automatically will detect and publish/unpublish services.
3. Lookup (DNS).
4. Call.

Host lookups. Given a name, give me an IP.

Service lookups. Goes deeper. Ports etc.


### Client Libraries

On the cient side theres lots of plumbing to take care of:

- Retries.
- Flow control. Backoff.
- Circuit breakers.
- Versioning and [Postel's Law](http://en.wikipedia.org/wiki/Robustness_principle).
- Serialisation and deserialisation.
- Understanding documentation (hopefully without misinterpretation).

Implementation options:

- Ideally automatically code generate and publish a jar, a gem, a whatever module depending on technology stacks you are supporting.
- Go with a framework, like [Finagle](https://twitter.github.io/finagle/) to take this burden on.
- Standardise a way of creating client libs for each service that takes care of the above problems.

> Finagle is an extensible RPC system for the JVM, used to construct high-concurrency servers. Finagle implements uniform client and server APIs for several protocols, and is designed for high performance and concurrency.


## Events

Events are the "jewel" of Microservices. It's common place to focus most attention on "services", one can easily get caught up thinking in terms of a synchronous nest of request/response conversations taking place. This is a disaster waiting to happen. Events need to be treated as a first class citizen.


### Event Structures

What data goes into an event. More specifically, what is the structure and metadata that makes up an event. Give this careful consideration, as depending on the problem you're solving, can provide flexibility you may not be aware of today, providing flexibility for tomorrow.

Three common approaches:

- **Snapshot**. The entity (e.g. customer), at a point in time.
- **Callback**. The fact something interesting just happened (e.g. customer updated), with a reference URI to callback on.
- **Delta**. Both before and after versions of the entity, including differences.





### Kafka

> Apache Kafka is publish-subscribe messaging rethought as a distributed commit log.

[Kafka](http://kafka.apache.org/) is distibuted, scalable, durable and fast messaging on steroids. [LinkedIn](http://data.linkedin.com/opensource/kafka) open sourced Kafka, and its totally amazing.

Kafka is a convenient place to centralise logs. Absolutely everything. Kafka will not only easily handle it, downstream consumers can subscribe to logs/messages of interest, catering for both real-time and batch based consumers.





## Docker

Docker is a no brainer. Just use it. Materialise isolated, predicable environments fast. Minimise dev/prod parity.


### TemplatingContainer specific configuration with templating

There are lots of ways to tackle container configuration. A simple, ubiquatous and effective method is to use environment variables. Yes environment variables. Consistent with [The Twelve-Factor App](http://12factor.net/config) way of thinking...supported absolutely everywhere, they just work.

> Env vars are easy to change between deploys without changing any code; unlike config files, there is little chance of them being checked into the code repo accidentally; and unlike custom config files, or other config mechanisms such as Java System Properties, they are a language and OS agnostic standard.

The code running in a container may have various configuration files. Example, a `*.properties` file part of some Java software. Use environment variables to provide specific container state. On startup the container should template all configuration based on environment, followed by starting the service.


#### Templating Technology

Who cares really. The point is keep it simple.

- bash with sed.
- Node.js with Jade.
- [Mustache.java](https://github.com/spullara/mustache.java) with Java.
- Scala with Scalate.



#### Dynamic Configuration

For configuration that is less static in nature, and dynamic reloads are appropriate.

Use [consul-template](https://github.com/hashicorp/consul-template) to watch/poll [Consul](https://www.consul.io/)'s key/value store for configuration changes. Trigger the reload of files and services when changes detected.

> The daemon `consul-template` queries a Consul instance and updates any number of specified templates on the filesystem.


### Docker Orchestration

Managing lots of Docker containers becomes a problem in itself. Docker orchestration systems are built to address that problem.

Take a container. Express the desired management characterists of this container, such as number of instances, the target specfication of machines on which it should run, what to do in the event of failure (e.g. alert someone, attempt to restart X times), what other containers in-turn this container depends on, or is it stateless.

Some example implementation options (note this is an exploding field right now, expect lots of change, standardisation and consistency improvements over the next year):

- [Apache Mesos](http://mesos.apache.org/)
- [Marathon](https://github.com/mesosphere/marathon)
- [Chronos](https://github.com/mesos/chronos)
- [Google Kubernetes](https://github. com/GoogleCloudPlatform/kubernetes)
- [Centurion](https://github.com/newrelic/centurion)
- [Spotify Helios](https://github.com/spotify/helios)
- [Clocker](https://github.com/brooklyncentral/clocker)
- [Flocker](https://github.com/ClusterHQ/flocker)



## Centralise Logs

A no brainer. In an ecosystem of interconnected containers and Microservices. A potential ops nightmare.

Log File `=>` [Logstash](http://logstash.net/) `=>` [Elasticsearch](https://www.elastic.co/products/elasticsearch) `=>` [Kibana](https://www.elastic.co/products/kibana)


### Distributed Tracing

While the above solution is great, it doesn't assist us in understanding the hierachy of calls/logs, that is, when services in-turn consume other services. A layman's approach might be to go down the synthetic correlational identifier path...unfortunatly this just ends up flattening out the hierachy. It's actually an interesting dilemma. Luckily some clever Google and Twitter engineers have done some thinking for us: Googles [Dapper](http://research.google.com/pubs/pub36356.html) and Twitters [Zipkin](https://github.com/twitter/zipkin) are both good places to start.


## Monitoring

`/stats` `=>` `collectd` `=>` Circonus

All Microservices expose a `/stats` endpoint, that returns a standardised JSON structure with health statistics. Periodicly `collectd` scoops up all `/stats` endpoints, enriches this health data with more host related data from the Docker daemon, and pushes this bundle of health data to a monitoring service (e.g. Circonus).

Tip: use environment variables such as `STATS_ENABLED`, `STATS_PORT` and `STATS_URI` to signal the monitoring capabilities of a container to the outside world. Allowing for introspection on a container by container basis.

