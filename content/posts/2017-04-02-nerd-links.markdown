---
layout: post
title: "Nerd Links"
slug: "links"
date: "2017-04-02 13:38:10"
lastmod: "2020-05-21 20:37:20"
comments: false
categories:
    - geek
---

This is a list of valuable (to me) resources that I've managed to stumble across (hacker news, lobste.rs, cron.weekly) for learning more about mostly technology related topics.

<!-- vim-markdown-toc GFM -->

* [Architecture](#architecture)
* [Awesome](#awesome)
* [C](#c)
* [Cloud](#cloud)
* [Containers](#containers)
* [Culture](#culture)
* [Databases](#databases)
* [Development](#development)
* [Git](#git)
* [Golang](#golang)
* [Hardware](#hardware)
* [Linux](#linux)
* [Monitoring](#monitoring)
* [Networking](#networking)
* [Open source](#open-source)
* [Security](#security)
* [Serialization](#serialization)
* [Shell](#shell)
* [systemd](#systemd)
* [Text wrangling](#text-wrangling)
* [Vim](#vim)
* [Web](#web)

<!-- vim-markdown-toc -->

# Architecture

-   [Communicating Sequential Processes](http://www.usingcsp.com/cspbook.pdf) Tony Hoare's seminal 1977 paper on concurrency and CSP
-   [Why Segment Went Back to a Monolith](https://www.infoq.com/news/2020/04/microservices-back-again/) microservices come with serious tradeoffs

# Awesome

-   [awesome-baremetal](https://github.com/alexellis/awesome-baremetal)
-   [awesome-kubernetes](https://github.com/ramitsurana/awesome-kubernetes)

# C

-   [Easy Makefile](https://github.com/mortie/easy-makefile/) a Makefile boilerplate to hit the ground running

# Cloud

-   [mcm](https://zombiezen.github.io/mcm/) Minimal Configuration Manager
-   [Packer](https://www.hashicorp.com/blog/packer-1-0/) a tool for building images for cloud platforms, virtual machines, containers and more from a single source configuration.
-   [CloudBoost](https://www.cloudboost.io/) a complete serverless platform for your app.
-   [The Google Cloud Developer's Cheat Sheet](https://github.com/gregsramblings/google-cloud-4-words) every product in the Google Cloud family described in <=4 words
-   [Ask HN: Is Your Company Sticking to On-Premise Servers? Why?](https://news.ycombinator.com/item?id=23089999)
-   [Using AWS CodeBuild to Execute Administrative Tasks](https://aws.amazon.com/blogs/devops/using-aws-codebuild-to-execute-administrative-tasks/)

# Containers

-   [The Docker Handbook](https://www.freecodecamp.org/news/the-docker-handbook/)
-   [25 Basic Docker Commands for Beginners](https://codeopolis.com/posts/25-basic-docker-commands-for-beginners/)
-   [Setting the Record Straight: containers vs. Zones vs. Jails vs. VMs]()
-   [Docker Security Best Practices](https://blog.sqreen.io/docker-security/) tools and methods to help secure Docker
-   [Kubernetes Workshop](http://www.zoobab.com/kubernetes-workshop) tons of details for getting started
-   [10 Most Common Mistakes When Using Kubernetes](https://blog.pipetail.io/posts/2020-05-04-most-common-mistakes-k8s/)
-   [lens](https://github.com/lensapp/lens/) kube IDE
-   [kubeseal](https://crypt.codemancers.com/posts/2020-04-27-encrypting-and-storing-kubernetes-secrets-in-git/) how to safely store secrets in `git` if you want to use them in k8s
-   [Container Technologies at Coinbase](https://blog.coinbase.com/container-technologies-at-coinbase-d4ae118dcb6c) great history on how the industry got to containers, an why kubernetes isn't used
-   [A Practical Introduction to Container Security](https://cloudberry.engineering/article/practical-introduction-container-security/)

# Culture

-   [You Are Not Google](https://blog.bradfieldcs.com/you-are-not-google-84912cf44afb) if you’re using a technology that originated at a large company, but your use case is very different, it’s unlikely that you arrived there deliberately; no, it’s more likely you got there through a ritualistic belief that imitating the giants would bring the same riches.
-   [GitLab's Guide to All-Remote](https://about.gitlab.com/company/culture/all-remote/guide/) the remote manifesto, tips and tricks and remote resources
-   [Why we at $FAMOUS_COMPANY Switched to $HYPED_TECHNOLOGY](https://saagarjha.com/blog/2020/05/10/why-we-at-famous-company-switched-to-hyped-technology/)
-   [Habbits of High-Functioning Software Teams](https://deniseyu.io/2020/05/23/habits-of-high-performing-teams.html) characteristics and habits of the highest-performing dev teams

# Databases

-   [Things I Wished More Developers Knew About Databases](https://medium.com/@rakyll/things-i-wished-more-developers-knew-about-databases-2d0178464f78)
-   [SQL Coding Standards](http://wiki.c2.com/?AntiPatternsCatalog)

# Development

-   [What To Code](https://what-to-code.com) inspiration and ideas
-   [Why the developers who use Rust love it so much](https://stackoverflow.blog/2020/06/05/why-the-developers-who-use-rust-love-it-so-much/)
-   [Smocker](https://smocker.dev/) simple HTTP mock server, uses YAML to define mocks and responses

# Git

-   [Better Git configuration](https://blog.scottnonnenberg.com/better-git-configuration) links and resources on configuring & using git
-   [Automate Repetitive Tasks with Custom git Commands](https://gitbetter.substack.com/p/automate-repetitive-tasks-with-custom) how to write custom git commands

# Golang

-   [Containerize Your Go Developer Environment – Part 1](https://www.docker.com/blog/containerize-your-go-developer-environment-part-1/)
-   [Communicating Between Python and Go with gRPC](https://www.ardanlabs.com/blog/2020/06/python-go-grpc.html)
-   [GoFakeIt: A Random Fake Data Generator](https://github.com/brianvoe/gofakeit) over 120 functions for generating things like names, emails, locations, user agents, ...
-   [Exploring the Container Packages (list, ring, and heap)](https://therebelsource.com/blog/exploring-container-package-in-go-list-ring-and-heap/9zTBiMaaYg)
-   [LearnGo: A Large Collection of Go Examples, Exercises, and Quizzes](https://github.com/inancgumus/learngo)
-   [Writing Go CLIs With Just Enough Architecture](https://blog.carlmjohnson.net/post/2020/go-cli-how-to-and-advice/)
-   [A Go RabbitMQ Beginners' Tutorial](https://www.youtube.com/watch?v=pAXp6o-zWS4)
-   [Getting Hands-On with io_uring from Go](https://developers.mattermost.com/blog/hands-on-iouring-go/)
-   [RobotGo: Native Cross-Platform GUI Automation](https://github.com/go-vgo/robotgo) control the pointer, keyboard, read the screen, to automate many computer-based jobs
-   [Diving Into Go by Building a CLI Application](https://eryb.space/2020/05/27/diving-into-go-by-building-a-cli-application.html)
-   [Immutability Patterns in Go](https://rauljordan.com/2020/05/25/immutability-patterns-in-go.html)
-   [Writing An Interpreter In Go](https://interpreterbook.com/)

# Hardware

-   [Backblaze hard drive stats](https://www.backblaze.com/blog/backblaze-hard-drive-stats-q1-2020/)

# Linux

-   [An In-Depth Guide to iptables](https://www.booleanworld.com/depth-guide-iptables-linux-firewall/) covers pretty much every angle of iptables, from basic rules to NAT'ing to protocols and interfaces.
-   [mdadm Cheat Sheet](http://www.ducea.com/2009/03/08/mdadm-cheat-sheet/) practical commands when running software raid on Linux
-   [Async IO on Linux: select, poll, and epoll](https://jvns.ca/blog/2017/06/03/async-io-on-linux--select--poll--and-epoll/) thorough write-up on 'select', 'poll' and 'epoll' system calls, and how to measure them.
-   [The first 5 things to do when your Linux server keels over](https://insights.hpe.com/articles/the-first-5-things-to-do-when-your-linux-server-keels-over-1705.html) including hardware troubleshooting, checking the running state of applications
-   [How io_uring and eBPF Will Revolutionize Programming in Linux](https://thenewstack.io/how-io_uring-and-ebpf-will-revolutionize-programming-in-linux/) well explained history of Linux syscalls and their limitations, and how `io_uring` is a game changer by allowing async I/O via a pub/sub model
-   [bashtop](https://github.com/aristocratos/bashtop) gamified TUI resource monitor that shows usage and stats for processor, memory, disks, network and processes
-   [Time on Unix](https://venam.nixers.net/blog/unix/2020/05/02/time-on-unix.html) how time and localization works on Unix
-   [Tmux for mere mortals](https://zserge.com/posts/tmux/) good defaults, modifying the keybindings to boost usability
-   [Tips for cleaning up a Linux server](https://ma.ttias.be/clean-up-linux-server-using-these-simple-tips/) low hanging disk space fruit, like removing old kernels, pruning unused Docker space, clearing logs
-   [Shell productivity tips and tricks](https://blog.balthazar-rouberol.com/shell-productivity-tips-and-tricks) faster command line tips

# Monitoring

-   [Zabbix](https://www.zabbix.com)
-   [whatfiles](https://github.com/spieglt/whatfiles) logs the files programs CRUD, also traces new processes
-   [logtop](https://www.cyberciti.biz/faq/linux-unix-logtop-realtime-log-line-rate-analyser/) reads stdin, can sort on any field and is updated in realtime

# Networking

-   [59 Linux Networking commands and scripts](https://haydenjames.io/linux-networking-commands-scripts/) the ultimate network tools goto list.
-   [Introduction to tcpdump and wireshark](https://www.linux.com/blog/learn/chapter/linux-security/2017/2/linux-security-fundamentals-part-5-introduction-tcpdump-and-wireshark)
-   [hping3](https://linux.die.net/man/8/hping3) send arbitary TCP/IP packets to network hosts
-   [Setting up a Linux mail server](https://likegeeks.com/linux-mail-server/)
-   [linker∙d](https://linkerd.io/) dynamic linker for microservices, taking care of the communication work needed to interact with distributed services, including routing, load balancing, and retrying.
-   [Manually Throttle the Bandwidth of a Linux Network Interface](http://mark.koli.ch/slowdown-throttle-bandwidth-linux-network-interface) introduction to the `tc` tool for bandwidth shaping.
-   [connbeat](https://github.com/raboof/connbeat) agent that monitors TCP connection metadata and ships the data to Kafka or Elasticsearch, or an HTTP endpoint
-   [The Ultimate PCAP](https://weberblog.net/the-ultimate-pcap/) all protocols in a single PCAP
-   [What Every Developer Should Know About TCP](https://robertovitillo.com/what-every-developer-should-know-about-tcp/)
-   [SSH Tips & Tricks](https://smallstep.com/blog/ssh-tricks-and-tips/) 2FA, securely forwarding agents, quitting from stuck sessions and using `mosh` or `tmux`
-   [High Availability Load Balancers with Maglev](https://blog.cloudflare.com/high-availability-load-balancers-with-maglev/) CloudFlare on their load balancing stack, BGP, Maglev connection scheduling, IPVS, UDP encapsulation for faster delivery

# Open source

-   [Google Open Source](https://opensource.google.com/projects/explore/featured) 2000+ OSS projects managed by Google
-   [NSA on GitHub](https://nationalsecurityagency.github.io)

# Security

-   [Linux reverse engineering 101](https://github.com/michalmalik/linux-re-101) collection of resources for linux reverse engineering.
-   [Explain like I'm 5: Kerberos](http://www.roguelynn.com/words/explain-like-im-5-kerberos)
-   [OAuth 2.0 Security Best Current Practices](https://tools.ietf.org/html/draft-ietf-oauth-security-topics-15)
-   [SSHHeatmap](https://github.com/meesaltena/SSHHeatmap) script that generates a heatmap of IP's that made failed SSH login attempts using `/var/log/auth.log`

# Serialization

-   [Illustrated jq tutorial](https://mosermichael.github.io/jq-illustrated/dir/content.html) jq is a lightweight and flexible command-line JSON processor
-   [Cap'n Proto](https://capnproto.org/)
-   [Google Protocol Buffers](https://github.com/google/protobuf)

# Shell

-   [5 Types Of ZSH Aliases You Should Know](https://thorsten-hans.com/5-types-of-zsh-aliases) alias suffixes & global aliases, plus other neat tricks

# systemd

-   [Why I Prefer systemd Timers Over Cron](https://trstringer.com/systemd-timer-vs-cronjob/)
-   [journal-triggerd](https://github.com/jjk-jacky/journal-triggerd) runs trigger on systemd's journal messages.
-   [How to automatically execute shell script at startup boot on systemd](https://linuxconfig.org/how-to-automatically-execute-shell-script-at-startup-boot-on-systemd-linux)

# Text wrangling

-   [desed](https://github.com/SoptikHa2/desed) beautiful TUI that provides users with comfortable interface and practical debugger, used to step through complex sed scripts
-   [sed One Liners](http://www.pement.org/sed/sed1line.txt) huge collection of useful sed examples
-   [xsv](https://github.com/BurntSushi/xsv) CLI for indexing, slicing, analyzing, splitting and joining CSV files

# Vim

-   [An Introduction to Vim for SysAdmins](https://www.linux.com/learn/intro-to-linux/2017/2/vim-sysadmins)

# Web

-   [Certbot](https://certbot.eff.org/) automatically use Let’s Encrypt certificates
-   [Ask HN: Is There Still a Place for Native Desktop Apps?](https://news.ycombinator.com/item?id=23211851)
-   [topngx](https://github.com/gsquire/topngx) parse and aggregrate statistics from NGINX access logs
