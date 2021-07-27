---
layout: post
title: "Wireless SecOps"
draft: true
slug: "wireless"
date: "2021-07-26 18:37:54"
lastmod: "2021-07-26 18:37:52"
comments: false
categories:
    - linux
tags:
    - debian
---

I'm back at the University of UNSW and taking the *Wireless, Mobile and IoT Security* unit with Edward Farrell.


<!-- vim-markdown-toc GFM -->

* [Legal matter](#legal-matter)
* [Networking fundamentals](#networking-fundamentals)
    * [TCP and UDP](#tcp-and-udp)
    * [Data Link Layer](#data-link-layer)
* [Wireless fundamentals](#wireless-fundamentals)
* [Cool resources](#cool-resources)

<!-- vim-markdown-toc -->

# Legal matter

Relevant Australian law:

- [The Radiocommunications Act 1992](http://www5.austlii.edu.au/au/legis/cth/consol_act/ra1992218/) applies when listening on a spectrum. It defines spectrum use, unauthorised usage, and the ISM range. Interestlingly all devices use for radiocommunications must be licensed (e.g. all WiFi gear is licensed under *Low Interference Potential Devices* class.
- The Telecommunications Act 1997
- [The Telecommunications Act 1979](http://www8.austlii.edu.au/cgi-bin/viewdb/au/legis/cth/consol_act/taaa1979410/) telecommunications not to be intercepted

Other applicable computer crimes:

- http://www.austlii.edu.au/au/legis/cth/consol_act/ta1997214/
- http://www.austlii.edu.au/au/legis/cth/consol_act/taaa1979410/s7.html

In essence. Its NOT cool to intercept network communications. It totes cool to intercept radio communications.

ISM band, is a set of ranges reserved for *Industrial, Scientific and Medical* use. 433Mhz, 900Mhz, 2.4Ghz and 5.8Ghz


Legal checklist:

- Wifi active scanning = legal
- Interception (passive collection) = grey area
- Data injection = illegal


# Networking fundamentals

Networks vary from their design and purpose; common topologies include P2P, star, mesh, bus, ring and tree.

Most practical networks are built around the OSI (Open Systems Interconnection) model; physical, data link, network, transport, session, presentation and application

## TCP and UDP

Transmission Control Protocol is connection based, and involves a 3 way handshake prior to connection establishment and transmission.

- `SYN` client sends a syncronise packet to server
- `SYN-ACK` server acknowledge the sycronise packet
- `ACK` client finalised the deal, sending an acknowlegment back to server

User Datagram Protocol (UDP), unlike its big brother TCP, is connectionless.

## Data Link Layer

Responsible for taking the raw electrical data from the physical layer, wrapping it up in a logical structure with an addressing scheme (MAC and LLC).

A standards body known as the *802* project, specify operations for different types of networks:

- 802.1 Higher Layer LAN Protocols Working Group
- 802.3 Ethernet Working Group
- 802.11 Wireless LAN Working Group
- 802.15 Wireless Personal Area Network (WPAN) Working Group
- 802.16 Broadband Wireless Access Working Group
- 802.18 Radio Regulatory TAG
- 802.19 Wireless Coexistence Working Group
- 802.21 Media Independent Handover Services Working Group
- 802.22 Wireless Regional Area Networks
- 802.24 Smart Grid TAG

# Wireless fundamentals

> You see, wire telegraph is a kind of a very, very long cat. You pull his tail in New York and his head is meowing in Los Angeles. Do you understand this? And radio operates exactly the same way: you send signals here, they receive them there. The only difference is that there is no cat - Einstein (sometimes)

Any form of communication between two point that are not physically connected; radio, light/laser, sonic, electromagnetic induction.

# Cool resources

- [WiGLE](https://www.wigle.net/) consolidated information of wireless networks world-wide in a central DB
- [OverTheWire](https://overthewire.org/wargames/) help you to learn and practice security concepts in the form of fun-filled games
- [Sysinternal PsTools](https://docs.microsoft.com/en-au/sysinternals/downloads/pslist) a collection of low level system utilities for Windows NT
- [ACMA Australian radiofrequency spectrum allocations chart](https://www.acma.gov.au/sites/default/files/2019-10/Australian%20radiofrequency%20spectrum%20allocations%20chart.pdf)
