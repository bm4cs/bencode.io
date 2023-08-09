---
layout: post
draft: true
title: "Async Python"
slug: "pythonasync"
date: "2023-08-09 21:12:33+11:00"
lastmod: "2023-08-09 21:12:33+11:00"
comments: false
categories:
  - python
tags:
  - python
  - dev
  - code
---

## Background

Using `asyncio` will not make your code multi-threaded. That is, it will not cause multiple Python instructions to be executed at the same time, and it will not in any way allow you to side step the so-called “global interpreter lock” (GIL).

Some processes are CPU-bound: they consist of a series of instructions which need to be executed one after another until the result has been computed. Most of their time is spent making heavy use of the processor.

Other processes, however, are IO-bound: they spend a lot of time sending and receiving data from external devices or processes, and hence often need to start an operation and then wait for it to complete before carrying on. Whilst waiting they aren’t doing very much.

`asyncio` allows you to structure your code so that when one piece of linear single-threaded code (coroutine) is waiting for something to happen another can take over and leverage the CPU.

> It’s not about using multiple cores, it’s about using a single core more efficiently


## Awaitables

An object is *awaitable* if it can be used in an `await` expression. Many asyncio APIs are designed to accept awaitables, of which there are three main types: coroutines, Tasks and Futures.



<https://docs.python.org/3/library/asyncio-task.html>


<https://bbc.github.io/cloudfit-public-docs/asyncio/asyncio-part-1>
