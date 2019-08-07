---
layout: post
title: "Web Service Proxies"
date: "2008-02-04 23:31:36"
comments: false
categories:
- biztalk
---

Publishing BizTalk orchestrations (or schemas) as Web Services is a wonderful thing. A neat little code generator known as the [BizTalk Web Service Publishing Wizard](http://technet.microsoft.com/en-us/library/aa578703.aspx) accompanies the standard suite of BizTalk development tools, and basically plumbs up a classic (asmx) web service that inherits parts of the BizTalk object model. The web service must be hosted-and-execute on a BizTalk Server that holds the "exposed" orchestration. It then becomes a simple affair of defining a SOAP Receive Location that binds to the generated web service.

In my experience its something that gets done fairly frequently—exposing business process over web services. Until we ramp up in R2, asmx web service end-points will remain.

So thinking of it as business-as-usual (BAU) I went about exposing a newly crafted orchestration using the standard web service publishing wizard. After deploying it, configuring IIS and defining the new receive location, I was keen to take it for a test drive. I didnt get far...

> Internal SOAP Processing Failure at Microsoft.BizTalk.WebServices.ServerProxy.Invoke

The web method implementations for the generated web-service proxy are coupled (hardcoded) to a specific orchestration and receive port. Its not purely a "traditional" web-service in the sense that it inherits from pieces of the BizTalk object model—the key line of code that is called in each web method is the inherited **Invoke** routine. This line interacts with BizTalk by feeding it a number of arguments (orchestration name, port name, in-bound message content, etc) using a programmatic object model.

My exception message above in that case would seem to be rather generic—my guess was that basic connectivity to the BizTalk Server from the ASP.NET web-service could not be achieved. After a bit (hours) of snooping around my problem soon became very (embarrassingly) obvious. The IIS application pool identity under which the web-service was running had insufficient permission to interact with BizTalk (the management database, etc). All I needed to do was to configure a dedicated IIS application pool running under a domain (service) account identity that has sufficient permission to connect to BizTalk and its underlying management databases.
