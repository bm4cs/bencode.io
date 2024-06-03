---
layout: post
title: "Mapper Bug"
date: "2008-02-04 22:36:01"
comments: false
categories:
- biztalk
---

In the process of maintaining some existing maps, I interestingly came across the following error message, whenever I attempted to build the associated schemas project.

> Node `node name` - Specify a valid .NET type name for this root node. The current .NET type name of this root node is a duplicate.

When I opened the offending schema (which contained a number of imports) using the BizTalk mapper in VS.NET, the schema did indeed appear to contain repeating (or duplicate) nodes. After digging a little deeper by manually studying the schemas using a simple text editor [notepad2](http://www.notepad2.com), in-fact discovered that the schema definitions were sound. The mapper was misbehaving. After a quick google, soon located the official knowledge base article [KB922431](http://support.microsoft.com/?kbid=922431), including a hotfix and analysis of the problem. To get the hotfix a request must be submitted to Microsoft Online Customer Services.

More details about the problem and the resolution can be found [here](http://support.microsoft.com/?kbid=922431).
