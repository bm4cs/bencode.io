---
layout: post
draft: true
title: "Networking for developers"
slug: "networking"
date: "2022-05-17 18:00:04+11:00"
lastmod: "2022-05-17 18:00:04+11:00"
comments: false
categories:
  - network
tags:
  - network
  - tcpip
---

- [Overview](#overview)
- [The OSI Layers](#the-osi-layers)
  - [Layer 2 (Link)](#layer-2-link)
    - [Layer 2 (Link) Protocols](#layer-2-link-protocols)
  - [Layer 3 (Network)](#layer-3-network)
    - [Layer 3 (Network) Protocols](#layer-3-network-protocols)
  - [Layer 4 (Transport)](#layer-4-transport)
    - [TCP (tansmission control protocol):](#tcp-tansmission-control-protocol)
    - [UDP (user datagram protocol):](#udp-user-datagram-protocol)
    - [Layer 4 (Transport) Protocols](#layer-4-transport-protocols)
  - [Layer 7 (Application)](#layer-7-application)
    - [Layer 7 (Application) Protocols](#layer-7-application-protocols)
  - [Cloud Physical Networking](#cloud-physical-networking)
    - [The magic layer 2 scale sauce](#the-magic-layer-2-scale-sauce)
  - [Networking inside NT](#networking-inside-nt)
  - [Hyper-V Networking](#hyper-v-networking)
- [Network Emulators](#network-emulators)
  - [MiniNet](#mininet)
  - [Cisco Packet Tracer](#cisco-packet-tracer)
- [Network Tools and Simulators](#network-tools-and-simulators)
- [Cisco](#cisco)
  - [IOS shell](#ios-shell)
  - [IOS configuration](#ios-configuration)
- [Resources](#resources)

## Overview

The Open Systems Interconnection (OSI) model is an ISO standard, for generalising how computers communicate. It comprises of 7 layers (PDNTSPA - Please Do Not Throw Sausage Pizza Away):

| OSI layer | Name         | Includes                                                                                |
| --------- | ------------ | --------------------------------------------------------------------------------------- |
| 7         | Application  |                                                                                         |
| 6         | Presentation | Data normalisation (encoding, bit order)                                                |
| 5         | Session      |                                                                                         |
| 4         | Transport    | Segments and reassembles (TCP/UDP, ports)                                               |
| 3         | Network      | Connectivity and path selection between two hosts (IP addresses, routers)               |
| 2         | Data Link    | Data transmission formats and physical media control (Ethernet MAC, switches) addresses |
| 1         | Physical     | Bit transmission between devices (voltage levels, data rates)                           |

Common to categorise a problem to its layer, ex: for a cabling problem "I found it was a layer 1 issue".

Inside joke: a layer 8 issue = human/user issue

The TCP/IP pre-dates the OSI model (it was born as part of ARPAnet). The complete (all layers) data exchange unit is known as the Protocol Data Unit (PDU). Each layer has its own terminology for its data unit:

| TCP/IP layer | Name           | Data unit |
| ------------ | -------------- | --------- |
| 4            | Application    | Data      |
| 3            | Transport      | Segment   |
| 2            | Internet       | Packet    |
| 1            | Network Access | Frame     |

## The OSI Layers

### Layer 2 (Link)

At the physical link layer how do devices communicate (i.e, interconnect and exchange data)?

- Each device has a NIC that ships with a unique MAC (6-byte) address such as `30-65-EC-6F-C4-58`
- The first 3-bytes are used to flag the vendor
- Packets traditionally were broadcasted out to a devices
- Network switches dynamically learn and build up a mapping table of MAC to Ports

Complexity slowly increases.

- Many devices. Switches connected to switches.
- A interesting problem arose where the infinite broadcasting of unroutable packets could bring a network to its knees; _bridge loops_ and _broadcast radiation_.
- Protocols such as [Spanning Tree Protocol](https://en.wikipedia.org/wiki/Spanning_Tree_Protocol) invented by a smart lady [Radia Perlman](https://en.wikipedia.org/wiki/Radia_Perlman), overcame this by computing a least-cost tree across nodes and automatically unblocking or blocking the necessary switch ports to achieve it.
- At the electrical level, many corruption issues were experienced in practice. CRC checksums were introduced.
- Duplicate MAC addresses are a challenging issue; the addresses

As logical addressing schemes such as IP build on-top of layer 2, a scheme was needed for figuring out layer 2 MAC addresses from given only logical IP addresses.

- ARP was born "Address Resolution Protocol"
- Makes use of a special layer 2 packet known as a _broadcast packet_ (destination MAC is `FF:FF:FF:FF:FF:FF`)
- The broadcast packet floods the network, and is delivered to all

Some security standards as this layer have emerged, most notably [MACsec](https://en.wikipedia.org/wiki/IEEE_802.1AE).

#### Layer 2 (Link) Protocols

| TLA   | Un-TLA                                       | Description                                                |
| ----- | -------------------------------------------- | ---------------------------------------------------------- |
| ARP   | Address Resolution Protocol                  | Translation from logical to physical addressing addressing |
| L2TP  | Layer 2 Tunneling Protocol                   | What a great name.                                         |
| RSTP  | Rapid Spanning Tree Protocol                 | STP successor, adds convergence behaviors and bridge ports |
| STP   | Spanning Tree Protocol                       | Used to build a loop-free topology for Ethernet networks   |
| TRILL | Transparent Interconnection of Lots of Links | Proposal for an STP successor, which never got legs        |

### Layer 3 (Network)

As the needs and complexity of a layer 2 network grows, it becomes necessary to interlink network switches, which in-turn can connective many dozens of devices.

- A interest problem arose.
- As layer 2 operates by flooding and learning (coined a _broadcast storm_) to determine the physical MAC addresses of peers, results in much chatter.
- This is a known as a _Broadcast Domain_ used by layer 2 to support its _flood and learn_ model.
- This doesn't scale; the bigger layer 2 networks become the more flood and learn chatter that occurs.
- To scale, layer 3 (IP) networks were devised.
- By carving layer 2 broadcasting domains into _subnets_, it is now possible, using routers, to interlink these layer 2 subnets.
- In the case an IP address lives outside the current subnet, the MAC address of the router is resolved, known as the _default gateway_

Subnets made great strides in the design (and scale) of inter-networking devices:

- The problem of _broadcast storms_ in layer 2 networks, as part of its inherent flood and learn model, still was a scalability pain point, even with concept of subnets.
- The need to further partition layer 2 networks was strong.
- The [VLAN](https://en.wikipedia.org/wiki/VLAN) standard was born.
- VLANs by applying simple tags to layer 2 network frames, are able to further partition and limit the broadcast blast radius even further.
- Switches honour VLAN tags and will not broadcast frames between different VLANs.
- VLAN has a _trunk mode_ where it will freely broadcast through any layer 2 frames. This is to support advanced configurations where downstream appliances or hosts may wish to receive all layer 2 frames to make intelligent routing or filtering decisions.
- Operating systems support connecting a single NIC to multiple VLANs such as `eth0.1` `eth0.2` on Linux

Subnets use routers to inter-link them. But how do routers, which may in-turn be linked to many other routers, know where to send a packet onwards to the next part of its journey?

- Routing packets between subnets is akin to routing mail between inter-state post offices.
- Without hand configuring routing tables, a laborious and error prone activity, dynamic routing protocols were made.
- A router can advertise the subnet for which is knows about and is capable of routing.
- Using a routing protocol, routers can share this routing knowledge with each other.
- [BGP](https://en.wikipedia.org/wiki/Border_Gateway_Protocol) or Border Gateway Protocol is one popular option.

#### Layer 3 (Network) Protocols

| TLA   | Un-TLA                                     | Description                                                          |
| ----- | ------------------------------------------ | -------------------------------------------------------------------- |
| BGP   | Border Gateway Protocol                    | Used to exchange routing and reachability knowledge (Internet scale) |
| IS-IS | Intermediate System to Intermediate System | Routing packets based on best routes (Internet scale)                |
| MPLS  | Multi-protocol Label Switching             | Label (not address) based routing                                    |
| OSPF  | Open Shortest Path First                   | Routes based on link state route (LSR) (used inside a data center)   |

### Layer 4 (Transport)

Thankfully layer 3 provides the foundations for devices to communicate on a network.

Unfortunately we're not done.

When you think about a computer or device connected to a network, it is not uncommon for it to be running multiple processes that each in-turn wish to interact with the network. A given computer might run a web browser and SSH client simultanously.

- While layer 3 (IP) allows machine level packet exchange to take place, it is too crude for multiplexing this traffic between processes.
- Enter layer 4 which bolsters layer 3 (IP) with additional powers.
- Three key missing pieces are added on-top of IP; a _protocol field_ and two 16-bit _port fields_ for a source and destination port.
- 16-bit = 64K ports are possible
- [IANA](https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml) (Internet Assigned Numbers Authority) have estalbished common usages for particular port numbers.
- The source IP, dest IP, protocol, source port and dest port is known colloquially as the _5 tuple_
- The _5 tuple_ in essence defines the logical connection
- Sockets were an early layer 4 abstraction born in UNIX

#### TCP (tansmission control protocol):

- Provides the concept of a connection. A durable session is which data can flow.
- Establishing a TCP connection is infamously known as a _3-way handshake_ (`SYN`, `SYN-ACK`, `ACK`)
- On both the client and server accounting is established to facilitate re-ordering, acknowledging, congestion control and throttling, re-transmission, timeouts
- The great water analog for TCP. A sender has a bucket (buffer size) which is pored into a water pipe (bandwidth), which empties into receivers bucket (receive window buffer).

At its core TCP fundamentals to know well (kudos [Chris Greer](https://www.youtube.com/watch?v=xdQ9sgpkrX8) the Packet Pioneer):

- TCP handshake and options
  - Buffer (window) sizes
  - Sequence number
  - Scale factor
  - SACK
- TCP windows
- TCP retranmissions
- Selective acknowledgements

Wireshark TCP tricks for performance issues:

- Custom profile to paint events of interest, such as `SYN` packets as bright green
- Filter expressions
- Spotting delays in TCP streams using delta time (the time difference between adjacent packets)

#### UDP (user datagram protocol):

- While TCP adds great functionality such as connection establishment, flow control etc.
- This comes at a cost and is trade-off that must be made.
- Do the features TCP provides outweight the performance costs it must pay?
- UDP strips down most of the functionality provided by TCP, providing minimal layer 4 communication between processes.
- Given how entrenched TCP is throughout the infrastructure that makes up the Internet, there is now a movement to evolve TCP by building protocols on-top of UDP.
- Google for example have been experimenting with [SPDY](https://en.wikipedia.org/wiki/SPDY) and [QUIC](https://en.wikipedia.org/wiki/QUIC)
- SPDY (a pre-cursor for HTTP/2) reduces latency between the browser and server by applying compression (less data), multiplexing (less connections) and prioritisation (less waiting).

#### Layer 4 (Transport) Protocols

| TLA  | Un-TLA                         | Description                                    |
| ---- | ------------------------------ | ---------------------------------------------- |
| QUIC | Quick UDP Internet Connections | An optimised TCP implementation based on UDP   |
| SPDY | _Speedy_                       | The precursor to HTTP/2.                       |
| TCP  | Transmission Control Protocol  | A connection-oriented transport protocol.      |
| UDP  | User Datagram Protocol         | A connection-less, minimal transport protocol. |

### Layer 7 (Application)

TCP connections at scale, don't scale.

- At Google scale, even the seemingly simple TCP 3-way handshake can be harmful.
- But given how entrenched the Internet infrastructure and its protocols are, it is simply not feasible to redesign TCP.
- Google, well aware of this problem, came up with a great idea.
- Why not build a _new TCP_ on-top of the unencumbered UDP? The [SPDY](https://en.wikipedia.org/wiki/SPDY) and [QUIC](https://en.wikipedia.org/wiki/QUIC) proposals were born.
- SPDY (a pre-cursor for HTTP/2) reduces latency between the browser and server by applying compression (less data), multiplexing (less connections) and prioritisation (less waiting).
- HTTP/2 adds connection multiplexing; allowing multiple streams of data to traverse over a single connection. HTTP/2 overcomes [HOL](https://en.wikipedia.org/wiki/Head-of-line_blocking) at the layer 7, but still suffers from it as layer 4.
- HTTP/3 overcomes [HOL](https://en.wikipedia.org/wiki/Head-of-line_blocking) at layer 7 and layer 4 by using QUIC instead of TCP.
- In line with pressure to reduce RTT (round-trip time) connection overheads caused by handshakes, TLS 1.3 proposed design changes to TLS, inline with the QUIC and HTTP/3 movements.
- RTT (round trip time) is a useful unit of measurement in the reduction goal; being the complete time from request to receipt of response. Zero RTT (0-RTT) being the holy grail, with no preample connection establishment concerns.
- [QUIC](https://en.wikipedia.org/wiki/QUIC) in combination with HTTP/3, has effectively replaced TCP by offering (1) reliability, (2) flow control and per stream (3) prioritisation, (4) zero-RTT and (5) no head-of-line (HOL) blocking.

#### Layer 7 (Application) Protocols

| TLA  | Un-TLA                         | Description                                  |
| ---- | ------------------------------ | -------------------------------------------- |
| QUIC | Quick UDP Internet Connections | An optimised TCP implementation based on UDP |

### Cloud Physical Networking

Data centers with lots of servers = the cloud amirite.

- A rack houses lots of servers (aka blades or nodes).
- The nodes in a rack interface with the world via a network router located within the rack (aka the _Top of Rack_ (ToR) or _T0_ router)
- The T0 (ToR) routers are in-turn daisy-chained (using copper) with another layer of routers known as the _T1_ or _leaf routers_.
- The T0-to-T1 layer can only scale so far, e.g., there are only so many physical ports, latency requirements, so on. When a threshold of T0-and-T1 interconnections occur, this unit of nodes/T0s and T1 is clumped up. This clumping is known as a _cluster_.
- T0-to-T1 flows are efficiently distributed by leveraging ECMP (Equal Cost Multi Path).
- This T0-to-T1 _cluster_ can in-turn be inter-connected to yet another layer of swtiches, known as the T2 or _spine router_. This hierarchical scale model could in-theory go on and on.
- In practice the _spine routers_ (T2) within a physical region are daisy-chained via a _regional hubs_ (RH) and _regional aggregators_ (RA).
- Regions are in-turn interconnected via a WAN/SWAN network.
- Within a region, latency guarantees exist (X-ms inter-region and Y-ms within an availability-zone) by ensuring a fixed maximum diameter path between nodes.
- 2m nodes, 90k racks, 5k clusters, 250 DCs, 60 regions

#### The magic layer 2 scale sauce

- Layer 2 (data link) has inherent scalability problems (e.g., loops/STP, broadcasting) which traditional networks can tolerate. However, at hyper-scale simply does not work.
- Now what? Give up?
- Layer 2 communication must be sandboxed to small units.
- Layer 2 traffic is constrained to within the rack (i.e., the T0/ToR) and propagates no further.
- All communication from T0 and up is IP based (layer 3) routing.
- The magic of this design stems from the ToR/T0 router that lives within each rack. The ToR acts as a swtich to the nodes within its rack, but as a layer 3 router to everything above. Pretty cool right!




### Networking inside NT

The NT OS provides a number of abstractions.

1. The kernel `ntoskrnl.exe` interfaces and orchestrates with hardware, providing process governance etc.
2. TCP/IP layer implements RFCs and necessary glue to kernel to achieve them
3. AFD layer provides user-space application primitives

NDIS (network device interface specification) links the various layers together and provides a low level API for building network device drivers on top of. Can be thought of as a shim.




### Hyper-V Networking


Place marker: Rec6 00:04:14





## Network Emulators

To learn if you want to avoid cabling actual devices.

### MiniNet

### Cisco Packet Tracer

[Get it](https://skillsforall.com/resources/lab-downloads)
## Network Tools and Simulators

To learn if you want to avoid cabling actual devices.

- Cisco Packet Tracer
- Boson NetSim
- VIRL
- GNS3
- EVE-NG

## Cisco

Started life as purely a router company in 1984. IOS has been the OS driving these things ever since. Including the Catalyst switch range (Cresendo acquisition) and PIX firewall range (Network Translation acquisition).

IOS variations:

- NX-OS on the Nexus and MDS data center switches
- IOS-XR on service provider NCS, CRS, ASR9000 and XR12000 routers
- IOS-XE on ASR1000 series routers

### IOS shell

Shell modes:

- `hostname>` user exec mode
- `hostname#` privileged exec mode (`enable`)
- `hostname(config)#` global configuration mode (`configure terminal`)
- `hostname(config-if)#` interface configuration mode (`interface <if_id>`)

Prefix commands with `do` to avoid having to drop up/down into the correct shell mode.

Navigation:

- Abbreviation is supported everywhere, e.g. `en` = `enable`
- `exit` drops down a shell level (e.g., global configuration model to priviliged exec mode)
- `end` drop all the way down to priviliged exec mode
-

[Get it](https://www.eve-ng.net/)
Movement shortcuts:

- `ctrl-A` cursor to line begin
- `ctrl-E` cursor to line end
- `esc-F` move forward one word
- `esc-B` move backward one word
- `ctrl-P` previous command
- `ctrl-N` next command

Functional shortcuts:

- `ctrl-L` reprint line
- `ctrl-R` refresh
- `ctrl-C` exit command mode
- `ctrl-Z` run command and exit

Help:

- `?` help
- `sh?` commands that begin with `sh`
- `show ?` show nested-help for the `show` command
- `show ip ?` show nested-nested-help for the `show ip` command

Piped text processing:

- `show running-config interface FastEthernet0/0`
- `sh run | begin hostname`
- `show running-config | include FastEthernet0/0`
- `show running-config | exclude FastEthernet0/0`
- `show running-config | section interface`

### IOS configuration

Startup configuration lives on NVRAM and is persistent.

Runtime configuration however lives only in memory and is not persistent.

To save runtime configuration `copy running-config startup-config`

To factory reset `wr erase` or `erase startup-config` followed by `reload`

## Resources

- [CCNA Exam](https://www.cisco.com/c/dam/en_us/training-events/le31/le46/cln/marketing/exam-topics/200-301-CCNA.pdf)
- [Packet Tracer](https://skillsforall.com/resources/lab-downloads)

Chris Greer on TCP Fundamentals Part 1
https://www.youtube.com/watch?v=xdQ9sgpkrX8&t=536s
