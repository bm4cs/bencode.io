---
layout: post
title: "Kubernetes Secrets encoding gotcha"
draft: false
slug: "k8s-secrets"
date: "2021-08-25 14:17:32"
lastmod: "2021-08-25 14:17:34"
comments: false
categories:
    - kubernetes
tags:
    - kubernetes
    - k8s
    - gotcha
---

Kubernetes provides a neat concept for managing sensitive pieces of data, the [Secret](https://kubernetes.io/docs/concepts/configuration/secret/)

> A Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key. Such information might otherwise be put in a Pod specification or in a container image. Using a Secret means that you don't need to include confidential data in your application code.

Secret text is by default base64 encoded. For this reason it's recommended that secret definitions are not published to git.

A sample configuration:

```yaml
apiVersion v1
kind: Secret
metadata:
  name: postgres-secrets
  namespace: bencode
type: Opaque
data:
  username: cG9zdGdyZXMK #postgres
  password: cGFzc3dvcmQK #password
---
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: awesome-db
    image: postgres:latest
    env:
      - name: POSTGRES_USER
        valueFrom:
          secretKeyRef:
            name: postgres-secrets
            key: username
      - name: POSTGRES_PASSWORD
        valueFrom:
          secretKeyRef:
            name: postgres-secrets
            key: password
  restartPolicy: Never
```

I recently wasted several hours troubleshooting Pods that had environment bound to opaque passwords. Here's how I base64 encoded things:

```
echo password | base64
```

Turns out this is WRONG, as `echo` by default will emit line endings. This issue is rather tough to troubleshoot, as echoing out the environment variables from within the running *Pods*, everything appears to be in order.

The correct way to encode:

```
echo -n password | base64
```

