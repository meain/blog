---
comments: true
date: "2019-01-08T00:00:00Z"
description: A quick and simple introduction to writing a basic nginx conf file
keywords: nginx, web, server, config, conf
title: A really simple nginx config
---

This is another installment of "this is not a blog but a note for my future reference".

Here, I will introduce you to writing a very simple `nginx` config file.
The use case I will go over here assumes you have a directory of static files and a backend running somewhere.

# Where to put the files

First of all the config file is supposed to be located at `/etc/nginx/sites-available/yourapp`.
Here is a [stackoverflow link](https://stackoverflow.com/questions/11693135/multiple-websites-on-nginx-sites-available)
to what is `sites-available`. You will have to have symlink it to `sites-enabled`.

You can actually write the config at `/etc/nginx/nginx.conf` but you just
create(you will probably have one) a base config there and include this file there.
The `/etc/nginx/nginx.conf` file will have(need) something like this inside the `http` block.

```
include /etc/nginx/conf.d/*.conf;
include /etc/nginx/sites-enabled/*;
```

# What to put in the files

OK, now to write a really simple `nginx` config file.
Below will be something that you will end up with.

A great guide to static file serving and stuff is given [here](https://docs.nginx.com/nginx/admin-guide/web-server/serving-static-content/).

```
server {
    listen   80;

    client_max_body_size 200M;
    server_name yoursite.com www.yoursite.com;

    root /home/soham/doc_bot/chatty/dist;
    index index.html;

    location / {
        try_files $uri @backend;
    }

    location @backend {
        proxy_pass http://localhost:8080;
    }
}
```

So, you write the whole thing inside.

```
server {
 -- STUFF --
}
```

Btw, you might see code blocks which have `server` wrapped inside `http`.
You can skip that we have `http` inside `nginx.conf` and we are including this file inside of it.
Maybe a better explanation on [stackoverflow](https://stackoverflow.com/questions/20639568/when-do-we-need-to-use-http-block-in-nginx-config-file).

### `listen`

If it ain't obvious by now, it says `nginx` has to listen to port 80 for requests.

### `client_max_body_size`

Define the max size of the content that the client can send. Duh!

### `server_name`

Define the name of your server. You use this to say where the requests will come from.
Each server block will have one of these.

So that if you have a subdomain that you would like to map to a completely different project you could do it here.
A quick googling lead me [here](https://www.digitalocean.com/community/questions/what-exactly-is-server_name-in-nginx-configuration-file).

### `root and index`

`root` to specify where to look for static files. Give the path to where your static files are.

`index` is defined so as to say where to look for when there is no file defined, as in which is your `index.html`
equivalent.

### `location @backend`

This is used to tell `nginx` where your backend is. This could be a local link or even a link to an external server.

With `proxy_pass http://localhost:8080;` we tell that our backend is at `localhost:8080`.

### `location /`

The final piece, we tell `nginx` when a request comes in. You could have multiple `location` blocks if you have a
specific endpoint like `/api` or something for your backend.

Here we check if a file like that exists in static directory that we gave, if yes then serve the static file.
Otherwise route it to the backend.

# Starting and stopping `nginx`

Well, usually you will have `systemctl` running `nginx`, in which case you have the following commands.

> Might not be the case always, `nginx` may not be running through `systemctl`

```bash
systemctl status nginx
systemctl start nginx
systemctl stop nginx
systemctl restart nginx
```
