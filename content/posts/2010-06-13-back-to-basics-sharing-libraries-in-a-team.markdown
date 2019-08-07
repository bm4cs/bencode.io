---
layout: post
title: "Sharing Libraries in a Team"
date: "2010-06-13 01:01:20"
comments: false
categories: "BizTalk"
---

When developing in a team consisting of more members than yourself, you’ll quickly run into the scenario where shared libraries and/or other similar resources need to be shared in someway.

Its especially nice when you can cleanly compile code freshly pulled from source control. In my opinion, this is a must. Sloppiness here can cause heartache throughout the the entire development lifecycle of the project. This problem is aggravated with the introduction of new starters that come on board…they do a get latest, build and spend the next few days crawling through hundreds of build errors.

So what to do with all those third party assemblies that have made their way into the code base? If Alice added the references on her box, checks in, Bob is not going to be happy when he goes to do a “get latest”.

Its at this point most environments i’ve worked within take the laziest and simpliest option. “Hey everyone, we need to make that we all bind source control to the same local working folder (e.g. c:\projects\) mmmkay?”. If everyone has a local working folder of c:\projects, then absolute dll’s references should resolve just fine. While this is simple and can work, is rarely documented beyond the developers that came up with the plan.

What alternatives are there? Several, they all involve adding a layer of indirection, so the physical location of the assemblies is abstracted away from the project references. The simplest and effective strategy I have seen leverages <a href="http://en.wikipedia.org/wiki/Subst">subst</a> (or the more modern symbolic linking support now available in Vista and higher using mklink). The idea is in source control, maintain a hive of pre-built assemblies that are common across the team, for example:

    $/Foo.Common.Hive/NUnit.Framework/1.1.23.0/NUnit.Framework.dll     
    $/Foo.Common.Hive/bLogical.Shared.Functoids/1.0.0.0/bLogical.Shared.Functoids.dll      


Bind them to a physical location *anywhere* on your development/build box. Run the following command:

    subst q: c:\local\location\of\your\choice\

This will create a virtual drive (q:) on the machine that actually resolves to the contents of the `c:\local\location\of\your\choice\` directory. Visual Studio assembly reference's should be added through the virtual (q:) drive – hence adding a layer of abstraction. The only catch is all developers need to ensure that the virtual drive is subst’ed prior to building—however on the plus side, I can put the source where I like, and the chances of getting a clean build have been improved significantly.

