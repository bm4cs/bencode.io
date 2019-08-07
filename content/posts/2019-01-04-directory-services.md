---
layout: post
title: "SSO with Active Directory"
date: "2019-01-04 11:10:10"
comments: false
categories: 
- dev
tags:
- ldap
- kerberos
- sssd
- nss
---

Providing SSO by integrating Linux (or FreeBSD) with a directory service, like Microsoft Active Directory (AD), is no where as daunting as it once was, and highlights some fascinating subsystems that enable users to be defined from a variety of data sources (such as LDAP) other than just the traditional `/etc/passwd` file.



- [Initial setup](#initial-setup)
- [Kerberos](#kerberos)
  - [Create service keytab on AD](#create-service-keytab-on-ad)
- [System Security Services Daemon (sssd)](#system-security-services-daemon-sssd)
- [Name Service Switch (nss)](#name-service-switch-nss)
- [PAM (Pluggable Authentication Module)](#pam-pluggable-authentication-module)
- [Testing](#testing)
  - [Listing Users](#listing-users)
  - [Listing Groups](#listing-groups)
  - [id](#id)
- [Troubleshooting](#troubleshooting)
  - [Samba (smbd) Join Issues](#samba-smbd-join-issues)
  - [Clock Synchronisation Issues](#clock-synchronisation-issues)
  - [Clearing SSSD Cache](#clearing-sssd-cache)
- [End to end script (for Ansible)](#end-to-end-script-for-ansible)



# Initial setup

Update `/etc/resolv.conf` to bind to the AD DNS server. This will enable `realmd` to discover and join the active directory domain (i.e. kerberos realm).

    nameserver 192.168.56.101

Update `/etc/hostname`, ensuring the host has a meaningful name suffixed with the domain that it will be joining (e.g. `host1.bencode.net`). Tip if `realm join` gives the error message *realm: Couldn’t join realm: This computer’s host name is not set correctly* then you know you forgot to do this:

    heaphy.bencode.net

Install `realm` dependency packages, `pytalloc`, `samba-common-tools` and `samba-libs`. If offline, `realm join` will attempt to do this:

    yum install pytalloc samba-common-tools samba-libs





# Kerberos

Designed at MIT, is an authentication system that guarantees that users and services are who they claim to be. Using crypto to make nested sets of credentials called *tickets*, they are passed around the network for certify identity and provide access to network services.

To gain a deeper conceptualisation, its hard to beat Bill Bryant's brilliant [Designing an Authentication System: A Dialogue in Four Scenes](https://web.mit.edu/kerberos/dialogue.html).

## Create service keytab on AD

While there are a few ways to create the Kerberos keytab, I struggled with all of them, except using this (AD based) method. When the keytab file just doesn't cut it, `sssd` will simply log:

> Failed to initialize credentials using keytab \[MEMORY:/etc/krb5.keytab\]: KDC reply did not match expectations. Unable to create GSSAPI-encrypted LDAP connection.

As per the [doco](https://docs.pagure.org/SSSD.sssd/users/ldap_with_ad.html), to connect my RHEL box (called `HEAPHY`) to the *bencode.net* AD domain.

* If needed, on the DC, using the *users and computers* MMC snap-in, create computer object for the Linux host attempting to join the domain.
* On a command prompt run:
  * `setspn -A host/heaphy.bencode.net@BENCODE.NET HEAPHY`
  * `setspn -L HEAPHY`
  * `ktpass /princ host/heaphy.bencode.net@BENCODE.NET /out krb5.keytab /crypto all /ptype KRB5_NT_PRINCIPAL -desonly /mapuser BENCODE\HEAPHY$ /pass \*`
* This sets the machine account password, and UPN for the principal.
* Transfer the keytab file to the Linux host, placing it at `/etc/krb5.keytab`
* Ensure `root:root` ownership, and `0600` permissions.

Next up, setup `/etc/krb5.conf`:


    includedir /etc/krb5.conf.d/
    
    [logging]
     default = FILE:/var/log/krb5libs.log
     kdc = FILE:/var/log/krb5kdc.log
     admin_server = FILE:/var/log/kadmind.log
    
    [libdefaults]
     dns_lookup_realm = true
     dns_lookup_kdc = true
     ticket_lifetime = 24h
     renew_lifetime = 7d
     forwardable = true
     rdns = false
     default_realm = BENCODE.NET
     default_tkt_enctypes = arcfour-hmac
     #default_keytab_name = FILE:/etc/krb5.keytab
    
    [realms]
     #BENCODE.NET = {
      #kdc = dodgy-dc.bencode.net
      #admin_server = dodgy-dc.bencode.net
     #}
    
    [domain_realm]
     #.bencode.net = BENCODE.NET
     #bencode.net = BENCODE.NET


Verify a Kerberos ticket and session can be obtained:

    kinit -k host/heaphy.bencode.net

Then list ticket grants:

    klist -ke




# System Security Services Daemon (sssd)

`sssd` is a one stop shop for identity wrangling, authentication, caching and account mapping. It supports authentication through LDAP and Kerberos. `sssd` only supports authentication over encrypted connections (i.e. LDAPS or TLS). The offical [documentation](https://docs.pagure.org/SSSD.sssd/users/ldap_with_ad.html) was a god send. A sample RHEL 7 `/etc/sssd/sssd.conf` for integration with a Windows 2016 AD configuration:

    [sssd]
    domains = bencode.net
    config_file_version = 2
    services = nss, pam
    
    [domain/bencode.net]
    enumerate = true
    id_provider = ad
    auth_provider = krb5
    access_provider = ad
    chpass_provider = ad
    ad_domain = bencode.net
    realmd_tags = manages-system joined-with-samba 
    cache_credentials = True
    krb5_realm = BENCODE.NET
    krb5_server = dodgy-dc.bencode.net
    krb5_kpasswd = dodgy-dc.bencode.net
    krb5_ccachedir = /tmp
    krb5_store_password_if_offline = True
    default_shell = /bin/bash
    ldap_id_mapping = True
    ldap_idmap_autorid_compat = True
    ldap_max_id = 2000200000
    ldap_idmap_range_size = 2000000000
    fallback_homedir = /home/%u@%d

After updating `sssd.conf`, bounce the service `systemctl restart sssd`, and tail the logs `less +F /var/log/messages`, before doing the restart, as any issues will be immediately logged.

Once `sssd` is setup to interface with an LDAP or Kerberos domain, the system needs to be configured to use it as the source for identity and authentication information. Two elegantly designed security systems, known as the name service switch and PAM, provide this.



# Name Service Switch (nss)

Created to ease the selection between various configuration databases (e.g. for user identity) and name resolution mechanisms. Configured by `/etc/nsswitch.conf`, the syntax is simple, specify the type of lookup (e.g. passwd for users) and the list of sources in the order they should be queried. For example:

    passwd: files sss
    shadow: files sss
    group: files sss

Instructs `nss` to consult the local `passwd`, `group` and `shadow` files first, but then defer to Active Directory (or any LDAP store) by consulting `sssd`.


# PAM (Pluggable Authentication Module)

PAM is great.

    # authconfig --enablesssd --enablesssdauth --enablemkhomedir --update



# Testing

Now everything just works, you can list out users and groups with `getent`. 

First ensure there are some custom user objects exist in the AD domain.

![Active Directory Users](/images/adusers.png "Active Directory Users")


## Listing Users

Note that normally `sssd` would not accept `getent passwd` without a specify set of users, as this implies you want to list every single user object in the LDAP directory (not a great idea). I have overriden this for testing by adding `enumerate = true` to `sssd.conf` as I have done above.

    $ getent passwd
    root:x:0:0:root:/root:/bin/bash
    adm:x:3:4:adm:/var/adm:/sbin/nologin
    ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
    ben:x:1000:1000:ben:/home/ben:/bin/bash
    geoclue:x:996:994:User for geoclue:/var/lib/geoclue:/sbin/nologin
    rpc:x:32:32:Rpcbind Daemon:/var/lib/rpcbind:/sbin/nologin
    gluster:x:995:991:GlusterFS daemons:/run/gluster:/sbin/nologin
    tcpdump:x:72:72::/:/sbin/nologin
    abrt:x:173:173::/etc/abrt:/sbin/nologin
    dodgy-dc$:*:201000:200516:DODGY-DC:/home/dodgy-dc$@bencode.net:/bin/bash
    heaphy$:*:201106:200515:HEAPHY:/home/heaphy$@bencode.net:/bin/bash
    krbtgt:*:200502:200513:krbtgt:/home/krbtgt@bencode.net:/bin/bash
    tridge:*:201108:200513:Andrew Tridgell:/home/tridge@bencode.net:/bin/bash
    guest:*:200501:200514:Guest:/home/guest@bencode.net:/bin/bash
    administrator:*:200500:200513:Administrator:/home/administrator@bencode.net:/bin/bash
    brightw:*:201110:200513:Walter Bright:/home/brightw@bencode.net:/bin/bash
    piker:*:201105:200513:Rob RP. Pike:/home/piker@bencode.net:/bin/bash
    defaultaccount:*:200503:200513:DefaultAccount:/home/defaultaccount@bencode.net:/bin/bash
    tanena:*:201109:200513:Andrew Tanenbaum:/home/tanena@bencode.net:/bin/bash

Nice! The AD user objects stand out with their high UID values (which start from 201000).

These users can be used like a vanilla (local) users, example:

    # su - tridge
    Creating home directory for tridge.
    
    $ date +%A
    Sunday
    
    $ pwd
    /home/tridge@bencode.net


## Listing Groups

Again done with `getent`:

    $ getent group
    root:x:0:
    wheel:x:10:ben
    cdrom:x:11:
    mail:x:12:postfix
    games:x:20:
    users:x:100:
    chrony:x:988:
    domain admins:*:200512:administrator
    group policy creator owners:*:200520:administrator
    dnsadmins:*:201101:
    kerneldevs:*:201107:tridge,piker
    enterprise admins:*:200519:administrator
    domain guests:*:200514:guest
    allowed rodc password replication group:*:200571:
    denied rodc password replication group:*:200572:krbtgt,administrator,dodgy-dc$
    developers:*:201103:
    read-only domain controllers:*:200521:
    schema admins:*:200518:administrator
    ras and ias servers:*:200553:
    domain users:*:200513:administrator,defaultaccount,krbtgt,piker,tridge,tanena,brightw

Groups with high GID (200000+) are AD domain groups.


## id

    $ id piker
    uid=201105(piker) gid=200513(domain users) groups=200513(domain users),201107(kerneldevs)



# Troubleshooting

## Samba (smbd) Join Issues

I noticed when running through the setup that `smbd` unlinked from the domain somehow, in syslog you'll get a:

> kerberos_kinit_password SERVER$@COMPANY.COM failed: Preauthentication failed

To reproduce try:

    net ads testjoin

Joining the domain again made this go away (root cause remains unknown):

    net ads join -U Administrator
    net ads info


## Clock Synchronisation Issues

Make sure that clocks of all hosts participating in the Kerberos realm are syncrhonised. In my fake enterprise network, I just set the NTP server up on the DC, and have the NTP client on the Unix boxes point to it. Kerberos is very sensative about accurate time. If clock discrepencies are detected `sssd` log:

> TSIG error with server: clocks are unsynchronized


To setup an NTP server on the Windows DC, in PowerShell run:

    w32tm /config /manualpeerlist:pool.ntp.org /syncfromflags:MANUAL
    Stop-Service w32time
    Start-Service w32time

Then on the RHEL machines, that are using AD for SSO, register the DC in `/etc/ntp.conf`:

    server dodgy-dc.bencode.net prefer

Then force a sync (the IP of the DC):

    ntpdate -u 192.168.56.101


## Clearing SSSD Cache

To invalidate all cached entries:

    $ sudo sss_cache -E

Or brute force:

    $ sudo systemctl stop sssd
    $ sudo rm -rf /var/lib/sss/db/*
    $ sudo systemctl start sssd



# End to end script (for Ansible)

[Found](https://docs.pagure.org/SSSD.sssd/users/ldap_with_ad.html) this gem when banging my head against the Kerberos Active Directory wall. This will be very handy for scripting this procedure with Ansible. Note this configures things slightly differently to my working config outlined above, but gives a good gist for taking a scripting approach to things.


    export SETUP_ADDOMAIN=SITE.LOCAL
    export SETUP_FQDOMAIN=site.local
    export SETUP_ADMIN_USER=joiner
    export SETUP_ADMIN_PASSWORD="nacho libre is king"
    export SETUP_ADMIN_GROUP="domain admins"
    
    alias install="yum install -y"
    
    
    export SETUP_DC=$( adcli info ${SETUP_ADDOMAIN} | grep '^domain-controllers = ' | awk '{print $3}' )
    
    # configure kerberos
    cat > /etc/krb5.conf << EOM
    
    [logging]
     default = FILE:/var/log/krb5libs.log
     kdc = FILE:/var/log/krb5kdc.log
     admin_server = FILE:/var/log/kadmind.log
    
    [libdefaults]
     default_realm = ${SETUP_ADDOMAIN}
     dns_lookup_realm = true
     dns_lookup_kdc = true
     ticket_lifetime = 24h
     renew_lifetime = 7d
     forwardable = true
     default_keytab_name = FILE:/etc/krb5.keytab
    
    [realms]
     ${SETUP_ADDOMAIN} = {
      kdc = ${SETUP_DC}
      admin_server = ${SETUP_DC}
     }
    
    [domain_realm]
     .${SETUP_FQDOMAIN} = ${SETUP_ADDOMAIN}
     ${SETUP_FQDOMAIN} = ${SETUP_ADDOMAIN}
    
    EOM
    
    # configure sssd
    
    install sssd
    
    cat >  /etc/sssd/sssd.conf << EOM
    
    [sssd]
    services = nss, pam, ssh, pac
    config_file_version = 2
    domains = ${SETUP_ADDOMAIN}
    
    [domain/${SETUP_ADDOMAIN}]
    ad_domain = ${SETUP_ADDOMAIN}
    krb5_realm = ${SETUP_ADDOMAIN}
    cache_credentials = True
    id_provider = ad
    auth_provider = krb5
    krb5_server = ${SETUP_DC}
    krb5_ccachedir = /tmp
    krb5_store_password_if_offline = True
    default_shell = /bin/bash
    #use_full_qualified_names = False
    override_homedir = /home/%u
    ldap_id_mapping = True
    # ldap_idmap_default_domain_sid = <sid>
    ldap_idmap_autorid_compat = True
    ldap_max_id = 2000200000
    ldap_idmap_range_size = 2000000000
    access_provider = ad
    chpass_provider = ad
    
    # enable dynamic dns updates
    dyndns_update = true
    dyndns_refresh_interval = 43200
    dyndns_update_ptr = true
    dyndns_ttl = 3600
    
    EOM
    
    chmod 600 /etc/sssd/sssd.conf
    
    # install keytab with ktutil
    ktutil << EOM
    addent -password -p ${SETUP_ADMIN_USER}@${SETUP_ADDOMAIN} -k 1 -e rc4-hmac
    ${SETUP_ADMIN_PASSWORD}
    wkt /etc/krb5.keytab
    quit
    EOM
    
    # enable sssd
    authconfig --enablesssd --enablesssdauth --enablemkhomedir --update
    
    systemctl enable sssd
    systemctl start sssd
    
    # join domain from the sssd side
    echo -n ${SETUP_ADMIN_PASSWORD} | adcli join --stdin-password -U ${SETUP_ADMIN_USER} ${SETUP_ADDOMAIN}
    
    # configure samba (member server is default configuration)
    
    install samba
    
    cat > /etc/samba/smb.conf << EOM
    [global]
      workgroup = $( echo $SETUP_ADDOMAIN | cut -d. -f1 )
      realm = ${SETUP_ADDOMAIN}
      netbios name = ${SETUP_HOSTNAME}
      password server = *
      server string = Samba Server Version %v
      security = ADS
      log file = /var/log/samba/log.%m
      max log size = 5000
      load printers = No
      idmap config * : backend = tdb
      log level = 4
      local master = no
      domain master = no
      preferred master = no
      wins support = no
      wins proxy = no
      dns proxy = yes
      name resolve order = wins bcast host lmhosts
      obey pam restrictions = yes
      
    [homes]
      comment = Home Directories
      browseable = no
      writable = yes
      valid users = @"domain users${SETUP_FQDOMAIN}"
      path = /home/%U
    EOM
    
    
    # join domain from the samba side
    echo -n ${SETUP_ADMIN_PASSWORD} | net ads join -U ${SETUP_ADMIN_USER}
    
    systemctl enable smb
    systemctl start smb
    
    # sss takes over /etc/nsswitch for sudoers. remove that (avoids frequent "SECURITY information" emails in debian)
    sudo sed -i /^sudoers:/s/sss// /etc/nsswitch.conf
    
    # configure selinux
    setsebool -P samba_create_home_dirs on
    setsebool -P samba_enable_home_dirs on
    setsebool -P use_samba_home_dirs on
    
    # NOTE: Read samba_selinux(8) man page for configuring shares


