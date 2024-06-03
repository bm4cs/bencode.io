---
layout: post
title: ".NET 4.0 GAC Post-build Event Command"
date: "2011-07-09 07:00:00"
comments: false
categories:
- dev
tags:
- csharp
---

For [various design reasons](http://stackoverflow.com/questions/2660355/net-4-0-has-a-new-gac-why) .NET 4.0 has it's own GAC, located here.

    %systemroot%\Windows\Microsoft.NET\assembly

An updated version 4.0 of gacutil is available as a part of the Windows SDK. Here is a handy VS.NET "Post-build event command", that will .NET 4.0 GAC your freshly baked assemblies.

    "%programfiles(x86)%\Microsoft SDKs\Windows\v7.0A\Bin\NETFX 4.0 Tools\gacutil.exe" /i "$(TargetPath)"
