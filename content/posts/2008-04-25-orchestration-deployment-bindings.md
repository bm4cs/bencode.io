---
layout: post
title: "Orchestration Deployment Error 26"
date: "2008-04-25 21:47:41"
comments: false
categories:
- biztalk
---

There seems to be an intermittent deployment problem with BizTalk 2006, that has been the cause of much time wasting. When attempting to deploy BizTalk artefacts either explicitly using the BizTalk Administration Console or the Visual Studio deploy functionality results in the following:

> Error 26 Failed to add resource(s). Change requests failed for some resources.<br />
> BizTalkAssemblyResourceManager failed to complete end type change request. Failed to update binding information. Could not enlist orchestration 'Net.Bencode.Orchestration,Orchestration, Version=1.0.0.0, Culture=neutral'. Could not enlist orchestration 'Orchestration.TestProcess'. All orchestration ports must be bound and the host must be set.

Most unusual. Binding validation issues at deployment time. Thanks to [James French](http://geekswithblogs.net/nsthompson/archive/2006/10/12/BindingFailureBlocksOrchestrationDeployment.aspx#352872) soon discovered that the issue is related to the bindings cache that BizTalk maintains. In short, BizTalk creates using assembly reflection, and maintains using the `BizTalkMgmt` database `BindingInfo.xml` files in the `C:\Documents and Settings\User\Application Data\Microsoft\BizTalk Server\Deployment\BindingFiles` directory. Destroying these temporary BindingInfo files forces fresh binding files to be generated and solves the above error.

