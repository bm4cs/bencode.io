---
layout: post
title: "Reverse Engineering Object Files"
date: "2019-02-25 08:44:10"
comments: false
categories: [dev]
tags: [infosec]
---



# Object Files


Checkout command to read magic, command `magic`


Relocations are also known as fixups.

Relocations enable the linker to tie up memory pointers to various dependencies, an object file might have.

Dynamic linking, loads shared object code into the address space of the consuming process. Global offset table (Linux) or import table (windows). `.so` in UNIX, or `.dll` in Windows.

ELF is a common object representation, that is represented as a running process in memory, when bootstrapped by the OS.

Typicaly load addresses of object code must start on the beginning of a page binary (4k).

TODO: put nifty diagram Silvio drew up here.

* Physical to virtual mapping done by the kernel.
* Relocations allow shuffling and nitting up dependencies can occur.
* Pages are memory can be reused (mapped) across multiple processes - e.g. sharing libc for example
* COW (copy of write)


ASLR 
Paging table
TLB (transition look aside buffer)


# ELF, PE and Java Class


ASLR (address space layout randomization)

## ELF

TODO: include layout diagram.

One simple way to obfuscate debuggers, is to strip section headers out of the object file (ELF).

Symbols can be ripped out using the `strip` command.

A program header is required for an executable. Interesting fact, ELF accounts for virtual and physical addresses, but in practice everything uses virtual.


## PE

Aimed to be backwards compatible with MS-DOS. `struct`'s are very verbose and descriptive e.g. `SizeOfUnitializedData`.

TODO: include layout diagram.

Section names are embedded in the PE section header (not a string table like ELF), and must be 8 characters long.

The header has a `DataDirectory` a chunk of further metadata, including things like dynamic linking information.


## Java Class

TODO: include layout diagram.

Through layers of headers, drill through to the *code attribute*, which provides details around the stack and variables.


Geometric checking, reporting for anomolies in binaries.






# Defcon CPU Auditing Video

MSR (model specific registers) 64-bit registers for tossing data not related to computation.

Which MSR's are implemented by the processor?

Brute force try to `rdmsr` ever MSR address from ECX. Found 1300 MSR's with this approach.

Used a timing side channel approach, by measuring `rdtmsp` measurements either side. Different microcode (ucode) implements the different MSR's. Observations:

* Functionally different MSRs will have different access times
* Found 43 unique MSRs out of the 1300, based on timing profile.


TODO: More info on x86 ring system



# Linking and Loading

`/proc/<pid>/map` will show memory mapped segments.

*BSS* is for uninitialised data, that may potentially be used in the future.

The *heap* lives in the data segment. The heap allocator must obtain the physical memory in page sized chunks, but can present virtual memory more granularly.

`mmap` on Linux, or `VirtualAlloc` on Windows to allocate heaps.

Heap that is readable, writable and executable is suspicious.

The volitility framework takes into accoun the `rwx` flags.

Interesting x86 registers:

* `esp` for the stack pointer
* `ebp` for the frame pointer


## Environment

In Linux, environment variables.
In Windows, PEB (Process Execution Block)?


## Dynamic LInking

GOT (Global Offset Table)





# Object Code and Instruction Set Architectures


Instruction representation.

Three address code:

    INSTRUCTION srcX, srcY, dest

Two address code:

    INSTRUCTION src, dst

The two industry heavy weight syntax's are the **AT&T** syntax versus **Intel** syntax.

The **Intel** syntax, is nicer to work with generally due to its handling of various addressing modes. Some Intel syntax traits:

* Destination always first
* `MOV EAX,[EDX+EBX*4+8]`


Page 13 in slides - most complex. Revisit.


## RISC vs CISC

Reduced vs Complex Instruction Sets.


Commonality across instruction sets:

* Data loading and movement.


### x86

Registers can be split from 32-bit to 16-bit to 8-bit, due to evolution of the architecture over time.






# Program Representation

To aid analysis of binaries and object files, we need to represent features in such a way to aid automatic analysis using machine learning techniques, indexing, querying and further analysis.

Some of the features of a binary, that are useful to represent include.

* *Strings* - deals with string handling, which is common in anti-virus (signatures). This includes byte level and human readable strings. Most algorithms are *O(n.m)* where n and m are the lengths of strings. It may be useful to consider *ngram* features, to gain alternative intelligence.
* *Graphs* - a graph invariant. Useful graphs to represent could be the call graph, control flow graph, dependency graphs
* *Bytes* - can consider the binary as one large string.
* *Instructions* - could use opcodes as a feature vector.
* *Blocks* - an efficient hash known as the small primes product.
* *API calls* represents library calls in a program, such as use of the Windows API or `libc`





# Dynamic Analysis

Involves running a malicious program, and observing it in a controlled environment. Dynamic analysis overcomes some of the shortcomings of static analysis such as anti-disassembly tricks, pointers, and dynamically generated code.


Sandboxing options:

* *Debuggers* come in both software and hardware variants. Software breakpoints in x86 leverages the interupt 3 (`int3` or `0xCC`) instruction, the debugger holts on the interupt, and swaps in the original instruction after the breakpoint is released.
* *TF* or trap flag single step execution, after the execution of every instruction is another option.
* Hooking API calls - 
* *Whole system emulation* using an emulator like QEMU or Bochs. Emulators have access to every instruction that is executed, and can be used to unpack encrypted malware.

Cuckoo Sandbox, runs an application on host

Introspection:

Once sandboxed, the action of the process needs monitoring.






# Binary Analysis

Disassembly is concerned with converting the object code back into assembly.

Tools like IDA Pro. Interestingly the NSA are open sourcing their *GHIDRA* disassembler next week (at RSA conf in March 2019).

TODO: ROP chains.

Disassembly algorithms:

* Linear sweep
* Recursive decent
* Speculative
* Procedure based
* 

TODO: Chechout IDA pro blog post *a simplex method*






# Packing and Unpacking (Obfuscation)

## Unpacking

Comes down to knowing when to dump memory, as an appropriate time.

One approach would be to observe and plot the number of procedure calls as a histogram. An unpacker generally works in a tight loop decrypting and unpacking a binary. When it's observed that the lump of decyption work is done, it's often a very useful point to dump the memory of the process.

Tools like [volitility](http://TODO) are very handy for doing the memory dump forensics at a later stage.




# Windows Tools

## OllyDbg

> OllyDbg is an x86 debugger that emphasizes binary code analysis, which is useful when source code is not available. It traces registers, recognizes procedures, API calls, switches, tables, constants and strings, as well as locates routines from object files and libraries.


## HxD

Awesome hex editor.



## Immunity Debugger





# Linux Tools

## objdump

TODO


## strings



## ssdeep



