---
layout: post
title: "Smashing the Stack Walk-throughs"
date: "2019-07-04 8:40:10"
comments: false
categories:
- cybersec
tags:
- hacking
---

Here I plan to take a closer look at vulnerabilties around the use of the x86 stack, by causing a *buffer overflow*. The stack is only one type of attack in a pool of many others such as heap allocators, race conditions, root exploits, ELF, networking, viruses, etc.


# Why a stack?

The most elegant and clearly written resource for understanding the stack and its weaknesses is the seminal paper by Aleph One called [Smashing The Stack For Fun And Profit](https://www.win.tue.nl/~aeb/linux/hh/phrack/P49-14), PDF version [here](/blob/stack_smashing.pdf).

The stack exists to provide hardware level support for procedures (or functions), one of the most important concepts introduced by high-level languages such as C. A procedure call alters the control flow, like a jump does, but unlike a jump, when finished, a procedure returns control to the instruction following the call.

The stack is also used to dynamically allocate local variables used in functions, to pass parameters to functions, and to return values from the function.


# How the stack works

A stack is a contiguous block of memory. A register called the *stack pointer* (SP) points to the top of the stack.


and the *base pointer* (BP) to the buffer of contiguous memory. A *stack frame* is piece of the stack from the *base pointer* (BP) onwards. Stack frames are an important concept when it comes to calling a sub-routine, which in turn needs it own piece of stack for its variables and arguments.

Static variables are allocated by the object file loader (e.g. ELF or PE) into the data segment. Dynamic variables are allocated at runtime on the stack.

    /------------------\  lower
    |                  |  memory
    |       Text       |  addresses
    |                  |
    |------------------|
    |   (Initialized)  |
    |        Data      |
    |  (Uninitialized) |
    |------------------|
    |                  |
    |       Stack      |  higher
    |                  |  memory
    \------------------/  addresses

The `RET` instruction pops the last value off the stack, which supposed to be the returning address, and assign it to the `IP` register 



