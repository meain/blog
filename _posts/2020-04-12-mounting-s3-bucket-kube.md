---
layout: post
title: "Mouting S3 bucket in a docker container"
description: "Mouting S3 bucket in a docker container in a kubernetes cluster"
comments: true
keywords: "docker, s3, mount, s3fs, fuse, kubernetes, aws, gcp, gks, eks"
---

Another installment of me figuring out more of kubernetes.

So, I was working on a project which will let people login to a web service and spin up a coding env with prepopulated
data and creds. We were spinning up kube pods for each user.

All of our data is in s3 buckets, so it would have been really easy if could just mount s3 buckets in the docker
container. My initial thought was that there would be some [PV](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) which I could use, but it can't be that simple right.

So after some hunting, I thought I would just mount the s3 bucket as a volume in the pod. I was not sure if this was the
right way to go, but I thought I would go with this anyways.

I found this repo [s3fs-fuse/s3fs-fuse](https://github.com/s3fs-fuse/s3fs-fuse) which will let you mount s3.
Tried it out in my local and it seemed to work pretty well. Could not get it to work in a docker container initially but
figured out that I just had to give the container extra privileges.

Adding `--privileged` to the docker command takes care of that.

Now to actually get it running on k8s.

### Step 1: Create Docker image

This was relatively straight foreward, all I needed to do was to pull an alpine image and installing 
[s3fs-fuse/s3fs-fuse](https://github.com/s3fs-fuse/s3fs-fuse) on to it.

Just build the following container and push it to your container.
I have published this image on my Dockerhub. You can use [that](https://hub.docker.com/r/meain/s3-mounter) if you want.


```docker
FROM alpine:3.3

ENV MNT_POINT /var/s3fs
ARG S3FS_VERSION=v1.86

RUN apk --update --no-cache add fuse alpine-sdk automake autoconf libxml2-dev fuse-dev curl-dev git bash; \
    git clone https://github.com/s3fs-fuse/s3fs-fuse.git; \
    cd s3fs-fuse; \
    git checkout tags/${S3FS_VERSION}; \
    ./autogen.sh; \
    ./configure --prefix=/usr; \
    make; \
    make install; \
    make clean; \
    rm -rf /var/cache/apk/*; \
    apk del git automake autoconf;

RUN mkdir -p "$MNT_POINT"

COPY run.sh run.sh
CMD ./run.sh
```

**run.sh**

```sh
echo "$AWS_KEY:$AWS_SECRET_KEY" > passwd && chmod 600 passwd
s3fs "$S3_BUCKET" "$MNT_POINT" -o passwd_file=passwd  && tail -f /dev/null
```

### Step 2: Create ConfigMap

The Dockerfile does not really contain any specific items like bucket name or key. Here we use a `ConfigMap` to inject
values into the docker container. A sample `ConfigMap` will look something like this.\
Replace the empty values with your specific data.
Afer that just `k apply -f configmap.yaml`

**configmap.yaml**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: s3-config
data:
  S3_REGION: ""
  S3_BUCKET: ""
  AWS_KEY: ""
  AWS_SECRET_KEY: ""
```

### Step 3: Create DaemonSet

Well we could technically just have this mounting in each container, but this is a better way to go.
What we are doing is that we mount s3 to the container but the folder that we mount to, is mapped to host machine.

With this, we will easily be able to get the folder from the host machine in any other container just as if we are
mounting a normal fs.

The visualisation from [freegroup/kube-s3](https://github.com/freegroup/kube-s3) makes it pretty clear.

![screenshot]({{site.url}}{{site.baseurl}}/assets/images/s3-mount.png)


Since every pod expects the item to be available in the host fs, we need to make sure all host VMs do have the folder. A
`DaemonSet` will let us do that. A `DaemonSet` pretty much ensures that one of this container will be run on every node
which you specify. In our case, we ask it to run on all nodes.

Once ready `k apply -f daemonset.yaml`.

> If you check the file, you can see that we are mapping /var/s3fs to /mnt/s3data on host

**daemonset.yaml**

```yaml
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  labels:
    app: s3-provider
  name: s3-provider
spec:
  template:
    metadata:
      labels:
        app: s3-provider
    spec:
      containers:
      - name: s3fuse
        image: meain/s3-mounter
        securityContext:
          privileged: true
        envFrom:
        - configMapRef:
            name: s3-config
        volumeMounts:
        - name: devfuse
          mountPath: /dev/fuse
        - name: mntdatas3fs
          mountPath: /var/s3fs:shared
      volumes:
      - name: devfuse
        hostPath:
          path: /dev/fuse
      - name: mntdatas3fs
        hostPath:
          path: /mnt/s3data
```

With that applied you will have :

```
$ k get all
NAME                    READY   STATUS    RESTARTS   AGE
pod/s3-provider-psp9v   1/1     Running   0          39m
pod/s3-provider-zvfrs   1/1     Running   0          39m

NAME                         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/s3-provider   2         2         2       2            2           <none>          39m
```

By now, you should have the host system with s3 mounted on `/mnt/s3data`.
You can check that by running the command `k exec -it s3-provider-psp9v -- ls /var/s3fs`

### Step 4: Running your actual container

With all that setup, now you are ready to go in and actually do what you started out to do. I will show a really simple
pod spec.

**pod.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: nginx
    name: s3-test-container
    securityContext:
      privileged: true
    volumeMounts:
    - name: mntdatas3fs
      mountPath: /var/s3fs:shared
  volumes:
  - name: mntdatas3fs
    hostPath:
      path: /mnt/s3data
```

Run this and if you check in `/var/s3fs`, you can see the same files you have in your s3 bucket.

*Change `mountPath` to change where it gets mounted to. Change `hostPath.path` to a subdir if you only want to expose on
specific folder*

## Extra resources

- [freegroup/kube-s3](https://github.com/freegroup/kube-s3)

- [s3fs-fuse/s3fs-fuse](https://github.com/s3fs-fuse/s3fs-fuse)

- [skypeter1/docker-s3-bucket](https://github.com/skypeter1/docker-s3-bucket)

- [Kubernetes-shared-storage-with-S3-backend](https://icicimov.github.io/blog/virtualization/Kubernetes-shared-storage-with-S3-backend/)
