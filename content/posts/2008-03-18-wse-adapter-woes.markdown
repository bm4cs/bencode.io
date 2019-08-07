---
layout: post
title: "WSE Adapter Woes"
date: "2008-03-18 23:38:11"
comments: false
categories: BizTalk
---


Every now and then I come across a solution that employs the BizTalk Web Service Enhancement (WSE) 2.0 adapter suite—a legacy technique for getting BizTalk to consume/expose web services.

The WSE adapter pack includes the foundation runtime binaries and a cool schema generation wizard that neatly plugs into Visual Studio—the "Add Generated Items" option available in solution explorer will get options for doing WSE schema generation.

Recently I had to maintain a legacy (2004) solution—among other activities this involved defining a number of new logical ports in an existing orchestration. After a typical BizTalk build-deploy-test cycle I soon discovered that the WSE adapter was not happy...

> Failed to transmit message. <br />
> Exception: System.ArgumentNullException: Value cannot be null.<br />
> Parameter name: methodname

After digging through the light but sufficient documentation that ships with the WSE adapter, found that the adapter infers the web method to invoke using the operation name that is specified on the logical port to which it is bound. For some reason this was not working—some environments it would work and others it would not.

I hope to revisit this problem to properly get to the bottom of it, but my temporary work-around with the intension of moving forward was to explicitly define the SoapAction context property on the message from the calling orchestration/s—which in effect instructs the WSE adapter of the web method that is to be invoked. For more information refer to the documentation that ships with the WSE adapter, around configuring dynamic send ports (even if your not actually interested in using dynamic send ports).

    requestMessage(WSE.SoapAction) = "http://bencode.net/OperationName";
