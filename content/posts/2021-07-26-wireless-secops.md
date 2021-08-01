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
    * [Wireless protocol issues](#wireless-protocol-issues)
    * [Types of wireless](#types-of-wireless)
    * [The Wi-Fi protocol](#the-wi-fi-protocol)
    * [Wi-Fi security mechanisms](#wi-fi-security-mechanisms)
        * [WEP](#wep)
        * [WPA](#wpa)
        * [WPA2](#wpa2)
    * [Wi-Fi attacks](#wi-fi-attacks)
* [WiFi defences](#wifi-defences)
    * [Client protections](#client-protections)
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

Any form of communication between two points that are not physically connected; radio, light/laser, sonic, electromagnetic induction.

Wireless brings with it major security concerns; around confidentiality, integrity and availability. That is:

- Its noisy - prone to DoS
- Unlike a physical medium such as cable, is not guaranteed to go where you intend - prone to interception (passive)
- Has an obvious source - can be determined through triangulation
- Hard to validate the signal source - prone to active interception i.e. MITM, spoofing, replay attacks

## Wireless protocol issues

A *protocol* is the standard set of communication structures and states - like a language.

Security issues can arise in the standard (such as 802.11g) or its implementation.

## Types of wireless

- Personal Area Networks (PAN) - low power, 1-10 metre range
- Local Area Networks (LAN) - intermediate range, 10-200 metre
- Metropolitan Area Networks (MAN) - long distance
- Terrestrial Area Networks (TAN) - extreme distance

## The Wi-Fi protocol

Wi-Fi coined as Wireless Fidelity, was initially rolled in the late 90's under the alias of 802.11.

Three frame types:

1. [Control frames](https://supportforums.cisco.com/document/52391/80211-frames-starter-guide-learn-wireless-sniffer-traces) aid in the delivery of data frames - power-save poll, request-to-send, clear-to-send, acknowledgements
2. [Management frames](https://supportforums.cisco.com/document/52391/80211-frames-starter-guide-learn-wireless-sniffer-traces) connection establishment and maintenance - probe, association, beacon, action
3. *Data frames* the actual data itself

Historically there is only support for encrypting data frames. 802.11AC allow for crypto of control and management frames.

## Wi-Fi security mechanisms

### WEP

The original 802.11 implementation, superseded in 2003. Offered 64 or 128 bit RC4 cipher. 64-bit uses a 40-bit key with a 24-bit initialisation vector (IV) while 128-bit used a 104-bit key with a 24-bit IV.

WEP had two authentication types, **shared key** and **open system**.

In shared key, a 4 step challenge-response handshake takes place:

1. Client sends auth request to AP
2. AP responds with challenge (plain text)
3. Client encrypts challenge with WEP key and sends it in another auth request.
4. AP confirms decrypted challenge matches.
5. WEP key is the used for encypting data frames.

In open system mode, the WEP key in not used as part of the auth process, only for encrypting the data frames. Any client can auth, but only those with the correct key can encrypt/decrypt.

### WPA

In response to WEP being broken and hardware based. 802.11i was too far away from being feasible.

WPA was born, offering two modes; **pre-shared** key (personal) and **enterprise**.

Unlike WEP offers per-packet integrity and keying for traffic keys.

A WPA passphrase is a product of the ESSID and password, and can be collected via a listening device (would need to collect a handshake for a new connection or a re-authenticate).

Rainbow tables for common SSID/password combos.

### WPA2

The full security product, envisioned in 802.11i.

Uses AES in block cipher mode.

The main key is used to make a session key. This prevents loss of the main key, if session traffic is comprimised.

Extensible Authentication Protocol (EAP) provides pluggable authentication types:

- EAP-TLS
- PEAP
- EAP-MD-5

## Wi-Fi attacks

On the protocols:

- WEP - issues with RC4 stream cipher, stream ciphers require a constant changing running key, if key never changes there is a greater opportunity to reverse it, as highlighted by [Fluher, Mantin and Shamir](http://www.crypto.com/papers/others/rc4_ksaproc.pdf) in 2001.
- WPA and WPA2 - much stronger, clients assume APs with same SSID are part of the same network backbone, its possible to add a malicious AP close by to try to collect clients from a legitimate source. Pre-shared key derives key from SSID and passphrase, using a network capture, its possible to brute-force a simple key - known SSID's and passwords can be generated in advance (rainbow tables available for common SSID).
- SSID hiding
- WPS - wifi protected setup provides a convenient method for onboarding clients, often cant be disabled, one vector is the *external register* that only requires the routers 8 digit PIN, when a PIN auth fails a `EAP-NACK` is sent back to the client. Sadly `EAP-NACK` messages are sent in such a way that an attacker can determine if the first half of the PIN is correct! The last digit is a given, because its a checksum. This greatly wittles the attemps from 10^8, down to 10^4 + 10^3 = 11K attempts
- Cleartext management frames - possible to manipulate these control and management frames to spoof connected devices, most common is the **deauth** to deauthenticate existing clients

Cross cutting vectors:

- Attacks on AP's - data santisation issues around data elements in the frames themselves, or even with [SSID names](http://www.cvedetails.com/cve/CVE-2013-1131/), attacks on the administrative interface (HTTP, FTP, SSH, telnet), firmware family attacks such as heartbleed
- Fake services - promicuious clients that will connect to unsecured services e.g. *Free McDonalds WiFi*, users expect to see an HTTP portal which in turn MSF payloads could be deployed, if a network has the same SSID clients will automatically migrate over if the signal is stronger presenting the opportunity to steal clients
- Rogue AP's - an AP installed on a network without the knowledge of network admins, hide in plain sight (same model and location as existing devices), hidden taped under desks or behind wall plugs, use a software AP
- Attacks on connected clients - wifi clients can be visible to each other, potential to join a network and attack other connected clients
- MAC location tracking - disconnected clients periodically send out probes for existing networks they know, this traffic can be monitored and triangulated to determine its location. The list of *favourite networks* is leaked and can be used. Tools can respond to these probe requests, which in turn triggers the set up of a network, the client joins and can then be exploited.


# WiFi defences

To defend can think across the client, protocol and network itself.

## Client protections

- Don't use wireless - specialised detectors, sweeps, active knowledge of connected devices
- Don't connect to random wireless networks - clean out preferred network list
- Disable WiFi when not required
- Modern mobile devices (post 2014) will send probe requests with a random MAC - this is only done for connecting, so address filtering not broken
- Don't use WEP
- Don't use WPA
- Pre-shared keys are brute force attackable - don't allow this, by using strong passphrase and SSID's that are less common
- Encrypted management frames - 802.11AC introduced some support for this, however the following are not encrypted; probe request and responses, association requets and responses - this prevents deauth attacks
- Enterprise wireless - in a better state due to more infrastructure and less focus on convenience
- Perform network discovery and site surveying to baseline landscape for a SOC, understand changes to clients overtime, such as Ekahau and Kismet
- Geo fencing involves deriving geographic bound on wireless clients - using the received signal strength indicator (RSSI) can approximate distance to client, unfortunately a single AP has no concept of direction with a standard antenna, however using three APs spread apart one can pinpoint geo location.
- WiFi Aware paired with 802.11AC which uses multiple antennas - makes it possible to stop devices from being authorised (however does not stop passive interception).
- Wireless Intrusion Detection System (wIDS) - system that blocks anomalous wireless behaviour, which can include RSSI and geo markers - detectable behaviour rogue APs within the physical buildings, AP's using the same SSID, use of active discovery tools, multiple devices at different locations with same username/password, 
- Fake AP - hide real APs in the noise




# Cool resources

- [Great Scott Gadgets - Software Defined Radio Lession 1](https://greatscottgadgets.com/sdr/1/)
- [HackRF - open source hardware and software designs for an SDR](https://github.com/mossmann/hackrf)
- [ESP8266 microcontroller](https://www.jaycar.com.au/wifi-mini-esp8266-main-board/p/XC3802) $5 wifi microcontroller
- [Matthew Garrett Amazon Security Teardowns](https://mjg59.dreamwidth.org/) robust example of security teardown
- Rainbow tables of common ESSID/password combinations
- Network discovery tools *Active*: netstumbler, kismax, istumbler *Passive*: aircrack-ng, kismet, ettercap, tcpdump
- [WiGLE](https://www.wigle.net/) consolidated information of wireless networks world-wide in a central DB
- [OverTheWire](https://overthewire.org/wargames/) help you to learn and practice security concepts in the form of fun-filled games
- [Sysinternal PsTools](https://docs.microsoft.com/en-au/sysinternals/downloads/pslist) a collection of low level system utilities for Windows NT
- [ACMA Australian radiofrequency spectrum allocations chart](https://www.acma.gov.au/sites/default/files/2019-10/Australian%20radiofrequency%20spectrum%20allocations%20chart.pdf)
- [CIA triad]() general purpose risk assessment fy.com.au
ramework
