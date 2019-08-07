---
layout: post
title: "CNO Presentation"
date: "2018-07-27 08:47:01"
comments: false
categories:
- hacking
tags:
- offensive
- cno
---


# Intro

Containers, and specifically Docker are attracting a crazy amount of industry attention, particularly, I'm finding the software dev space.


# Slide 1

OK, just quickly what is Docker.

> Docker is a computer program that performs operating-system-level virtualization also known as containerization. Docker is used to run software packages called "containers".

> "Build once, configure once, and run anywhere.”


# Slide 2

In a containerised world, the container becomes the standard unit of management and deployment. Containers provide a safe and consistent space for processes to run in. A container for example, could contain an Apache web server and all the dependencies it requires. Containers can in theory run all sorts of workloads...webapps, database servers, desktop processes.


# Slide 3

Compared to VMs (hypervisors), which are real things, containers are fake. Containers unlike VMs, can be thought of more as a process container contrasted to a OS container. Containers do not each host their own kernel, like a VM, but instead share a single underlying kernel which provides strong process isolation between the containers. To put them in prespective, a commodity machine that is able to run say 10 VM's, could run several hundred containers. One chap spun up 652 Ubuntu 14 containers on his dev laptop. This is why containers are sometime dubbed as *lightweight VMs*.


# Slide 4

Breaking down the primitives a bit more:

* `namespaces` control what a process can see (PID, mount, network, IPS, user, cgroup)
* `cgroups` (or control groups) control what a process can use, providing resource management (memory, CPU, blkio, cpuset, devices etc). The lions share of the design and implementation was made by Google engineers, which was later released in 2007 in 2.6.24 kernel. Is the basis for Docker, systemd, LXC, CoreOS, and more.
* Then we have the Linux Security Module aspect, which controls and audits various process actions such as file (read, write, execute) and system functions (mount, network, tcp). In the case of Docker, uses AppArmor (per-process profiles - e.g. network access, raw socket access, file read/write) or SELinux. Capabilities (which break system privileges into small pieces such as the ability to set the system clock CAP_SYS_TIME, or CAP_KILL which permits the sending of signals to processes) and Seccomp (a user space to kernel syscall filter/whitelist) add an extra layers of protection.

Basicaly a bunch of kernel duct tape, to simulate small process environments.


# Slide 5

# Why is Docker interesting?

There are many reasons. Here's one: in the software space, we waste enormous amounts of time debugging environments and code. Often builds work on one machine, and not another, and completely fail in the 
target environments which are often configured very differently.

**Works on my machine**

Containers are said to alleviate/solve this problem, by providing *dev-prod parity*. The concept is if a dev can get their software running in a container running on their laptop or workstation, that same container can be picked up run anywhere with a high degree of confidence, such as a production environment, or a cloud provider such as Google or AWS.

> "Build once, configure once, and run anywhere.”


# Slide 6

To get going, developers can now simply download Docker images for boxes they need straight off Docker Hub (the AppStore for Docker), giving them the power to spin up the infrastructure as they need.

Tons of the Docker images are available on Docker hub, for example, an Apache web server, a bare bones Python or Ruby container, MySQL container? Last night I tried searching for some Hadoop containers. Its not uncommon for these to be several years old, and often contributed by an unofficial source.



# Slide 7

Docker gives development teams the ability to spin up container infrastructure as needed, with less need to involve traditional IT operations areas.



# Slide 8

As a reuslt, IT environments may now be prone to increased complexity and technical debt, which will increase with time.

**Container ship burning**

> "put your apps in a container!" they said
> "devs can manage them!" they said
> "super easy!" they said


# Slide 9

Breaking out of a container provides huge bang for buck, although difficult, gives you not only the underlying OS, but all of its containers (could be hundreds).

Daniel Shapira walks through elevating the capabilities, through a kernel exploit relating to the `waitd()` syscall in kernels 4.12-4.13 in late 2017.


> Chris Salls discovered that when the waitid() syscall in Linux kernel v4.13 was refactored, it accidentally stopped checking that the incoming argument was pointing to userspace. This allowed local attackers to write directly to kernel memory, which could lead to privilege escalation.

As briefly touched on earlier, Docker uses the underlying Linux capabilities model to provide better isolation for containers. Docker simply disables capabilities that would enable container escape. Increased capabilities would be a huge security concern, meaning containers could for example access the network interface and sniff the traffic of other containers or the host itself, or mount volumes and load kernel modules etc.

In a nutshell Daniel gets the kernel to overwrite the address pointer defining the uid definition on the `struct cred` with 0 (i.e. root), for a process he forks within a Docker container. Once obtains uid==0, then can in turn elevate capabilities.


# Slide 10 - final thoughts

Over the last few years, I've noticed the hype for containers only seems to be increasing. In the craze of developer productivity, faster deploy to production cycles, and increased utilisation of hardware investments, comes at a price:

* Developers downloading and using random base images, which end up in production. While convenient and fast deploy to production, are already behind in terms of patching and vunerabilties (e.g. containers running out of date versions of Java, web servers, etc). Malware opportunities!?
* Increased environmental complexity with an sea of containers running various workloads = Increased attack surface and exploitation opportunities. Patch management hell (e.g. old containers = old vunerabilities; heartbleed, shellshock).
* Breaking out of a container provides huge bang for buck, although difficult, gives you not only the underlying OS, but all of its containers.
