---
layout: post
title: "Sequential Receives"
date: "2008-09-02 23:32:40"
comments: false
categories:
- biztalk
---

Today I came across an interesting compile time error, given a scenario I had never exercised before. I had a vanilla orchestration that was receiving the same message type (same schema different message instance) using two different receive ports. I wanted to correlate the orchestration, so the first receive shape was set to activate with an "Initialising Correlation Set" and the second receive shape was set with a "Following Correlation Set". This setup produced the following compile time error:

    C:\BizTalkApp\Flows\ProcessA.odx(221,13): error X2259: in a sequential convoy the ports must be identical
    C:\BizTalkApp\Flows\ProcessA.odx(215,22): could be 'TestPortA'
    C:\BizTalkApp\Flows\ProcessA.odx(221,13): or 'TestPortB'

Awesome. My convoy knowledge is not very deep, so I spent some time with a high quality MSDN article written by Stephen Thomas titled [BizTalk Server 2004 Convoy Deep Dive](http://msdn.microsoft.com/en-us/library/ms942189.aspx). This helped fill some gaps on the subtle's of doing sequential convoys.


There seem to be a couple of common options to this error:

- Don't define multiple receive ports. The one receive port can be connected to both correlating configured receive shapes. This wasn't an option in my scenario, as I needed to bind the logical ports to two different physical ports (e.g. HTTP and MSMQ).
- Don't intialise the correlation set using a receive shape—use a send shape instead. Thanks to Bruno Spinelli for [posting this](http://p2p.wrox.com/topic.asp?TOPIC_ID=49988) option up on the wrox forums.
