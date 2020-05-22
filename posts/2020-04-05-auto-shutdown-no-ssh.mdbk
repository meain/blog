---
date: 2020-04-05
layout: layouts/post.njk
permalink: "{{ page.date | date: '%Y' }}/{{ page.fileSlug }}/"
description: Auto shutdown VM if no active SSH connections and a peek into my workflow
keywords: workflow, automatic, ssh, shutdown, VM, SSH
title: Auto shutdown VM if no active SSH connections
---

Here is a simple workflow that I have extracted out into a blog.
I generally have a VM on standby to offload some tasks over to that VM instead of running things on my laptop.

One main example of this is when I am trying to do some experiment and check if a container still builds after I do some
changes. I usually make the changes and offload the build piece over to the VM. A good thing about VM is that it is more
powerful that my computer, has more storage for more caching, and also a much faster internet connection.
*It was an obvious choice.*

I have a script which will rsync files into the VM and run a docker build. [Here](https://github.com/meain/dotfiles/blob/master/scripts/.bin/try-build)
is the script available on my Github.

I don't need it to on when not in use. I am nice person and usually shuts it down after I need it but the thing is I at
times forget to do so. That is when I decided that I could probably write something to check if I am using that and shut
down if I am not.

The solution that I came up with was to check if there has been any SSH connections in the past hour and shut down
the VM if none. Here is the script that I am using.

```shell
if last | grep "still logged in";then
    exit 0
fi

LAST_ACCESS="$(stat -c'%X' /var/log/wtmp)"
CURRENT_TIME="$(date +%s)"
DIFF="$((CURRENT_TIME-LAST_ACCESS))"
if [ $DIFF -ge 3600 ];then
    sudo shutdown
fi
```

Let me explain.

First we check if there are any active SSH connections to the machine. We can do that by using the `last` command.
Here is the output of that command.

![screenshot](/images/ssh-last.png)

The first two lines of the script are for this. It checks if the string "still logged in" is in the output of the `last`
command. If so, we know that there is an active ssh connection and we can abort the script.

If not, then we have to check when the last connection was closed.
There are a lot of commands that will give you the complete login details as to when someone logged in and out.
But the simplest route for us is to check when the file `/var/log/wtmp` was last written.

This is a file which contains info about ssh connections, so the last time this got updated will be the last time
someone logged out or in to the machine. And since we checked that there are no active sessions, this will be last time
someone logged out.

To get the last accessed time on `/var/log/wtmp` we can use the `stat` command.

![screenshot](/images/ssh-stat.png)

We can compare this time to the current time and check if the difference is more that 60*60 (1hour). You can vary this
time with what you feel comfortable.
If the check return true, we just do a shutdown.

Now with this script placed somewhere we can just call this script from a cronjob.
And now you have a VM that will shut itself down after use.

One possible improvement is that we could probably looks for processes which might be running with high cpu load and
not shutdown if that is the case. But I always have an ssh connection if I am working, so this works for me.
