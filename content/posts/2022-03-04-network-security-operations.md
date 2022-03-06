---
layout: post
draft: false
title: "Network Security Operations (SecOps)"
slug: "secops"
date: "2022-03-04 17:41:11+11:00"
lastmod: "2022-03-04 17:41:16+11:00"
comments: false
categories:
    - cyber
tags:
    - cyber
    - defensive
    - blueteam
    - university
    - networking
    - cisco
---

Semester 1 2022 has snuck up on me again. This semester as part of the UNSW and ADFA run [Master of Cyber Security](https://www.unsw.adfa.edu.au/study/postgraduate-coursework/master-cyber-security) degree, I'm taking the [blue team](https://en.wikipedia.org/wiki/Blue_team_%28computer_security%29) core unit _ZEIT8026 Cyber Defence - Network Security Operations (SecOps)_ lectured by [Dr Waqas Haider](https://www.linkedin.com/in/dr-waqas-haider-6a47b91b/) and [Dr Nour Moustafa](https://www.linkedin.com/in/dr-nour-moustafa-0a7a7859/). Unlike its sister [red team](https://en.wikipedia.org/wiki/Red_team) unit _ZEIT8020 Cyber Offense - Cyber Network Operations (CNO)_ which I took in 2018, ZEIT8026 aims to lay the foundational knowledge of cyber defence operations:

> Various cyber defence technologies will be covered to defend against modern cyber threats using existing defence tools and machine learning-enabled defence techniques. Security Information and Event Management (SIEM), firewalls, honeypots, Intrusion Detection Systems (IDS), Security Operation Centre (SOC) and Incident Response (IR) techniques and tools will be covered. This course will increase the competency of participants in building cyber defence within an organisation.

The unit looks terrific. 11 weeks of jam packed, fascinating topics around industry methodologies for threat and vulnerability modelling, to actual working practical knowledge including building a SIEM with Splunk, network packet tracing en mass and taking a scientific approach to finding anomalies and potential threat signatures by exploiting ML across the many data points that will be captured. Here's the modules:

* [Cyber Defence Foundations](#cyber-defence-foundations)
* [Threat Modelling](#threat-modelling)
* [Vulnerability Assessment](#vulnerability-assessment)
* [Host and Network Security Monitoring](#host-and-network-security-monitoring)
* [Data Collection and Analysis](#data-collection-and-analysis)
* [Signature based defence](#signature-based-defence)
* [Machine Learning for Cyber Defence](#machine-learning-for-cyber-defence)
* [Machine Learning based Intrusion Detection](#machine-learning-based-intrusion-detection)
* [Incident Response 1](#incident-response-1)
* [Incident Response 2](#incident-response-2)
* [SOC Insights](#soc-insights)


## Cyber Defence Foundations

Summary:

- The OSI network model is touched on (every single unit seems to do this). Waqas higlights that the physical layer is where most of the innovation is taking place, requiring deep domain knowledge in RF, electrical engineering, etc. The upper layers have been done to death.
- DeepSig is a world leading AI based RF detection company, with great resources such as YouTube channels.
- Common network segregation techniques; *Zones* to constrict access to groups of resources (data, applications), *Subnets* constrict based on IP routing, and [VLANs](https://www.youtube.com/watch?v=fRuBHSf3Hac) constrict the Ethernet ports on a network switch that can exchange layer 2 frames.
- Common network attacks; MAC flooding, VTP attacks, VLAN hopping

#### Network Security Operations (SecOps)

A forest from the trees overview of the broad field of SecOps:

- Collect
    - Network-based
        - IDS
        - Logs
    - Host-based
        - Logs
        - IDS
- Detect
    - Anomaly
        - Machine learning (ML)
        - HoneyNet
        - Honeytokens
    - Reputation
        - Signature
        - IDS rules
        - IOCs
- Protect
    - Prevent
        - Whitelisting, patching
        - Architecture
        - Pen testing
    - Limit impact
        - Privilege restriction and zoning
        - Backups
- Respond
    - Investigate
        - Validation
        - Correlation
    - Remediate

#### Gems

- Cisco Packet Tracer on Windows. Actually mind blowing. A full blown network designer and emulator, including end point devices (NICs, operating systems), routers, switches, wireless devices, WAN emulation and more. You can cable between each device (e.g., copper crossover, copper straight-through, etc), bring up cisco shells on the routers and switches for advanced router configurations and setup fine grained subnets, IPs, VLANs, you name it. You can then jump on the end point hosts (e.g., windows or linux machines), start a shell up and trying exploring the route tables, ARP, `ping`, like you're on a full blown OS. For years I've wondered how networking people learn and play around with physical like networking techniques without having to setup physical devices. This is it! Insanely cool.
- [Cyber Ben-Gurion University of the Negev: Air Gap Research by Dr Mordechai Guri](https://cyber.bgu.ac.il/air-gap/): An Israel uni that is publishing some incredible research in the field of signal detection and intelligence, in the space of air-gapping (a common technique employed by highly secure organisations). Great videos on PowerHammer (power line based signals), MOSQUITO (acoustic speaker to speaker communication between air gapped computers), ODINI (leaking data from a Faraday cage) and many more.
- [SWAN: Secure Wireless Agile Networks](https://www.swan-partnership.ac.uk/research-challenges/): A cool company based in the UK, that is pushing the boundaries of what is currently accepted the norm in terms of RF based network systems. They are sponsoring a number of PhD opportunities.
- [SBIR: Cyber Vulnerabilities and Mitigations in the Radio Frequency Domain](https://www.sbir.gov/node/1208173): Great paper from the American governments Small Business Innovation Research incubator.
- [DeepSig Inc: Wireless Threat Detection and Analytics](https://www.deepsig.ai/threat-warning-analytics): OmniSIG Sensor makes it possible to rapidly detect emitters across a wide range of bands and emitter types while on small or mobile platforms or while deployed on radio infrastructure devices making it an ideal enabler for coverage mapping, usage mapping, interference hunting, unauthorized emitter hunting, cyber-threat detection, and other mobile mapping applications


#### Cisco IOS

Getting to play with the internals of Cisco routers and switches has been a blast. These devices run Cisco's IOS (Internetwork OS). As a user of IOS get to use a high-level shell when on the devices. For example, here I configure a specific Ethernet port on a [Cisco Catalyst Ws-C2960-24TT switch](https://www.cisco.com/c/en/us/support/switches/catalyst-2960-series-switches/series.html) to prevent MAC address flooding by configuring the specific port to learn the connected clients MAC (sticky) and enforce it:

```
Switch#conf t
Enter configuration commands, one per line. End with CNTL/Z.
Switch(config)#int FastEthernet0/1
Switch(config-if)#switchport mode access
Switch(config-if)#switchport port-security
Switch(config-if)#switchport port-security maximum 1
Switch(config-if)#switchport port-security mac-address sticky
Switch(config-if)#switchport port-security violation shutdown
Switch(config-if)#end
```

Verify configuration is persistent:

```
Switch#show port-security
Secure Port MaxSecureAddr CurrentAddr SecurityViolation Security Action
               (Count)      (Count)        (Count)
---------------------------------------------------------------
        Fa0/1        1         0                 0          Shutdown
-----------------------------------------------------------------

Switch#show port-security interface fa0/1
Port Security              : Enabled
Port Status                : Secure-up
Violation Mode             : Shutdown
Aging Time                 : 0 mins
Aging Type                 : Absolute
SecureStatic Address Aging : Disabled
Maximum MAC Addresses      : 1
Total MAC Addresses        : 0
Configured MAC Addresses   : 0
Sticky MAC Addresses       : 0
Last Source Address:Vlan   : 0000.0000.0000:0
Security Violation Count   : 0
```

Before any packets have flowed through the switch, can see it hasn't learned any MACs yet:

```
Switch#show mac-address-table 
Mac Address Table
------------------------------------------
Vlan    Mac Address      Type        Ports
----    -----------      ----        -----
   1    0001.9780.1134   DYNAMIC     Gig0/1
```

After pushing some ICMP echo packets (`ping`) from the connected client computer through the switch to the router, can see it learns the MAC of the client (`0009.7c41.3c61`) that is connected to the specific Ethernet jack on the switch:

```
Switch#show mac-address-table 
Mac Address Table
------------------------------------------
Vlan    Mac Address      Type        Ports
----    -----------      ----        -----
   1    0001.9780.1134   DYNAMIC     Gig0/1
   1    0009.7c41.3c61   STATIC      Fa1/1
```

The test. Unplug the first test host from the switch port. Plug a new host (i.e., with a different MAC) into the same switch port and try to `ping` the router on the other side of the switch. The switch will immediately shut the port down:

```
Switch#show port-security interface fa0/1
Port Security              : Enabled
Port Status                : Secure-down
Violation Mode             : Shutdown
Aging Time                 : 0 mins
Aging Type                 : Absolute
SecureStatic Address Aging : Disabled
Maximum MAC Addresses      : 1
Total MAC Addresses        : 1
Configured MAC Addresses   : 0
Sticky MAC Addresses       : 1
Last Source Address:Vlan   : 00E0.8FEB.D146:1
Security Violation Count   : 1
```

## Threat Modelling


## Vulnerability Assessment


## Host and Network Security Monitoring

PCAPs. Splunk.


## Data Collection and Analysis

AI and ML.

## Signature based defence

AI and ML.

## Machine Learning for Cyber Defence


## Machine Learning based Intrusion Detection


## Incident Response 1


## Incident Response 2


## SOC Insights


