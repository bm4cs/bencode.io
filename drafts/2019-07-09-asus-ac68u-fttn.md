---
layout: post
title: "Asus DSL-AC68U on NBN FTTN"
date: "2019-07-09 19:20:10"
comments: false
categories:
- general
tags:
- hardware
---

The [DSL-AC68U](https://www.asus.com/au/Networking/DSLAC68U/) ADSL/VDSL router is a solid choice, and supports a range of WAN based protocols.

> Compatible with ADSL2/2+, ADSL, VDSL2, fiber and cable services

It works great with NBN FTTN (fibre to the node), see required configuration below.

Go to Administration > **DSL**:

* DSL Modulation: VDSL2
* ANNEX Mode: Annex A/I/J/L/M
* Dynamic Lice Adjustment (DLA): Enabled
* SRA (Seamless Rate Adaptation): Enabled
* G.INP (G.998.4): Enabled *important: port will be blocked*

**VDSL Settings**:

* VDSL Profile: 17a multi mode
* Stability Adjustment: Disabled
* Rx AGC Gain Adjustment: Default
* UPBO – Upstream Power Back Off: Enabled
* ESNP – Enhanced Sudden Noice Protection: Default
* Bitswap: Enabled
* G.vector (G.993.5): Enabled *important: port will be blocked*
* Non-standard G.Vector (G.993.5): Disabled

Go to **WAN**:

Set WAN Type to DSL and VDSL WAN (PTM)
Click on the 'Edit PVC' option:

* WAN Connection Type – Automatic IP
* Enable WAN – Yes
* Enable NAT – Yes
* Enable UpnP – Yes

**802.1Q**:

* Enable – No
* VLAN 0
* 802.1P 0

Reboot the modem. Once rebooted, connect phone line.
