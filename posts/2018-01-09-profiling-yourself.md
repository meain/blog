---
date: 2018-01-09
layout: layouts/post.njk
permalink: "{{ page.date | date: '%Y' }}/{{ page.fileSlug }}/"
description: This guide helps you to set up something that will let you take a picture
  of yourself every time you open the laptop with the laptop camera
keywords: mac, photo, camera, script, daily
title: Take a picture of you every time you open your laptop
---

> Take a photo every time the lid is open using the laptop camera.

Hey, ever seen those time-lapse videos of plants growing up in a BBC documentary and thought wish I could do that for me.

You haven't? I knew.

But here is how you would do it if you had thought of doing it. ( in OSX )

> It also helped me to see who tried to open up my laptop when I was not around.

I started doing this in march of 2016 ( now have about 3700 images ) and from time to time try creating something like a time-lapse.
It is kinda fun. Maybe, at least for some.

![screenshot]( /img/loginimages-screenshot.png )


# How to

### Step 1

Install [imagesnap](https://github.com/rharder/imgnap).

### Step 2

Keep this in a file named `imageme.sh` in a folder any folder.

```shell
#!/bin/sh
DATE=$(date "+%Y-%m-%d_%H-%M-%S")
imagesnap -w 2.00 "$HOME/.loginimages/$DATE.jpg"
```

What the above script does is it creates a date string with year-month-day-hour-minute-second and now take a picture using `imagesnap` and save it to your home directory.

> The `-w 2.00` is a wait time so as to make sure we get your photo.

### Step 3

Install [sleepwatcher](http://www.bernhard-baehr.de/).

You could download the binary from the above webpage or install using `homebrew` (recommended).

`brew install sleepwatcher`

### Step 4

Now to actually run the script on wakeup.

Add this to file `/etc/rc.wakeup`

```shell
#!/bin/bash
# Run the following script on wakeup
PATH=$PATH:/usr/local/bin
/Users/$USER/.imagescript/imageme.sh
```

Here, replace `/Users/$USER/.imagescript/imageme.sh` with the path to where you saved the `imageme.sh` script.

### Step 5

Take a nap. zzzz.
