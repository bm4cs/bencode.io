---
layout: post
title: "Managing wifi on Arch"
date: "2020-03-16 17:47:10"
comments: false
categories:
- sysadmin
tags:
- wifi
---

See [archwiki](https://wiki.archlinux.org/index.php/NetworkManager#nmcli_examples):

`nmcli device wifi list` sniff currently available wifi ssids in range
`nmcli connection show` show active connection/s
`nmcli device wifi connect Jeneffer password S3CR3T` connect to ssid
`nmcli device wifi connect Jeneffer password S3CR3T hidden yes` connect to hidden ssid
`nmcli connection up uuid UUID` reconnect a disconnected interface
`nmcli device` list all interfaces and their state
`mcli device disconnect wlp3s0` disconnect an interface
`nmcli radio wifi off` disable wifi radio


