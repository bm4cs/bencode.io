---
layout: post
title: "Azure Essentials List"
date: "2012-02-26 08:00:00"
comments: false
categories: "Azure"
---

A living post of the tools, frameworks and guidance that have made life with Azure better.

So we've had a big couple of months at Mexia working with Microsoft and the Azure Service Bus. Just in this small timespan, the platform has been evolving rapidly; a new version of the SDK (1.6) was dropped, offical documentation has undergone complete rewrites, the service bus pricing model was overhauled (for the better)... As a developer working with Azure, it is also very volitile grounds. The (ever growing) Azure community is doing an amazing job filing the many gaps that exist in the overall development experience, as the technology matures.

Here I wanted to start the dumping out of various resources that have been useful through real world experiences developing for Windows Azure and particularly the Azure Service Bus.

## Frameworks/Libraries
-   [The Transient Fault Handling Application Block](http://windowsazurecat.com/2011/02/transient-fault-handling-framework/) Because when anything that can fail, will fail.
-   [SbAzTool](http://code.msdn.microsoft.com/windowsazure/Authorization-SBAzTool-6fd76d93) Neat ACS library that is aware of the Service Bus specific roles/claims. Handy for the programmatic provisioning of service identities, relying parties, and rule groups.
-   [protobuf](http://code.google.com/p/protobuf-net/) Protocol buffers is the name of the binary serialization format used by Google for much of their data communications. When performance really matters, you need to be smart about how data moves across the wire. Think XML, but smaller, faster, and simpler.
-   [WCF Behaviors to support Service Bus Brokered Messaging](http://code.msdn.microsoft.com/How-to-integrate-a-BizTalk-1079811b) If you want to use the NetMessaging binding, and brokered messaging with the Service Bus, get these now.

## Documentation
-   [Creating Custom Performance Counters for Windows Azure Applications with PowerShell](http://msdn.microsoft.com/en-us/library/windowsazure/hh508994.aspx)
-   [Windows Azure Service Bus REST API Reference](http://msdn.microsoft.com/en-us/library/windowsazure/hh780717.aspx)
-   [ACS Error Codes](http://msdn.microsoft.com/en-us/library/windowsazure/gg185949.aspx)
-   [Azure AppFabric Data Centre IP's](Additional Data Centers for Windows Azure AppFabric)
-   [Windows Azure Service Dashboard](http://www.windowsazure.com/en-us/support/service-dashboard/)
-   [How to Integrate a BizTalk Server Application with Service Bus Queues and Topics](http://msdn.microsoft.com/en-us/library/windowsazure/hh542796(v=vs.103).aspx)

## Deployment
-   [Azure Powershell Cmdlets](http://wappowershell.codeplex.com/)
-   [Azure Service Bus Powershell Provider](http://msdn.microsoft.com/en-us/library/windowsazure/ee706741.aspx)
-   [SQLAzure Migration Wizard](http://sqlazuremw.codeplex.com/) The SQL Azure Migration Wizard (SQLAzureMW) analyzes schema, generates scripts, and migrates data via BCP. Slick! 
-   [TeamCity](http://www.jetbrains.com/teamcity/)

## Networking
-   [Fiddler2](http://fiddler2.com/fiddler2/) Azure can get cryptic if misused. Without HTTP/s tracing you are going in blind.
-   [TcpTrace](http://www.pocketsoap.com/tcpTrace/) Simple effective HTTP tunnel.
-   [Wfetch](http://www.microsoft.com/download/en/details.aspx?displaylang=en&id=21625) Powerful HTTP/s message generator. Support many security protocols (e.g. NTLM) that similar tools often overlook.


## Diagnostics/Monitoring
-   [Cerebrata Diagnostics Manager](http://www.cerebrata.com/products/AzureDiagnosticsManager/) Azure VM performance counters (including aggregations), trace logs, event logs - get this tool immediately! Amazing.
-   [Service Bus Explorer](http://code.msdn.microsoft.com/windowsazure/Service-Bus-Explorer-f2abca5a) The Azure CAT teams contribution to making life with the Serice Bus better. Complete management of topics/subscriptions/filters, complete with test harness.
-   [Greybox](http://greybox.codeplex.com/) What VM instances are running in my subscription again? Handy task bar toast notifier thats got your back.
