---
layout: post
title: "BizTalk 2006 Install Problems on Windows XP"
date: "2008-12-21 13:09:38"
comments: false
categories: "BizTalk"
---

Today while doing some vanilla BizTalk 2006 R2 installs, discovered the installer was choking with:

Error 5003.Regsvcs failed for assembly C:\Program Files\Microsoft BizTalk Server 2006\Microsoft.BizTalk.Deployment.dll.
Return code 1.

![regsvcs error](/images/regsvcs.jpg)

Awesome. Other cases of a malfunctioning regsvcs executable have been [reported](http://www.webservertalk.com/message1430831.html). For reasons that remain unknown to me `regsvcs.exe` stop functioning following the installation of SP1 for VS.NET 2005 and the .NET 2.0. `regsvscs.exe` appeared to be intact, but invoking any of it functionality (including listing its command line help) would return nothing—hence the return code 1 problem.

Solution: Repair the .NET Framework 2.0 binaries. I grabbed a fresh copy of the service pack. It is important that `egsvcs.exe` functions correctly—you can test it while reinstalling the service pack by running `regsvcs.exe /?`. If it lists out help you're good to go.

