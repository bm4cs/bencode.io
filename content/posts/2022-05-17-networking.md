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
  - [Layer 2 (Link)](#layer-2-link)
    - [Layer 2 (Link) Protocols](#layer-2-link-protocols)
  - [Layer 3 (Network)](#layer-3-network)
    - [Layer 3 (Network) Protocols](#layer-3-network-protocols)
  - [Layer 4 (Transport)](#layer-4-transport)

## Overview

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
