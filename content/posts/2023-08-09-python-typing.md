---
layout: post
draft: false
title: "Python Type Annotations"
slug: "pythontypes"
date: "2023-08-09 20:44:33+11:00"
lastmod: "2023-08-09 20:44:33+11:00"
comments: false
categories:
  - python
tags:
  - python
  - dev
  - code
---

Start with the [docs](https://docs.python.org/3/library/typing.html) and the [Type hints cheat sheet](https://mypy.readthedocs.io/en/stable/cheat_sheet_py3.html)

Topics for consideration:

- syntax shorthands e.g. `|` for Union or Optional
- Self
- If you are using the typing library then there is an abstract type class provided for asynchronous context managers AsyncContextManager[T], where T is the type of the object which will be bound by the as clause of the async with statement.
- mypy

If you are using typing then there is an abstract class `Awaitable` which is generic, so that `Awaitable[R]` for some type R means _anything which is awaitable, and when used in an await statement will return something of type R_.
