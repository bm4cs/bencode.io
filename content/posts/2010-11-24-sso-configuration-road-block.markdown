---
layout: post
title: "SSO Configuration Road Block"
date: "2010-11-24 12:58:25"
comments: false
categories: "BizTalk"
---

Recently I’ve had the need to setup a BizTalk Server 2006 R2 virtual machine. Quietly confident about my experience with this version of BizTalk, I jumped in head first to *quickly* get a simple single server based installation configured on a 32-bit VMWare based VM.

Lesson learned today; never, ever underestimate the obscure errors that BizTalk Server can produce. The install was smooth sailing. But when the time came to configure SSO, this happended:

> Failed to generate and backup the master secret to file: C:\Program Files\Common Files\Enterprise Single Sign-On\SSO07AB.bak (SSO) Additional Information (0x80070005) Access is Denied.

I wracked my brain for a previous solution to this, but never have I seen this. There is [speculation](http://blogical.se/blogs/mikael_sand/archive/2009/10/01/failed-to-create-the-master-secret-file-why-do-these-things-always-happen-to-me.aspx) this may be a very rare bug that arises only in the context of doing single server VM based configurations. Regardless of the cause, it is not helpful.

Thank you to [Mikael Sand](http://blogical.se/blogs/mikael_sand/archive/2009/10/01/failed-to-create-the-master-secret-file-why-do-these-things-always-happen-to-me.aspx), for detailing the solution to this. Un-configure and manually blast away any features and/or databases the configuration tool may have created. Create the two groups *SSO Administrators* and *SSO Affiliate Administrators* (alternatively name them whatever you like) manually. Add the account you are running the configuration tool under, and the BizTalk service account to these newly created groups. Log off. Re-run the configuration tool.

What a curve ball!
