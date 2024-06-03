---
layout: post
draft: false
title: "Kustomize"
slug: "kustomize"
date: "2024-05-03 22:17:30"
lastmod: "2024-05-03 22:17:30"
comments: false
categories:
  - kubernetes
tags:
  - k8s
  - kustomize
---


Kustomize is built into `kubectl` with `-k`. Great samples on [kubernetes.io/docs](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)

> Kustomize provides a template-free way to customize kubernetes manifest

Contents:

- [Generating resources](#generating-resources)
- [Setting cross cutting fields](#setting-cross-cutting-fields)
- [Composing and customizing resources](#composing-and-customizing-resources)
  - [Composing](#composing)
  - [Customizing](#customizing)
    - [Patches](#patches)
    - [Images](#images)
    - [Replacements](#replacements)
- [Reference](#reference)

In a nutshell provides 3 key features:

1. generating resources from other sources
2. setting cross-cutting fields for resources
3. composing and customizing collections of resources

## Generating resources

To generate a ConfigMap from an `.env` file, add an entry to the envs list in `configMapGenerator`. Kustomize supports other formats such as `.properties`.

The `.env` file:

```env
FOO=Bar
```

`kustomization.yaml`:

```yaml
configMapGenerator:
  - name: example-configmap-1
    envs:
      - .env
```

Run it:

```bash
kubectl kustomize ./
```

The generated result:

```yaml
apiVersion: v1
data:
  FOO: Bar
kind: ConfigMap
metadata:
  name: example-configmap-1-42cfbf598f
```

## Setting cross cutting fields

It's common to set cross-cutting fields for all Kubernetes resources in a project. Some use cases for setting cross-cutting fields:

- setting the same namespace for all Resources
- adding the same name prefix or suffix
- adding the same set of labels
- adding the same set of annotations

`deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx
```

`kustomization.yaml`:

```yaml
namespace: my-namespace
namePrefix: dev-
nameSuffix: "-001"
commonLabels:
  app: bingo
commonAnnotations:
  oncallPager: 800-555-1212
resources:
  - deployment.yaml
```

Run it:

```bash
kubectl kustomize ./
```

The generated result:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    oncallPager: 800-555-1212
  labels:
    app: bingo
  name: dev-nginx-deployment-001
  namespace: my-namespace
spec:
  selector:
    matchLabels:
      app: bingo
  template:
    metadata:
      annotations:
        oncallPager: 800-555-1212
      labels:
        app: bingo
    spec:
      containers:
        - image: nginx
          name: nginx
```

## Composing and customizing resources

### Composing

Kustomize supports composition of different resources. The `resources` field, in the `kustomization.yaml` file, defines the list of resources to include in a configuration. Here's an NGINX application comprised of a `Deployment` and a `Service`:

`kustomization.yaml`:

```yaml
resources:
  - deployment.yaml
  - service.yaml
```

### Customizing

#### Patches

Kustomize supports different patching mechanisms through `patchesStrategicMerge` and `patchesJson6902`. `patchesStrategicMerge` is a list of file paths. Each file should be resolved to a strategic merge patch. The names inside the patches must match Resource names that are already loaded. Small cohensive patches that do one thing are recommended. For example, create one patch for increasing the deployment replica number and another patch for setting the memory limit.

`deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  selector:
    matchLabels:
      run: my-nginx
  replicas: 2
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
        - name: my-nginx
          image: nginx
          ports:
            - containerPort: 80
```

`increase_replicas_patch.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  replicas: 3
```

`set_memory_patch.yaml.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  template:
    spec:
      containers:
        - name: my-nginx
          resources:
            limits:
              memory: 512Mi
```

`kustomization.yaml`:

```yaml
resources:
  - deployment.yaml
patchesStrategicMerge:
  - increase_replicas.yaml
  - set_memory.yaml
```

To apply objects:

```bash
kubectl apply -k <directory>/
```

#### Images

Container images or injecting field values from other objects into containers without creating patches

`kustomization.yaml`:

```yaml
resources:
  - deployment.yaml
images:
  - name: nginx
    newName: my.image.registry/nginx
    newTag: 1.4.0
```

#### Replacements

Sometimes the application running in a Pod may need to use configuration values from other objects. For example, a Pod from a Deployment object need to read the Service name from Env or as a command argument. Here we lift the post processed service name and inject it as the 3rd command argument on the pod spec:

`kustomization.yaml`:

```yaml
namePrefix: dev-
nameSuffix: "-001"

resources:
  - deployment.yaml
  - service.yaml

apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
replacements:
  - source:
      kind: Service
      name: my-nginx
      version: v1
    targets:
      - fieldPaths:
          - spec.template.spec.containers.0.command.2
        select:
          group: apps
          kind: Deployment
          name: my-nginx
          version: v1
```

## Reference

<https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/>
