---
layout: post
title: "IntelliJ Bad Font Rendering on Linux"
date: "2015-12-05 16:12:00"
comments: false
categories:
- dev
tags:
- java
---

Font rendering in IntelliJ on Linux looks horrid. Any Java based application does for that matter. I can't take it anymore. I just burnt 30 minutes looking into solutions. Fastest option, run it on the Linux optimised JVM [tuxjdk](https://code.google.com/p/tuxjdk/).

> tuxjdk is a series of patched to OpenJDK to enhance user experience with Java-based and Swing-based tools (NetBeans, Idea, Android Studio, etc)

Instructions (for me) next time this happens:

1. Download [tuxjdk](https://code.google.com/p/tuxjdk/) and unpack it in `/usr/lib/jvm`, e.g. `/usr/lib/jvm/jdk-8u25-tuxjdk-b01`
2. Run IntelliJ like this; `export IDEA_JDK=/usr/lib/jvm/jdk-8u25-tuxjdk-b01/ & ./idea.sh`

![IntelliJ running on Fedora 22 and tuxjdk](/images/intellij.png)

