---
layout: post
draft: false
title: "Digital Forensics"
slug: "digitalforensics"
date: "2023-007-22 16:13:36+11:00"
lastmod: "2023-007-22 16:13:36+11:00"
comments: false
categories:
  - cyber
tags:
  - cyber
  - defensive
  - blueteam
  - forensics
  - university
---

Its 2023 S2 and time for my final subject in the UNSW Cyber Security Masters course, [digtital forensics](https://legacy.handbook.unsw.edu.au/postgraduate/courses/2018/ZEIT8028.html) run by [Seth Enoka](seth.enoka@adfa.edu.au).

- [Tools](#tools)
- [Module 0 - Intro](#module-0---intro)
  - [The Detective](#the-detective)
  - [The Storyteller](#the-storyteller)
  - [The Adversary](#the-adversary)
- [Module 1 - The Forensic Method](#module-1---the-forensic-method)
  - [Investigative Leads](#investigative-leads)
  - [Analysis Administration](#analysis-administration)
  - [Gathering Requirements](#gathering-requirements)
  - [Analysis Prioritisation](#analysis-prioritisation)
  - [The Digital Forensic Lifecycle](#the-digital-forensic-lifecycle)
- [Module 2 - Disk Forensics](#module-2---disk-forensics)
- [Resources and coolness](#resources-and-coolness)

## Tools

| Tools                                            | Description                                                                                                                                                                                              |
| ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Yara                                             | A pattern-matching tool used in malware research and forensic analysis to identify and classify files based on defined rules and signatures.                                                             |
| Volatility 2 & 3                                 | Open-source memory forensics frameworks used to extract and analyze digital artifacts from volatile memory (RAM) in a memory dump to investigate cyber incidents and malware.                            |
| Volatility USNParser Plugin                      | A Volatility plugin specifically designed to parse and extract information from the USN journal on Windows systems, aiding in file activity analysis.                                                    |
| SCCA Tools                                       | SCCA (Source Code Control System Analysis) Tools assist in examining version control system repositories to identify code changes, contributors, and track project history.                              |
| ESEDB Tools                                      | These tools provide access to Extensible Storage Engine (ESE) Database files, commonly used in Windows applications, for analysis and recovery purposes.                                                 |
| analyzeMFT                                       | A tool used in digital forensics to parse and analyze the Master File Table (MFT) entries from NTFS filesystems, revealing information about files and directories.                                      |
| Oletools                                         | A collection of Python-based tools for analyzing and extracting data from OLE (Object Linking and Embedding) files, such as Microsoft Office documents, often used in malware analysis.                  |
| Wireshark                                        | A widely-used network protocol analyzer that captures and inspects data packets on a network, helping with network troubleshooting, security analysis, and protocol reverse engineering.                 |
| The Sleuth Kit (TSK)                             | An open-source digital forensic toolkit that includes various CLI tools (`mmls`, `fls`, `icat`) for file system analysis and data recovery from different operating systems.                             |
| Plaso                                            | An open-source Python-based tool used for super timeline creation and log analysis, helping to reconstruct events and activities from various data sources for forensic investigations.                  |
| Advanced Forensics Format Library (afflib) Tools | Tools for working with the Advanced Forensics Format (AFF), an extensible open file format used in computer forensics to store disk images and related metadata.                                         |
| wxHexEditor                                      | A hexadecimal editor with a graphical user interface, used for low-level data inspection and editing in forensic analysis and reverse engineering.                                                       |
| Gnumeric                                         | A spreadsheet application, similar to Microsoft Excel, used for data analysis and visualization, including data manipulation and statistical functions.                                                  |
| Personal Folder File Tools (pfftools)            | Tools designed to work with Personal Folder File (PFF) formats, commonly used by Microsoft Outlook to store emails, calendars, and other personal data. These tools aid in email forensics and analysis. |

## Module 0 - Intro

Locards Principle (Edmond Locard aka Sherlock Holmes of France)

> Every contract by a criminal leaves behind a trace

- A perpetrator will bring something to a crime scene
- A perpetrator will leave something at a crime scene
- Trace evidence bears witness to the crime and does not forget
- The only failure of trace evidence is when a human is unable to find, study, or understand it

Digital Forensic Analysis is the detailed examination of the various data elements, and their structures, extracted from digital evidence. Examination is performed from multiple viewpoints to derive meaning and intelligence:

- Analysis is not just looking at individual artefacts in isolation
- Analysis is more than just making observations, it’s requires critical thinking
- Data points must be tied together to tell a complete story, if possible
- Your aim should be to derive meaning from your data

Its not enough to stick to surface levels findings, analysis needs to go deeper. To prove the existance of a file for example, can occur through file system recovery, using backups or volume shadow copies, MFT, eventlog, what user account was responsible, was it created over a network file server such as SMB or NFS. Correlating this evidence creates a much a stronger case.

### The Detective

During an investigation, your primary role will be the digital detective; the person charged with solving the situation at hand. As a detective, you’re responsible for solving the puzzle, which often requires you to:

- Acquire the digital evidence
- Examine the digital evidence for potential leads
- Postulate potential narratives derived from your leads
- Extinguish lines of inquiry

### The Storyteller

Once the investigation is complete your role changes to that of the storyteller. As a storyteller you’re responsible for recounting the events of the situation, which
includes:

- Compiling and filtering your investigation findings into a single narrative
- Effectively communicating your narrative to your client
- Directly answering your client’s questions
- Supporting your findings and assertions with evidence

Tips: always take notes as you go with time details, the report is king, report should address clients enquiries or problems

### The Adversary

To aid your investigation there’s another role you may want to play, which is that of the perpetrator. Being able to think like your adversary provides a significant advantage in
your detective work:

- Seeing through the eyes of the perpetrator can help reveal their purpose and intent
- Increases the efficiency of the investigation
- Extinguishes lines of inquiry that are of low probability

Tips: this does NOT mean red teaming which can conflate or stomp on evidence, helps to think what is likely most lucrative to an adversary

## Module 1 - The Forensic Method

### Investigative Leads

Real world forensic investigations are not linear; don’t expect to easily find your answers on the first try. The typical method of investigation is to generate and extinguish hypotheses
and lines of inquiry:

- A lead is simply a data point of interest that requires further investigation
- Think of it as a clue as to what occurred
- You might start your investigation with very few leads
- If something feels off, then it becomes a candidate for investigation

Tips: try not to get tunnel vision on a particular lead it could be a legimate false positive

### Analysis Administration

It is imperative that you take a structured, methodical, and documented approach to your forensic investigations. Most students and junior investigators skip this step, discounting its
importance. They always learn the hard way.

Using something as simple as a spreadsheet, document and track your:

- Evidence (e.g. size, hash, datetime, origin)
- Investigative leads (i.e. threads/hypotheses) (e.g. description, datetime, status, priority)
- Analysis findings (description, datetime, related artefacts)
- Client requirements (description, datetime, importance, deadline)

[The Value of Contemporaneous Notes](https://www.sans.org/reading-room/whitepapers/forensics/paper/39185)

### Gathering Requirements

The first step in all analysis workflows should be qualifying the client’s investigation requirements. This sounds easier than it usually is; most clients don’t have the required
experience to know what questions they should ask, and what questions it’s possible to answers with forensics:

- Investigations need to be appropriately SMART (specific, measurable, achievable, relevant, time-bound)
- _Tell me everything_ is never a valid requirement
- Requirements need to be of a fine enough granularity for you to be able to predict your costs (e.g. time, money, etc)
- What was taken? Which accounts were compromised? What was the initial attack vector?

Tips: its just not possible to completely prove that all adversary activity has been identified

### Analysis Prioritisation

Being able to prioritise your forensic analysis is key to an efficient and timely forensic investigation:

- Align your investigation priorities with those of the client requirement priorities
- If you identify multiple analysis pathways to (potentially) the same destination, then always do the easy stuff first

Tips: go for low hanging fruit think like an adversary, for example a user that can't access email vs anomalious domain controller activity

### The Digital Forensic Lifecycle

Just like in software engineering (and several other disciplines), agility is important when conducting a digital forensic investigation. Investigations can be large and run for several months:

- Produce reports and update the client often
- Seek client feedback to re-orient your investigation priorities as and when necessary
- Provide rapid actionable feedback with the intent to disrupt the adversary
- Promote efficacy and efficiency

Tips: client priorities change regularly validate, ultimately lifecycle is in the interest of being most effective


## Module 2 - Disk Forensics

Fundamentals such as file structures, metadata, file systems concepts, Windows file systems, and disk partitioning are covered, leading to a practical investigative scenario.

- File system features
- FAT, exFAT, and NTFS
- File slack
- Volume shadow copies
- Master boot record partition table
- GUID partition table
- Partition slack


## Resources and coolness

- Windows shellbags
- 8 timestamps on an NTFS file system, an attacker can fairly easily mutate 4 of them, hard to convincingly adjust nano-second level
- [MITRE ATT&CK](https://attack.mitre.org/matrices/enterprise/)
- [MITRE ATT&CK for ICS](https://attack.mitre.org/matrices/ics/)
- [Cyber Kill Chain](https://www.lockheedmartin.com/en-us/capabilities/cyber/cyber-kill-chain.html)
- [Industrial Cyber Kill Chain](https://www.sans.org/white-papers/36297/)
- [Locard's Exchange Principle](https://en.wikipedia.org/wiki/Locard%27s_exchange_principle)
- [NIST Guide to Forensics in Incident Response](https://nvlpubs.nist.gov/nistpubs/legacy/sp/nistspecialpublication800-86.pdf)
- [Dragos Threat Groups](https://www.dragos.com/threat-groups/)
- [Crowdstrike Adversary Groups](https://adversary.crowdstrike.com/en-US/)
- [Diamond Model for Intrusion Analysis](https://www.dragos.com/resource/the-diamond-model-an-analysts-best-friend/)
- [The Four Types of Threat Detection](https://www.dragos.com/wp-content/uploads/The_Four_Types-of_Threat_Detection.pdf)







