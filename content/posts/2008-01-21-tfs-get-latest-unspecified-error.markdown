---
layout: post
title: "TFS Get Latest = Unspecified Error"
date: "2008-01-21 21:17:21"
comments: false
categories: BizTalk
---

Last week, I needed branch a BizTalk codebase off so some enhancement work could take place. After re-jigging a dozen or so projects, was quiet proud of the new (and in my opinion) more logical solution structure. OK, first test... shut-down VS.NET, re-open it and do a get-latest. I get the following:


![TFS get latest error message](/images/tfs_getlatest_error.png)

Soon after I discovered this <a href="http://vaultofthoughts.net/VisualSourceSafeUnexpectedError.aspx" target="_blank">post</a> by Michal Talaga. He suggests that a corruption to the VS.NET SUO (Solution User Options) file is responsible, and that simply deleting it and having VS.NET recreate it remedies the problem. While skeptical at first, was pleasantly surprised to find that it fixed the problem.

