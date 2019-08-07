---
layout: post
title: "DIY Computer Part 4 Machine Language"
date: "2016-05-23 19:34:10"
comments: false
categories:
- geek
tags:
- nand2tetris
---

A continuation of my participation in the amazing [Nand2Tetris](http://www.nand2tetris.org/) course, by Noam Nisan and Shimon Schocken, now running on [Coursera](https://www.coursera.org/course/nand2tetris1).

> In this course you will build a modern computer system, from the ground up. We’ll take you from constructing elementary logic gates all the way through creating a fully functioning general purpose computer. In the process, you will learn how really computers work, and how they are designed.

If interested, see prior posts:

- [DIY Computer Part 1 The NAND Gate]({% post_url 2016-03-06-diy-computer-nands %})
- [DIY Computer Part 2 The ALU]({% post_url 2016-03-12-diy-computer-alu %})
- [DIY Computer Part 3 Memory]({% post_url 2016-03-12-diy-computer-alu %})


[comment]: <TODO #1: diagram of overall hack machine>

A machine language manipulates a memory using a processor and a set of registers.

> Machine language is the most profound interface in the overall computer; the fine line where hardware and software meet. This is the point where the abstract thoughts of the programmer, as manifested in symbolic instructions, are turned into physical operations performed in silicon.

A highlevel snippet such as:

    while (R1 >= 0) {
    	// segment1
    }
    // segment2

For a machine, translates to:

    loopstart:
      JNG R1,loopend
      //segment1 translated instructions
      JMP loopstart
    loopend:
      //segment2 translated instructions



When dealing with hardware, instructions must ultimately be coded as binary. To make this process more human friendly, can represent the finite grammar of possible insrtuctions, symbolically.

For example:

    @17
    D+1;JLE

Has a one-to-one binary translation of:

    0000000000010001
    1110011111000110


Enter the Hack machine language.

Hack deals with two distinct address spaces, an *instruction memory* and a *data memory*. Both memories are 16-bit wide and have a 15-bit address space, meaning that the maximum addressable size of each memory is 32K 16-bit words.


# Grammar #

# D register #

The data register. Holds a single 16-bit value.


# M register #

Represents the actively selected 16-bit RAM register (32767 or 2^15-1 tiny 16-bit buckets) addressed by `A`.


# A instruction #

The address register. Holds a single 16-bit value. `RAM[A]` becomes the selected `RAM` register.

Syntax: `@value`

Example: `@21`

`RAM[21]` is now selected, and the `M` register will now point to this location.

To set RAM location 100 to -1:

    @100
    M=-1

The `A` instruction is able to represent 2^15-1 or 32767 possible locations. This is because, in binary, the `A` instruction, is represented as `0value`, where value is a 15-bit binary number, or in other words, the first bit `0` is reserved for the opcode (operation code) of `A`:

    @21

Translates to:

    0000000000010101


# C instruction #

Syntax: `dest = comp ; [jump]`

**dest**:

`null`, `M`, `D`, `MD`, `A`, `AM`, `AD`, `AMD`

**comp** (one of the following ALU supported operations):

`0`, `1`, `-1`, `D`, `A`, `!D`, `!A`, `-D`, `-A`, `D+1`, `A+1`, `D-1`, `A-1`, `D+A`, `D-A`, `A-D`, `D&A`, `D|A`, `M`, `!M`, `-M`, `M+1`, `M-1`, `D+M`, `D-M`, `M-D`, `D&M`, `D|M`

**jump** (optional):

`null`, `JGT`, `JEQ`, `JGE`, `JLT`, `JNE`, `JLE`, `JMP`


Snippet:

    @1
    M=A-1;JEQ

- Register `A` is 1.
- `RAM[1]` is set to 0.
- The next instruction to execute is instruction `1`.

In binary, the C instructions symbolic syntax is `dest = comp ; [jump]`, translates to:

    1 - opcode
    1 - n/a
    1 - n/a
    a - comp bits
    c1 - comp bits
    c2 - comp bits
    c3 - comp bits
    c4 - comp bits
    c5 - comp bits
    c6 - comp bits
    d1 - dest bits
    d2 - dest bits
    d3 - dest bits
    j1 - jump bits
    j2 - jump bits
    j3 - jump bits


Lets decompose this.

First the *comp* coding, to indicate the desired computation that is to take place. Note the use of the front `a` bit, used to toggle between modes:

a=0 | c1 | c2 | c3 | c4 | c5 | c6 | a=1
--- | --- | --- | --- | --- | --- | --- | ---
`0` | `1` | `0` | `1` | `0` | `1` | `0` |
`1` | `1` | `1` | `1` | `1` | `1` | `1` |
`-1` | `1` | `1` | `1` | `0` | `1` | `0` |
`D` | `0` | `0` | `1` | `1` | `0` | `0` |
`A` | `1` | `1` | `0` | `0` | `0` | `0` | `M`
`!D` | `0` | `0` | `1` | `1` | `0` | `1` |
`!A` | `1` | `1` | `0` | `0` | `0` | `1` | `!M`
`-D` | `0` | `0` | `1` | `1` | `1` | `1` |
`-A` | `1` | `1` | `0` | `0` | `1` | `1` | `-M`
`D+1` | `0` | `1` | `1` | `1` | `1` | `1` |
`A+1` | `1` | `1` | `0` | `1` | `1` | `1` | `M+1`
`D-1` | `0` | `0` | `1` | `1` | `1` | `0` |
`A-1` | `1` | `1` | `0` | `0` | `1` | `0` | `M-1`
`D+A` | `0` | `0` | `0` | `0` | `1` | `0` | `D+M`
`D-A` | `0` | `1` | `0` | `0` | `1` | `1` | `D-M`
`A-D` | `0` | `0` | `0` | `1` | `1` | `1` | `M-D`
`D&A` | `0` | `0` | `0` | `0` | `0` | `0` | `D&M`
`D|A` | `0` | `1` | `0` | `1` | `0` | `1` | `D|M`


Second the *dest* coding, to indicate where the computed bits are to be stored:

d1 | d2 | d3 | Symbol | Destination
--- | --- | --- | --- | ---
`0` | `0` | `0` | `null` | The value is not stored anywhere
`0` | `0` | `1` | `M` | Memory[A]
`0` | `1` | `0` | `D` | D register
`0` | `1` | `1` | `MD` | Memory[A] and D register
`1` | `0` | `0` | `A` | A register
`1` | `0` | `1` | `AM` | A register and Memory[A]
`1` | `1` | `0` | `AD` | A register and D register
`1` | `1` | `1` | `AMD` | A register, Memory[A], and D register

And finally to complete the binary definition of the `C` instruction, we have the *jump* bits coding.

j1 (out < 0) | j2 (out = 0) | j3 (out > 0) | Symbol | Description
--- | --- | --- | --- | ---
`0` | `0` | `0` | `null` | No jump
`0` | `0` | `1` | `JGT` | If out > 0 jump
`0` | `1` | `0` | `JEQ` | If out = 0 jump
`0` | `1` | `1` | `JGE` | If out >= 0 jump
`1` | `0` | `0` | `JLT` | If out < 0 jump
`1` | `0` | `1` | `JNE` | If out <> 0 jump
`1` | `1` | `0` | `JLE` | If out <= 0 jump
`1` | `1` | `1` | `JMP` | Jump





# Symbols #

Assembly commands can refer to memory locations using either constants or symbols.


## Predefined symbols ##

A special subset of RAM addresses can be referred to by any assembly program using the following predefined symbols

### Virtual registers ###

To simplify assembly programming, the symbols `R0` to `R15` are predefined to refer to RAM addresses 0 to 15, respectively. A cleaner alternative than using a combination of the `A` and `M` instructions.


### Predefined pointers ###

The symbols `SP`, `LCL`, `ARG`, `THIS`, and `THAT` are predefined to refer to RAM addresses 0 to 4, respectively. Note that each of these memory locations has two labels. For example, address 2 can be referred to using either R2 or ARG.

### I/O pointers ###

The symbols `SCREEN` and `KBD` are predefined to refer to RAM addresses 16384 (0x4000) and 24576 (0x6000), respectively, which are the base addresses of the screen and keyboard memory maps.

 
## Label symbols ##

These user-defined symbols, which serve to label destinations of goto commands, are declared by the pseudo-command `(Xxx)`. This directive defines the symbol `Xxx` to refer to the instruction memory location holding the next command in the program. A label can be defined only once and can be used anywhere in the assembly program, even before the line in which it is defined.


## Variable symbols ##

Any user-defined symbol `Xxx` appearing in an assembly program that is not predefined and is not defined elsewhere using the `(Xxx)` command is treated as a variable, and is assigned a unique memory address by the assembler, starting at RAM address 16 (0x0010).




# Examples #


## Simple memory addressing ##

Set RAM location 300 to `D-1`:

    @300
    M=D-1


## Simple jumping ##

If `D-1` equals `0` jump to execute the instruction stored in `ROM[33]`:

    @33
    D-1;JEQ // if (D-1 == 0) goto 33


## Simple jumping II ##

Unconditionally execute the instruction stored in `ROM[16]`:

    @19
    0;JEQ


## If condition as jumps ##

Jump fun:

    // if RAM[3] == 5
    // then goto 100
    // else goto 200

    @3
    D=M
    @5
    D=D-A
    @100
    D;JEQ
    @200
    0;JMP


## Pointers ##

    // for (i=0; i<n; i++) arr[i] = -1
    
    // arr=100
    @100
    D=A
    @arr
    M=D

    // n=10
    @10
    D=A
    @n
    M=D

    // i=0
    @i
    M=0

    (LOOP)
      // if (i==n) goto END
      @i
      D=M
      @n
      D=D-M
      @END
      D;JEQ

      // RAM[arr+i] = -1
      @arr
      D=M
      @i
      A=D+M //pointer!
      M=-1

      // i++
      @i
      M=M+1

      @LOOP
      0;JMP

    (END)
      @END
      0;JMP




## Fill ##

Demonstrates how machine language can integrate with I/O devices. This program will fill the screen buffer (512 x 256) with black or white pixels, if a keyboard button press is detected. The `@SCREEN` (16384) and `@KBD` (24576) symbols are nothing but pointers to memory offsets.

    @pixel_state_past //0xFFFF=black, 0x0000=white
    M=-1
    D=0
    @PREPARE
    0;JMP

    (MAIN)
      @KBD
      D=M
    
      @PREPARE
      D;JEQ // if no key, leave D=0
      D=-1 // else -1
    
    
    (PREPARE)
      @pixel_state
      M=D
      @pixel_state_old
      D=D-M
    
      @MAIN
      D;JEQ // dont repaint if equal
    
      @pixel_state
      D=M
      @pixel_state_old
      M=D
    
      @SCREEN
      D=A
      @8192
      D=D+A
      @pixel_pointer
      M=D // setup pointer
    
    
    (RENDERLOOP)
      @pixel_pointer
      D=M-1
      M=D // decrement by one pixel
    
      @MAIN
      D;JLT // if (pixel_pointer<0) return
    
      @pixel_state
      D=M // what pixel value
    
      @pixel_pointer
      A=M // where to write pixel
      M=D // write it
    
      @RENDERLOOP
      0;JMP // rinse and repeat
