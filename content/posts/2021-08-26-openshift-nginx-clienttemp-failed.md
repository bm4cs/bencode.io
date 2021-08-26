---
layout: post
title: "OpenShift NGINX 13: permission denied /var/cache/nginx/client_temp"
draft: false
date: "2021-08-26 16:36:19"
lastmod: "2021-08-26 16:36:22"
comments: false
categories:
    - kubernetes
tags:
    - kubernetes
    - k8s
    - openshift
    - nginx
---

Trying to deploy an NGINX container to an OpenShift cluster today, ran into:

```
nginx: [emerg] mkdir() "/var/cache/nginx/client_temp" failed (13: Permission denied)
```

To do some investigating spun up a new *Pod* an attached an interactive shell using `oc`:

```
oc run --rm -i -t frontend --image=artifactory.bencode.net/frontend:1.0.0 --restart=Never --command -- /bin/sh
```

Indeed a quick `ls -la /var/cache` revealed that the `nginx` subdirectory is writtable by `root`. No good for OpenShift, which by default is non-root:

```
$ whoami
1000790000
```

Luckily nginxinc maintain a rootless optimised base container image called [nginxinc/nginx-unprivileged](https://hub.docker.com/r/nginxinc/nginx-unprivileged).

