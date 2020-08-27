---
layout: post
draft: true
title: "Kubernetes"
slug: "k8s"
date: "2020-08-18 20:11:30"
lastmod: "2020-08-18 20:11:34"
comments: false
categories:
    - linux
tags:
    - k8s
    - containers
---

# What the?

> The name Kubernetes originates from Greek, meaning helmsman or pilot.

k8s is two concepts; the control plane and nodes.

Where a _node_ is a worker machine that hosts _pods_. The _control plane_ takes care of the nodes and pods.

The **control plane** comprises of `kube-api-server` the frontend API that ties everything together, and the `kube-scheduler` which figures out which nodes to run pods on. A database is needed to store all this information, surely. Yup, its `etcd` which is a hipster key value store.

The **worker nodes** comprise of a `kubelet` agent that talks with the control plane, `kube-proxy` a network proxy, `supervisord` monitoring of the kubelet and pods, a software defined network (SDN) agent such as `weave`, a unified logging agent such as `fluentd`, and of course a container runtime of some sort. Docker is a popular choice. The CRI (container runtime interface) attempt shine some standardisation in this space, making it possible to swap different container runtimes in, such as `containerd` and `CRI-O`.

# The API

[Kubernetes API reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/)

The backbone of the control plane, it exposes and manipulates objects such as pods, namespaces and MANY others, as `kubectl api-resources` will show.

Versioning is taken very seriously, with the goal of not breaking compatibility. New alpha and beta functionality is released under a version tag. See `kubectl api-versions`.

# Local setup

Time to spin up nodes, lots of nodes, control plane nodes and worker nodes. More than one control node can bring fault tolerance say to things like `etcd`.

# kubectl

`kubectl get all`
`kubectl get all -n kube-system`

# Resources

-   [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
-   [kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
-   [Kubernetes API reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/)
