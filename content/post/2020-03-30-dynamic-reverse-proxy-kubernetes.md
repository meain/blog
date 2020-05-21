---
comments: true
date: "2020-03-30T00:00:00Z"
description: Setting up dynamic reverse proxy using nginx in Kubernetes
keywords: kubernetes, ingress, reverse-proxy, dynamic, nginx
title: Dynamic reverse proxy using nginx in Kubernetes
---

OK, first of all, let me make sure that you understand what we are trying to do here.

Let us say that I have a lot of `kubernetes` services with names like below. This list may grow or shrink dynamically
and is controlled by some other script.

*I am spinning up a dev instances for each use as they login. Something new I am working on.*

```
exper-0
exper-1
exper-2
exper-3
exper-4
```

Now if I do not wanna create separate ingress for each item, how would I go about doing this?

> Heads Up. You cannot use default `nginx ingress` for this.

# Architecture

Here is an overview of how we do this.

- Create a custom nginx deployment with a specific `nginx.conf` injected using a `configmap`.
- Create a service which will expose this custom nginx deployment
- Define an ingress with `*.mydomain.com` mapped to this service

With this setup we will have `exper-0.mydomain.com` pointing to `exper-0`.

# Code

Now, going about actually doing it.

## `nginx.conf` and `configmap.yaml`

As we discussed above we need to define a custom nginx conf. This part is expained here.
The essence of your nginx conf is:

```nginx
server {
  listen 80;

  server_name ~^(?<subdomain>.*?)\.;
  resolver kube-dns.kube-system.svc.cluster.local valid=5s;

  location / {
    proxy_pass http://$subdomain.mynamespace.svc.cluster.local;
    proxy_set_header Host $host;
  }
}
```

*Replace `mynamespace` with the namespace you have this thing in*

Let me explain what is going on.

- You listen on port 80. Basic.
- For servername, you have a regex that will pull the first block of hostname to `subdomain`. This gets used a few
lines down.
- You have to specify a resolver as nginx has to resolve this into and actual IP(internal IP of svc).
- Now, inside location block you grab everything and pass it over to `http://$subdomain.mynamespace.svc.cluster.local` which will
resolve to the IP of the service.
- You also need to change `Host` as otherwise it will be set as `http://$subdomain.mynamespace.svc.cluster.local` instead
of `exper-0.mydomain.com`.

We actually need a bit more sutff to support websocket.

```nginx
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "Upgrade";
```

Add in a healthcheck.

```nginx
location /healthz {
  return 200;
}
```

With all that in, it will look something like this.

```nginx
server {
  listen 80;

  server_name ~^(?<subdomain>.*?)\.;
  resolver kube-dns.kube-system.svc.cluster.local valid=5s;

  location /healthz {
    return 200;
  }

  location / {
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_pass http://$subdomain.msce0.svc.cluster.local;
    proxy_set_header Host $host;
  }
}
```

We will also have to add some root config as we have to write a complete `nginx.conf`.
Pull all that together and drop it into a `configmap.yaml` and we have our first `kubernetes` object.

**configmap.yaml**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: confnginx
data:
  nginx.conf: |
    user  nginx;
    worker_processes  1;
    error_log  /var/log/nginx/error.log warn;
    pid        /var/run/nginx.pid;
    events {
        worker_connections  1024;
    }
    http {
      include       /etc/nginx/mime.types;
      default_type  application/octet-stream;
      log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                          '$status $body_bytes_sent "$http_referer" '
                          '"$http_user_agent" "$http_x_forwarded_for"';
      access_log  /var/log/nginx/access.log  main;
      sendfile        on;
      keepalive_timeout  65;
      server {
        listen 80;

        server_name ~^(?<subdomain>.*?)\.;
        resolver kube-dns.kube-system.svc.cluster.local valid=5s;

        location /healthz {
          return 200;
        }

        location / {
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "Upgrade";
          proxy_pass http://$subdomain.msce0.svc.cluster.local;
          proxy_set_header Host $host;
          proxy_http_version 1.1;
        }
      }
    }
```

## `deployment.yaml` and `service.yaml`

There is nothing fancy in here. Just a plain old `deployment.yaml` and `service.yaml`.

> Inside `deployment.yaml` we have to make sure to load the `configmap` we setup. See the `volumeMounts` section.

**deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:alpine
          ports:
          - containerPort: 80
          volumeMounts:
            - name: nginx-config
              mountPath: /etc/nginx/nginx.conf
              subPath: nginx.conf
      volumes:
        - name: nginx-config
          configMap:
            name: confnginx
```

**service.yaml**

```yaml
kind: Service
apiVersion: v1
metadata:
  name: nginx-custom
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    name: nginx
```

## `ingress.yaml`

Now with the service setup, we can use an ingress to give it a `hostname`.

**ingress.yaml**

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: ingress-nginx-custom
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: '*.mydomain.com'
    http:
      paths:
      - path: /
        backend:
          serviceName: nginx-custom
          servicePort: 80
```

# Deploy

Well, I am pretty sure you know how to do this. But essentially

```sh
k apply -f configmap.yaml
k apply -f deployment.yaml
k apply -f service.yaml
k apply -f ingress.yaml
```

<center><h1>K. THANKS. BYE</h1></center>
