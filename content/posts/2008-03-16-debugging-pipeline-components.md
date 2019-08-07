---
layout: post
title: "Debugging Pipeline Components"
date: "2008-03-16 11:05:41"
comments: false
categories: "BizTalk"
---

Of late I have been spending most of my free time (which isnt a great deal) with pipeline components. BizTalk pipelining is very intriguing and potentially a powerful tool in any BizTalk developers toolkit.

Pipeline component development like most BizTalk related development, seems to involve allot of boilerplate code. Others have tried to counter this with VS.NET wizards (eg. pipeline component wizard, adapter wizard, etc). For some reason I just dont like these...they are a little heavy for my needs.

The BizTalk SDK (to my surprise) includes several useful [pipeline samples](http://msdn2.microsoft.com/en-us/library/aa578544.aspx), ranging from using the standard pipeline components that ship with BizTalk, to crafting custom stream classes that plug-in to the standard component model. I hope to create a small suite of component templates and streamers that I can keep handy for various scenarios.

When you actually start writing custom pipeline components the inefficiency of the BizTalk build-deploy-test cycle becomes unbearable. Gilles (back in 2004) posted about a very handy technique ([How to Debug a BizTalk 2004 Pipeline](http://blogs.msdn.com/gzunino/archive/2004/07/01/171281.aspx)) for interactively debugging pipeline components. It removes the need to perform BizTalk deployments in order to test your pipeline components.

The BizTalk SDK ships with a number of [managed executables](http://msdn2.microsoft.com/en-us/library/ms966489.aspx) specifically designed to exercise pipelines in the same way BizTalk Server would. By configuring a pipeline component C# class library to bind against a startup application of `pipeline.exe` and defining the test input message and  pipeline definition `.btp` arguments, it becomes a simple affair of hitting F5 to get interactive debugging. I couldn't believe what an effective time saver this simple technique was.
