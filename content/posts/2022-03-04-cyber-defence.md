---
layout: post
draft: false
title: "Cyber Defence Operations"
slug: "blueteam"
date: "2022-03-04 17:41:11+11:00"
lastmod: "2022-04-17 20:35:19+11:00"
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

- [1 Cyber Defence Foundations](#1-cyber-defence-foundations)
    - [1.1 Cyber Defence Foundations Gems](#11-cyber-defence-foundations-gems)
    - [1.2 Cyber Defence Foundations Papers](#12-cyber-defence-foundations-papers)
    - [1.3 Cisco IOS](#13-cisco-ios)
- [2 Threat Modelling](#2-threat-modelling)
    - [2.1 Threat Modelling Gems](#21-threat-modelling-gems)
    - [2.2 Threat Modelling Papers](#22-threat-modelling-papers)
- [3 Vulnerability Assessment](#3-vulnerability-assessment)
    - [3.1 Vulnerability Assessment Gems](#31-vulnerability-assessment-gems)
    - [3.2 Vulnerability Assessment Papers](#32-vulnerability-assessment-papers)
- [4 Host and Network Security Monitoring](#4-host-and-network-security-monitoring)
    - [4.1 Host and Network Security Gems](#41-host-and-network-security-gems)
    - [4.2 Host and Network Security Papers](#42-host-and-network-security-papers)
- [5 Data Collection and Analysis](#5-data-collection-and-analysis)
    - [5.1 Data Collection and Analysis Gems](#51-data-collection-and-analysis-gems)
    - [5.2 Data Collection and Analysis Papers](#52-data-collection-and-analysis-papers)
- [6 Signature based defence](#6-signature-based-defence)
    - [6.1 Signature based defence Gems](#61-signature-based-defence-gems)
    - [6.2 Signature based defence Papers](#62-signature-based-defence-papers)
- [7 Machine Learning for Collection and Detection](#7-machine-learning-for-collection-and-detection)
    - [7.1 Machine Learning for Collection and Detection Gems](#71-machine-learning-for-collection-and-detection-gems)
      - [7.1.1 Creating custom Snort rules](#711-creating-custom-snort-rules)
      - [7.1.2. Crafting packets with scapy](#712-crafting-packets-with-scapy)
      - [7.1.3 Using Security Onions MySQL DB of raw events](#713-using-security-onions-mysql-db-of-raw-events)
    - [7.2 Machine Learning for Collection and Detection Papers](#72-machine-learning-for-collection-and-detection-papers)
- [8 Machine Learning based Intrusion Detection](#8-machine-learning-based-intrusion-detection)
    - [8.1 Machine Learning based Intrusion Detection Gems](#81-machine-learning-based-intrusion-detection-gems)
      - [8.1.1 Using scikit-learn to mop up data (imputation)](#811-using-scikit-learn-to-mop-up-data-imputation)
      - [8.1.2 Data pre-processing (munging) basics for ML using Python](#812-data-pre-processing-munging-basics-for-ml-using-python)
      - [8.1.3 Label Encoding using Python and scikitlearn](#813-label-encoding-using-python-and-scikitlearn)
      - [8.1.4 One Hot Encoding using Python and pandas](#814-one-hot-encoding-using-python-and-pandas)
      - [8.1.5 A Decision Tree Classifier ML model in action using scikit-learn](#815-a-decision-tree-classifier-ml-model-in-action-using-scikit-learn)
    - [8.2 Machine Learning based Intrusion Detection Papers](#82-machine-learning-based-intrusion-detection-papers)
- [9 Incident Response](#9-incident-response)
    - [9.2 Incident Response Gems](#92-incident-response-gems)
    - [9.2 Incident Response Papers](#92-incident-response-papers)

## 1 Cyber Defence Foundations

TODO

-   The OSI network model is touched on (every single unit seems to do this). Waqas higlights that the physical layer is where most of the innovation is taking place, requiring deep domain knowledge in RF, electrical engineering, etc. The upper layers have been done to death.
-   [DeepSig](https://www.deepsig.ai/) is a world leading AI based wireless and RF signal detection company, with great resources such as YouTube channels.
-   Common network segregation techniques; _Zones_ to constrict access to groups of resources (data, applications), _Subnets_ constrict based on IP routing, and [VLANs](https://www.youtube.com/watch?v=fRuBHSf3Hac) constrict the Ethernet ports on a network switch that can exchange layer 2 frames.
-   Common network attacks; MAC flooding, VTP attacks, VLAN hopping

A forest from the trees overview of the broad field of SecOps:

- [1 Cyber Defence Foundations](#1-cyber-defence-foundations)
    - [1.1 Cyber Defence Foundations Gems](#11-cyber-defence-foundations-gems)
    - [1.2 Cyber Defence Foundations Papers](#12-cyber-defence-foundations-papers)
    - [1.3 Cisco IOS](#13-cisco-ios)
- [2 Threat Modelling](#2-threat-modelling)
    - [2.1 Threat Modelling Gems](#21-threat-modelling-gems)
    - [2.2 Threat Modelling Papers](#22-threat-modelling-papers)
- [3 Vulnerability Assessment](#3-vulnerability-assessment)
    - [3.1 Vulnerability Assessment Gems](#31-vulnerability-assessment-gems)
    - [3.2 Vulnerability Assessment Papers](#32-vulnerability-assessment-papers)
- [4 Host and Network Security Monitoring](#4-host-and-network-security-monitoring)
    - [4.1 Host and Network Security Gems](#41-host-and-network-security-gems)
    - [4.2 Host and Network Security Papers](#42-host-and-network-security-papers)
- [5 Data Collection and Analysis](#5-data-collection-and-analysis)
    - [5.1 Data Collection and Analysis Gems](#51-data-collection-and-analysis-gems)
    - [5.2 Data Collection and Analysis Papers](#52-data-collection-and-analysis-papers)
- [6 Signature based defence](#6-signature-based-defence)
    - [6.1 Signature based defence Gems](#61-signature-based-defence-gems)
    - [6.2 Signature based defence Papers](#62-signature-based-defence-papers)
- [7 Machine Learning for Collection and Detection](#7-machine-learning-for-collection-and-detection)
    - [7.1 Machine Learning for Collection and Detection Gems](#71-machine-learning-for-collection-and-detection-gems)
      - [7.1.1 Creating custom Snort rules](#711-creating-custom-snort-rules)
      - [7.1.2. Crafting packets with scapy](#712-crafting-packets-with-scapy)
      - [7.1.3 Using Security Onions MySQL DB of raw events](#713-using-security-onions-mysql-db-of-raw-events)
    - [7.2 Machine Learning for Collection and Detection Papers](#72-machine-learning-for-collection-and-detection-papers)
- [8 Machine Learning based Intrusion Detection](#8-machine-learning-based-intrusion-detection)
    - [8.1 Machine Learning based Intrusion Detection Gems](#81-machine-learning-based-intrusion-detection-gems)
      - [8.1.1 Using scikit-learn to mop up data (imputation)](#811-using-scikit-learn-to-mop-up-data-imputation)
      - [8.1.2 Data pre-processing (munging) basics for ML using Python](#812-data-pre-processing-munging-basics-for-ml-using-python)
      - [8.1.3 Label Encoding using Python and scikitlearn](#813-label-encoding-using-python-and-scikitlearn)
      - [8.1.4 One Hot Encoding using Python and pandas](#814-one-hot-encoding-using-python-and-pandas)
      - [8.1.5 A Decision Tree Classifier ML model in action using scikit-learn](#815-a-decision-tree-classifier-ml-model-in-action-using-scikit-learn)
    - [8.2 Machine Learning based Intrusion Detection Papers](#82-machine-learning-based-intrusion-detection-papers)
- [9 Incident Response](#9-incident-response)
    - [9.2 Incident Response Gems](#92-incident-response-gems)
    - [9.2 Incident Response Papers](#92-incident-response-papers)

#### 1.1 Cyber Defence Foundations Gems

-   Cisco Packet Tracer on Windows. Actually mind blowing. A full blown network designer and emulator, including end point devices (NICs, operating systems), routers, switches, wireless devices, WAN emulation and more. You can cable between each device (e.g., copper crossover, copper straight-through, etc), bring up cisco shells on the routers and switches for advanced router configurations and setup fine grained subnets, IPs, VLANs, you name it. You can then jump on the end point hosts (e.g., windows or linux machines), start a shell up and trying exploring the route tables, ARP, `ping`, like you're on a full blown OS. For years I've wondered how networking people learn and play around with physical like networking techniques without having to setup physical devices. This is it! Insanely cool.
-   [Ettercap](https://www.ettercap-project.org/) is an amazing program for fooling around with common network protocols and services. Here we used it to perform a MITM attack by pretending to be a DHCP server (spoofing).
-   ARP poisoning with `arpspoof`. Enough said: `arpspoof -i eth0 -t 10.1.1.12 10.1.1.228` (`-t` being the target host to ARP poison). Dump the ARP tables on the various targets e.g., on windows `arp -a`. Quite an effective MITM technique for siphoning frames between hosts, assuming you forward everything on so it appears legitimate.
-   [Cyber Ben-Gurion University of the Negev: Air Gap Research by Dr Mordechai Guri](https://cyber.bgu.ac.il/air-gap/): An Israel uni that is publishing some incredible research in the field of signal detection and intelligence, in the space of air-gapping (a common technique employed by highly secure organisations). Great videos on PowerHammer (power line based signals), MOSQUITO (acoustic speaker to speaker communication between air gapped computers), ODINI (leaking data from a Faraday cage) and many more.
-   [tyranid/ExampleChatApplication](https://github.com/tyranid/ExampleChatApplication) a simple example command line chat application written for .NET to learn network protocol analysis, great for messing around with packet analysers like `tcpdump` or `wireshark`
-   [SWAN: Secure Wireless Agile Networks](https://www.swan-partnership.ac.uk/research-challenges/): A cool company based in the UK, that is pushing the boundaries of what is currently accepted the norm in terms of RF based network systems. They are sponsoring a number of PhD opportunities.
-   [SBIR: Cyber Vulnerabilities and Mitigations in the Radio Frequency Domain](https://www.sbir.gov/node/1208173): Great paper from the American governments Small Business Innovation Research incubator.
-   [DeepSig Inc: Wireless Threat Detection and Analytics](https://www.deepsig.ai/threat-warning-analytics): OmniSIG Sensor makes it possible to rapidly detect emitters across a wide range of bands and emitter types while on small or mobile platforms or while deployed on radio infrastructure devices making it an ideal enabler for coverage mapping, usage mapping, interference hunting, unauthorized emitter hunting, cyber-threat detection, and other mobile mapping applications

#### 1.2 Cyber Defence Foundations Papers

-   [Novokhrestov, A., Konev, A., Shelupanov, A. and Buymov, A., 2020, March. Computer network threat modelling. In Journal of Physics Conference Series (Vol. 1488, p. 012002)](/papers/security/defensive/Novokhrestov_2020_ComputerNetworkThreatModelling.pdf)
-   [Bakhshi, Z., Balador, A. and Mustafa, J., 2018, April. Industrial IoT security threats and concerns by considering Cisco and Microsoft IoT reference models. In 2018 IEEE Wireless Communications and Networking Conference Workshops (WCNCW) (pp. 173-178). IEEE.](/papers/security/defensive/Bakhshi_2018_IndustrialInternetOfThingsSecurityThreatsByConsideringCiscoAndMicrosoftReferenceModels.pdf)
-   [Qian, K., Parizi, R.M. and Lo, D., 2018, December. OWASP Risk Analysis Driven Security Requirements Specification for Secure Android Mobile Software Development. In 2018 IEEE Conference on Dependable and Secure Computing (DSC) (pp. 1-2). IEEE.](/papers/security/defensive/Qian_2018_OWASPRiskAnalysisDrivenSecurityRequirementsForSecureAndroidMobileSoftware.pdf)

#### 1.3 Cisco IOS

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

## 2 Threat Modelling

#### 2.1 Threat Modelling Gems

-   [OWSAP Threat Dragon](https://threatdragon.github.io/) an open-source threat modelling tool from OWASP. In a nutshell creates threat model diagrams as part of a secure SDLC. Model an applications architecture visually, the stores, actors, processes, data flows and trust boundaries. Record possible threats and the decided mitigations. Visually models the threat model components and threat surfaces. Generates reports. Supports the [STRIDE](http://TODO), [CIA]() and [LINDDUN]() methodologies.
-   [Microsoft Threat Modeling Tool](https://docs.microsoft.com/en-us/azure/security/develop/threat-modeling-tool) allows software architects to identify and mitigate potential security issues early, when they are relatively easy and cost-effective to resolve. It was designed with non-security experts in mind, making threat modeling easier for all developers by providing clear guidance on creating and analysing threat models.
-   [MITRE StixViz](https://github.com/STIXProject/stix-viz) an open-source threat modelling and visualisation tool by MITRE Corporation, visualises Structured Threat Information eXpression (STIX) documents as a node-link tree with the root at the top of the XML structure.

#### 2.2 Threat Modelling Papers

-   [Moustafa, N., Adi, E., Turnbull, B., & Hu, J. (2018). A new threat intelligence scheme for safeguarding industry 4.0 systems. IEEE Access, 6, 32910-32924.](/papers/security/defensive/Moustafa_2018_ANewThreatIntelligenceSchemeForSafeguardingIndustry4Systems.pdf)
-   [Al-Hawawreh, M., Moustafa, N., Garg, S., & Hossain, M. S. (2020). Deep Learning-enabled Threat Intelligence Scheme in the Internet of Things Networks. IEEE Transactions on Network Science and Engineering.](/papers/security/defensive/Al-Hawawreh_2020_DeepLearningEnabledThreatIntelligenceSchemeInTheInternetOfThingsNetworks.pdf)

## 3 Vulnerability Assessment

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

#### 3.1 Vulnerability Assessment Gems

-   [Damn Vulnerable Web App](https://github.com/digininja/DVWA) a PHP/MySQL web application that is damn vulnerable. Its main goal is to be an aid for security professionals to test their skills and tools in a legal environment, help web developers better understand the processes of securing web applications and to aid both students & teachers to learn about web application security in a controlled class room environment.
-   [OWASP Risk Rating Methodology](https://owasp.org/www-community/OWASP_Risk_Rating_Methodology)
-   [NIST 800-30 - Guide for Conducting Risk Assessments](https://csrc.nist.gov/publications/detail/sp/800-30/rev-1/final)
-   [Government of Canada - Harmonized TRA Methodology](https://cyber.gc.ca/en/guidance/harmonized-tra-methodology-tra-1)
-   [Mozilla Risk Assessment Summary](https://infosec.mozilla.org/guidelines/assessing_security_risk)
-   [Mozilla Rpaid Risk Assessment (RRA)](https://infosec.mozilla.org/guidelines/risk/rapid_risk_assessment.html)

#### 3.2 Vulnerability Assessment Papers

-   [Easttom, Chuck. "Vulnerability Assessment and Management." In The NICE Cyber Security Framework, pp. 241-258. Springer, Cham, 2020.](/papers/security/defensive/Easttom_2020_NICECyberSecurityFramework_VulnerabilityAssessmentAndManagement.pdf)

## 4 Host and Network Security Monitoring

TODO: week 4 lecture

#### 4.1 Host and Network Security Gems

-   `iptables` firewall organises its rule policies as a set of tables that hold chains, that hold rules.
-   Common tables include `filter`, `nat` and `mangle`
-   Common chains are `INPUT` for packets inbound to host, `OUTPUT` opposite of `INBOUND`, `FORWARD` packets destined for anohter NIC on host, `PREROUTING` for packet manipulation
-   To list the rule chains on the `filter` table: `iptables -t filter -L -n`
-   Port forward port everything on 8080 to port 80: `iptables -t nat -A PREROUTING -d 10.1.1.131 -p tcp --dport 8080 -j DNAT --to 10.1.1.131:80`
-   [pfSense](https://www.pfsense.org/) is an insanely powerful network router and firewall based on FreeBSD. It offers a neat web UI. Notable features include traffic shaping, VPNs using IPsec or PPTP, captive portal, stateful firewall, network address translation, 802.1q support for VLANs and dynamic DNS.

#### 4.2 Host and Network Security Papers

-   [Ganin, A.A., Quach, P., Panwar, M., Collier, Z.A., Keisler, J.M., Marchese, D. and Linkov, I., 2020. Multicriteria decision framework for cybersecurity risk assessment and management. Risk Analysis, 40(1), pp.183-199.](#TODO)
-   [Humayun, M., Niazi, M., Jhanjhi, N.Z., Alshayeb, M. and Mahmood, S., 2020. Cyber security threats and vulnerabilities: a systematic mapping study. Arabian Journal for Science and Engineering, 45(4), pp.3171-3189.](#TODO)

## 5 Data Collection and Analysis

TODO: week 5 lecture

#### 5.1 Data Collection and Analysis Gems

-   Splunk is the defacto player in the SIEM space. Tasks such as real-time file system monitoring of hosts, log collection and centralisation, crafting rule sets for attack vectors you want to keep an eye on and getting proactive alerts when trip wires are set off.
-   Some concrete data sources Splunk Enterprise supports; local event logs, remote event logs, files and directories, HTTP event collector, TCP/UDP, local performance monitoring, remote performance monitoring, registry monitoring, active directory monitoring, local windows host monitoring (i.e., perflogs), windows network monitoring, windows print monitoring, scripts, powershell v3 parameter inputs.
-   Splunk Forwarders are akin to agents that run out on the fleet of hosts, they can collate logs and metrics about the host, and firehose this data back to the central splunk cluster. Nothing rocket science going on here.

#### 5.2 Data Collection and Analysis Papers

-   [Sekharan, S.S. and Kandasamy, K., 2017, March. Profiling SIEM tools and correlation engines for security analytics. In 2017 International Conference on Wireless Communications, Signal Processing and Networking (WiSPNET) (pp. 717-721). IEEE](#TODO)
-   [Majeed, A., ur Rasool, R., Ahmad, F., Alam, M. and Javaid, N., 2019. Near-miss situation based visual analysis of SIEM rules for real time network security monitoring. Journal of Ambient Intelligence and Humanized Computing, pp.1509-1526](#TODO)

## 6 Signature based defence

TODO: week 6 lecture

#### 6.1 Signature based defence Gems

-   Splunk can easily play the role of a HIDS (host IDS) or NIDS (network IDS), identifying common hacks such as DoS, brute force account/password guessing, SQL injection and cross site scripting (XSS) attempts on web apps, DHCP spoofing, ARP poisoning, `nmap` scan and ping sweeps, and plenty more.
-   `hping3` is a nice little NIX-based packet flooder
-   For example to stress an `ftpd` running on default 21: `hping3 -c 500 -d 120 -S -w 64 -p 21 --flood --rand-source 10.1.1.12` [read more here](https://www.blackmoreops.com/2015/04/21/denial-of-service-attack-dos-using-hping3-with-spoofed-ip-in-kali-linux/)
-   In splunk this can be observed by searching on all port 21 inbound packets detected for running this query: _21 and inbound_. From here its simple to create an alert off the back of the query pattern; e.g., trigger an alert when more than 100 per minute port 21 inbound packets are detected.
-   `hydra` is the goto NIX-based brute forcer. You feed it a list of logins and a list of passwords and it will fire each permutation at the target.
-   `hydra –L ~/logins.txt –P ~/passwords.txt ftp://10.1.1.12`
-   `hydra -L /usr/share/wordlist/fasttrack.txt -P /usr/share/wordlist/fasttrack.txt 192.168.0.12 ftp`
-   Splunk by parsing the logs of the `ftpd` (such as IIS) can be configured to trigger an alert when a certain threshold of `USER` and `PASS` log entries are seen in a time window. In the Splunk web UI its a piece of cake; Search and Reporting > Wack _PASS_ into the omnibox search field > Save As > Alert
-   Handy common SQL injection detection search patterns are `%' OR '' = ''` and `'' OR 1=1/* ''`
-   In the Splunk web UI its simple; Search and Reporting > Wack _OR 1 and OR_ into the omnibox search field > Save As > Alert. The noteworth twist on the splunk alert here, is that a single SQL injection attempt must be reported immediately (i.e., don't try to aggregate these events, as just one is harmful). In Splunk this is achieved by setting the _Trigger alert when_ type as _Per-Result_ and setting it to _1_.
-   Cross site scripting (XSS) happens when a web app persists unsanitised or unencoded user inputs (i.e., suprisingly common) giving attackers a convenient method of injecting markup and javascript, which in turn get rendered out raw to other users.
-   Splunk queries on the web apps custom logs using patterns such as _script_ to detect `<script>` tags are effective. This does however assume that user provided inputs are logged by the web app.

#### 6.2 Signature based defence Papers

-   [Haider, W., Moustafa, N., Keshk, M., Fernandez, A., Choo, K.K.R. and Wahab, A., 2020. FGMC-HADS: Fuzzy Gaussian mixture-based correntropy models for detecting zero-day attacks from linux systems. Computers & Security, 96, p.101906.](#TODO)
-   [Wang, Yu, et al. "A fog-based privacy-preserving approach for distributed signature-based intrusion detection." Journal of Parallel and Distributed Computing 122 (2018): 26-35.](#TODO)

## 7 Machine Learning for Collection and Detection

TODO: summarise week 7 lecture

#### 7.1 Machine Learning for Collection and Detection Gems

-   [Security Onion](https://securityonionsolutions.com/software/) (SO) is a complete distribution open source security tools, in much the same way Kali is. However, unlike Kali which targets offensive security tools, SO focuses on defensive tools; particularly around network monitoring collection, detection and analysis.
-   Useful SO commands; `nsm` to list available network security monitoring tools, `so-status`, `so-start`
-   [Sguil](https://bammv.github.io/sguil/index.html) (pronounced squeal) is a storage back-end and graphical front-end designed for network security analysts. The GUI (made in tcl/tk) provides access to realtime events, session data, and raw packet captures off the raw network interfaces available. At a network level it offers two interfaces; the management network interface for remote interfacing administratively and the monitoring network interface for sniffing packets on the network promiscuously. Important to note that squil is for managing alert events, the actual detection work is performed by Snort.
-   [Squert](http://www.squertproject.org/) is a web frontend to Sguil. Similar to Elastic's Kibana it can quickly aggregate and weight huge amounts of time series events, making it intuitive to pose questions of the data.
-   [Snort](https://www.snort.org/) an open-source Network Intrusion Detection System (NIDS) that detects packets that match a configurable rule set and generates alerts.
-   [Zeek](https://zeek.org/) (formally bro) is not an active security device, like a firewall or intrusion prevention system. Rather, Zeek sits on a “sensor,” a hardware, software, virtual, or cloud platform that quietly and unobtrusively observes network traffic. Zeek interprets what it sees and creates compact, high-fidelity transaction logs, file content, and fully customized output, suitable for manual review on disk or in a more analyst-friendly tool like a security and information event management (SIEM) system.
-   [Scapy](https://scapy.net/) is a neat (Python based) TUI for generating different kinds of packets and throwing them at a host. In other words it's a packet generator.
-   Security Onion ships with a bunch of common malicious activity PCAP's (`/opt/samples/mta`) which is useful for validating, such as `2014-12-07-Neutrino-EK-traffic.pcap` (a common exploit kit)
-   Speaking of Elastic, the SecurityOnion distribution also packages a fully setup Elastic stack, pre-configured to tip all the raw Zeek/OSSEC (HIDS) and Snort/Suricata (NIDS) data. I'm a big fan of the elastic stack.

Sguil showing sniffed ICMP echo, RDP and nmap port scan:

![Sguil showing sniffed ICMP RDP and nmap port scan](/images/blueteam-sguil-showing-sniffed-ping-rdp-and-nmap-scan.png)

The Squert web UI detailed event view:

![Squert event view](/images/blueteam-squert-webui-event-view.png)

The Squert web UI aggregate view:

![Squert summary view](/images/blueteam-squert-webui-summary-view.png)

##### 7.1.1 Creating custom Snort rules

First up a simple class based rule. The following will detect any ICMP echo (ping) requests sent out from a specific Windows Server host called `DMZ-Corporate`. Things to note:

-   You can assign any packets that match this rule to an alert class such as _attempted recon_

```sh
echo 'alert icmp 192.168.0.228 any -> any any (msg:"ICMP from Target DMZ-Corporate (1337 h4x07 warning)"; sid:1000000; classtype:attempted-recon;)' > /etc/nsm/rules/local.rules
rule-update
```

Once apply any pings that come out of the old Windows box should be sniffed and shown in Sguil like so:

![Sguil showing custom ICMP echo request Snort rule](/images/blueteam-sguil-showing-custom-icmp-snort-rule.png)

Now for a content based rule, that will dig into the guts of a packet.

```sh
echo 'alert tcp any any -> any 1337 (msg:"New 0 day exploit"; content:"UniqueString1234"; flow:to_server; nocase; sid:1000001; classtype:client-side-exploit; rev:1;)' > /etc/nsm/rules/local.rules
rule-update
```

Now throw a TCP packet with a data payload that contains `UniqueString1234` at port 1337 on any host (see notes on `scapy` below), Sguil will now detect and pick it up.

##### 7.1.2. Crafting packets with scapy

Scapy is just a beautiful little TUI. It interactively walks you through the crafting and transmission of a network packet by providing an object model you can whip together and has brilliant tab completion. After firing it up on a TTY you'll be thrown into it's interactive shell, like this:

```sh
>>> ip = IP()
>>> ip.dst = "10.1.1.228"
>>> tcp = TCP()
>>> tcp.dport = 1337
>>> payload = "UniqueString1234"
>>> send(ip/tcp/payload)
.
Sent 1 packets.
```

##### 7.1.3 Using Security Onions MySQL DB of raw events

It's just a vanilla mysql database called `securityonion_db`. Nice and simple!

```
sudo mysql --defaults-file=/etc/mysql/debian.cnf -D securityonion_db
mysql> USE securityonion_db;
mysql> SHOW TABLES;
```

Using SQL you can now throw whatever questions you have at the data.

What are the 20 most common types of security events? `SELECT COUNT(*) AS tally, signature, signature_id FROM event WHERE status=0 GROUP BY signature ORDER BY tally DESC LIMIT 20;`

What are the 20 most recent types of security events? `SELECT COUNT(*) AS tally, signature, signature_id, timestamp FROM event WHERE status=0 GROUP BY signature ORDER BY timestamp DESC LIMIT 20;`

#### 7.2 Machine Learning for Collection and Detection Papers

-   [A holistic review of network anomaly detection systems: A comprehensive survey (2019)](#TODO)
-   [Security and Privacy for Artificial Intelligence: Opportunities and Challenges (2021)](#TODO)

## 8 Machine Learning based Intrusion Detection

Here will explore data pre-processing techniques for developing machine learning (ML) algorithms to discover attack events based on behavioural analysis. Unlike predefined static rules driven software such as OSSIM, firewalls and all of the Security Onion packaged tools.

-   A huge part of ML goes into data engineering the raw data. That is, preparing and normalising the data is a consistent and tidy way in which a meaningful ML model can be built upon. Python (and support data science libs) is a powerful option in this space.
-   Feature conversion is about shaping the raw data. Popular strategies are a simple _Label Encoder_ or a _One Hot Encoder_ (aka dummy coding).
-   _Label Encoding_ transforms non-numerical (ordinal) values into, well...numerical values! Values always are between 0 and n. A protocol attribute for example (tcp, udp, snmp) could encode as (0, 1, 2)
-   _Label Encoding_ depending on the type of model, may decrease performance, as all the data is now represented similarly. 0 signifies the protocol type of tcp, but 0 may be using to signify something else in another field. This lack of representation uniqueness across fields can imped some model types.
-   _One Hot Encoding_ breaks out (pivots) values into discrete columns (or features). I like to think of one hot encoding as just a simple bitmap of all the features. For example, the protocol feature which contains (tcp, udp snmp) in _One Hot Encoding_ would result in a new column for each value; that is a column for tcp (protocol_tcp), for udp (protocol_udp) and snmp (protocol_snmp). Each containing only simple boolean (bits).
-   _One Hot Encoding_ clearly could result is a HUGE number of features.

#### 8.1 Machine Learning based Intrusion Detection Gems

-   When it comes to data science, Python with the following infamous libraries, #amirite
    -   `numpy` provides a powerful N-dimensional array object and many useful linear algebra, Fourier transform, and random number capabilities
    -   `scipy` provides many user-friendly and efficient numerical routines such as routines for numerical integration and optimisation
    -   `pandas` provides fast, flexible, and expressive data structures designed to make working with "relational" or "labeled" data both easy and intuitive. It aims to be the fundamental high-level building block for doing practical, real world data analysis
    -   `scikit-learn` wraps up a number of machine learning models, built on top of SciPy
    -   `matplotlib` is a comprehensive library for creating static, animated, and interactive visualisations
    -   `seaborn` built on-top of `matplotlib`, aims to make visualization a central part of exploring and understanding data. Its dataset-oriented plotting functions operate on dataframes and arrays containing whole datasets and internally perform the necessary semantic mappings and statistical aggregations to produce informative plots
-   [Argus](http://argus.tcp4me.com/) is a system and network monitor that includes a web front-end and a MySQL database. Unlike real-time network monitors, Argus is handy for performing retrospective analysis of activity by using a remote MySQL database. First start Argus `sudo argus -P 561 -d` and then start tracing traffic: `./rasqlinsert -M cache -m none -S 10.1.1.10:561 -w mysql://root:admin@10.1.1.12/network_data/tb_data -s +ltime +seq +dur +mean +stddev +smac +dmac +sum +min +max +soui +doui +sco +dco +spkts +dpkts +sbytes +dbytes +rate +srate +drate`

##### 8.1.1 Using scikit-learn to mop up data (imputation)

In the real world, data is often quite scrappy, missing values and so on.

> A basic strategy to use incomplete datasets is to discard entire rows and/or columns containing missing values. However, this comes at the price of losing data which may be valuable (even though incomplete). A better strategy is to impute the missing values, i.e., to infer them from the known part of the data.

[Imputation](https://scikit-learn.org/stable/modules/impute.html) is about using a more intelligent model to scavenge the pieces of data that are still valuable.

##### 8.1.2 Data pre-processing (munging) basics for ML using Python

```python
import numpy as np
import scipy as sp
import pandas as pd
import matplotlib as mpl
import seaborn as sns

#
# Read and parse external data (so SLICK)
#
df = pd.read_csv("~/network_data.csv")
df.head(3)              # show first 3 in pandas data frame (default is 5)

#
# Get help
#
help(pd.read_csv)       # get help on the pandas read_csv function

#
# Explore the data frame
#
df['proto'].dtype       # string is object
df['saddr'].dtype       # float64
df.dtypes               # show the types for each columns
df.columns              # show the labels for each column
df.shape                # show count of rows and columns ex: (2000, 10)
df.describe()           # show stats the data such as count, mean, std, percentiles
print(df)               # show data frame as tabular text and output
df.method()             # explore methods available on the data frame

#
# Group by aggregation (GROUP BY)
#
df_label = df.groupby(['label'])      # group by the values in the label column
df_label.mean()                       # calc the mean for each column against the label
#
#           dttl	    shops	    sload	        srate	    dtcpb
# label
# attack	66.932271	20.409031	297635.130502	619.888445	2.097451e+09
# normal	100.825911	0.052632	7794.605662	    9.111258	1.729420e+08


#
# Filtering data (WHERE)
#
df_sub = df[ df['dttl'] > 7.1 ]       # basic condition on a column
df_sub.head(5)                        # first 5 rows
df[df.isnull().any(axis=1)].head()    # select rows with least one null value (in any column)


#
# Slicing (SELECT col1, col2 and WHERE)
#
df[['proto','dttl']]                  # select by column names
df[10:20]                             # select * columns only for rows 10-20
df_sub.loc[1:10,['proto','label']]    # or do both; only rows 1-10 and 2 specific columns
df.iloc[:, 0]                         # first column
df.iloc[:, -1]                        # last column
df.iloc[0:7]                          # first 7 rows
df.iloc[:, 0:2]                       # first 2 columns

#
# Find and replace
#
df_zeros = df.fillna(0)                          # globally replace nulls with 0
df_zeros[df_zeros.isnull().any(axis=1)].head()   # validate nulls are gone
df_zeros.method()                                # explore methods available on the data frame
```

##### 8.1.3 Label Encoding using Python and scikitlearn

```python
from sklearn.preprocessing import LabelEncoder

df_zeros = df.fillna(0)                                      # globally replace nulls with 0
obj_df = df_zeros.select_dtypes(include=['object']).copy()   # only select string (in python, strings are objects)

# mutate the existing data frame with sklearn
sk_encoder = LabelEncoder()
df_zeros['proto'] = sk_encoder.fit_transform(df_zeros['proto'].astype('str'))
df_zeros['saddr'] = sk_encoder.fit_transform(df_zeros['saddr'].astype('str'))
df_zeros['daddr'] = sk_encoder.fit_transform(df_zeros['daddr'].astype('str'))
df_zeros['state'] = sk_encoder.fit_transform(df_zeros['state'].astype('str'))
df_zeros['label'] = sk_encoder.fit_transform(df_zeros['label'].astype('str'))

df_zeros.head(10)

#
# Everything is now be numerically classified (i.e, label encoded) - AWESOME!
#
# 	proto	saddr	daddr	state	dttl	shops	        sload	srate	dtcpb	label
# 0	0	    2	    13	    2	    0.0	0.0	4.718540e+02	0.983029	0.0	0
# 1	4	    1	    18	    0	    16.0	0.0	0.000000e+00	0.000000	0.0	1
# 2	0	    1	    17	    2	    0.0	0.0	5.282374e+02	1.100495	0.0	1
# 3	2	    11	    123	    7	    0.0	0.0	5.648498e+04	78.451370	0.0	1
# 4	1	    1	    0	    2	    0.0	0.0	0.000000e+00	0.000000	0.0	1
# 5	1	    1	    0	    2	    0.0	0.0	0.000000e+00	0.000000	0.0	1
# 6	1	    1	    0	    2	    0.0	0.0	0.000000e+00	0.000000	0.0	1
# 7	1	    1	    0	    2	    0.0	0.0	0.000000e+00	0.000000	0.0	1
# 8	4	    1	    107	    2	    0.0	0.0	1.445783e+06	1807.229004	0.0	1
# 9	4	    11	    128	    2	    0.0	0.0	2.067480e+06	2153.625244	0.0	1
```

##### 8.1.4 One Hot Encoding using Python and pandas

```python
import pandas as pd

df_dummies=pd.get_dummies(df)
df_dummies.shape                # (5, 161) - 161 columns!

#
# All values are now broken out into bitmap columns - AWESOME!
#
```

##### 8.1.5 A Decision Tree Classifier ML model in action using scikit-learn

```python
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, confusion_matrix
from sklearn . tree import DecisionTreeClassifier

df = pd. read_csv ('~/network_data_numbers.csv')
y = df['label']. values
x = df.drop('label', axis=1).values

# divide data into training and testing sets
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.2, random_state=1)

model = DecisionTreeClassifier()
model.fit(x_train, y_train)                                   # train the model
y_pred = model.predict(x_test)                                # prediction using the testing phase
print("accuracy", accuracy_score(y_pred, y_test))             # measure performance using accuracy 
print("confusion matrix", confusion_matrix(y_pred, y_test))   # measure performance confusion matrix
```

#### 8.2 Machine Learning based Intrusion Detection Papers

-   [A review of intrusion detection systems using machine and deep learning in internet of things: Challenges, solutions and future directions (2020)](#TODO)
-   [DAD: A Distributed Anomaly Detection system using ensemble one-class statistical learning in edge networks (2021)](#TODO)

## 9 Incident Response


#### 9.2 Incident Response Gems

- [OSSEC](https://www.ossec.net/) is an open-source host-based intrusion detection system (IDS); log analysis, integrity checking, Windows registry monitoring, rootkit detection, time-based alerting and active response. It is made up of a backend with strong suite of CLIs, a web frontend and agents.
- [OSSIM](https://cybersecurity.att.com/products/ossim) provides a unified web UI overlay of the many security signals and tools.
    - Dynamically build up inventory you wish to protect on your network (Environment | Assets and Groups)
    - Host level packet captures (Environment | Traffic Captures)
    - Ships with many great rule sets (detecting cleartext FTP logins, eventlog clearing, account creation, failed login attempts)


#### 9.2 Incident Response Papers
