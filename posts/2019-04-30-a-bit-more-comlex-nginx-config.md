---
date: 2019-04-30
layout: layouts/post.njk
description: More stuff about an nginx config
keywords: nginx, web, server, config, conf
title: A bit more about configuring nginx (rewrite and alias)
---

We went through some basic stuff you need to understand to configure `nginx` in [an old blog](https://meain.io/blog/2019/a-really-simple-nginx-conf/).
After writing that I had to work on another project which was a bit messy.
So I went over more stuff, and I thought I would write about it.

Before going into the blog, let me go in what is the situation that I was in.

I had two frontend (static file) endpoints and two apis.
Let us call the frontends f1 and f2 and the apis a1 and a2.

f1 is a completely independent one with no backend.
f2 depends on both a1 and a2.

There was some things we did in the frontend.
Request from f2 to a1 was prefixed by `/a1` which had to be removed before we could process in the api a1.
Same for a2.

Here is the important part of the config ended up using.

```nginx
server {
    server_name mysite.com;

    root /home/meain/f1/dist;
    index index.html;

    location /f2 {
      alias /home/meain/f2/dist;
    }

    location / {
      try_files $uri $uri/ =404;
      expires max;
    }

    location /api2 {
        rewrite ^/api2/(.*)$ /$1 break;
        proxy_pass http://localhost:8001;
    }

    location /api1 {
      rewrite /api1/(.*)$ /$1 last;
      proxy_pass http://localhost:8000;
    }
}
```

Essentially I just want to introduce you to `alias` and `rewrite`.

So, if you check the `location /` block, it checks for the static file and if it cannot find it, it returns `404`.
You could check out about returning a custom `404` page [here](https://www.digitalocean.com/community/tutorials/how-to-configure-nginx-to-use-custom-error-pages-on-ubuntu-14-04)

For f2, we just change the location where nginx checks for the files by using the `alias` keyword.

Now for using the backends, we have to remove the extra `/api1` or `/api2` in front
For this we make use of the `rewrite` keyword.

We use `rewrite` to write a regex that will transform the incoming request url.
Here we are using capture groups to just remove the `/api1` or `/api2` in front.

And, guess what, it works.

Well, this is a small one, but I am guessing it came in handy for someone.
