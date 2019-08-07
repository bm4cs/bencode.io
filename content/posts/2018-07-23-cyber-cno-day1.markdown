---
layout: post
title: "CNO Day 1 Enumeration"
date: "2018-07-23 09:26:01"
comments: false
categories: "cybersec"
---

Covers basics starting with enumeration.

There is a process to exposing vunerabilities. Not a linear process. Imposter syndrome is huge in this field, due to the complexity of the field, and how many domains it covers.

The anatomy of a hack (EEE); Enumeration, Exploitation, Escalation


There are multiple ways to do one thing, for example to figure out if  the `sshd` daemon is running you could:

* Check if port 22 is listening `netstat -tlp`
* Check if the sshd process is running
* Try to ssh connect to the daemon
* List the running services through systemd



# Tools

Tools to grok:

* nc
* wireshark
* nikto
* nmap


## nmap

[SAN's Nmap Cheatsheet](https://blogs.sans.org/pen-testing/files/2013/10/NmapCheatSheetv1.1.pdf)

Scan a subnet:

    nmap -sP 192.168.0.0/24

Scan (fast) a host for open ports:

    nmap -F 192.168.0.14

Verbose and detailed service analysis:

    nmap -A -sV 192.168.0.62


## netcat

[San's netcat cheetsheet](https://www.sans.org/security-resources/sec560/netcat_cheat_sheet_v1.pdf)

Allows us to connect to network services to see if they're accessible.

    nc -nv 192.168.0.14 110

Allows us to establish network listeners.

    nc -nvlp 4444

Transferring files:

    nc -nvlp 4444 > program.exe
    nc -nv 192.168.0.99 4444 < program.exe

Remote administration is possible, by binding a shell:

    nc -nvlp 4444 -e /bin/bash
    nc -nv 127.0.0.1 4444

Port scanning (randomise port enumeration and max wait time of 1s):

    nc -z -v -r -w1 192.168.0.14 80-120


## Wireshark

Tip: Always capture first, and analyse later.

Can laer filter on MAC, IP, and other protocol specific features.

Follow TCP Stream, is a super handy feature.


## tcpdump

CLI version of wireshark, without dissectors and other features. Can be used to save pcap files for dissection later.


## OpenVAS

> The world's most advanced Open Source vulnerability scanner and manager




# Open Source Intelligence

Common OSINT sources; whois, linkedin, facebook, pastebin, breach dumps, shodan, internet archive (wayback machine), theharvester

http://www.exploit-db.com/google-hacking-database/

Google queries:

    site:linkedin.com (inurl:com/pub | inurl:com/in) -inurl:pub/dir "Company"



# Enumeration

One of the most important aspects to invest in early. If incorrect assumptions are made, you can follow rabbit holes that waste significant amounts of time.



## Port Scanning

**nmap** TCP scanning (connect, syn). UDP scanning. NSE (nmap scripting engine) scripts, are useful for example running a SMB like client.
* Firewalls and other network appliances can interfere with results. Try from another IP.

Port scanners generally target *interesting* ports. Specify ports explicitly.

Tip: Always scan for UDP services. They take a very long time, as datagrams are fired off, and may be filtered and never come back.

A SYN scan is simply a SYN/SYN-ACK shake, without the 3rd piece (ACK) of the handshake. Where a full CONNECT scan is a more realistic 3-way handshake, that mimics a real connection.

### Flags

* `-O` identify OS based on response
* `-sV` and `-A` will conduct service fingerprinting using service banners and eumeration scripts.
* `-sP` scan hosts on a specified network e.g. `nmap -sP 192.168.0.0/24`


### NSE (Scripting Engine)

There are tons of scripts in `/usr/share/nmap/scripts`, everything from probes to exploits.

Categories of scripts are supported, for example:

* `nmap --script default`
* `nmap --script=*smb* 192.168.0.0/24


### Exercises

**Conduct a TCP connect scan against HOST using netcat**

Port scanning (randomise port enumeration and max wait time of 1s):

    nc -z -v -r -w1 192.168.0.14 80-120


**Conduct a TCP connect scan against HOST using nmap**

    nmap -sV 192.168.0.14

**Conduct a TCP SYN scan against 192.168.0.14 using nmap**


**Conduct a UDP scan against 192.168.0.14 using nmap**


**Read the nmap man page. Try some other scan types and observe the differences in wireshark**


## DNS Enumeration

Forward and reverse lookups:

    dig mordoor.com
    dig -x 192.168.0.14

Zone transfers:

    dig axfr mordoor.com @ns1.mordoor.com

DNSrecon

    dnsrecon -d mordoor.com -t axfr

DNSenum

    dnsenum mordoor.com


## SMTP Enumeration

The protocol supports a bunch of commands to allow the sending of email. Checkout the SMTP RFCs.

Hook up to the SMTP server with netcat (`nc -nv 192.168.0.1 25`)

    VRFY person@example.com
    EXPN maillist@example.com


## SMB enumeration

Find hosts running SMB services

    nmap -p 139,445 192.168.0.0/24

Interact with those services to gather information

    nbtscan -r 192.168.0.0/24

Enumerate those SMB services

    enum4linux -a 192.168.0.14

TODO: Do a nmap --script=*smb* scripting.



## SNMP enumeration

SNMP interacts via UDP port 161. The SNMP MIB contains information relating to network management. SNMP services require public and private community string to interact.

A real gold mine for discovering recon about a host, such as it physical location.

* Scan for open UDP161 ports with nmap and use NSE (nmap scripting engine)
* Scan and interact with UDP161 ports using `onesixtyone`
* `snmpwalk` can dump out the entire MIB

`onesixtyone` is a really handy tool for probing SNMP community strings, and can be fed a word list to enumerate through. The following will test the *public* community string:

    onesixtyone 192.168.0.123 public

Tip for `snmpwalk` help (such as the -m and -O switches), checkout the `snmpcmd`.

    snmpwalk -mALL -OS -c public -v 192.168.0.61 2> /dev/null

Keep an eye out for particular MIB's. For example, if `snmpwalk` dumped out `iso-3.6.1.2.1.1.6`, you could search the MIB on [oid-info](http://www.oid-info.com), and you would find this relates to the machines physical location.



## Directory enumeration

How do you know if a website has areas they don't wish you to see? Checkout the `robots.txt`.

Tools such as `gobuster` to try visiting a huge amount of directories. Those that exist will return a HTTP 200, those that don't a 404.

Checkout `dirb`, which throws a dictionary at the HTTP server, for example:

    dirb http://192.168.0.60





# Enumeration exercises

* What is the physical location of the box (according to its own records)?
* What is the Linux kernel version in use?
* What is the OS?
* What is the SSH EdDSA hostkey?
* What is the full email address of all employee's at shoprite.com?

