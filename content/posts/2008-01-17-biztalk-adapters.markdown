---
layout: post
title: "BizTalk Adapters"
date: "2008-01-17 23:24:53"
comments: false
categories: BizTalk
---

This is an unusual one. Today I was faced by a general question from management on the kind of technology we are capable of integrating with. We use (and love) BizTalk. My initial thoughts were "BizTalk can integrate with anything"... failing that a built-in adapter could do the job, one could then look to purchasing a third-party adapter or even look at rolling one in-house. Adapters plumb data to and/or from a variety of different mediums—that more or less fall into one of four categories: line-of business system (eg. SAP, Business Application XYZ), middleware (eg. TIBCO) , transport (eg. WCF, file system) or database (eg. SQL Server, Oracle).

In my experience, I have never really had to deviate far from the "bread-and-butter" adapters (FILE, SOAP, WSE 2.0, SMTP, etc), so I found it rather enlightening to actually have a look at what's available out-of the box, what (some) third-party vendors are doing in the adapter space, and what options exist for hand-rolling.

 <a href="http://www.microsoft.com/biztalk/evaluation/adapter/default.mspx" target="_blank">Adapters included with BizTalk Server 2006 and BizTalk Server 2006 R2</a>

 <a href="http://www.microsoft.com/biztalk/evaluation/adapter/partner/2004.mspx" target="_blank">BizTalk Partner Adapters 2004 (Third-Party Vendors)</a>

 <a href="http://www.microsoft.com/biztalk/technologies/wcflobadaptersdk.mspx" target="_blank">WCF LOB Adapter SDK</a>: Running on R2? WCF provides an insanely powerful platform for building adapters on.

 <a href="http://www.codeplex.com/BizTalkAdapterWizard" target="_blank">BizTalk Adapter Wizard</a>: Another codeplex wizard for BizTalk to help create your own adapter.
