---
layout: post
title: "Nerd Gems 💎"
slug: "gems"
date: "2017-04-02 13:38:10+11:00"
lastmod: "2023-08-03 15:31:58+11:00"
comments: false
categories:
  - geek
---

_Updated: 2022-03-07_

This is a list of valuable (to me) developer resources that I've managed to stumble across (books, courses, friends and fellow programmers, hacker news, lobste.rs, university).

- [Architecture](#architecture)
- [AI and ML](#ai-and-ml)
- [Awesome](#awesome)
- [C](#c)
- [Cloud](#cloud)
- [Containers](#containers)
- [Cheat sheets](#cheat-sheets)
- [Culture](#culture)
- [Databases](#databases)
- [Development](#development)
- [Diagramming](#diagramming)
- [dotfiles](#dotfiles)
- [Encoding and Serialization](#encoding-and-serialization)
- [Git](#git)
- [Golang](#golang)
- [gRPC](#grpc)
- [Hardware](#hardware)
- [Humanities](#humanities)
- [Jobs](#jobs)
- [Languages](#languages)
- [Linux](#linux)
- [Monitoring](#monitoring)
- [Networking](#networking)
- [Open source](#open-source)
- [Papers](#papers)
- [Python](#python)
- [Security](#security)
- [Shell](#shell)
- [systemd](#systemd)
- [Text wrangling](#text-wrangling)
- [Talks](#talks)
- [Testing](#testing)
- [TypeScript](#typescript)
- [Web](#web)

## Architecture

- [.NET Microservices: Architecture for Containerized .NET Applications](https://docs.microsoft.com/en-us/dotnet/architecture/microservices/) a fantastic resource for working with the modern .NET stack (post 2022)
- [Communicating Sequential Processes](http://www.usingcsp.com/cspbook.pdf) Tony Hoare's seminal 1977 paper on concurrency and CSP
- [Why Segment Went Back to a Monolith](https://www.infoq.com/news/2020/04/microservices-back-again/) microservices come with serious tradeoffs
- [All software sucks](http://harmful.cat-v.org/software/) complexity is the bane of all software, simplicity is the most important quality

## AI and ML

- [Andrej Karpathy on The spelled-out intro to neural networks and backpropagation: building micrograd](https://www.youtube.com/watch?v=VMj-3S1tku0) a 2.5 hour step-by-step spelled-out explanation of backpropagation and training of neural networks. It only assumes basic knowledge of Python and a vague recollection of calculus from high school.

## Awesome

- [awesome-baremetal](https://github.com/alexellis/awesome-baremetal)
- [awesome-kubernetes](https://github.com/ramitsurana/awesome-kubernetes)
- [learn-anything/books](https://github.com/learn-anything/books)

## C

- [Easy Makefile](https://github.com/mortie/easy-makefile/) a Makefile boilerplate to hit the ground running
- [Handmade Hero](https://handmadehero.org/) an educational series by Casey Muratori that teaches low-level game programming techniques by example
- [Eskil Steenberg on How I program in C](https://www.youtube.com/watch?v=443UNeGrFoM)

## Cloud

- [mcm](https://zombiezen.github.io/mcm/) Minimal Configuration Manager
- [Packer](https://www.hashicorp.com/blog/packer-1-0/) a tool for building images for cloud platforms, virtual machines, containers and more from a single source configuration.
- [CloudBoost](https://www.cloudboost.io/) a complete serverless platform for your app.
- [The Google Cloud Developer's Cheat Sheet](https://github.com/gregsramblings/google-cloud-4-words) every product in the Google Cloud family described in under 4 words
- [Ask HN: Is Your Company Sticking to On-Premise Servers? Why?](https://news.ycombinator.com/item?id=23089999)
- [Using AWS CodeBuild to Execute Administrative Tasks](https://aws.amazon.com/blogs/devops/using-aws-codebuild-to-execute-administrative-tasks/)

## Containers

- [OKD: The Community Distribution of Kubernetes that powers OpenShift](https://github.com/openshift/okd/)
- [The Docker Handbook](https://www.freecodecamp.org/news/the-docker-handbook/)
- [25 Basic Docker Commands for Beginners](https://codeopolis.com/posts/25-basic-docker-commands-for-beginners/)
- [Setting the Record Straight: containers vs. Zones vs. Jails vs. VMs]()
- [Docker Security Best Practices](https://blog.sqreen.io/docker-security/) tools and methods to help secure Docker
- [Kubernetes Workshop](http://www.zoobab.com/kubernetes-workshop) tons of details for getting started
- [10 Most Common Mistakes When Using Kubernetes](https://blog.pipetail.io/posts/2020-05-04-most-common-mistakes-k8s/)
- [lens](https://github.com/lensapp/lens/) kube IDE
- [kubeseal](https://crypt.codemancers.com/posts/2020-04-27-encrypting-and-storing-kubernetes-secrets-in-git/) how to safely store secrets in `git` if you want to use them in k8s
- [Container Technologies at Coinbase](https://blog.coinbase.com/container-technologies-at-coinbase-d4ae118dcb6c) great history on how the industry got to containers, an why kubernetes isn't used
- [A Practical Introduction to Container Security](https://cloudberry.engineering/article/practical-introduction-container-security/)
- [Webtop](https://docs.linuxserver.io/images/docker-webtop) full desktop environments in officially supported flavors accessible via any modern web browser

## Cheat sheets

- [Linux Commands - A practical reference](http://www.pixelbeat.org/cmdline.html) an amazing cheat sheet, quick reference
- [The Ultimate List of SANS Cheat Sheets](https://www.sans.org/blog/the-ultimate-list-of-sans-cheat-sheets/) when it comes to quality cyber-security training and certs SANS is world leading. They have an amazing collection of thoughtful and useful cheat sheets from topics such as _Writing Tips for IT Professionals_, _Windows to Unix Cheat Sheet_, to using pieces of software such as `nmap`, `netcat`, `burb`. Its a treasure trove!
- [Lenny Zeltser's IT and Information Security Cheat Sheets](https://zeltser.com/cheat-sheets/) speaking of thoughtful cheat sheets, lots of wisdom here

## Culture

- [Why we're leaving the cloud](https://world.hey.com/dhh/why-we-re-leaving-the-cloud-654b47e0)
- [You Are Not Google](https://blog.bradfieldcs.com/you-are-not-google-84912cf44afb) if you’re using a technology that originated at a large company, but your use case is very different, it’s unlikely that you arrived there deliberately; no, it’s more likely you got there through a ritualistic belief that imitating the giants would bring the same riches.
- [GitLab's Guide to All-Remote](https://about.gitlab.com/company/culture/all-remote/guide/) the remote manifesto, tips and tricks and remote resources
- [Why we at $FAMOUS_COMPANY Switched to $HYPED_TECHNOLOGY](https://saagarjha.com/blog/2020/05/10/why-we-at-famous-company-switched-to-hyped-technology/)
- [Habbits of High-Functioning Software Teams](https://deniseyu.io/2020/05/23/habits-of-high-performing-teams.html) characteristics and habits of the highest-performing dev teams

## Databases

- [Things I Wished More Developers Knew About Databases](https://medium.com/@rakyll/things-i-wished-more-developers-knew-about-databases-2d0178464f78)
- [SQL Coding Standards](http://wiki.c2.com/?AntiPatternsCatalog)
- [PostgreSQL Course: A Curious Moon](https://bigmachine.io/products/a-curious-moon/) learn PostgreSQL the way the pros do: on the job and under pressure. You'll assume the role of interim DBA at aerospace startup Red:4, exploring data from the Cassini mission!

## Development

- [What To Code](https://what-to-code.com) inspiration and ideas
- [Why the developers who use Rust love it so much](https://stackoverflow.blog/2020/06/05/why-the-developers-who-use-rust-love-it-so-much/)

## Diagramming

- [Excalidraw](https://excalidraw.com/) beautiful web based diagrams
- [PlantText](https://www.planttext.com/) PlantUML (text) based diagram generator

## dotfiles

- [HexDSL](https://git.hexdsl.co.uk/HexDSL/dots)
- [LukeSmithxyz](https://github.com/LukeSmithxyz/voidrice)
- [uoou](https://gitlab.com/uoou)

## Encoding and Serialization

- [The Absolute Minimum Every Software Developer Absolutely, Positively Must Know About Unicode and Character Sets (No Excuses!)](https://www.joelonsoftware.com/2003/10/08/the-absolute-minimum-every-software-developer-absolutely-positively-must-know-about-unicode-and-character-sets-no-excuses/)
- [Illustrated jq tutorial](https://mosermichael.github.io/jq-illustrated/dir/content.html) jq is a lightweight and flexible command-line JSON processor
- [Cap'n Proto](https://capnproto.org/)
- [Google Protocol Buffers](https://github.com/google/protobuf)

## Git

- [Better Git configuration](https://blog.scottnonnenberg.com/better-git-configuration) links and resources on configuring & using git
- [Automate Repetitive Tasks with Custom git Commands](https://gitbetter.substack.com/p/automate-repetitive-tasks-with-custom) how to write custom git commands

## Golang

- [Everyday Golang](https://gumroad.com/l/everyday-golang)
- [Containerize Your Go Developer Environment – Part 1](https://www.docker.com/blog/containerize-your-go-developer-environment-part-1/)
- [Communicating Between Python and Go with gRPC](https://www.ardanlabs.com/blog/2020/06/python-go-grpc.html)
- [GoFakeIt: A Random Fake Data Generator](https://github.com/brianvoe/gofakeit) over 120 functions for generating things like names, emails, locations, user agents, ...
- [Exploring the Container Packages (list, ring, and heap)](https://therebelsource.com/blog/exploring-container-package-in-go-list-ring-and-heap/9zTBiMaaYg)
- [LearnGo: A Large Collection of Go Examples, Exercises, and Quizzes](https://github.com/inancgumus/learngo)
- [Writing Go CLIs With Just Enough Architecture](https://blog.carlmjohnson.net/post/2020/go-cli-how-to-and-advice/)
- [A Go RabbitMQ Beginners' Tutorial](https://www.youtube.com/watch?v=pAXp6o-zWS4)
- [Getting Hands-On with io_uring from Go](https://developers.mattermost.com/blog/hands-on-iouring-go/)
- [RobotGo: Native Cross-Platform GUI Automation](https://github.com/go-vgo/robotgo) control the pointer, keyboard, read the screen, to automate many computer-based jobs
- [Diving Into Go by Building a CLI Application](https://eryb.space/2020/05/27/diving-into-go-by-building-a-cli-application.html)
- [Immutability Patterns in Go](https://rauljordan.com/2020/05/25/immutability-patterns-in-go.html)
- [Writing An Interpreter In Go](https://interpreterbook.com/)

## gRPC

- [gRPC - Best Practices](https://kreya.app/blog/grpc-best-practices/)

## Hardware

- [Backblaze hard drive stats](https://www.backblaze.com/blog/backblaze-hard-drive-stats-q1-2020/)
- [Build an 8-bit CPU by Ben Eater](https://eater.net/8bit/) a programmable 8-bit computer from scratch on breadboards using only simple logic gates
- [nand2tetris](https://www.nand2tetris.org/) a distilled version of the book The Elements of Computing Systems, By Noam Nisan and Shimon Schocken (MIT Press), contains all the project materials and tools necessary for building a general-purpose computer system and a modern software hierarchy from the ground up


## Humanities

- [The Chomsky List](https://chomskylist.com/where-start-chomsky-best-books.php)
- [A definitive guide to Noam Chomsky: 10 books to get you started](https://ideapod.com/a-definitive-guide-to-noam-chomsky-10-books-to-get-you-started/)
- [RATM reading list](https://www.goodreads.com/list/show/77151.Rage_Against_The_Machine_s_Recommended_Reading_List)

## Jobs

- [Inspired corp](inspiredcorp.com.au)

## Languages

- [Crafting Interpreters by Robert Nystrom](https://craftinginterpreters.com/) Ever wanted to make your own programming language or wondered how they are designed and built? If so, this book is for you.

## Linux

- [Linux Commands - A practical reference](http://www.pixelbeat.org/cmdline.html) an amazing cheat sheet, quick reference
- [16 Linux server monitoring commands you really need to know](https://insights.hpe.com/articles/16-linux-server-monitoring-commands-you-really-need-to-know-1703.html)
- [Best 15 Unix Command Line Tools](https://www.edumobile.org/linux/best-15-unix-command-line-tools/)
- [An In-Depth Guide to iptables](https://www.booleanworld.com/depth-guide-iptables-linux-firewall/) covers pretty much every angle of iptables, from basic rules to NAT'ing to protocols and interfaces.
- [mdadm Cheat Sheet](http://www.ducea.com/2009/03/08/mdadm-cheat-sheet/) practical commands when running software raid on Linux
- [Async IO on Linux: select, poll, and epoll](https://jvns.ca/blog/2017/06/03/async-io-on-linux--select--poll--and-epoll/) thorough write-up on 'select', 'poll' and 'epoll' system calls, and how to measure them.
- [The first 5 things to do when your Linux server keels over](https://insights.hpe.com/articles/the-first-5-things-to-do-when-your-linux-server-keels-over-1705.html) including hardware troubleshooting, checking the running state of applications
- [How io_uring and eBPF Will Revolutionize Programming in Linux](https://thenewstack.io/how-io_uring-and-ebpf-will-revolutionize-programming-in-linux/) well explained history of Linux syscalls and their limitations, and how `io_uring` is a game changer by allowing async I/O via a pub/sub model
- [bashtop](https://github.com/aristocratos/bashtop) gamified TUI resource monitor that shows usage and stats for processor, memory, disks, network and processes
- [Time on Unix](https://venam.nixers.net/blog/unix/2020/05/02/time-on-unix.html) how time and localization works on Unix
- [Tmux for mere mortals](https://zserge.com/posts/tmux/) good defaults, modifying the keybindings to boost usability
- [Tips for cleaning up a Linux server](https://ma.ttias.be/clean-up-linux-server-using-these-simple-tips/) low hanging disk space fruit, like removing old kernels, pruning unused Docker space, clearing logs
- [Shell productivity tips and tricks](https://blog.balthazar-rouberol.com/shell-productivity-tips-and-tricks) faster command line tips

## Monitoring

- [Zabbix](https://www.zabbix.com)
- [whatfiles](https://github.com/spieglt/whatfiles) logs the files programs CRUD, also traces new processes
- [logtop](https://www.cyberciti.biz/faq/linux-unix-logtop-realtime-log-line-rate-analyser/) reads stdin, can sort on any field and is updated in realtime

## Networking

- [PacketLife Cheat Sheets](https://packetlife.net/library/cheat-sheets/)
- [The Packet Pioneer Chris Greer on TCP Fundamentals Part 1 TCP/IP Explained with Wireshark](https://www.youtube.com/watch?v=xdQ9sgpkrX8)
- [59 Linux Networking commands and scripts](https://haydenjames.io/linux-networking-commands-scripts/) the ultimate network tools goto list.
- [Introduction to tcpdump and wireshark](https://www.linux.com/blog/learn/chapter/linux-security/2017/2/linux-security-fundamentals-part-5-introduction-tcpdump-and-wireshark)
- [hping3](https://linux.die.net/man/8/hping3) send arbitary TCP/IP packets to network hosts
- [Setting up a Linux mail server](https://likegeeks.com/linux-mail-server/)
- [linker∙d](https://linkerd.io/) dynamic linker for microservices, taking care of the communication work needed to interact with distributed services, including routing, load balancing, and retrying.
- [Manually Throttle the Bandwidth of a Linux Network Interface](http://mark.koli.ch/slowdown-throttle-bandwidth-linux-network-interface) introduction to the `tc` tool for bandwidth shaping.
- [connbeat](https://github.com/raboof/connbeat) agent that monitors TCP connection metadata and ships the data to Kafka or Elasticsearch, or an HTTP endpoint
- [The Ultimate PCAP](https://weberblog.net/the-ultimate-pcap/) all protocols in a single PCAP
- [What Every Developer Should Know About TCP](https://robertovitillo.com/what-every-developer-should-know-about-tcp/)
- [SSH Tips & Tricks](https://smallstep.com/blog/ssh-tricks-and-tips/) 2FA, securely forwarding agents, quitting from stuck sessions and using `mosh` or `tmux`
- [High Availability Load Balancers with Maglev](https://blog.cloudflare.com/high-availability-load-balancers-with-maglev/) CloudFlare on their load balancing stack, BGP, Maglev connection scheduling, IPVS, UDP encapsulation for faster delivery
- [Networking for Game Programmers: UDP vs TCP](https://gafferongames.com/post/udp_vs_tcp/)

## Open source

- [Google Open Source](https://opensource.google.com/projects/explore/featured) 2000+ OSS projects managed by Google
- [NSA on GitHub](https://nationalsecurityagency.github.io)

## Papers

- Coming soon

## Python

- [Python Design Patterns](https://python-patterns.guide/)
- [Inside the Python Virtual Machine](https://leanpub.com/insidethepythonvirtualmachine)
- [Full Speed Python from Superior School of Technology of Setúbal](https://github.com/joaoventura/full-speed-python/tree/master)
- [Intermediate Python](https://leanpub.com/intermediatepython)
## Security

- [OST2.FYI](https://ost2.fyi/) OpenSecurityTraining2's mission is to provide the world's deepest and best cybersecurity training. That our classes are free is just a bonus!
- [The Ultimate List of SANS Cheat Sheets](https://www.sans.org/blog/the-ultimate-list-of-sans-cheat-sheets/) when it comes to quality cyber-security training and certs SANS is world leading. They have an amazing collection of thoughtful and useful cheat sheets from topics such as _Writing Tips for IT Professionals_, _Windows to Unix Cheat Sheet_, to using pieces of software such as `nmap`, `netcat`, `burb`. Its a treasure trove!
- [Lenny Zeltser's IT and Information Security Cheat Sheets](https://zeltser.com/cheat-sheets/) speaking of thoughtful cheat sheets, lots of wisdom here
- [Linux reverse engineering 101](https://github.com/michalmalik/linux-re-101) collection of resources for linux reverse engineering.
- [Explain like I'm 5: Kerberos](http://www.roguelynn.com/words/explain-like-im-5-kerberos)
- [OAuth 2.0 Security Best Current Practices](https://tools.ietf.org/html/draft-ietf-oauth-security-topics-15)
- [SSHHeatmap](https://github.com/meesaltena/SSHHeatmap) script that generates a heatmap of IP's that made failed SSH login attempts using `/var/log/auth.log`

## Shell

- [Byobu](https://www.byobu.org/) multiplexer, enhanced profiles, convenient keybindings, configuration utilities, and toggle-able system status notifications for `screen` and `tmux`
- [Makeself](https://makeself.io/) a self-extracting archiving tool for Unix systems, in 100% shell script
- [5 Types Of ZSH Aliases You Should Know](https://thorsten-hans.com/5-types-of-zsh-aliases) alias suffixes & global aliases, plus other neat tricks
- [Bash aliases you can’t live without](https://opensource.com/article/19/7/bash-aliases)

## systemd

- [Why I Prefer systemd Timers Over Cron](https://trstringer.com/systemd-timer-vs-cronjob/)
- [journal-triggerd](https://github.com/jjk-jacky/journal-triggerd) runs trigger on systemd's journal messages
- [How to automatically execute shell script at startup boot on systemd](https://linuxconfig.org/how-to-automatically-execute-shell-script-at-startup-boot-on-systemd-linux)

## Text wrangling

- [CyberChef](https://gchq.github.io/CyberChef/) the ultimate open-source (by GCHQ) text wrangler you'll ever need, life changing
- [desed](https://github.com/SoptikHa2/desed) beautiful TUI that provides users with comfortable interface and practical debugger, used to step through complex sed scripts
- [sed One Liners](http://www.pement.org/sed/sed1line.txt) huge collection of useful sed examples
- [xsv](https://github.com/BurntSushi/xsv) CLI for indexing, slicing, analyzing, splitting and joining CSV files

## Talks

- [Rich Hickey on Simple Made Easy]()
- [Mike Acton on Data-orientated Design]()
- [Jonathan Blow on Programming Aesthetics learned from making independent games]()
- [Eskil Steenberg on How I program in C]()
- [Rich Hickey on Hammock Driven Development]()
- [Brian Will on Why OOP is Bad]()
- [Abner Coimbre on What Programming is Never About]()
- [Scott Meyers on CPU Caches and Why You Care]()
- [Jeff and Casey Show on The Evils of Non-native Programming]()
- [Jeff and Casey’s Guide to Becoming a Bigger Programmer]()
- [Hadi Hariri on The Silver Bullet Syndrome]()
- [Bryan Cantrill on Fork Yeah! The Rise and Development if illumos]()
- [Rob Pike on Concurrency Is Not Parallelism]()
- [James Mickens on JavaScript]()
- [Liz Rice on Containers From Scratch]()
- [James Mickens on Why Do Keynote Speakers Keep Suggesting That Improving Security Is Possible?]()

## Testing

- [Smocker](https://smocker.dev/) simple HTTP mock server, uses YAML to define mocks and responses
- [MockServer](https://www.mock-server.com/) for any system you integrate with via HTTP or HTTPS MockServer can be used as: a mock configured to return specific responses for different requests, a proxy recording and optionally modifying requests and responses or as both a proxy for some requests and a mock for other requests at the same time

## TypeScript

- [The Consise TypeScript Book](https://github.com/gibbok/typescript-book/)

## Web

- [HTML5 UP](https://html5up.net/) makes spiffy HTML5 site templates that are HTML5 + CSS3, customizable and 100% free under the Creative Commons
- [How I built a modern website in 2021](https://kentcdodds.com/blog/how-i-built-a-modern-website-in-2021)
- [Certbot](https://certbot.eff.org/) automatically use Let’s Encrypt certificates
- [Ask HN: Is There Still a Place for Native Desktop Apps?](https://news.ycombinator.com/item?id=23211851)
- [topngx](https://github.com/gsquire/topngx) parse and aggregrate statistics from NGINX access logs
