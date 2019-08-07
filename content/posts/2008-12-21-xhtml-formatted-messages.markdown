---
layout: post
title: "BizTalk XHTML Formatted Messages"
date: "2008-12-21 16:37:36"
comments: false
categories: "BizTalk"
---

BizTalk messages are very XML centric. A while ago there was a requirement to produce a neatly formatted XHTML report, which was destined to be emailed.

At the time I stumbled across a customised version of the [XslTransform pipeline component](http://msdn.microsoft.com/en-us/library/aa561389.aspx) which ships with the BizTalk SDK. It demonstrates how to apply an XSLT transformation in the pipeline. The customised version I was playing around with, pulled up XSLT from a SQL data store.
Regardless of where or how the transformation be done, we needed to produce an XHTML document as a result. The thing with XHTML is that is it just that. Its XML. A XSD schema can be produced from a well formed piece of XHTML. Therefore it is possible to create a strong message type (e.g. FooReport.xsd) which can then be pub/sub'ed with BizTalk.

High level steps:

- Generate the document schema using `xsd.exe`.
- Write the necessary transformation using BizTalk mapper, using the above as the destination schema.
- Depending on the client which will be picking up and rendering the XHTML (e.g. outlook, firefox) it is usually necessary to set the MIME type, so it knows to treat the content as a piece of XHTML. To do this from BizTalk set the ContentType context property: `errorReport(Microsoft.XLANGs.BaseTypes.ContentType) = "text/html";`


