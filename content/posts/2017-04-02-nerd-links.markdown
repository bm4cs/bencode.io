---
layout: post
title: "Nerd Links"
slug: "links"
date: "2017-04-02 13:38:10"
lastmod: "2020-04-29 10:43:10"
comments: false
categories:
- geek
---

This is a list of valuable (to me) resources that I've managed to stumble across (hacker news, lobste.rs, cron.weekly) for learning more about mostly technology related topics.

<!-- vim-markdown-toc GFM -->

* [Architecture](#architecture)
* [C](#c)
* [Containers](#containers)
* [Culture](#culture)
* [Databases](#databases)
* [Cloud](#cloud)
* [Git](#git)
* [Linux](#linux)
* [Networking](#networking)
* [Open source](#open-source)
* [Security](#security)
* [Serialization](#serialization)
* [systemd](#systemd)
* [Text wrangling](#text-wrangling)
* [Vim](#vim)
* [Web](#web)

<!-- vim-markdown-toc -->



# Architecture

- [You Are Not Google](https://blog.bradfieldcs.com/you-are-not-google-84912cf44afb) if you’re using a technology that originated at a large company, but your use case is very different, it’s unlikely that you arrived there deliberately; no, it’s more likely you got there through a ritualistic belief that imitating the giants would bring the same riches.
- [Communicating Sequential Processes](http://www.usingcsp.com/cspbook.pdf) Tony Hoare's seminal 1977 paper on concurrency and CSP



# C

- [Easy Makefile](https://github.com/mortie/easy-makefile/) a Makefile boilerplate to hit the ground running



# Containers

- [25 Basic Docker Commands for Beginners](https://codeopolis.com/posts/25-basic-docker-commands-for-beginners/)
- [Setting the Record Straight: containers vs. Zones vs. Jails vs. VMs]()
- [Docker Security Best Practices](https://blog.sqreen.io/docker-security/) tools and methods to help secure Docker
- [Kubernetes Workshop](http://www.zoobab.com/kubernetes-workshop) tons of details for getting started



# Culture

- [GitLab's Guide to All-Remote](https://about.gitlab.com/company/culture/all-remote/guide/) the remote manifesto, tips and tricks and remote resources



# Databases

- [Things I Wished More Developers Knew About Databases](https://medium.com/@rakyll/things-i-wished-more-developers-knew-about-databases-2d0178464f78) 
- [Introduction to Apache Hadoop (The Linux Foundation)](https://www.edx.org/course/introduction-apache-hadoop-linuxfoundationx-lfs103x#!)



# Cloud

- [mcm](https://zombiezen.github.io/mcm/) Minimal Configuration Manager
- [Packer](https://www.hashicorp.com/blog/packer-1-0/) a tool for building images for cloud platforms, virtual machines, containers and more from a single source configuration.
- [CloudBoost](https://www.cloudboost.io/) a complete serverless platform for your app.
- [The Google Cloud Developer's Cheat Sheet](https://github.com/gregsramblings/google-cloud-4-words) every product in the Google Cloud family described in <=4 words



# Git

- [Better Git configuration](https://blog.scottnonnenberg.com/better-git-configuration) links and resources on configuring & using git



# Linux


- [An In-Depth Guide to iptables](https://www.booleanworld.com/depth-guide-iptables-linux-firewall/) covers pretty much every angle of iptables, from basic rules to NAT'ing to protocols and interfaces.
- [mdadm Cheat Sheet](http://www.ducea.com/2009/03/08/mdadm-cheat-sheet/) practical commands when running software raid on Linux
- [Async IO on Linux: select, poll, and epoll](https://jvns.ca/blog/2017/06/03/async-io-on-linux--select--poll--and-epoll/) thorough write-up on 'select', 'poll' and 'epoll' system calls, and how to measure them.
- [The first 5 things to do when your Linux server keels over](https://insights.hpe.com/articles/the-first-5-things-to-do-when-your-linux-server-keels-over-1705.html) including hardware troubleshooting, checking the running state of applications
- [How io_uring and eBPF Will Revolutionize Programming in Linux](https://thenewstack.io/how-io_uring-and-ebpf-will-revolutionize-programming-in-linux/) well explained history of Linux syscalls and their limitations, and how `io_uring` is a game changer by allowing async I/O via a pub/sub model
- [bashtop](https://github.com/aristocratos/bashtop) gamified TUI resource monitor that shows usage and stats for processor, memory, disks, network and processes





# Networking

- [59 Linux Networking commands and scripts](https://haydenjames.io/linux-networking-commands-scripts/) the ultimate network tools goto list.
- [Introduction to tcpdump and wireshark](https://www.linux.com/blog/learn/chapter/linux-security/2017/2/linux-security-fundamentals-part-5-introduction-tcpdump-and-wireshark)
- [hping3](https://linux.die.net/man/8/hping3) send arbitary TCP/IP packets to network hosts
- [Setting up a Linux mail server](https://likegeeks.com/linux-mail-server/)
- [linker∙d](https://linkerd.io/) dynamic linker for microservices, taking care of the communication work needed to interact with distributed services, including routing, load balancing, and retrying.  
- [Manually Throttle the Bandwidth of a Linux Network Interface](http://mark.koli.ch/slowdown-throttle-bandwidth-linux-network-interface) introduction to the `tc` tool for bandwidth shaping.
- [connbeat](https://github.com/raboof/connbeat) agent that monitors TCP connection metadata and ships the data to Kafka or Elasticsearch, or an HTTP endpoint




# Open source

- [Google Open Source](https://opensource.google.com/projects/explore/featured) 2000+ OSS projects managed by Google
- [NSA on GitHub](https://nationalsecurityagency.github.io)



# Security

- [Linux reverse engineering 101](https://github.com/michalmalik/linux-re-101) collection of resources for linux reverse engineering.
- [Explain like I'm 5: Kerberos](http://www.roguelynn.com/words/explain-like-im-5-kerberos) 



# Serialization

- [Cap'n Proto](https://capnproto.org/)
- [Google Protocol Buffers](https://github.com/google/protobuf)



# systemd

- [Why I Prefer systemd Timers Over Cron](https://trstringer.com/systemd-timer-vs-cronjob/)
- [journal-triggerd](https://github.com/jjk-jacky/journal-triggerd) runs trigger on systemd's journal messages.
- [How to automatically execute shell script at startup boot on systemd](https://linuxconfig.org/how-to-automatically-execute-shell-script-at-startup-boot-on-systemd-linux)



# Text wrangling

- [desed](https://github.com/SoptikHa2/desed) beautiful TUI that provides users with comfortable interface and practical debugger, used to step through complex sed scripts
- [sed One Liners](http://www.pement.org/sed/sed1line.txt) huge collection of useful sed examples
- [xsv](https://github.com/BurntSushi/xsv) CLI for indexing, slicing, analyzing, splitting and joining CSV files



# Vim

- [An Introduction to Vim for SysAdmins](https://www.linux.com/learn/intro-to-linux/2017/2/vim-sysadmins)



# Web

- [webpack](https://webpack.github.io/) webpack is a module bundler; it takes modules with dependencies and emits flat static assets.

