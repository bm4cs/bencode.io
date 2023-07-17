---
layout: post
draft: false
title: "Information Assurance"
slug: "infoassurance"
date: "2023-03-04 13:22:36+11:00"
lastmod: "2023-03-04 13:22:36+11:00"
comments: false
categories:
  - cyber
tags:
  - cyber
  - defensive
  - blueteam
  - threats
  - vulnerabilities
  - university
---

Kicking off the 2023 University year I continue my journey into the Cybersecurity Masters program with unit [Infomation Assurance and Security](https://legacy.handbook.unsw.edu.au/postgraduate/courses/2018/ZEIT8021.html) run by [Michael McGarity](m.mcgarity@adfa.edu.au) and [Huadong Mo](huadong.mo@adfa.edu.au).

> Provides students with a deep understanding of the technical, management and organisational aspects of Information Assurance within a holistic legal and social framework.

The course is essentially modelled off the [CISSP certification](https://www.isc2.org/Certifications/CISSP#), which dives into the following subjects:

- make a realistic assessment of the needs for information security in an organisation
- discuss the implications of security decisions on the organisation's information systems
- understand the principles of writing secure code
- show an understanding of database and network security issues
- demonstrate an understanding of encryption techniques
- understand foundations of the tools and techniques in computer forensics
- show an appreciation of the commercial, legal and social context in which IT security is implemented
- apply knowledge gained to business and technical IA scenarios

## Intro

Not a one size fits all approach. Too many factors and seemingling chaotic variables, such as risk appetites, country legislation, the business vertical (mining vs banking vs government), acceditation frameworks that apply to certain industries, tolerances, technology limitations, and so on.

The systems engineering "V" provides a useful structured approach to building a complex system, integrating it and validating it. Security can be integrated at every stage in the "V", from high level architecture, component designs, software development, security unit testing (such as fuzzing), validating common vectors, ensuring that security mechanisms are effective such as anomogy detection systems.

## Risk management

### Risk and the CIA Triad

The CIA triad:

- Confidentiality: Only authorised entities have access to the data (e.g. lock on a safe provides
  confidentiality, encryption on block device)
- Integrity: there are no unauthorised modifications of the data (e.g. version control
  provides integrity)
- Availability: Authorised entities can access the data when and how they are permitted to do so (e.g. backups provide
  availability)

There is a <likelihood/probability> that a <threat> will exploit a <vulnerability> to <impact> an <asset>. We don’t
want this to happen so we introduce a <mitigation/control> which reduces the likelihood and/or impact resulting in an
acceptable <residual risk>.

Risk likelihood is typically quantified according to three factors:

1. Impact: Size of the effect on the asset
2. Likelihood: Probability of the threat being able to exploit the vulnerability
3. Exposure: Percentage of the asset exposed to the threat

Two common methods:

– Qualitative:
– Quantitative

### Threats

- Any aspects that create a risk to the organisation, its function, and its assets
- By Origin: Natural, Criminal, User error
- By Target
  – Hardware: Theft, Natural disaster, Fire, Bad batch
  – Software: Defects, Lack of security, Malware
  – Services: DoS/DDOS, “Man-in-the-middle”, Social engineering

### Threat Modelling

_Threat modelling_ is looking at an environment, system, or application from an attacker’s viewpoint and trying to determine vulnerabilities the attacker would exploit

Many techniques are availabile:

– Microsoft mnemonic STRIDE = Spoofing, Tampering, Repudiation, Information disclosure, Denial of Service, Elevation of privilege
– Operationally critical threat, asset and vulnerability evaluation (OCTAVE)
– Trike threat modelling. Development of data flow diagrams, use/misuse cases

_Vulnerabilities_ are any aspects of the organisation’s operation that could enhance a risk or the possibility of a risk being
realised, e.g.:
– Software
– Physical
– Personnel

## Network Security

IEC/ISO 7498 (Open Systems Interconnection — Basic Reference Model: The Basic Model)

This hinges on the 7-layer OSI networking model. PDNTSPA (Please Do Not Throw Sausage Pizza Away).

- L7 Application: Human supported messaging. DHCP, LDAP, HTTP, DNS, SNMP, VNC,
- L6 Presentation: Encoding methods (ASCII, UTF-8, unicode)
- L5 Session: Persistent connections between hosts. Protocols; PAP (password authentication protocol), CHAP, PPTP (point to point tunneling), RPC. ISO 7498 states no security services are provided in the session layer.
- L4 Transport: Segments. Streaming and end-to-end delivery guarantees, introduces ports. UDP and TCP.
- L3 Network: Packets. Logical addressing for unicast, multicast, anycast and broadcast interactions. Common protocols; IPv4, IPv6, ICMP, IGMP, OSPF (network size of shape discovery and mapping). Devices; routers, firewalls, NGFW
- L2 Data link: Frames. MAC, ARP, MPLS, spanning tree protocol (STP), multicast, switches, VLANs, flooding, spoofing,
- L1 Physical:

## Key takeaways

In a nutshell:

- This could easily be run as a one or two day course
- Standards (e.g. ISO27002) provide the breadth needed to tackle the overwhelming job of securing an organisation
- Control frameworks (e.g. ISM, NIST 800-53) compliment risk frameworks, by providing a catalog of concrete security and privacy controls
- Domain specific frameworks (e.g. NIST AI 100-1 for Artificial Intelligence Risk Management Framework) provide depth to an overall security strategy and plan
- Practices such as zero trust and defence in depth can be useful
