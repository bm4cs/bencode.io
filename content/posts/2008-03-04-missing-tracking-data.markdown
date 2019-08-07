---
layout: post
title: "Missing Tracking Data?"
date: "2008-03-04 22:38:59"
comments: false
categories:
- biztalk
---

BizTalk's tracking capabilities are a wonderful diagnostic feature when in thick of core BizTalk development work, or when a curly situation raises its head in a production environment. Typically when involved with BizTalk development it is not uncommon to find yourself integrating with COTS (Commercial Off The Shelf) products. Participating systems can (and do) deviate from the agreed contracts, sometimes in ways never foreseen. Doing integration between business units and their systems is a political hotspot when things go wrong; being able to identify the cause of an integration problem quickly is crucial. BizTalk tracking can be easily switched on and off at runtime, at both the port and orchestration level. The actual information (message bodies and/or context properties) and the granularity (pre and/or post processing) of tracking can be easily controlled using the administration console.

In my current development environment tracking never worked as expected. 99% of the time I could never extract message bodies using the HAT (Health and Activity Tracking) tool. Although frustrated, I never spent the time to investigate why this was until recently. After a bit of digging around, soon discovered that tracking data is actually shipped out of the message box at (by default) one minute intervals by the SQL Server Agent job `TrackedMessages_Copy_BizTalkMsgBoxDb`. When I attempted to manually invoke the job I quickly found that the job failed to execute due to a lack of sysadmin privilege to the SQL Server.

The SQL Server Agent windows service had been setup to run under a low privileged domain account which in-fact had no (let alone sysadmin) privileges to the SQL Server. After reconfiguring the account under which the windows service ran under I was in-luck. The job was now happily shipping message tracking data into the `BizTalkDTADb` database.

Now message tracking was 100% reliable and I felt invincible—having the knowledge that I could now reliably capture the complete message bodies and context properties of incoming and outgoing messaging is very comforting.

So if your having problem with tracking and everything looks to be enabled, make sure you check out the `TrackedMessages_Copy_BizTalkMsgBoxDb` SQL Server Agent job.
