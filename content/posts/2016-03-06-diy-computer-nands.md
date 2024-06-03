---
layout: post
title: "DIY Computer Part 1 The NAND Gate"
date: "2016-03-06 09:53:10"
comments: false
categories:
- geek
tags:
- nand2tetris
---

I love computers. When I recently discovered that the [Nand2Tetris](http://www.nand2tetris.org/) guys, Noam Nisan and Shimon Schocken, had just packaged their famous course into a neat 12 week [Coursera](https://www.coursera.org/course/nand2tetris1) package, I couldn't resist studying it any longer.

> In this course you will build a modern computer system, from the ground up. We’ll take you from constructing elementary logic gates all the way through creating a fully functioning general purpose computer. In the process, you will learn how really computers work, and how they are designed.

I also picked up a copy of their excellent textbook [The Elements of Computing Systems](http://www.amazon.com/Elements-Computing-Systems-Building-Principles/dp/0262640686/ref=ed_oe_p).



## Basic Gates ##

Fundamental chips with truth tables.


### AND ###

Perhaps the most useful, an AND gate’s output is on (true/high) if and only if both inputs are on.

    |   a   |   b   |  out  |
    |   0   |   0   |   0   |
    |   0   |   1   |   0   |
    |   1   |   0   |   0   |
    |   1   |   1   |   1   |


### NOT ###

The NOT gate’s output is the opposite of the input.

    |  in   |  out  |
    |   0   |   1   |
    |   1   |   0   |



### OR ###

On when either (including both) input is on.

    |   a   |   b   |  out  |
    |   0   |   0   |   0   |
    |   0   |   1   |   1   |
    |   1   |   0   |   1   |
    |   1   |   1   |   1   |


### MUX (Multiplexor) ###

An input selector. Three inputs `a`, `b` and `sel`, and a single output `out`. On when either `sel` is off and input `a` is on, or `sel` is on and input `b` is on. Can be assembled using `AND`, `OR` and `NOT` gates.

Incredibly powerful. For example, enables the concept of programmable chips, such as an AndMuxOr chip, which in essence wires a single `AND` gate, and a single `OR` gate through a multiplexor, allowing the chip consumer to select the mode of operation.

In communications, the `MUX` is the backbone for encoding many discrete messages on a single communications line, by using an oscilator as the selection input. Decoding of the stream of bits can similarly occur, by applying an oscilator with a `DMUX` chip.


    |   a   |   b   |  sel  |  out  |
    |   0   |   0   |   0   |   0   |
    |   0   |   0   |   1   |   0   |
    |   0   |   1   |   0   |   0   |
    |   0   |   1   |   1   |   1   |
    |   1   |   0   |   0   |   1   |
    |   1   |   0   |   1   |   0   |
    |   1   |   1   |   0   |   1   |
    |   1   |   1   |   1   |   1   |

Or in abbreviated form:

    |  sel  |  out  |
    |   0   |   a   |
    |   1   |   b   |



### DMUX (Demultiplexor) ###

An output selector. Two inputs `in` and `sel`, and two outputs `a` and `b`. When `sel` is on, will routes `in` to `a`, otherwise route `in` to `b`.

    |  in   |  sel  |   a   |   b   |
    |   0   |   0   |   0   |   0   |
    |   0   |   1   |   0   |   0   |
    |   1   |   0   |   1   |   0   |
    |   1   |   1   |   0   |   1   |



## Boolean Identities ##

**Commutative Laws**

    (x AND y) = (y AND x)
    (x OR y) = (y OR x)

**Associative Laws**

    (x AND (y AND z)) = ((x AND y) AND z)
    (x OR (y OR z)) = ((x OR y) OR z)

**Distributive Laws**

    (x AND (y OR z)) = (x AND y) OR (x AND z)
    (x OR (y AND z)) = (x OR y) AND (x OR z)

**De Morgan Laws**

    NOT(x AND y) = NOT(x) OR NOT(y)
    NOT(x OR y) = NOT(x) AND NOT(y)


**Boolean Function Synthesis** is the premise that by reviewing the truth table for a particular function, that a series of boolean algebra statement can be assembled for only the so called "truth" conditions, `OR`'ing them all together. By applying various laws (e.g. distributive, De Morgan etc) you can often decompose the algebra into a much simplier form. Practically making the implementation simpler, more efficient and cheaper to physically implement. Unforunately this is not a straight forward procedure ([NP-hard](https://en.wikipedia.org/wiki/NP-hardness) problem).



## Enter NAND ##

A remarkable mathematical property of the above primitives, thanks to the narrow and finite world of boolean algebra (unlike that of integers for example), is that **any**, yes **any**, boolean function can be represented using an expression containing just `AND`, `OR` and `NOT` operations.

A premise that the world of digital computers completely hinges on.

This can be incredibly taken even further. Given that the humble `OR` gate alone is versatile enough of representing any function (that is, it is capable of producing a signal of 0 or 1, based on all variations of input signal, unlike an `AND` gate which has the property that if you only feed it zeroes it will always have zero as output), and thanks to De Morgan, we know that an `OR` gate can be represented as a combination of `NOT` and `AND` gates:

    (x OR y) = NOT(NOT(x) AND NOT(y))

Therefore, `OR` as a primitive, can be dumped. Sorry `OR`. Leaving us with just `AND` and `NOT` as the primitive operations on which everything else in the Boolean world can be built. There is another atomic function, that by alone, like `OR`, can compute everything. Enter `NAND`.

`NAND` truth table:

    |   a   |   b   |  out  |
    |   0   |   0   |   1   |
    |   0   |   1   |   1   |
    |   1   |   0   |   1   |
    |   1   |   1   |   0   |

Given that `NAND` can effortlessly represent:

- `NOT` by feeding both inputs the same value, that is, `NOT(x) = (x NAND x)`
- `AND` by negating `NAND` itself, that is, `(x AND y) = NOT(x NAND y)`

And with that, we can see how `NAND` provides the fundamental Boolean building block upon which everything in a digital computer can be built with.

![Mind blown](/images/mindblown.jpg "Mind blown")

Yes, mind blowingly cool.


## Buses ##

A bus put simply, is a unit of bits. In HDL, `mybus[8]` is a bus of 8 bits, which is commonly referred to as a [byte](https://en.wikipedia.org/wiki/Byte)).

**Sub-buses** are useful for composing and/or breaking down buses.

A composition example in HDL. Here the 16 input pins to `Add16`, are formed by combining two smaller 8-bit buses, `lsb` and `msb`, to form an overall 16-bit representation.

    IN lsb[8], msb[8];
    Add16(a[0..7]=lsb, a[8..15]=msb, b=..., out=...);



## The Hack chip-set API  ##

Below is a list of all the chip interfaces in the Hack chip-set, prepared by [Warren Toomey](http://www.nand2tetris.org/software/HDL%20Survival%20Guide.html). If you need to use a chip-part, you can copy-paste the chip interface and proceed to fill in the missing data. This is a very useful list to have bookmarked or printed.

    Add16(a= ,b= ,out= ); 
    ALU(x= ,y= ,zx= ,nx= ,zy= ,ny= ,f= ,no= ,out= ,zr= ,ng= ); 
    And16(a= ,b= ,out= ); 
    And(a= ,b= ,out= ); 
    ARegister(in= ,load= ,out= ); 
    Bit(in= ,load= ,out= ); 
    CPU(inM= ,instruction= ,reset= ,outM= ,writeM= ,addressM= ,pc= ); 
    DFF(in= ,out= ); 
    DMux4Way(in= ,sel= ,a= ,b= ,c= ,d= ); 
    DMux8Way(in= ,sel= ,a= ,b= ,c= ,d= ,e= ,f= ,g= ,h= ); 
    DMux(in= ,sel= ,a= ,b= ); 
    DRegister(in= ,load= ,out= ); 
    FullAdder(a= ,b= ,c= ,sum= ,carry= );  
    HalfAdder(a= ,b= ,sum= , carry= ); 
    Inc16(in= ,out= ); 
    Keyboard(out= ); 
    Memory(in= ,load= ,address= ,out= ); 
    Mux16(a= ,b= ,sel= ,out= ); 
    Mux4Way16(a= ,b= ,c= ,d= ,sel= ,out= ); 
    Mux8Way16(a= ,b= ,c= ,d= ,e= ,f= ,g= ,h= ,sel= ,out= ); 
    Mux(a= ,b= ,sel= ,out= ); 
    Nand(a= ,b= ,out= ); 
    Not16(in= ,out= ); 
    Not(in= ,out= ); 
    Or16(a= ,b= ,out= ); 
    Or8Way(in= ,out= ); 
    Or(a= ,b= ,out= ); 
    PC(in= ,load= ,inc= ,reset= ,out= ); 
    RAM16K(in= ,load= ,address= ,out= ); 
    RAM4K(in= ,load= ,address= ,out= ); 
    RAM512(in= ,load= ,address= ,out= ); 
    RAM64(in= ,load= ,address= ,out= ); 
    RAM8(in= ,load= ,address= ,out= ); 
    Register(in= ,load= ,out= ); 
    ROM32K(address= ,out= ); 
    Screen(in= ,load= ,address= ,out= ); 
    Xor(a= ,b= ,out= ); 


## Getting physical ##

Using a electronics breadboard, and old raspberry pi with a breakout kit, and a bunch of commodity NAND chips from my local electronics store, I plan to mess around with physically constructing the following composite gates (as per [nand2tetris project 1](http://nand2tetris.org/01.php)) all based on NAND's.

1. NOT gate
1. AND gate
1. OR gate
1. XOR gate
1. MUX gate
1. DMUX gate
1. 16-bit NOT
1. 16-bit AND
1. 16-bit OR
1. 16-bit MUX
1. 16-bit OR
1. 16-bit/4-way MUX
1. 16-bit/8-way MUX
1. 4-way DMUX
1. 8-way DMUX


![74HC30 8 NAND Gate IC](/images/nand_ic.jpg "74HC30 8 NAND Gate IC")

Source: [Jaycar Electronics](http://www.jaycar.com.au/Active-Components/Integrated-Circuits/Logic/74HC132-Quad-2-in-NAND-Gate-IC/p/ZC4844) the 74HC132 Quad 2 in NAND Gate IC



If interested, see follow up post [DIY Computer Part 2 The ALU]({% post_url 2016-03-06-diy-computer-nands %}).
