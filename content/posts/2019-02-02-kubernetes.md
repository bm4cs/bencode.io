---
layout: post
title: "Kubernetes"
date: "2019-02-02 13:34:10"
comments: false
categories:
- k8s
tags:
- containers
- docker
---

- [Terminology](#terminology)
- [Machine Configuration](#machine-configuration)
  - [Static IP's](#static-ips)
  - [Disable SELinux](#disable-selinux)
  - [SSL Certificates](#ssl-certificates)
- [Download for Offline Install](#download-for-offline-install)
  - [Docker 17.x (17.12.1-ce)](#docker-17x-17121-ce)
  - [Rancher 2.x](#rancher-2x)
  - [Burn DVD](#burn-dvd)
- [Installation](#installation)
  - [Docker 17.x (17.12.1-ce)](#docker-17x-17121-ce-1)
  - [Rancher 2.x](#rancher-2x-1)
    - [Handy Container Mop Up Scripts](#handy-container-mop-up-scripts)
- [Using Rancher](#using-rancher)
- [Troubleshooting](#troubleshooting)
  - [Docker logs](#docker-logs)
- [Resources](#resources)

My adventures setting up a local Kubernetes control plane and cluster up.

The name *Kubernetes* originates from Greek, meaning helmsman or pilot, and is the root of governor and cybernetic.

> Kubernetes is a portable, extensible open-source platform for managing containerised workloads and services, that facilitates both declarative configuration and automation.

It's a platform for managing containers.

A running Kubernetes cluster contains node agents (kubelet) and a cluster control plane (aka master), with cluster state backed by a distributed storage system (etcd).

While all the big cloud providers now have k8s offerings, its still feasible to get all this setup on your own kit (vms or bare metal), thanks to distributions like [Agile Stacks](https://www.agilestacks.com/) and [Rancher](https://rancher.com/). I found the Rancher documentation outstanding. In this guide, I'll be going with Rancher for no particular reason.

My target environment:

* RHEL 7.5
* Docker 17.x
* Rancher 2.x

Checkout Rancher's [node requirements](https://rancher.com/docs/rancher/v2.x/en/installation/requirements/) for more.




# Terminology

Each computing resource in a Kubernetes *cluster* is called a *node*. Nodes can be either bare metal or VM's. Kubernetes classifies nodes into three types: etcd nodes, control plane nodes, and worker nodes.





# Machine Configuration

## Static IP's

On a hat based distro, head into `/etc/sysconfig/network-scripts`, and edit the ifcfg script that relates to your network interface (in my case `enp0s3`):

    $ sudo vim /etc/sysconfig/network-scripts/ifcfg-enp0s3

By default, interfaces are setup to use DHCP. Set the `BOOTPROTO` to `none` for a static IP. My script ended up looking like this:

    TYPE=Ethernet
    BOOTPROTO=none
    IPV4_FAILURE_FATAL=no
    IPV6INIT=no
    NAME=enp0s3
    UUID=5f645dcb-c5cd-431c-add1-4f449dcadec0
    DEVICE=enp0s3
    ONBOOT=yes
    IPADDR=192.168.1.115
    NETMASK=255.255.255.0
    GATEWAY=192.168.1.1
    DNS1=1.1.1.1
    DNS2=1.0.0.1


## Disable SELinux

Causes havoc with the kubelet service (found this out the hard way on one of my worker nodes).

    $ sudo sestatus
    SELinux status:                 enabled
    SELinuxfs mount:                /sys/fs/selinux
    SELinux root directory:         /etc/selinux
    Loaded policy name:             targeted
    Current mode:                   enforcing
    Mode from config file:          enforcing
    Policy MLS status:              enabled
    Policy deny_unknown status:     allowed
    Max kernel policy version:      31

Disable it (temporarily):

    $ sudo setenforce 0

Disable it (permanently):

    $ sudo vim /etc/selinux/config

Set `SELINUX=disabled`. Reboot the machine.




## SSL Certificates

TODO




# Download for Offline Install

## Docker 17.x (17.12.1-ce)

As per [docs](https://docs.docker.com/install/linux/docker-ce/centos/), register the official yum repo:

    $ sudo yum install -y yum-utils device-mapper-persistent-data lvm2
    $ sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

Next cache a version of Docker 17.x (at time of writing Rancher 2.x only supports 17) and any dependencies needed, for later installation.

    $ sudo yum --showduplicates list docker-ce | expand
    Loading mirror speeds from cached hostfile
     * base: ftp.swin.edu.au
     * extras: ftp.swin.edu.au
     * updates: centos.mirror.digitalpacific.com.au
    Available Packages
    docker-ce.x86_64             17.03.3.ce-1.el7                    docker-ce-edge 
    docker-ce.x86_64             17.04.0.ce-1.el7.centos             docker-ce-edge 
    docker-ce.x86_64             17.05.0.ce-1.el7.centos             docker-ce-edge 
    docker-ce.x86_64             17.06.0.ce-1.el7.centos             docker-ce-edge 
    docker-ce.x86_64             17.06.1.ce-1.el7.centos             docker-ce-edge 
    docker-ce.x86_64             17.06.2.ce-1.el7.centos             docker-ce-edge 
    docker-ce.x86_64             17.07.0.ce-1.el7.centos             docker-ce-edge 
    docker-ce.x86_64             17.09.0.ce-1.el7.centos             docker-ce-edge 
    docker-ce.x86_64             17.09.1.ce-1.el7.centos             docker-ce-edge 
    docker-ce.x86_64             17.10.0.ce-1.el7.centos             docker-ce-edge 
    docker-ce.x86_64             17.11.0.ce-1.el7.centos             docker-ce-edge 
    docker-ce.x86_64             17.12.0.ce-1.el7.centos             docker-ce-edge 
    docker-ce.x86_64             17.12.1.ce-1.el7.centos             docker-ce-edge 
    docker-ce.x86_64             18.01.0.ce-1.el7.centos             docker-ce-edge 
    docker-ce.x86_64             18.02.0.ce-1.el7.centos             docker-ce-edge 
    docker-ce.x86_64             18.03.0.ce-1.el7.centos             docker-ce-edge 
    docker-ce.x86_64             18.03.1.ce-1.el7.centos             docker-ce-edge 
    docker-ce.x86_64             18.04.0.ce-3.el7.centos             docker-ce-edge 
    docker-ce.x86_64             18.05.0.ce-3.el7.centos             docker-ce-edge 
    docker-ce.x86_64             18.06.0.ce-3.el7                    docker-ce-edge 
    docker-ce.x86_64             18.06.1.ce-3.el7                    docker-ce-edge 
    docker-ce.x86_64             3:18.09.0-3.el7                     docker-ce-edge 
    docker-ce.x86_64             3:18.09.1-3.el7                     docker-ce-edge 


Once you've identified the specific version details, pull the trigger and download the rpms and any needed dependencies:

    $ sudo yum install docker-ce-17.12.1.ce-1.el7.centos --downloadonly --downloaddir=.

Alternatively you can manually [download](https://download.docker.com/linux/centos/7/x86_64/stable/Packages/) the official RPM's 


## Rancher 2.x

Head to the Rancher [Git repo](https://github.com/rancher/rancher/releases) and download the `rancher-images.txt`, `rancher-load-images.sh` and `rancher-save-images.sh` scripts.

To download, and tarball up all the needed docker images to support a Rancher k8s cluster management control plane, Rancher provided a handy script:

    $ ./rancher-save-images.sh --image-list ./rancher-images.txt

After running this ended up with a 2.7G file called `rancher-images.tar.gz`.

This can be used to hydrate a Docker registry. I setup a local registry server using the [official](https://docs.docker.com/registry/deploying/) `registry:2` image. This by default binds to port 5000. To spool it up is dead simple:

    $ docker run -d -p 5000:5000 --restart=always --name registry registry:2



## Burn DVD

Slight side track here. Burning a DVD using CLI program `growisofs`.

> growisofs - combined genisoimage frontend/DVD recording program.

Organise everything into a source directory:

    $ tree ./airgap-k8s/
    ./airgap-k8s/
    ├── docker
    │   ├── 17
    │   │   ├── container-selinux-2.74-1.el7.noarch.rpm
    │   │   └── docker-ce-17.12.1.ce-1.el7.centos.x86_64.rpm
    │   └── 18
    │       ├── containerd.io-1.2.2-3.el7.x86_64.rpm
    │       ├── container-selinux-2.74-1.el7.noarch.rpm
    │       ├── docker-ce-18.09.1-3.el7.x86_64.rpm
    │       └── docker-ce-cli-18.09.1-3.el7.x86_64.rpm
    ├── docker-images
    │   ├── asp-dotnet-core-samples.tar
    │   └── registry2.tar
    └── rancher
        ├── rancher-images.tar.gz
        ├── rancher-images.txt
        ├── rancher-load-images.sh
        ├── rancher-mirror-to-rancher-org.sh
        └── rancher-save-images.sh


Make an ISO:

    $ mkisofs -R -J -o ~/isos/airgap-k8s.iso ./airgap-k8s/
    I: -input-charset not specified, using utf-8 (detected in locale settings)
    Using RANCH000.SH;1 for  ./airgap-k8s/rancher/rancher-load-images.sh (rancher-mirror-to-rancher-org.sh)
    Using RANCH001.SH;1 for  ./airgap-k8s/rancher/rancher-mirror-to-rancher-org.sh (rancher-save-images.sh)
    Using DOCKE000.RPM;1 for  ./airgap-k8s/docker/18/docker-ce-cli-18.09.1-3.el7.x86_64.rpm (docker-ce-18.09.1-3.el7.x86_64.rpm)
    Using CONTA000.RPM;1 for  ./airgap-k8s/docker/18/containerd.io-1.2.2-3.el7.x86_64.rpm (container-selinux-2.74-1.el7.noarch.rpm)
      0.31% done, estimate finish Sun Feb  3 21:34:17 2019
      0.63% done, estimate finish Sun Feb  3 21:31:38 2019
      0.94% done, estimate finish Sun Feb  3 21:30:45 2019
      1.25% done, estimate finish Sun Feb  3 21:30:18 2019

Check DVD device name (`sr0`):

    $ less /proc/sys/dev/cdrom/info

Burn the DVD:

    $ growisofs -dvd-compat -Z /dev/sr0=./airgap-k8s.iso 
    Executing 'builtin_dd if=./airgap-k8s.iso of=/dev/sr0 obs=32k seek=0'
    /dev/sr0: "Current Write Speed" is 16.4x1352KBps.
         786432/3268724736 ( 0.0%) @0.1x, remaining 415:32 RBU 100.0% UBU   0.0%
       24346624/3268724736 ( 0.7%) @5.1x, remaining 19:59 RBU 100.0% UBU  98.4%


# Installation

## Docker 17.x (17.12.1-ce)

Now on the target node computers, actually install the packages:

    $ sudo yum install docker-ce-17.12.1.ce-1.el7.centos

By default this is masked and disabled for systemd management, fix this:

    $ systemctl enable docker
    $ systemctl unmask docker

Spark it up:

    $ systemctl start docker



## Rancher 2.x

This can be used to hydrate a Docker registry. I setup a local registry server using the [official](https://docs.docker.com/registry/deploying/) `registry:2` image. This by default binds to port 5000. To spool it up is dead simple:

    $ docker run -d -p 5000:5000 --restart=always --name registry registry:2


Next run the Rancher hydration script:

    $ sudo ./rancher-load-images.sh --image-list ./rancher-images.txt --registry localhost:5000


Confirm by listing out the registry:

    $ sudo docker image ls



Now on the control plane machine, you should be able to [bootstrap rancher](https://rancher.com/docs/rancher/v2.x/en/installation/air-gap-single-node/install-rancher/) - note this is the lazy self-signed certificates option:

    $ sudo docker run -d --restart=unless-stopped -p 80:80 -p 443:443 192.168.1.116:5000/rancher/rancher:v2.1.6


If this doesn't work, and you're using a dodgy self signed Docker registry (like me), you'll need to whitelist it, as by default Docker does not permit insecure communication (such as untrusted SSL certs):

As root create `/etc/docker/daemon.json`, and pop the following into it:

    {
      "insecure-registries" : ["192.168.1.116:5000"]
    }

After creating `daemon.json` bounce the docker daemon:

    $ sudo systemctl restart docker



Running `docker run` should produce:

    $ sudo docker run -d --restart=unless-stopped -p 80:80 -p 443:443 192.168.1.116:5000/rancher/rancher:v2.1.6
    Unable to find image '192.168.1.116:5000/rancher/rancher:v2.1.6' locally
    v2.1.6: Pulling from rancher/rancher
    Digest: sha256:924b8acaa169821c86b840c33e1d79d87db0dfbb84dae6c102cc7c196811230f
    Status: Downloaded newer image for 192.168.1.116:5000/rancher/rancher:v2.1.6
    93ff1ffb9abe93b674f0a8787fca4e4a849dd11bdb5cd8055cae561b5dfbeca7

Ensure it's running:

$ sudo docker ps
CONTAINER ID        IMAGE                                       COMMAND             CREATED             STATUS              PORTS                                      NAMES
93ff1ffb9abe        192.168.1.116:5000/rancher/rancher:v2.1.6   "entrypoint.sh"     4 minutes ago       Up 4 minutes        0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   pedantic_shaw

Then point a browser at the IP of the node (https of course).

After resetting the admin password. You'll be presented with the *create cluster* wizard. Create a custom cluster. It's all quite intuitive.

At the node provisioning stage, its up to you to specify node roles out of the following:

* etcd
* Control Plane
* Worker


I created an `etcd` and control plane node with this (note the `--etcd` and `--controlplane` switches):

    sudo docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run rancher/rancher-agent:v2.1.6 --server https://192.168.1.115 --token cnbdzh6hdqg2trghnxcwdxdrfpbfbltrpqjrsr9qh24qqt2fwrvhls --ca-checksum 61f6923ccee33f6adac25675e6a9e348e575f67c277b377b82d401c72442b4a0 --etcd --controlplane

And a worker node with this (note the `--worker` switch):

    sudo docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run rancher/rancher-agent:v2.1.6 --server https://192.168.1.115 --token cnbdzh6hdqg2trghnxcwdxdrfpbfbltrpqjrsr9qh24qqt2fwrvhls --ca-checksum 61f6923ccee33f6adac25675e6a9e348e575f67c277b377b82d401c72442b4a0 --worker



This resulted in the following containers running on my single CentOS 7.5 VM:

    $ sudo docker ps
    CONTAINER ID        IMAGE                                       COMMAND                  CREATED             STATUS              PORTS                                      NAMES
    5780859077f2        rancher/rancher-agent:v2.1.6                "run.sh --server htt…"   5 seconds ago       Up 4 seconds                                                       blissful_wescoff
    b23954773abd        rancher/rancher-agent:v2.1.6                "run.sh --server htt…"   3 minutes ago       Up 3 minutes                                                       gracious_hawking
    611ab63c1f34        rancher/rancher-agent:v2.1.6                "run.sh -- share-roo…"   3 minutes ago       Up 3 minutes                                                       share-mnt
    b93c1d652fcb        rancher/rancher-agent:v2.1.6                "run.sh --server htt…"   3 minutes ago       Up 3 minutes                                                       nostalgic_dubinsky
    93ff1ffb9abe        192.168.1.116:5000/rancher/rancher:v2.1.6   "entrypoint.sh"          10 minutes ago      Up 10 minutes       0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp       pedantic_shaw


Returning to the Rancher UI, will see that the new cluster is in the *provisioning* state. Be patient, this took about 10 minutes on my local setup.

> This cluster is currently Provisioning; areas that interact directly with it will not be available until the API is ready. Pulling image [rancher/hyperkube:v1.11.6-rancher1] on host [192.168.1.115]


You'll know when RKE has finished provisioning, there will be dozens of containers running to support the k8s ecosystem, including controllers, schedulers, a network fabric, ingress controllers and much more.

    $ docker ps
    CONTAINER ID        IMAGE                                                   COMMAND                  CREATED              STATUS              PORTS                                      NAMES
    29eb169fafdf        192.168.1.121:5000/rancher/hyperkube:v1.11.6-rancher1   "/opt/rke-tools/entr…"   7 seconds ago        Up 6 seconds                                                   kube-proxy
    b4eaa67bf584        f3d94aa8c942                                            "run.sh"                 8 seconds ago        Up 6 seconds                                                   k8s_agent_cattle-node-agent-jbl8l_cattle-system_c2568e4c-2772-11e9-ada9-0800272cc3f6_0
    b09088df31f6        192.168.1.121:5000/rancher/pause-amd64:3.1              "/pause"                 8 seconds ago        Up 7 seconds                                                   k8s_POD_cattle-node-agent-jbl8l_cattle-system_c2568e4c-2772-11e9-ada9-0800272cc3f6_0
    9a59b7ec3dd3        192.168.1.121:5000/rancher/hyperkube:v1.11.6-rancher1   "/opt/rke-tools/entr…"   19 seconds ago       Up 18 seconds                                                  kubelet
    5443cab9f32a        192.168.1.121:5000/rancher/hyperkube:v1.11.6-rancher1   "/opt/rke-tools/entr…"   31 seconds ago       Up 30 seconds                                                  kube-scheduler
    22f4cde3f4e7        192.168.1.121:5000/rancher/hyperkube:v1.11.6-rancher1   "/opt/rke-tools/entr…"   44 seconds ago       Up 42 seconds                                                  kube-controller-manager
    d4e7256f0ca9        192.168.1.121:5000/rancher/hyperkube:v1.11.6-rancher1   "/opt/rke-tools/entr…"   About a minute ago   Up About a minute                                              kube-apiserver
    a48bf60cedee        192.168.1.121:5000/rancher/rke-tools:v0.1.15            "/opt/rke-tools/rke-…"   About a minute ago   Up About a minute                                              etcd-rolling-snapshots
    1e2982389b9b        192.168.1.121:5000/rancher/coreos-etcd:v3.2.18          "/usr/local/bin/etcd…"   About a minute ago   Up About a minute                                              etcd
    5dc52bbda74b        f3d94aa8c942                                            "run.sh"                 About a minute ago   Up About a minute                                              k8s_cluster-register_cattle-cluster-agent-648c669ff-62bmh_cattle-system_9078a001-2772-11e9-ab6e-0800272cc3f6_0
    eeb23ca914bb        rancher/pause-amd64:3.1                                 "/pause"                 About a minute ago   Up About a minute                                              k8s_POD_cattle-cluster-agent-648c669ff-62bmh_cattle-system_9078a001-2772-11e9-ab6e-0800272cc3f6_0
    eccf9a4c922b        192.168.1.121:5000/rancher/rancher-agent:v2.1.6         "run.sh --server htt…"   About a minute ago   Up About a minute                                              wonderful_swirles
    82d1903edcf1        7eca10056c8e                                            "start_runit"            About a minute ago   Up About a minute                                              k8s_calico-node_canal-c549z_kube-system_2f634cdd-26df-11e9-a8a0-0800272cc3f6_11
    9e1e965085fa        8a7739f672b4                                            "/sidecar --v=2 --lo…"   About a minute ago   Up About a minute                                              k8s_sidecar_kube-dns-7588d5b5f5-z7f62_kube-system_9e327cb3-26d9-11e9-a8a0-0800272cc3f6_2
    29fbddcfc059        e183460c484d                                            "/cluster-proportion…"   About a minute ago   Up About a minute                                              k8s_autoscaler_kube-dns-autoscaler-5db9bbb766-4ls55_kube-system_9e24ac20-26d9-11e9-a8a0-0800272cc3f6_2
    b574106e818d        rancher/metrics-server-amd64                            "/metrics-server --s…"   About a minute ago   Up About a minute                                              k8s_metrics-server_metrics-server-97bc649d5-8b4t6_kube-system_a1473d6d-26d9-11e9-a8a0-0800272cc3f6_2
    6dbe0aa0e7a9        846921f0fe0e                                            "/server"                About a minute ago   Up About a minute                                              k8s_default-http-backend_default-http-backend-797c5bc547-vht58_ingress-nginx_a9974b4d-26d9-11e9-a8a0-0800272cc3f6_2
    4d8708ed7a0b        6816817d9dce                                            "/dnsmasq-nanny -v=2…"   About a minute ago   Up About a minute                                              k8s_dnsmasq_kube-dns-7588d5b5f5-z7f62_kube-system_9e327cb3-26d9-11e9-a8a0-0800272cc3f6_2
    a9dc6b7fbfbe        192.168.1.121:5000/rancher/rancher-agent:v2.1.6         "run.sh --server htt…"   About a minute ago   Up About a minute                                              dreamy_thompson
    05562b62f4e1        f0fad859c909                                            "/opt/bin/flanneld -…"   About a minute ago   Up About a minute                                              k8s_kube-flannel_canal-c549z_kube-system_2f634cdd-26df-11e9-a8a0-0800272cc3f6_2
    25b703b7b8b7        rancher/pause-amd64:3.1                                 "/pause"                 2 minutes ago        Up About a minute                                              k8s_POD_kube-dns-autoscaler-5db9bbb766-4ls55_kube-system_9e24ac20-26d9-11e9-a8a0-0800272cc3f6_2
    bfda5698f14d        55ffe31ac578                                            "/kube-dns --domain=…"   2 minutes ago        Up About a minute                                              k8s_kubedns_kube-dns-7588d5b5f5-z7f62_kube-system_9e327cb3-26d9-11e9-a8a0-0800272cc3f6_2
    fdf944746dda        rancher/pause-amd64:3.1                                 "/pause"                 2 minutes ago        Up About a minute                                              k8s_POD_metrics-server-97bc649d5-8b4t6_kube-system_a1473d6d-26d9-11e9-a8a0-0800272cc3f6_2
    c5702943a490        9f355e076ea7                                            "/install-cni.sh"        2 minutes ago        Up About a minute                                              k8s_install-cni_canal-c549z_kube-system_2f634cdd-26df-11e9-a8a0-0800272cc3f6_2
    fe7b5dbdb31d        rancher/pause-amd64:3.1                                 "/pause"                 2 minutes ago        Up About a minute                                              k8s_POD_default-http-backend-797c5bc547-vht58_ingress-nginx_a9974b4d-26d9-11e9-a8a0-0800272cc3f6_2
    ceacdd957362        rancher/pause-amd64:3.1                                 "/pause"                 2 minutes ago        Up 2 minutes                                                   k8s_POD_kube-dns-7588d5b5f5-z7f62_kube-system_9e327cb3-26d9-11e9-a8a0-0800272cc3f6_2
    b568e6616d77        rancher/pause-amd64:3.1                                 "/pause"                 2 minutes ago        Up 2 minutes                                                   k8s_POD_canal-c549z_kube-system_2f634cdd-26df-11e9-a8a0-0800272cc3f6_2
    28ed37a566f0        rancher/pause-amd64:3.1                                 "/pause"                 2 minutes ago        Up 2 minutes                                                   k8s_POD_nginx-ingress-controller-dbhfc_ingress-nginx_2f61cb7e-26df-11e9-a8a0-0800272cc3f6_2
    93ff1ffb9abe        192.168.1.116:5000/rancher/rancher:v2.1.6               "entrypoint.sh"          19 hours ago         Up 2 minutes        0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   pedantic_shaw


### Handy Container Mop Up Scripts

Through my learning experience, messed things up badly several times. It was handy to be able to nuke every docker container running. Credit to [Christoph Baudson](http://blog.baudson.de/blog/stop-and-remove-all-docker-containers-and-images) for these:

List all containers:

    docker ps -aq

Stop all running containers:

    docker stop $(docker ps -aq)

Remove all containers:

    docker rm $(docker ps -aq)

Remove all images:

    docker rmi $(docker images -q)




# Using Rancher


Once provisioned, try *Launch kubectl* via the Rancher web UI. This is a vanilla [kubectl](https://kubernetes.io/docs/reference/kubectl/cheatsheet/) CLI:

    > kubectl get all
    NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
    service/kubernetes   ClusterIP   10.43.0.1    <none>        443/TCP   15m

Nice!



# Troubleshooting

## Docker logs

You'll need to know the ID (or name) of the container you're troubleshooting, e.g `5759f60a7c41` is the *rancher-agent* running below:

    $ sudo docker ps
    CONTAINER ID        IMAGE                                             COMMAND                  CREATED             STATUS              PORTS               NAMES
    5759f60a7c41        192.168.1.121:5000/rancher/rancher-agent:v2.1.6   "run.sh --server htt…"   2 minutes ago       Up 2 minutes                            stoic_torvald

To view its logs:

    $ docker logs 5759f60a7c41
    INFO: Arguments: --server https://192.168.1.115 --token REDACTED --ca-checksum 61f6923ccee33f6adac25675e6a9e348e575f67c277b377b82d401c72442b4a0 --worker
    INFO: Environment: CATTLE_ADDRESS=192.168.1.30 CATTLE_INTERNAL_ADDRESS= CATTLE_NODE_NAME=routeburn CATTLE_ROLE=,worker CATTLE_SERVER=https://192.168.1.115 CATTLE_TOKEN=REDACTED
    INFO: Using resolv.conf: search bencode.net nameserver 1.1.1.1 nameserver 1.0.0.1
    INFO: https://192.168.1.115/ping is accessible
    INFO: Value from https://192.168.1.115/v3/settings/cacerts is an x509 certificate


You can also follow (`-f`) logs:

    $ docker logs -f kubelet




# Resources

* [https://kubernetes.io/docs/home/]()
* [https://rancher.com/docs/rancher/v2.x/en/overview/]()



