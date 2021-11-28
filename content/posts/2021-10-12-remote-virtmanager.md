---
layout: post
title: "Remote KVM using virt-manager and qemu+ssh"
draft: true
date: "2021-10-12 17:22:22"
lastmod: "2021-10-12 17:22:22"
comments: false
categories:
  - linux
tags:
  - linux
  - kvm
  - virtualisation
---


```
Unable to connect to libvirt qemu+ssh://ben@192.168.1.101/system.

authentication unavailable: no polkit agent available to authenticate action 'org.libvirt.unix.manage'

Verify that the 'libvirtd' daemon is running on the remote host.

Libvirt URI is: qemu+ssh://ben@192.168.1.101/system
```