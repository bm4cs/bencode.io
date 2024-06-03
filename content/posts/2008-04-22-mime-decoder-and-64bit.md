---
layout: post
title: "MIME Decoder and 64bit"
date: "2008-04-22 22:48:22"
comments: false
categories:
- biztalk
---

This week I got a great introduction to the subtle difficulties that are waiting to be encountered when running a 32-bit component in a 64-bit environment. In short, an orchestration that employed the standard (ships with BizTalk) MIME Decoder pipeline component was consistently failing with the following:

> The invocation of a pipeline component continued to raise the following exception.<br />
> The pipeline "Net.Bencode.Pipeline.Decoder" could not be created for execution. Error Details: "Retrieving the COM class factory for component with CLSID {254B4004-2AA7-4C82-BB2E-18BA7F22DCD2} failed due to the following error: 80040154."

WTF. After much digging around and troubleshooting, found the problem related to a partcular BizTalk (MIME Decoder) component that only supports a 32-bit execution mode. When executing in a native 64-bit execution environment (e.g. Windows Server 2003 R2 x64) serious instability issues arose (the component would just fail with leaving extremely misleading/confusing diagnostics behind). BizTalk is capable of providing an emulated 32-bit execution mode by using WOW64.

The solution to this problem was to run the orchestration (which uses the MIME Decoder component through a custom pipeline) under a 32-bit host instance. The original problem ("Retrieving the COM class factory for component with CLSID") can be easily reproduced by switching off the 32-bit emulation mode.

Apparently this applies to a small handful of components (and adapters) in BizTalk. As stated on [TechNet](http://technet.microsoft.com/en-us/library/aa560166.aspx):

> "Running the WSE adapter, FTP adapter, SQL adapter, POP3 adapter, and MIME Decoder on 64-bit host instances is not supported"

