---
layout: post
title: "Reverse Engineering Quizzes"
date: "2019-02-25 08:44:10"
comments: false
categories: [dev]
tags: [infosec]
---

A summary of learnings from reverse engineering.

- [Malcious Actions](#malcious-actions)
- [Malware Delivery and Exploitation](#malware-delivery-and-exploitation)
- [Command and Control (C2, C&C)](#command-and-control-c2-cc)
- [Persistence and Evading Detection](#persistence-and-evading-detection)
- [Side Channel Attacks and Jumping Airgaps](#side-channel-attacks-and-jumping-airgaps)
- [Object File Formats](#object-file-formats)
- [ELF, PE and Java Class](#elf-pe-and-java-class)
- [Linking and Loading](#linking-and-loading)
  - [Virtual Memory](#virtual-memory)
- [Object Code and Instruction Set Architectures Quiz](#object-code-and-instruction-set-architectures-quiz)
  - [x86 registers](#x86-registers)
  - [CISC and RISC](#cisc-and-risc)
- [Program Representation](#program-representation)
- [Program Analysis](#program-analysis)




# Malcious Actions

**Architectures for botnet communication**

* Client server
* Central command


**Types of malicious activities used for finanical gain**

* Malware
* Spyware
* Social engineering
* 


**Service that can be used for domain registration**

`whois` information with fake information (e.g. owner) about the domain registration.


**Banking malware implementing spyware**

Could be done via a browser plugin for example.






# Malware Delivery and Exploitation


*What physical interface allows writing to memory as an attack using DMA?*

PCIe

*What attack surface is exposed by the kernel?*

* syscall interface into the kernel from userland.
* `ioctls`
* device drivers
* file systems
* networking code


*What is the security risk for exploitation by installing a lot of device drivers?*

* large footprint
* not reviewed as much as core kernel code



*Name 3 exploit mitigation techniques*

* non executable stack/heap
* address space layout randomisation (ASLR) - hard to build ROP chain
* detecting corrupt heap metadata



*If kernel addresses are randomized, how might an attacker obtain key kernel addresses to use in an exploit?*

Brute force.

Side channel attack using branch target buffer.


*What architecture do modern basebands use?*

Hexagon made by Qualcomm, which is VLIW architecture.


*How might a baseband attack against mobile phones be delivered?*

* Inject browser exploit into network stream from base band
* Exploit gains code execution on the application processor


*What type of OS does a baseband run on?*

A RTOS called QuRT by Qualcomm.


*What exploit mitigations does the Hexagon Snapdragon use?*

* Custom heap allocator
* Data execution prevention (DEP)


*Name two attacks to escalate from the baseband to the application processor (attacks on older baseband architectures are valid for your answer)*

* Base band attack
* Application processor attack


*What are 3 types of attacks against cars?*

* CAN bus
* Keyless entry
* Internet connectivity


*In what package/image is the iPhone baseband distributed as?*

ELF binaries


*How might you obtain the firmware for a Mask ROM?*

Physical imaging of the decapped IC.


*What is IC decapsulation/decapping? What purpose does it have?*

Exposes the physical surface for analysis.





# Command and Control (C2, C&C)

*Name 2 architectures for C2 of a botnet.*

* client server
* peer to peer (P2P)


*What are the advantages and disadvantages of each?*

Client server

Pros: Administration and management of master is simplified.
Cons: centralised, single points of failure, domain can be taken down, IRC channel blocked

P2P:

Pros: decentralised, can piggy back existing P2P protocols, PKI encryption
Cons: more complex administration


*What is the purpose of Fast-Flux DNS?*

To diversify the number of host IP's addressed to a single DNS record.


*Why does modern malware use cloud services for C2?*

Very robust server platform. Traffic blends in with the noise, of general use.






# Persistence and Evading Detection

*What is the MBR?*

The Master Boot Record. The first sector, as part of the bootstrapping procedure. Typically runs a later stage boot loader (e.g. GRUB)


*How does a bootkit use an MBR?*

Modifies the bootloader in such a way that code can be executed prior to OS load. Highly persistent, across boots.


*What is the difference between a user land rootkit and a kernel land rootkit?*

Focused on applications running in (non-privileged) user mode space. Hook API's, infecting executables. Kernel focuses on modifing pieces of the OS.


*What is blue pill?*

A hypervisor based rootkit.


*Name 2 devices or (sub)system susceptible to a firmware-based rootkit?*

* BIOS/UEFI
* Hard disks
* Network cards


*What is a rootkit/bootkit defense?*

PKI and digital signing.


*How might one defeat trustzone?*

* private keys leaked
* bootloader bugs, may allow loading an unsigned image
* user space bugs still will allow code execution after booting, but obviously not persistent





# Side Channel Attacks and Jumping Airgaps


*What is a side channel attack?*

An (physical) attack that avoids breaking the security of a system.


*Name 3 types of side channels*

Timing, power, acoustic

*How does a timing attack work?*

Measures and observes the length of time computations take.


*What is a constant time operation and why is it useful?*

It doesn't disclose to an outside observer the behaviour of an operation or program.


*Why should untrusted and trusted network cables in a secure environment be separated?*




*What device is used to obtain a power trace in simple power analysis?*

Oscilloscope.



*SPA and DPA differ in what way?*

* SPA (simple power analysis) is concerned with the amount of power a controller uses reveals the **type** of computation.
* DPA (differential power analysis), the amount of power a controller uses reveals the **actual data** in a computation.




*What are 2 ways to reduce or mitigate the risk of RF emanations from a monitor?*

Shielding. Font modification.


*In a glitching attack, what can be glitched?*

Clock or power glitching.


*What commercial device implements glitching and power analysis?*

Chip whisperer.




# Object File Formats


*How does an Operating System recognise an object file?*

Three options; magic header info, file name or by just trying the load.


*How are the various parts of an object file divided internally?*

Headers, relocations, symbols, dynamic linking, debugging.


*Name what type of things can go into an object file.*

As above.

*Name 3 object files from 3 different Operating Systems.*

PE, ELF and Java class.

*What attributes are associated with loadable segments and object code in an object file?*

Access protection properties, load address and a size.


*What is the difference between the physical memory associated with object code in a loadable segment and virtual memory?*

Physical is the actual size of object code in the file. Virtual is how much memory is allocated by the OS when loading the object code.


*Why might the virtual address of a loadable segment be aligned to a 4k boundary?*

The kernel fakes a nice sequential continuous chunk of memory to the consuming process. What is really going on, is that its mapping to banks of physical memory chips. The unit of management, is archtecture specific, and in the case of x86 is 4k. Interestingly there are some huge optimisations available here, for the kernel to provide, such as reuse of commonly linked code across multiple processes (such as libc). In the event a process attempt to modify this shared memory, CoW (copy on write), mean the modified version could be dumped out and mapped into the address space specific to the process. 




# ELF, PE and Java Class


*What structure begins an ELF binary?*

The ELF header, specifically the magic bytes.


*How is an ELF binary recognised by the Operating System?*

Magic marker.


*Where is the layout for the program headers and section headers given?*

The ELF header.


*What are the different views of an ELF binary?*

Linking view and execution view.


*What view(s) does a shared library have? Why?*

Both views. Needs to be relocatable, as will likely be contained within a running (executable) process.


*In what view are relocations required?*

Linking view.


*When is it necessary to have program headers?*

In both executable and shared objects.


*How does a PE binary divide itself into parts – what name is given to each part?*

Sections.


*Why does a PE binary have a DOS header?*

Backwards compatibility.


*Why doesn’t a Java Class file have relocations?*

JIT compiler.


*Object code is assigned to what kind of things in a Class file?*

A code attribute `Code_attribute`


*In which part of the file is the number of methods identified?*

The `ClassFile`




# Linking and Loading


*What are the stages of transforming source code into a native application?*

Source > Compilation > Assembly > Object Code > Linking > Native Executable


*At what point in the process is the native code bound to an address?*

At runtime (execution).


*What is responsible for allocating virtual memory when a native application is loaded?*

By the kernel at process load.


*How does Linux know a program being executed should be treated as a script?*

Magic bit (the `#!`).


*Briefly describe how interpretation works.*

Disptach (REPL) loop.


*Name a system that uses Just-in-Time compiler*

Java Virtual Machine (JVM).


*What is the output of a JIT compiler at development time?*

Bytecode.


*What is an advantage of JIT over interpreted languages?*

Compiled. Can make smart optimisation decision about its environment.


## Virtual Memory

*Each object file typically has 3 parts to it in virtual memory. Name them*

* Text/code
* Initialised data
* Uninitalised data

And a heap and stack.

*How many stacks does a typical multithreaded application use? Why?*

One per thread, with a shared heap.


*What is the initial state of the BSS after process loading?*

Unitialised data, and is zero'd during process loading.


*What Windows API call is often used by malware to allocate virtual memory?*

`VirtualAlloc`





# Object Code and Instruction Set Architectures Quiz

## x86 registers

*What register is the stack pointer?*

esp

*What register is the frame pointer?*

ebp

*How many general purpose registers are there?*

8

*How do you access the lower 16 bits of ecx?*

cx


*How do you access the high 8 bits of that result?*

ch


*And the low 8 bits?*

cl


*How do we use xor to set a register to zero?*

    xor %reg,%reg


*What are some instructions to use the stack in x86?*

push, pop


*If the call instruction pushes a return address on the stack, how might we use this to get the address of the current instruction?*

Buffer overflow.



## CISC and RISC

*How might you load a 32 bit value into a register when the instruction size for your architecture is only 32 bits?*

Load high bits, then low bits using 2 instructions.


*What is a delay slot?*

An instruction, following branches, that are executed regardless of which branch is taken.


*Why is a delay slot used?*

Better use of pipelines, and to avoid penalties from pipeline stalls.






# Program Representation

*Name 4 different types of mathematical objects*

Vectors, sets, trees and graphs


*How is a string different to a sequence?*

Sequence is a particular order of characters (e.g. a then at some point further b then some point further c)


*What cross-disciplinary field looks heavily at sequence alignment?*

Genome sequences.


*How efficient is it to compare two strings using the edit distance?*

O(n.m)


*How efficient is it to compare two vectors using something like the Euclidean distance?*

TODO


*How efficient is it to compare two graphs using the edit distance?*

NP

*What strategy can we use to make graph comparisons feasible?*

Use heuristics instead to show similarity.


*What is a basic block?*

A set of instructions.


*What is a control flow graph?*

The intraprocedural contorl flow.


*What is a call graph?*

The interprocedural control flow.


*What is the difference between a control flow graph and a call graph?*

One is concerned with flow within a procedure. One is concerned about the relationship between procedures.


*Where can we statically get a list of useful (to malware analysis) API calls from a PE binary?*

TODO


*When we use instructions as a feature, what variety of instruction types can we use?*

TODO




# Program Analysis

What is the process of recognising tokens from a source file?
How are these tokens represented in their description file?
What is the process of converting a sequence of tokens into a concrete-syntax-tree?
What type of languages can a parser typically recognise?















