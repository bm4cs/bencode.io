---
layout: post
title: "Reserved words and Distinguished Fields"
date: "2008-02-13 23:01:56"
comments: false
categories:
- biztalk
---

The other day I built a schema that was the cause of much confusion and time wasting. Basically the tiny schema was being used by a centralised error handling process, that was designed to subscribe to and publish errors. The schema had a number of child elements, two of which were named "message" and "source". Each field in the schema was distinguished (not promoted) to allow participating orchestrations to examine and/or manipulate the error message instances.

So thinking it be business as usual (BAU) I went about assigning the distinguished message fields using various expression and assignment orchestration shapes. To my frustration the VS.NET XLANG editor (the one you get when editing an expression or assignment) kept red-squiggly underlining the "message" and "source" distinguished fields whenever I attempted to reference them (as below), with the unhelpful error message of:

> Unexpected keyword: message, cannot find symbol

`myMessage.myRoot.message` or `myMessage.myRoot.source`

It turns out that I was unlucky, `message` and `system` are reserved words in the XLANG grammar. Be careful of [XLANG reserved words](http://msdn2.microsoft.com/en-us/library/aa547020.aspx) when distinguishing message fields.
