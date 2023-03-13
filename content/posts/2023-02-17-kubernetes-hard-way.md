---
layout: post
draft: true
title: "Kubernetes the hard way"
slug: "k8shard"
date: "2023-02-17 19:44:36+11:00"
lastmod: "2023-02-17 19:44:36+11:00"
comments: false
categories:
  - kubernetes
tags:
  - kubernetes
  - k8s
  - devops
---

Kelsey Hightower's brilliant guide on building a kubernetes cluster by hand from the ground up, for more see [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way.git)

Instead of using GCP I've gone with 6 local ubuntu server 22.04 VMs using VirtualBox.

## Install client tools

CloudFlare SSL tools:

```sh
wget -q --show-progress --https-only --timestamping \
  https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssl \
  https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssljson

chmod +x cfssl cfssljson
sudo mv cfssl cfssljson /usr/local/bin/
```

kubectl:

```sh
wget https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

## Setup VMs

Setup 3 control plane nodes and 3 worker nodes, as follows:

- controller-0: 10.240.0.10
- controller-1: 10.240.0.11
- controller-2: 10.240.0.12
- worker-0: 10.240.0.20
- worker-1: 10.240.0.21
- worker-2: 10.240.0.22

Ensure on each:

- `k8s` account with password `password`
- `sshd` installed
- 

## Certificates and keys

Provision certs and keys as per the CloudFlare SSL toolkit in the official guide.

Distribute keys to worker nodes:

```bash
scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem k8s@10.240.0.20:~/
scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem k8s@10.240.0.21:~/
scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem k8s@10.240.0.22:~/
```

Distribute certs and keys to controller nodes:

TODO
