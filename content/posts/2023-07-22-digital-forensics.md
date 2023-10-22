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
- [Module 5 - Memory Forensics](#module-5---memory-forensics)
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

## Module 5 - Memory Forensics

Covers the history of memory forensics and modern "von-neumann" computer architecture, followed by several memory management techniques and look at how these can be leveraged in forensic processes.

- Process concept
- Memory layout
- Process management
- Windows environment block
- Thread concept
- Thread management
- Virtual memory
- Page concept
- Memory protections
- Virtual Address Descriptor (VAD)
- Kernel interface
- Hibernation

THe tool of choice here is `volatility`, which I've dabbled with years ago at BSides.`volatility` is a framework that analyses memory dumps from 32 and 64-bit Windows, Linux, Mac, and Android systems. The framework is many things: open-source; written in Python; operable on Windows, macOS, and Linux; extensible and scriptable; unparalleled in the number of feature sets provided which are based on reverse engineering and specialist research; comprehensively supportive of most memory file formats; fast and efficient; and backed by a large and active community, including both users and contributors.

[Volatility cheat sheet](https://downloads.volatilityfoundation.org/releases/2.4/CheatSheet_v2.4.pdf)


Fireeye have a fork that adds support for decompressing Windows 10 memory pages.

`volatility` is very extensible, baseline your specific installation to see how its configured:

```bash
$ vol2.py --info
Volatility Foundation Volatility Framework 2.6.1

Profiles
--------
VistaSP0x64           - A Profile for Windows Vista SP0 x64
VistaSP0x86           - A Profile for Windows Vista SP0 x86
VistaSP1x64           - A Profile for Windows Vista SP1 x64
VistaSP1x86           - A Profile for Windows Vista SP1 x86
VistaSP2x64           - A Profile for Windows Vista SP2 x64
VistaSP2x86           - A Profile for Windows Vista SP2 x86
Win10x64              - A Profile for Windows 10 x64
Win10x64_10240_17770  - A Profile for Windows 10 x64 (10.0.10240.17770 / 2018-02-10)
Win10x64_10586        - A Profile for Windows 10 x64 (10.0.10586.306 / 2016-04-23)
...

Plugins
-------
amcache                    - Print AmCache information
apihooks                   - Detect API hooks in process and kernel memory
atoms                      - Print session and window station atom tables
atomscan                   - Pool scanner for atom tables
auditpol                   - Prints out the Audit Policies from HKLM\SECURITY\Policy\PolAdtEv
bigpools                   - Dump the big page pools using BigPagePoolScanner
bioskbd                    - Reads the keyboard buffer from Real Mode memory
...

Address Spaces
--------------
AMD64PagedMemory                  - Standard AMD 64-bit address space.
ArmAddressSpace                   - Address space for ARM processors
FileAddressSpace                  - This is a direct file AS.
HPAKAddressSpace                  - This AS supports the HPAK format
...
```

Lets first shake the dump down with `imageinfo`:

```bash
$ vol2.py imageinfo -f memory.dmp
Volatility Foundation Volatility Framework 2.6.1
          Suggested Profile(s) : Win10x64_17134, Win10x64_10240_17770, Win10x64_10586, Win10x64_14393, Win10x64, Win2016x64_14393, Win10x64_16299, Win10x64_17763, Win10x64_15063 (Instantiated with Win10x64_15063)
                     AS Layer1 : SkipDuplicatesAMD64PagedMemory (Kernel AS)
                     AS Layer2 : WindowsCrashDumpSpace64 (Unnamed AS)
                     AS Layer3 : FileAddressSpace (/mnt/hgfs/ZEIT8028/Lab05-MemoryForensics/Lab 5 - Memory Forensics/memory.dmp)
                      PAE type : No PAE
                           DTB : 0x1ad002L
                          KDBG : 0xf8067bea55e0L
          Number of Processors : 2
     Image Type (Service Pack) : 0
                KPCR for CPU 0 : 0xfffff8067aeec000L
                KPCR for CPU 1 : 0xffff89809f420000L
             KUSER_SHARED_DATA : 0xfffff78000000000L
           Image date and time : 2019-07-13 15:29:09 UTC+0000
     Image local date and time : 2019-07-13 15:29:09 +0000
```

Memory from a win10 system. Given its Windows lets get more specific with `kdbgscan` which will parse out the NT KDBG kernel structure which amoung many things includes system build and service pack metadata:

```bash
$ vol2.py -f memory.dmp kdbgscan
Volatility Foundation Volatility Framework 2.6.1
**************************************************
Instantiating KDBG using: Kernel AS Win10x64_14393 (6.4.14393 64bit)
Offset (V)                    : 0xf8067bea55e0
Offset (P)                    : 0x1ea55e0
KdCopyDataBlock (V)           : 0xf8067bd2cd68
Block encoded                 : No
Wait never                    : 0x6374c2003c046f78
Wait always                   : 0x7808e1376e99800
KDBG owner tag check          : True
Profile suggestion (KDBGHeader): Win10x64_14393
Version64                     : 0xf8067bea8dc0 (Major: 15, Minor: 17763)
Service Pack (CmNtCSDVersion) : 0
Build string (NtBuildLab)     : 17763.1.amd64fre.rs5_release.180
PsActiveProcessHead           : 0xfffff8067beb5680 (145 processes)
PsLoadedModuleList            : 0xfffff8067bec1a10 (158 modules)
KernelBase                    : 0xfffff8067baa2000 (Matches MZ: True)
Major (OptionalHeader)        : 10
Minor (OptionalHeader)        : 0
KPCR                          : 0xfffff8067aeec000 (CPU 0)
KPCR                          : 0xffff89809f420000 (CPU 1)
...
```

The various BuildStrings parsed out of KDBG structures, is most revealing, in this case the `Win10x64_17763` profile should be compatible with this particular memory dump.

Lets try and list running processes with `pslist` (or `pstree`) which will parse applicable NT kernel process management structures:

```bash
$ vol2.py -f memory.dmp --profile=Win10x64_17763 pslist
Volatility Foundation Volatility Framework 2.6.1
Offset(V)          Name                    PID   PPID   Thds     Hnds   Sess  Wow64 Start
------------------ -------------------- ------ ------ ------ -------- ------ ------ ------------------------------
0xffff9b01d206b040 System                    4      0    115        0 ------      0 2019-07-13 14:44:28 UTC+0000
0xffff9b01d2081080 Registry                 88      4      4        0 ------      0 2019-07-13 14:44:20 UTC+0000
0xffff9b01d2bba040 smss.exe                276      4      2        0 ------      0 2019-07-13 14:44:28 UTC+0000
0xffff9b01d2fe4140 csrss.exe               388    380     10        0      0      0 2019-07-13 14:44:30 UTC+0000
0xffff9b01d569a080 wininit.exe             468    380      1        0      0      0 2019-07-13 14:44:31 UTC+0000
0xffff9b01d570f080 services.exe            604    468      9        0      0      0 2019-07-13 14:44:31 UTC+0000
0xffff9b01d571b0c0 lsass.exe               624    468      9        0      0      0 2019-07-13 14:44:31 UTC+0000
0xffff9b01d579d200 svchost.exe             728    604      1        0      0      0 2019-07-13 14:44:33 UTC+0000
0xffff9b01d57a3100 fontdrvhost.ex          736    468      5        0      0      0 2019-07-13 14:44:33 UTC+0000
0xffff9b01d57cc200 svchost.exe             812    604     25        0      0      0 2019-07-13 14:44:33 UTC+0000
0xffff9b01d5e4e280 svchost.exe             860    604     16        0      0      0 2019-07-13 14:44:33 UTC+0000
...
```

Cool! Lets dig deeper by drilling into the security context (SID) of specific processes (PID):

```bash
$ vol2.py -f memory.dmp --profile=Win10x64_17763 getsids -p 8816,8728,8960,7320
Volatility Foundation Volatility Framework 2.6.1
notepadz.exe (8816): S-1-5-18 (Local System)
notepadz.exe (8816): S-1-5-32-544 (Administrators)
notepadz.exe (8816): S-1-1-0 (Everyone)
notepadz.exe (8816): S-1-5-11 (Authenticated Users)
notepadz.exe (8816): S-1-16-16384 (System Mandatory Level)
cmd.exe (8728): S-1-5-18 (Local System)
cmd.exe (8728): S-1-5-32-544 (Administrators)
cmd.exe (8728): S-1-1-0 (Everyone)
cmd.exe (8728): S-1-5-11 (Authenticated Users)
cmd.exe (8728): S-1-16-16384 (System Mandatory Level)
conhost.exe (8960): S-1-5-18 (Local System)
conhost.exe (8960): S-1-5-32-544 (Administrators)
conhost.exe (8960): S-1-1-0 (Everyone)
conhost.exe (8960): S-1-5-11 (Authenticated Users)
conhost.exe (8960): S-1-16-16384 (System Mandatory Level)
plink.exe (7320): S-1-5-18 (Local System)
plink.exe (7320): S-1-5-32-544 (Administrators)
plink.exe (7320): S-1-1-0 (Everyone)
plink.exe (7320): S-1-5-11 (Authenticated Users)
plink.exe (7320): S-1-16-16384 (System Mandatory Level)
```

The Windows Shimcache was created by Microsoft beginning in Windows XP to track compatibility issues with executed programs. This cache stores various file metadata depending on the operating system.

It’s important to understand there may be entries in the Shimcache that haven’t executed. There are two actions that can cause the Shimcache to record an entry:

1. A file is executed: this is recorded on all versions of Windows beginning with XP
2. On Windows Vista, 7, Server 2008, and Server 2012, the Application Experience Lookup Service may record Shimcache entries for files in a directory that a user interactively browses. For example, if a directory contains the files “foo.txt” and “bar.exe”, a Windows 7 system may record entries for these two files in the Shimcache

The serialised cache data associated with this information is stored in the Windows Registry in the following location, however it’s typically not written out until the system gracefully performs a shutdown:

`REG: HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache\`

`volatility` can parse both the unflushed in-memory shimcache (`shimcachemem`) and the persisted registry shimcache (`shimcache`):

```bash
$ vol2.py -f memory.dmp --profile=Win10x64_17763 shimcachemem
Volatility Foundation Volatility Framework 2.6.1
Order Last Modified         Last Update           Exec Flag  File Size  File Path
----- --------------------- --------------------- ---------- ---------- ---------
WARNING : volatility.debug    : Yara module is not installed
INFO    : volatility.debug    : Shimcache found at 0xffffb6041851b3b8
INFO    : volatility.debug    : Shimcache found at 0xffffb604184fdef8
    1 2019-07-13 15:26:45                                               C:\Users\Bob\AppData\Local\Microsoft\OneDrive\19.103.0527.0003\FileSyncConfig.exe
    2 2019-07-13 15:26:29                                               C:\Users\Bob\AppData\Local\Microsoft\OneDrive\Update\OneDriveSetup.exe
    3 2019-07-13 15:26:46                                               C:\Users\Bob\AppData\Local\Microsoft\OneDrive\OneDrive.exe
    4 2019-07-13 15:23:42                                               C:\Users\Bob\AppData\Local\Microsoft\OneDrive\18.143.0717.0002\FileSyncConfig.exe
    5 2019-05-12 23:36:44                                               C:\Users\Bob\Desktop\x64\mimikatz.exe
    6 2019-07-13 06:52:16                                               \\tsclient\stager\malicious.exe
    7 2019-07-13 06:53:55                                               \\tsclient\stager\notepadz.exe
    8 2018-09-15 07:28:20                                               C:\Windows\system32\AUDIODG.EXE
    9 2019-07-13 15:09:41                                               C:\Program Files\WindowsApps\Microsoft.WindowsStore_11905.1001.4.0_x64__8wekyb3d8bbwe\Application
...
```

Let go deeper with those suspicious looking processes. Hopefully some of their remnants will exist in the in-memory file system data structures. Extracting the MFT using the `mftparser` command, will output the MFT in a sleuthkit (tsk) body timeline format. [Andrea Fortuna](https://andreafortuna.org/2017/08/21/volatility-my-own-cheatsheet-part-8-filesystem/) has pro tips about `mftparser`. Also RTFM with `vol2.py -f memory.dmp --profile=Win10x64_17763 mftparser -h`


```bash
$ vol2.py -f memory.dmp --profile=Win10x64_17763 mftparser --output=body --output-file=mft.body
Volatility Foundation Volatility Framework 2.6.1
Outputting to: mft.body
Scanning for MFT entries and building directory, this can take a while
```


For analysis, convert the raw MFT bindump to a tsk (sleuthkit) timeline:

```bash
$ apropos mactime
mactime (1)          - Create an ASCII time line of file activity

$ mactime -b mft.body -d > mft.csv
```


Looking over the resident MFT data, its clear this system is compromised. Let figure out how the backdoor and persistence was achieved. `mftparser` can output as text (more verbose than the `mactime` conversion approach above):

```bash
$ vol2.py -f memory.dmp --profile=Win10x64_17763 mftparser --output=text --output-file=mft.txt
```

Next run some scans in `vim`:

```bash
$ vim mft.txt

***************************************************************************
***************************************************************************
MFT entry found at offset 0x10520000
Attribute: In Use & File
Record Number: 84896
Link count: 1


$STANDARD_INFORMATION
Creation                       Modified                       MFT Altered                    Access Date                    Type
------------------------------ ------------------------------ ------------------------------ ------------------------------ ----
2019-07-13 14:55:14 UTC+0000 2019-07-13 14:55:14 UTC+0000   2019-07-13 14:55:14 UTC+0000   2019-07-13 14:55:14 UTC+0000   Archive

$FILE_NAME
Creation                       Modified                       MFT Altered                    Access Date                    Name/Path
------------------------------ ------------------------------ ------------------------------ ------------------------------ ---------
2019-07-13 14:55:14 UTC+0000 2019-07-13 14:55:14 UTC+0000   2019-07-13 14:55:14 UTC+0000   2019-07-13 14:55:14 UTC+0000   Users\Alan\AppData\Local\Temp\Service.ps1

$DATA
0000000000: 24 70 61 74 68 20 3d 20 22 24 65 6e 76 3a 54 45   $path.=."$env:TE
0000000010: 4d 50 5c 6e 6f 74 65 70 61 64 7a 2e 65 78 65 22   MP\notepadz.exe"
0000000020: 0a 0a 69 66 20 28 54 65 73 74 2d 50 61 74 68 20   ..if.(Test-Path.
0000000030: 2d 50 61 74 68 20 24 70 61 74 68 29 20 7b 0a 20   -Path.$path).{..
0000000040: 20 20 20 4e 65 77 2d 53 65 72 76 69 63 65 20 2d   ...New-Service.-
0000000050: 4e 61 6d 65 20 22 4e 6f 74 65 70 61 64 7a 22 20   Name."Notepadz".
0000000060: 2d 42 69 6e 61 72 79 50 61 74 68 4e 61 6d 65 20   -BinaryPathName.
0000000070: 24 70 61 74 68 20 2d 44 69 73 70 6c 61 79 4e 61   $path.-DisplayNa
0000000080: 6d 65 20 22 4e 6f 74 65 70 61 64 7a 22 20 2d 44   me."Notepadz".-D
0000000090: 65 73 63 72 69 70 74 69 6f 6e 20 22 4e 6f 6e 2d   escription."Non-
00000000a0: 6d 61 6c 69 63 69 6f 75 73 20 4e 6f 74 65 70 61   malicious.Notepa
00000000b0: 64 22 20 2d 53 74 61 72 74 75 70 54 79 70 65 20   d".-StartupType.
00000000c0: 41 75 74 6f 6d 61 74 69 63 0a 20 20 20 20 53 74   Automatic.....St
00000000d0: 61 72 74 2d 53 65 72 76 69 63 65 20 2d 4e 61 6d   art-Service.-Nam
00000000e0: 65 20 22 4e 6f 74 65 70 61 64 7a 22 0a 7d         e."Notepadz".}
...
```

`mftparser` can extract such memory resident files specified as a comma delimetered list of offsets `-o <offset1>,<offset2>`) and dump their raw contents to a directory with `-D <dirname>`:

```bash
$ vol2.py -f memory.dmp --profile=Win10x64_17763 mftparser -o 0x10520000,0x117926000,0x11f04a800 -D ./resident/
Volatility Foundation Volatility Framework 2.6.1
***************************************************************************
MFT entry found at offset 0x10520000
Attribute: In Use & File
Record Number: 84896
Link count: 1
...
```



## Resources and coolness

- Windows shellbags
- 8 timestamps on an NTFS file system, an attacker can fairly easily mutate 4 of them, hard to convincingly adjust nano-second level
- [Eric Zimmermans Windows Forensics Tools]()
- [SANS Hunt Evil Poster](https://www.sans.org/posters/hunt-evil/) Knowing what’s normal on a Windows host helps cut through the noise to quickly locate potential malware. Use this information as a reference to know what’s normal in Windows and to focus your attention on the outliers.
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
