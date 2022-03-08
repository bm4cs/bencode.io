---
layout: post
draft: false
title: "Cyber Defence Operations"
slug: "blueteam"
date: "2022-03-04 17:41:11+11:00"
lastmod: "2022-03-08 11:26:25+11:00"
comments: false
categories:
    - cyber
tags:
    - cyber
    - defensive
    - blueteam
    - threatmodels
    - vulnerabilities
    - university
    - networking
    - cisco
---

Semester 1 2022 has snuck up on me again. This semester as part of the UNSW and ADFA run [Master of Cyber Security](https://www.unsw.adfa.edu.au/study/postgraduate-coursework/master-cyber-security) degree, I'm taking the [blue team](https://en.wikipedia.org/wiki/Blue_team_%28computer_security%29) core unit _ZEIT8026 Cyber Defence - Network Security Operations (SecOps)_ lectured by [Dr Waqas Haider](https://www.linkedin.com/in/dr-waqas-haider-6a47b91b/) and [Dr Nour Moustafa](https://www.linkedin.com/in/dr-nour-moustafa-0a7a7859/). Unlike its sister [red team](https://en.wikipedia.org/wiki/Red_team) unit _ZEIT8020 Cyber Offense - Cyber Network Operations (CNO)_ which I took in 2018, ZEIT8026 aims to lay the foundational knowledge of cyber defence operations:

> Various cyber defence technologies will be covered to defend against modern cyber threats using existing defence tools and machine learning-enabled defence techniques. Security Information and Event Management (SIEM), firewalls, honeypots, Intrusion Detection Systems (IDS), Security Operation Centre (SOC) and Incident Response (IR) techniques and tools will be covered. This course will increase the competency of participants in building cyber defence within an organisation.

The unit looks terrific. 11 weeks of jam packed, fascinating topics around industry methodologies for threat and vulnerability modelling, to actual working practical knowledge including building a SIEM with Splunk, network packet tracing en mass and taking a scientific approach to finding anomalies and potential threat signatures by exploiting ML across the many data points that will be captured. Here's the modules:

-   [Network Security Operations](#network-security-operations)
    -   [Cyber Defence Foundations Gems](#cyber-defence-foundations-gems)
    -   [Cyber Defence Foundations Papers](#cyber-defence-foundations-papers)
    -   [Cisco IOS](#cisco-ios)
-   [Threat Modelling](#threat-modelling)
    -   [Threat Modelling Gems](#threat-modelling-gems)
    -   [Threat Modelling Papers](#threat-modelling-papers)
-   [Vulnerability Assessment](#vulnerability-assessment)
    -   [Vulnerability Assessment Gems](#vulnerability-assessment-gems)
    -   [Vulnerability Assessment Papers](#vulnerability-assessment-papers)
-   [Host and Network Security Monitoring](#host-and-network-security-monitoring)
-   [Data Collection and Analysis](#data-collection-and-analysis)
-   [Signature based defence](#signature-based-defence)
-   [Machine Learning for Cyber Defence](#machine-learning-for-cyber-defence)
-   [Machine Learning based Intrusion Detection](#machine-learning-based-intrusion-detection)
-   [Incident Response 1](#incident-response-1)
-   [Incident Response 2](#incident-response-2)
-   [SOC Insights](#soc-insights)

## Network Security Operations

TODO

-   The OSI network model is touched on (every single unit seems to do this). Waqas higlights that the physical layer is where most of the innovation is taking place, requiring deep domain knowledge in RF, electrical engineering, etc. The upper layers have been done to death.
-   [DeepSig](https://www.deepsig.ai/) is a world leading AI based wireless and RF signal detection company, with great resources such as YouTube channels.
-   Common network segregation techniques; _Zones_ to constrict access to groups of resources (data, applications), _Subnets_ constrict based on IP routing, and [VLANs](https://www.youtube.com/watch?v=fRuBHSf3Hac) constrict the Ethernet ports on a network switch that can exchange layer 2 frames.
-   Common network attacks; MAC flooding, VTP attacks, VLAN hopping

A forest from the trees overview of the broad field of SecOps:

-   Collect
    -   Network-based
        -   IDS
        -   Logs
    -   Host-based
        -   Logs
        -   IDS
-   Detect
    -   Anomaly
        -   Machine learning (ML)
        -   HoneyNet
        -   Honeytokens
    -   Reputation
        -   Signature
        -   IDS rules
        -   IOCs
-   Protect
    -   Prevent
        -   Whitelisting, patching
        -   Architecture
        -   Pen testing
    -   Limit impact
        -   Privilege restriction and zoning
        -   Backups
-   Respond
    -   Investigate
        -   Validation
        -   Correlation
    -   Remediate

#### Cyber Defence Foundations Gems

-   Cisco Packet Tracer on Windows. Actually mind blowing. A full blown network designer and emulator, including end point devices (NICs, operating systems), routers, switches, wireless devices, WAN emulation and more. You can cable between each device (e.g., copper crossover, copper straight-through, etc), bring up cisco shells on the routers and switches for advanced router configurations and setup fine grained subnets, IPs, VLANs, you name it. You can then jump on the end point hosts (e.g., windows or linux machines), start a shell up and trying exploring the route tables, ARP, `ping`, like you're on a full blown OS. For years I've wondered how networking people learn and play around with physical like networking techniques without having to setup physical devices. This is it! Insanely cool.
-   [Ettercap](https://www.ettercap-project.org/) is an amazing program for fooling around with common network protocols and services. Here we used it to perform a MITM attack by pretending to be a DHCP server (spoofing).
-   ARP poisoning with `arpspoof`. Enough said: `arpspoof -i eth0 -t 10.1.1.12 10.1.1.228` (`-t` being the target host to ARP poison). Dump the ARP tables on the various targets e.g., on windows `arp -a`. Quite an effective MITM technique for siphoning frames between hosts, assuming you forward everything on so it appears legitimate.
-   [Cyber Ben-Gurion University of the Negev: Air Gap Research by Dr Mordechai Guri](https://cyber.bgu.ac.il/air-gap/): An Israel uni that is publishing some incredible research in the field of signal detection and intelligence, in the space of air-gapping (a common technique employed by highly secure organisations). Great videos on PowerHammer (power line based signals), MOSQUITO (acoustic speaker to speaker communication between air gapped computers), ODINI (leaking data from a Faraday cage) and many more.
-   [tyranid/ExampleChatApplication](https://github.com/tyranid/ExampleChatApplication) a simple example command line chat application written for .NET to learn network protocol analysis, great for messing around with packet analysers like `tcpdump` or `wireshark`
-   [SWAN: Secure Wireless Agile Networks](https://www.swan-partnership.ac.uk/research-challenges/): A cool company based in the UK, that is pushing the boundaries of what is currently accepted the norm in terms of RF based network systems. They are sponsoring a number of PhD opportunities.
-   [SBIR: Cyber Vulnerabilities and Mitigations in the Radio Frequency Domain](https://www.sbir.gov/node/1208173): Great paper from the American governments Small Business Innovation Research incubator.
-   [DeepSig Inc: Wireless Threat Detection and Analytics](https://www.deepsig.ai/threat-warning-analytics): OmniSIG Sensor makes it possible to rapidly detect emitters across a wide range of bands and emitter types while on small or mobile platforms or while deployed on radio infrastructure devices making it an ideal enabler for coverage mapping, usage mapping, interference hunting, unauthorized emitter hunting, cyber-threat detection, and other mobile mapping applications

#### Cyber Defence Foundations Papers

-   [Novokhrestov, A., Konev, A., Shelupanov, A. and Buymov, A., 2020, March. Computer network threat modelling. In Journal of Physics Conference Series (Vol. 1488, p. 012002)](/papers/security/defensive/Novokhrestov_2020_ComputerNetworkThreatModelling.pdf)
-   [Bakhshi, Z., Balador, A. and Mustafa, J., 2018, April. Industrial IoT security threats and concerns by considering Cisco and Microsoft IoT reference models. In 2018 IEEE Wireless Communications and Networking Conference Workshops (WCNCW) (pp. 173-178). IEEE.](/papers/security/defensive/Bakhshi_2018_IndustrialInternetOfThingsSecurityThreatsByConsideringCiscoAndMicrosoftReferenceModels.pdf)
-   [Qian, K., Parizi, R.M. and Lo, D., 2018, December. OWASP Risk Analysis Driven Security Requirements Specification for Secure Android Mobile Software Development. In 2018 IEEE Conference on Dependable and Secure Computing (DSC) (pp. 1-2). IEEE.](/papers/security/defensive/Qian_2018_OWASPRiskAnalysisDrivenSecurityRequirementsForSecureAndroidMobileSoftware.pdf)

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

#### Threat Modelling Gems

-   [OWSAP Threat Dragon](https://threatdragon.github.io/) an open-source threat modelling tool from OWASP. In a nutshell creates threat model diagrams as part of a secure SDLC. Model an applications architecture visually, the stores, actors, processes, data flows and trust boundaries. Record possible threats and the decided mitigations. Visually models the threat model components and threat surfaces. Generates reports. Supports the [STRIDE](http://TODO), [CIA]() and [LINDDUN]() methodologies.
-   [Microsoft Threat Modeling Tool](https://docs.microsoft.com/en-us/azure/security/develop/threat-modeling-tool) allows software architects to identify and mitigate potential security issues early, when they are relatively easy and cost-effective to resolve. It was designed with non-security experts in mind, making threat modeling easier for all developers by providing clear guidance on creating and analysing threat models.
-   [MITRE StixViz](https://github.com/STIXProject/stix-viz) an open-source threat modelling and visualisation tool by MITRE Corporation, visualises Structured Threat Information eXpression (STIX) documents as a node-link tree with the root at the top of the XML structure.

#### Threat Modelling Papers

-   [Moustafa, N., Adi, E., Turnbull, B., & Hu, J. (2018). A new threat intelligence scheme for safeguarding industry 4.0 systems. IEEE Access, 6, 32910-32924.](/papers/security/defensive/Moustafa_2018_ANewThreatIntelligenceSchemeForSafeguardingIndustry4Systems.pdf)
-   [Al-Hawawreh, M., Moustafa, N., Garg, S., & Hossain, M. S. (2020). Deep Learning-enabled Threat Intelligence Scheme in the Internet of Things Networks. IEEE Transactions on Network Science and Engineering.](/papers/security/defensive/Al-Hawawreh_2020_DeepLearningEnabledThreatIntelligenceSchemeInTheInternetOfThingsNetworks.pdf)

## Vulnerability Assessment

Identification of the vulnerabilities that exist in a computing system, triages and ranks based on risk and recommends remediation that balances constraints (e.g., environment, design, cost, return on investment).

1. Vulnerability Identification; two broad categories known and unknown
2. Analysis
3. Risk assessment
4. Remediation

In terms of the [MITRE ATT&CK framework](https://attack.mitre.org/) vulnerability assessment falls into stage 1, the Reconnaissance stage:

1. Reconnaissance
1. Resource Development
1. Initial Access
1. Execution
1. Persistence
1. Privilege Escalation
1. Defense Evasion
1. Credential Access
1. Discovery
1. Lateral Movement
1. Collection
1. Command and Control
1. Exfiltration
1. Impact

Types of scanning:

-   Basic audit scans; such as in Australia the Information Security Manual (ISM), ISO 27001, PCI DSS
-   Managed security scans; automated software based solutions
-   In-depth scans; pen testing

Other noteworthy:

-   Hunt teams are a recent movement, in which dedicated specialist team embedded within an organisation leverage data science, ML, big data to proactively and creatively look for anamoloies and threat signatures. As threats are
-   Classification of vulnerabilities; host, network, application, active or passive, in-house vs outsourced, internal vs external

Basic tools of the trade in this realm:

-   `nmap` basics. Again most units in this degree include this.
    -   `nmap -sP` ICMP echo scan, failing hosts are picked up in ARP table
    -   `nmap -sU` layer 4 UDP scan (port knock)
    -   `nmap -sS` layer 4 TCP SYN scan (port knock)
    -   `nmap -sV` tries to service fingerprint based on known signatures
-   [Tenable Nessus](https://www.tenable.com/products/nessus) a closed-source vulnerability scanner by tenable. They are a world leader in this space for a reason, amazing.
-   [Burb Suite](https://portswigger.net/burp) the leading web security and penetration testing toolkit. Great features such as a MITM proxy that you can configure your browsers to tunnel traffic through.
-   [OWASP ZAP](https://www.zaproxy.org/) the famous ZAP (Zed Attack Proxy) tool by OWASP. The world’s most widely used web app scanner. Free and open source. Actively maintained by a dedicated international team of volunteers.
-   [Nikto]() or closed-source version [Netsparker]()
-   [skipfish](https://www.kali.org/tools/skipfish/)

#### Vulnerability Assessment Gems

-   [Damn Vulnerable Web App](https://github.com/digininja/DVWA) a PHP/MySQL web application that is damn vulnerable. Its main goal is to be an aid for security professionals to test their skills and tools in a legal environment, help web developers better understand the processes of securing web applications and to aid both students & teachers to learn about web application security in a controlled class room environment.
-   [OWASP Risk Rating Methodology](https://owasp.org/www-community/OWASP_Risk_Rating_Methodology)
-   [NIST 800-30 - Guide for Conducting Risk Assessments](https://csrc.nist.gov/publications/detail/sp/800-30/rev-1/final)
-   [Government of Canada - Harmonized TRA Methodology](https://cyber.gc.ca/en/guidance/harmonized-tra-methodology-tra-1)
-   [Mozilla Risk Assessment Summary](https://infosec.mozilla.org/guidelines/assessing_security_risk)
-   [Mozilla Rpaid Risk Assessment (RRA)](https://infosec.mozilla.org/guidelines/risk/rapid_risk_assessment.html)

#### Vulnerability Assessment Papers

-   [Easttom, Chuck. "Vulnerability Assessment and Management." In The NICE Cyber Security Framework, pp. 241-258. Springer, Cham, 2020.](/papers/security/defensive/Easttom_2020_NICECyberSecurityFramework_VulnerabilityAssessmentAndManagement.pdf)

## Host and Network Security Monitoring

Coming soon.

## Data Collection and Analysis

Coming soon.

## Signature based defence

Coming soon.

## Machine Learning for Cyber Defence

Coming soon.

## Machine Learning based Intrusion Detection

Coming soon.

## Incident Response 1

Coming soon.

## Incident Response 2

Coming soon.

## SOC Insights

Coming soon.
