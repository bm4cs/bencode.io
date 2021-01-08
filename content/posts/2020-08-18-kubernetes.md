---
layout: post
draft: false
title: "Kubernetes"
slug: "k8s"
date: "2020-08-18 20:11:30"
lastmod: "2020-12-17 22:14:51"
comments: false
categories:
  - linux
tags:
  - k8s
  - containers
---

> The name Kubernetes originates from Greek, meaning helmsman or pilot.

- [Terminology](#terminology)
- [Essentials](#essentials)
  - [Help](#help)
  - [Bash kubectl completion](#bash-kubectl-completion)
  - [Web UI dashboard](#web-ui-dashboard)
- [Pods](#pods)
  - [Creating a pod](#creating-a-pod)
    - [Option 1: Imperatively with the CLI](#option-1-imperatively-with-the-cli)
    - [Option 2: Declaratively with YAML](#option-2-declaratively-with-yaml)
  - [Port forwarding](#port-forwarding)
  - [Managing pods](#managing-pods)
  - [Pod Health](#pod-health)
- [Deployments and ReplicaSets](#deployments-and-replicasets)
  - [ReplicaSet](#replicaset)
  - [Deployment](#deployment)
  - [Deployments with kubectl](#deployments-with-kubectl)
  - [Deployment Options](#deployment-options)
    - [Rolling updates](#rolling-updates)
    - [Blue Green](#blue-green)
    - [Canary](#canary)
    - [Rollbacks](#rollbacks)
  - [StatefulSets](#statefulsets)
- [Services](#services)
  - [Service Types](#service-types)
  - [Port forwarding take 2](#port-forwarding-take-2)
  - [Services YAML](#services-yaml)
    - [NodePort example](#nodeport-example)
    - [ExternalName example](#externalname-example)
  - [Testing Service and Pod with curl](#testing-service-and-pod-with-curl)
- [Storage](#storage)
  - [Volumes](#volumes)
    - [Volume Types](#volume-types)
    - [Viewing a Pods volumes](#viewing-a-pods-volumes)
    - [emptyDir volume example](#emptydir-volume-example)
  - [PeristentVolumes and PeristentVolumesClaims](#peristentvolumes-and-peristentvolumesclaims)
  - [StorageClasses](#storageclasses)
- [ConfigMaps and Secrets](#configmaps-and-secrets)
  - [Defining ConfigMaps](#defining-configmaps)
  - [Consuming ConfigMaps](#consuming-configmaps)
- [The API](#the-api)
- [General kubectl](#general-kubectl)
- [Waaay cool](#waaay-cool)
- [Samples](#samples)
  - [node.js app](#nodejs-app)
- [microk8s](#microk8s)
  - [Shell improvements](#shell-improvements)
  - [PersistentVolume storage location](#persistentvolume-storage-location)
- [Resources](#resources)

# Terminology

k8s is two concepts; the control plane and nodes.

Terminology:

- **Control plane** management components that mother-hen nodes and pods
  - `kube-controller` the controller manager
  - `kube-api-server` the frontend API that ties everything together
  - `kube-scheduler` figures out which _nodes_ to run _pods_ on
  - `etcd` the underpinning database
- **Node** a worker machine (VM) that hosts _pods_
  - `kubelet` agent that talks with the control plane
  - `kube-proxy` a network proxy
  - `supervisord` monitoring of the kubelet and pods
  - `weave` a software defined network (SDN)
  - `fluentd` unified logging agent
  - `containerd` a container runtime of some sort
- **Pod** a set of containers (spacesuit)
- **ReplicaSet** manages replicas of a _pod_ (ex: 3 nginx pods)
- **Deployment** transitions actual state to desired state
- **Service** exposes an application that may be running on many pods, externally from the k8s cluster

# Essentials

## Help

- Local offline CLI based help is taken care of by the `kubectl explain` command. Whats a pod and how do you define it again? `kubectl explain pods`
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

## Bash kubectl completion

1. Register the bash completion script either per user `echo 'source <(kubectl completion bash)' >>~/.bashrc` or at machine level `kubectl completion bash >/etc/bash_completion.d/kubectl`
2. To work with aliases `echo 'alias k=kubectl' >>~/.bashrc` then `echo 'complete -F __start_kubectl k' >>~/.bashrc`

## Web UI dashboard

1. Follow the [Web UI docs](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/).
2. By default will need a token to authenticate. Use `kubectl describe secret -n kube-system` and find the token called `attachdetach-controller-token-dhx2s`.
3. Establish localhost (node) level connectivity to the kube API with `kubectl proxy` (or `microk8s dashboard-proxy`)
4. For external cluster web UI access on port 10433 `sudo microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443 --address 0.0.0.0`

# Pods

- a pod always lives on a single node (i.e. cant span nodes)
- are allocated unique IPs within the k8s cluster (i.e. cluster IPs, which are not externally accessible)
- containers within a pod, share the same network namespace (i.e. can communicate via loopback)
- container processes within the same pod, need to bind to different ports (e.g. cant have multiple port 80 processes in same pod)

## Creating a pod

### Option 1: Imperatively with the CLI

With `kubectl run my-frontend-pod --image=nginx:alpine`

### Option 2: Declaratively with YAML

Using `kubectl create/apply`.

First you need to articulate the various object settings as YAML.

Luckily these are well [documented](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/), such as the format for a [Pod](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#podspec-v1-core) or a [Deployment](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#deploymentspec-v1-apps) and so on.

```yml
apiVersion: v1
kind: Pod
metadata:
  name: my-nginx
  labels:
    app: nginx
    rel: stable
spec:
  containers:
    - name: my-nginx
      image: nginx:alpine
      ports:
        - containerPort: 80
      resources:
```

1. Author the YAML
2. Validate it `kubectl create -f my-nginx-pod.yml --dry-run=client --validate=true`
3. Run it `kubectl create -f my-nginx-pod.yml --save-config`

Highlights:

- `kubectl create` will error if an object already exists
- `kubectl apply` on the other hand is more accomodating, and will update existing objects if needed
- `kubectl create` has an `--save-config` option which will export the base configuration as YAML as store it in the YAML as an `metadata: Annotation`
- `kubectl delete -f my-nginx-pod.yml`
- YAML can be interactively edited with `kubectl edit` or patched with `kubectl patch`

## Port forwarding

After the pod is made, need to expose the pod externally in some way, so the outside world can get in. One option is simple port forwarding with `kubectl port-forward my-frontend-pod 8080:80` (8080 = external, 80 = internal)

1. `kubectl run my-nginx --image=nginx:alpine`
2. `kubectl get pods -o yaml`
3. `kubectl port-forward my-nginx 8080:80 --address 0.0.0.0`

## Managing pods

- `kubectl get pods -o yaml` get detailed pod information as YAML
- `kubectl describe pods my-nginx` awesome details about pod and its containers, but also full event log
- `kubectl delete pod my-frontend-pod` be aware, if made with a deployment, k8s will automatically recreate the pod (i.e. you need to delete the deployment first)
- `kubectl exec my-nginx -it sh` get an interative (i.e. `stdin` and `stdout`) TTY

## Pod Health

The kubelet uses [probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) to know when to bounce a container.

- _liveness probe_ when should a container be restarted?
- _readiness probe_ sometimes apps are temporarily unfit to serve traffic (e.g. sparking up a JVM is often slow, but fast after load)
- _startup probe_ for old apps that do take a long time to start, you can define a large startup probe threshold (ex: 300s) which must succeed before the liveness probe will kick in

A probe can comprise of:

- `ExecAction` run some shell in the container
- `TCPSocketAction` TCP request
- `HTTPGetAction` HTTP GET request

For example an HTTP GET probe:

```yml
apiVersion: v1
kind: Pod
---
spec:
  containers:
    - name: my-nginx
      image: nginx:alpine
      livenessProbe:
        httpGet:
          path: /index.html
          port: 80
        initialDelaySeconds: 15
        timeoutSeconds: 2
        periodSeconds: 5
        failureThreshold: 1
```

Versus an exec probe:

```yml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-exec
spec:
  containers:
    - name: liveness
      image: k8s.gcr.io/busybox
      args:
        - /bin/sh
        - -c
        - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
      livenessProbe:
        exec:
          command:
            - cat
            - /tmp/healthy
        initialDelaySeconds: 5
        periodSeconds: 5
```

If a pod fails a probe, by default it will be restarted (`restartPolicy: Always`)

# Deployments and ReplicaSets

A neat way of managing the rollout of _Pods_. _Deployment_ lean on the concept of a _ReplicaSet_, which ensures a specified number of instances of a _Pod_ runs.

Deploying _Pods_ by hand is unusual, always use _Deployments_

## ReplicaSet

- A _ReplicaSet_ can be thought of as a _Pod_ controller
- Uses a pod template (YAML) to spool up new pods when needed
-

## Deployment

[Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) were introduced post _ReplicaSets_, adds even more abstraction and convenience on top of _ReplicaSets_, such as zero downtime deploys.

- Wrap _ReplicaSets_
- Facilitate zero downtime rolling updates, by carefully creating and destroying _ReplicaSets_
- Provide rollbacks, if bugs are discovered in the latest release
- To manage the various _ReplicaSets_ and _Pods_ that get created and killed off, assigns unique labels
- A _Deployment_ spec in YAML is almost identical to a _ReplicaSet_. _Pod templates_ are defined, each with a selector, as various _Pods_ (ex: nginx, postgres, redix) can be managed by a single _Deployment_
- Label play a huge role in tying various _Pod_ workloads together as needed

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  selector:
    matchLabels:
      app: my-nginx
  replicas: 3
  minReadySeconds: 10 #dont kill my pod, wait at least 10s pls
  template:
    metadata:
      labels:
        app: my-nginx
    spec:
      containers:
        - name: my-nginx
          image: nginx:alpine
          ports:
            - containerPort: 80
          resources:
            limits:
              memory: "128Mi" #128 MB
              cpu: "100m" #100 millicpu (.1 cpu or 10% of the cpu)
```

Creating this deployment, will create 3 Pods, 1 ReplicaSet and 1 Deployment. Note the unique identifier added to the name of the ReplicaSet, matches up with the Pods. This simple scheme is extactly how k8s knows which Pods relate to ReplicaSets.

```
# kubectl create -f nginx.deployment.yml --save-config
deployment.apps/my-nginx created

# kubectl get all
NAME                            READY   STATUS    RESTARTS   AGE
pod/my-nginx-5bb9b897c8-hx2w5   1/1     Running   0          5s
pod/my-nginx-5bb9b897c8-ql6nq   1/1     Running   0          5s
pod/my-nginx-5bb9b897c8-j65xb   1/1     Running   0          5s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.152.183.1   <none>        443/TCP   26h

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-nginx   3/3     3            3           5s

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/my-nginx-5bb9b897c8   3         3         3       5s

```

## Deployments with kubectl

- `kubectl apply -f my-deployment.yml` create deployment (or update it as necessary)
- `kubectl create -f nginx.deployment.yml --save-config` as with other objects, create works too
- `kubectl get deployment --show-labels` show deployment labels
- `kubectl get deployment -l tier=backend` filter deployments on label match
- `kubectl delete my-deployment` blow it away
- `kubectl scale deployment my-deployment --replicas=5` awesome!
- `kubectl `
- `kubectl `

## Deployment Options

### Rolling updates

When deploying a new version of the app, this mode will replace a single v1 pod at a time, with a v2 pod only once its ready to serve traffic (readiness probe). If successful, it will continue in the same manner, until all v1 pods are gradually replaced.

### Blue Green

When you have two concurrent releases of an app running live in production. Traffic is gradually transferred from the old to the new.

### Canary

Deploying a canary involves deploying the new app side by side the old version, and allocating a controlled subset (ex: 1 in 10 request) of traffic to it, before fully rolling it out.

### Rollbacks

Reinstate the previous version of the deployment.

## StatefulSets

> Manages the deployment and scaling of a set of Pods, and provides guarantees about the ordering and uniqueness of these Pods.

`Deployment` or `ReplicaSet` workload types are stateless, in that `Pods` when provisioned or rescheduled are:

- not assigned stable identifier
- not deployed in any particular order
- not deleted in any particular order
- not scaled in any paricular order

A StatefulSet is almost identitical to a Deployment (i.e. based on the same container spec), however it:

- maintains a sticky identity for each Pod
- provides ordered deployment, deletion or scaling

Use cases:

- Stable, unique network identifiers
- Stable, persistent storage
- Ordered, graceful deployment and scaling
- Ordered, automated rolling updates

# Services

An abstraction to expose an app running on a set of _Pods_ as a network service.

Using Pod IP addresses directly simply doesnt scale, as Pods, and hence their IPs are ephemeral (i.e. can be killed off), and they can also be dynamically provisioned.

- _Services_ decouple consumers from _Pods_
- A _Service_ is assigned a fixed virtual IP (on the _Node_ by `kubectl`) and can load balance request over to the _Pods_
- Labels play a key role, in allowing the _Service_ to marry up to particular _Pods_
- _Services_ are not ephemeral
- _Pods_ in turn can (and should) address other _Pods_ through _Services_
- A _Service_ can map any incoming `port` to a `targetPort`
- A _Service_ can have multiple port definitions if needed
- Services when given a `.metadata.name`, its registered into the internal DNS within the cluster automatically (i.e. within cluster can just refer to its friendly name e.g. frontend _Pod_ can just access `backend:8080`)

## Service Types

Different way to network up _Services_ (ex: such as exposing a frontend app to an external IP for use by web browsers).

Types (as of late 2020) include:

1. `ClusterIP` exposes the Service on a cluster-internal IP (only reachable from within the cluster)
2. `NodePort` exposes the Service on each Node's IP at a static port. A ClusterIP Service, to which the NodePort Service routes, is automatically created. You'll be able to contact the NodePort Service, from outside the cluster, by requesting `<NodeIP>:<NodePort>`
3. `LoadBalancer` exposes the Service externally using a cloud provider's load balancer. `NodePort` and `ClusterIP` Services, are automatically created
4. `ExternalName` just like an alias or proxy to an external service that _Pods_ connect with. This will map the _Service_ to the contents of the `externalName` field (e.g. foo.bar.example.com), by returning a `CNAME` record with its value.

## Port forwarding take 2

As seen with _Pods_ you can port forward to them directly `kubectl port-forward my-frontend-pod 8080:80`

This can be applied to the high level constructs of _Deployments_ and _Services_:

```yml
kubectl port-forward deployment/my-sik-deployment 8080:80
kubectl port-forward service/my-sik-service 8080:80
```

## Services YAML

Based on [ServiceSpec v1 core](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#servicespec-v1-core).

Basic blueprint:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type:
  selector:
  ports:
```

- `type` is one of `ClusterIP`, `NodePort`, `LoadBalancer`
- `selector` selects _Pods_ this _Service_ applies to
- `port` the externally exposed port
- `targetPort` the _Pod_ port to forward onto

### NodePort example

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: NodePort
  selector:
    app: my-nginx
  ports:
    - port: 80
      targetPort: 80
      nodePort: 31000 #normally dynamically generated
```

### ExternalName example

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-service
spec:
  type: ExternalName
  externalName: api.bencode.net
  ports:
    - port: 9000
```

Pods wanting to consume the externally hosted API `https://api.bencode.net`, would instead target `external-service:9000`.

## Testing Service and Pod with curl

Shell into Pod a test URL. Note, you'll need to add `-c [container-id]` if a Pod is housing multiple containers.

```bash
kubectl exec [pod-name] -- curl -s http://[pod-ip]
```

`curl` is a luxury item when it comes to lean containers, and will need to be installed (ex: alpine) over an interactive TTY like so:

```bash
kubectl exec [pod-name] -it sh
apk add curl
curl -s http://[pod-ip]
```

# Storage

## Volumes

[Volumes](https://kubernetes.io/docs/concepts/storage/volumes/) are used to preserve state for Pods and containers.

- Volumes can be attached to Pods
- Containers rely on `mountPath` to get to the Volume
- Volumes can outlive the lifetime of Pods

### Volume Types

There are [many](https://kubernetes.io/docs/concepts/storage/volumes/#volume-types), some common options:

- `emptyDir` first created when a Pod is assigned to a Node, and exists as long as that Pod is running on that node. Useful for housing temporary scratch files.
- `hostPath` Pod mounts to the Nodes file system
- `nfs` literally an NFS backed file share mounted into the Pod
- `configMap` a way to inject configuration data into pods. The data stored in a ConfigMap can be referenced in a volume of type `configMap` and then consumed by containerized applications running in a pod.
- `persistentVolumeClaim` gives Pods more persistent storage

### Viewing a Pods volumes

Both `get` and `describe` commands on the Pod object expose volumes:

- `kubectl describe pod [pod-name]`
- `kubectl get pod [pod-name] -o yaml`

### emptyDir volume example

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-alpine-volume
spec:
  containers:
    - name: nginx
      image: nginx:alpine
      volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
          readOnly: true
      resources:
    - name: html-updater
      image: alpine
      command: ["/bin/sh", "-c"]
      args:
        - while true; do date >> /html/index.html;sleep 10; done
      resources:
      volumeMounts:
        - name: html
          mountPath: /html
  volumes:
    - name: html
      emptyDir: {} #lifecycle tied to Pod

# kubectl apply -f nginx-alpine-emptyDir.pod.yml
# kubectl port-forward nginx-alpine-volume 8080:80 --address 0.0.0.0
```

## PeristentVolumes and PeristentVolumesClaims

A _PersistentVolume_ is provisioned by an administrator (i.e. not dynamically as part of a _Deployment_), is cluster wide storage unit, that has a lifecycle independent from a _Pod_.

A _PeristentVolumesClaim_ is simply a request to make use of a particular _PersistentVolume_.

- A _PersistentVolume_ is available to a _Pod_, even if reallocated to another _Node_
- Relies on an underlying storage provider (GlusterFS, Ceph, NFS, cloud storage, etc)
- A _Pod_ binds to a _PersistentVolume_ by issuing a _PersistentVolumeClaim_

## StorageClasses

A way to manage storage as "profiles" (ex: a backup profile vs a low latency profile).

- Can dynamically provision storage as needed (unlike a _PersistentVolume_)
- Acts a storage template
- If enabled, admins dont have to get involved to create _PeristentVolumes_ in advance

StorageClass workflow:

1. Define a `StorageClass` (YAML)
2. Create a `PeristentVolumesClaim` that references the `StorageClass`
3. `StorageClass` provisioner will create `PersistentVolume`
4. After the actual storage is creatd for the `PersistentVolume`, the `PersistentVolume` is connected up to the original `PeristentVolumesClaim` (from step 2)

```yml
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app: mongo-env
  name: mongo-env
data:
  MONGODB_DBNAME: myMongoDb
  #TODO: Use Secret
  MONGODB_PASSWORD: password
  MONGODB_ROLE: readWrite
  #TODO: Use Secret
  MONGODB_ROOT_PASSWORD: password
  MONGODB_ROOT_ROLE: root
  MONGODB_ROOT_USERNAME: dbadmin
  MONGODB_USERNAME: webrole

---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
# The reclaim policy (keep storage around forevs) applies to the persistent volumes not the storage class itself
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer

---
# Note: While a local storage PV works, going with a more durable solution (NFS, cloud option, etc.) is recommended
# https://kubernetes.io/blog/2018/04/13/local-persistent-volumes-beta/
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mongo-pv
spec:
  capacity:
    storage: 10Gi
  # volumeMode block feature gate enabled by default with 1.13+
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  # StorageClass has a reclaim policy default so it'll be "inherited" by the PV
  # persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /tmp/data/db
  # the node this storage will be bound to
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - foobox002

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongo-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-storage
  resources:
    requests:
      storage: 10Gi

---
apiVersion: v1
kind: Service
metadata:
  name: mongo
spec:
  selector:
    app: mongo
  ports:
    - port: 27017
      targetPort: 27017

---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app: mongo
  name: mongo
spec:
  serviceName: mongo
  replicas: 1
  selector:
    matchLabels:
      app: mongo
  template:
    metadata:
      labels:
        app: mongo
    spec:
      containers:
        - image: mongo
          name: mongo
          ports:
            - containerPort: 27017
          command:
            - mongod
            - "--auth"
          resources: {}
          volumeMounts:
            - name: mongo-volume
              mountPath: /data/db
          env:
            - name: MONGODB_DBNAME
              valueFrom:
                configMapKeyRef:
                  key: MONGODB_DBNAME
                  name: mongo-env
            - name: MONGODB_PASSWORD
              valueFrom:
                configMapKeyRef:
                  key: MONGODB_PASSWORD
                  name: mongo-env
            - name: MONGODB_ROLE
              valueFrom:
                configMapKeyRef:
                  key: MONGODB_ROLE
                  name: mongo-env
            - name: MONGODB_ROOT_PASSWORD
              valueFrom:
                configMapKeyRef:
                  key: MONGODB_ROOT_PASSWORD
                  name: mongo-env
            - name: MONGODB_ROOT_ROLE
              valueFrom:
                configMapKeyRef:
                  key: MONGODB_ROOT_ROLE
                  name: mongo-env
            - name: MONGODB_ROOT_USERNAME
              valueFrom:
                configMapKeyRef:
                  key: MONGODB_ROOT_USERNAME
                  name: mongo-env
            - name: MONGODB_USERNAME
              valueFrom:
                configMapKeyRef:
                  key: MONGODB_USERNAME
                  name: mongo-env
      volumes:
        - name: mongo-volume
          persistentVolumeClaim:
            claimName: mongo-pvc
```

# ConfigMaps and Secrets

`ConfigMaps` store configuration information and surface it to containers.

- configuration is surfaced through to `Pods` as they are scheduled throughout the cluster
- can represent entire files (ex: JSON, XML, YAML) or specific key/value pairs
- values can be provided with `kubectl` (CLI) ex:
  - `--from-file`: `kubectl create configmap app-settings --from-file=settings.properties` this will implicitly add the file name as a root key into the `ConfigMap` data
  - `--from-env-file`: `kubectl create cm app-settings --from-env-file=settings.properties` will NOT add file name as root key, will quote non-string values.
  - `--from-literal`: `kubectl create configmap app-settings --from-literal=apiUrl=https://my-api --from-literal=otherKey=otherValue --from-literal=count=50`
- `ConfigMaps` are first class object type and can be defined with a manifest (YAML) like other k8s objects i.e. `kubectl apply -f settings.configmap.yml`

## Defining ConfigMaps

When adding a raw config file using `kubectl` and `--from-file`, note the file name is used as key for values:

`kubectl create configmap game-config --from-file=game.settings`

```yml
apiVersion: v1
kind: ConfigMap
data:
  game.config: |-
    enemies=aliens
    lives=3
    enemies.cheat=true
    enemies.cheat.level=noGoodRotten
```

Hand crafting the manifest work nicely, here some key/values and files are defined:

```yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: game-demo
data:
  # property-like keys; each key maps to a simple value
  player_initial_lives: "3"
  ui_properties_file_name: "user-interface.properties"

  # file-like keys
  game.properties: |
    enemy.types=aliens,monsters
    player.maximum-lives=5
  user-interface.properties: |
    color.good=purple
    color.bad=yellow
    allow.textmode=true
```

## Consuming ConfigMaps

To examine a `ConfigMap` as its manifest definition use `kubectl get configmap game-config -o yaml`

There are 4 ways to consume `ConfigMaps` from `Pods`:

1. Inside a container command and args
2. Environment variables for a container
3. Add as a file in read-only volume, for application to read
4. Write code to run within the `Pod` that uses the k8s API to read a `ConfigMap`

`Pods` can reference specific `ConfigMap` keys:

```yml
- name: UI_PROPERTIES_FILE_NAME
    valueFrom:
    configMapKeyRef:
        name: game-demo
        key: ui_properties_file_name
```

Or just expose every key defined in the `ConfigMap` as a corresponding container environment variable using the `envFrom` directive:

```yml
spec:
  containers:
    - name: demo
      image: alpine
      command: ["sleep", "3600"]
      envFrom:
        - configMapRef:
          name: game-demo
```

Complete example:

```yml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-demo-pod
spec:
  containers:
    - name: demo
      image: alpine
      command: ["sleep", "3600"]
      env:
        # Define the environment variable
        - name: PLAYER_INITIAL_LIVES # Notice that the case is different here
          # from the key name in the ConfigMap.
          valueFrom:
            configMapKeyRef:
              name: game-demo # The ConfigMap this value comes from.
              key: player_initial_lives # The key to fetch.
        - name: UI_PROPERTIES_FILE_NAME
          valueFrom:
            configMapKeyRef:
              name: game-demo
              key: ui_properties_file_name
      volumeMounts:
        - name: config
          mountPath: "/config"
          readOnly: true
  volumes:
    # You set volumes at the Pod level, then mount them into containers inside that Pod
    - name: config
      configMap:
        # Provide the name of the ConfigMap you want to mount.
        name: game-demo
        # An array of keys from the ConfigMap to create as files
        items:
          - key: "game.properties"
            path: "game.properties"
          - key: "user-interface.properties"
            path: "user-interface.properties"
```

# The API

[Kubernetes API reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/)

The backbone of the control plane, it exposes and manipulates objects such as pods, namespaces and MANY others, as `kubectl api-resources` will show.

Versioning is taken very seriously, with the goal of not breaking compatibility. New alpha and beta functionality is released under a version tag. See `kubectl api-versions`.

# General kubectl

- `kubectl version` cluster version
- `kubectl cluster-info`
- `kubectl get all` pull back info on pods, deployments, services
- `kubectl run [container-name] --image=[image-name]` simple deployment for a pod
- `kubectl port-forward [pod] [ports]` expose port in cluster for external access
- `kubectl expose ...` expose port for deployment or pod
- `kubectl create [resource]` create thing (pod, deployment, service, secret)
- `kubectl apply [resource]` create (or if it exists already modify) resource
- `kubectl get all`
- `kubectl get all -n kube-system`
- `kubectl get pods -o yaml` list all pods, output as YAML

# Waaay cool

- [Canary deployments](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/#canary-deployments)
- Services when given a `.metadata.name`, its registered into the internal DNS within the cluster automatically!

# Samples

## node.js app

[Source code](https://github.com/DanWahlin/DockerAndKubernetesCourseCode/tree/master/samples/deployments/node-app)

```js
const http = require("http"),
  os = require("os");

console.log("v1 server starting");

var handler = function (request, response) {
  console.log("Request from: " + request.connection.remoteAddress);
  response.writeHead(200);
  response.end("v1 running in a pod: " + os.hostname() + "\n");
};

var www = http.createServer(handler);
www.listen(8080);
```

```dockerfile
FROM node:alpine
LABEL author="Benjamin Simmonds"
COPY server.js /server.js
ENTRYPOINT ["node", "server.js"]
```

In the directory containing the `Dockerfile` and `server.js` build and tag a new image.

```bash
docker build -t node-app:1.0 .
```

Build a few versioned images, modifying the version output in `server.js` and the image tag to `2.0` and so on.

Then create deployments for each version.

Note: using my local private docker (localhost:32000) register managed by microk8s.

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-app
spec:
  replicas: 3
  minReadySeconds: 10
  selector:
    matchLabels:
      app: node-app
  template:
    metadata:
      labels:
        app: node-app
    spec:
      containers:
        - image: localhost:32000/node-app:1.0
          name: node-app
          resources:
```

And let the deployments roam free `kubectl apply -f node-app-v1.deployment.yml`. `kubectl get all` should show 3 v1 pod instances running.

To make life a bit easier, register a service:

```yml
apiVersion: v1
kind: Service
metadata:
  name: node-app
spec:
  type: LoadBalancer
  selector:
    app: node-app
  ports:
    - port: 80
      targetPort: 8080
```

Externally you should be able to access the service, on my microk8s cluster this is `http://192.168.122.103:32484/` (external service port shown in `kubectl get all` for the service)

Create deployment YAML for v2 (just change the image from `node-app:1.0` to `node-app:2.0`). ZAfter applying, you will witness a rolling update. Its freaking beautiful to watch <3!!

# microk8s

Love this distribution, which just works.

## Shell improvements

```bash
alias kubectl="microk8s kubectl"
alias mkctl="microk8s kubectl"
alias k="microk8s kubectl"
complete -F __start_kubectl k
```

## PersistentVolume storage location

[How to change microk8s kubernetes storage location](https://stackoverflow.com/questions/63803171/how-to-change-microk8s-kubernetes-storage-location)

[Microk8s storage configuration](https://discuss.kubernetes.io/t/microk8s-storage-configuration/8829)

By default uses `/var/snap/microk8s/common/var/lib/containerd` and `/var/snap/microk8s/common/run/`.

Edit `/var/snap/microk8s/current/args/containerd` and point the `--root` and `--state` to the volume you want. Here is an example that targets `/mnt`:

```
--config ${SNAP_DATA}/args/containerd.toml
--root /mnt/var/lib/containerd
--state /mnt/run/containerd
--address ${SNAP_COMMON}/run/containerd.sock
```

TODO: web UI dashboard, local image registry,

# Resources

- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
- [Kubernetes API reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/)
- [Useful GitHub repo with samples](https://github.com/DanWahlin/DockerAndKubernetesCourseCode)
- [NGINX Ingress Controller Documentation](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/)
- [Official examples GitHub repo](https://github.com/kubernetes/examples/)
