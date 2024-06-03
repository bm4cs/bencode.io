---
layout: post
title: "CNO Day 4 Metasploitable"
date: "2018-07-26 08:54:01"
comments: false
categories:
- hacking
tags:
- offensive
- cno
---


Awesome tip #1: In metasploit console (`msfconsole`), once you have loaded up an exploit, take `show payloads` for a spin. This will show all payloads that are compatible with the given exploit. Awesome!

Today we got the chance to work on [Metasploitable 3](https://github.com/rapid7/metasploitable3), a Windows VM with a number of vunerability and flags (15ish of them).

Its a great way to take this knowledge and apply it to an actual machine. I wont detail a full walkthrough, as there are already plenty, and I don't want to ruin the learning experience.

Once we gained a root shell no the (windows) machine, discovering the flags (images from a deck of cards), you will stumble upon pretty interesting obfuscation techniques. The 15 flags are somewhere. To add more forensic depth to the challenge, flags were corrupted/encoded/buried.

One page had a hex string (yes a hex string, not to be confused with base64). You'll need to be comfortable with converting and decoding a range of formats, for example:

    base64conv -i hex -o raw -r viewstate-data.txt -w joker.png

Alternate data streams on NTFS are one method of making files less visible. To show them:

    dir /R

Simple base64 decoding:

    base64 -d encoded-flag.txt > flag.png

Extracting hidden images out of pdf and docx files:

    pdfimages TODO
    unzip -d flag.docx


Grepping on Windows, with `findstr` for example:

    findstr /S /M /P /C:"hearts" *.log 2>null

- `/S` recurse
- `/M` print only the filename
- `/P` skip binary (non-printable) files
- `/C` search string
- `2>nul` pipe file access errors to a blackhole


# TODO's

* Get the Red and Blue Team books, which contain very useful common commands for dealing with Windows and NIX based operating systems.
* Checkout Pico CTF. A simpler CTF, that builds up with gradient nicely.
* Checkout CTF time.
* Check out XOR encoding
* Read up on rainbow tables.

