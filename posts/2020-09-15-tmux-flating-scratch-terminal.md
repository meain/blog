---
title: Floating scratch terminal in tmux
description: How to get a floating scratch terminal in tmux
keywords: tmux, shell, commandline
date: 2020-09-15
layout: layouts/post.njk
permalink: "{{ page.date | date: '%Y' }}/{{ page.fileSlug }}/"
---

Hi, Just another one off blog.
I have been using tmux for a while and one main thing I always wanted to have in tmux is a floating scratch terminal.
I got so used to this during my time with i3 and wanted to replicate it with just tmux.

![screenshot](/img/tmux-floating.png)

> Check out what I am talking about on [Youtube](https://youtu.be/PdL__5AydVE).  
> Code used here: [script](https://github.com/meain/dotfiles/blob/master/scripts/.bin/popuptmux) and [tmux-config](https://github.com/meain/dotfiles/blob/master/tmux/.tmux.conf)

A while back, tmux actually got [foating window](https://github.com/tmux/tmux/issues/1842) support and I am using it for a [lot of things](https://github.com/meain/dotfiles/blob/8523ac959e440e7d17e69507710ae85c200eea09/tmux/.tmux.conf#L216-#L231).
I had by this time had a floating terminal setup however and so did not really think about using this initially.

Today, I thought I would actually try getting this can be done in tmux. Just for the heck of it.

> **This is not yet in any released version just yet and you will have to build from master branch. It will be available in the 3.2 release.**

## Floating windows in tmux

Basically you can get a floating window in tmux using the following command:

```
tmux popup -R "ping meain.io"
```

This will start a ping to 'meain.io' in a floating window. Step one complete.

Now if you want to run something like a shell, you can use: 

```
tmux popup -KER zsh
```

> K & R is so that you can get input in to the process in the floating window  
> E is so that after clean exit, we return back

## Persisting session

Now that we have a terminal, we can technically use the tool that we have been using to persist stuff to persist the session.
When creating a popup, we can start a tmux session and attach to it on further invocations.
To quit out of the popup, we can just detach from it.

```shell
tmux popup -KER "tmux attach -t popup || tmux new -s popup"
```

The above script with attach to a session called popup, or create one if it does not exist.
We are half way there, but I don't wanna be pressing two different keys for showing and hiding the popup terminal.

For starters, let us create a script called `popuptmux` and put what we have in it.

**pouptmux**
```shell
tmux popup -KER "tmux attach -t popup || tmux new -s popup"
```

Now call this script with a tmux keybinding:

```
bind-key j run-shell 'popuptmux'
```

Now when you press <kbd>\<prefix\></kbd><kbd>j</kbd> it opens the session named `popup` in a floating window.
Now to make our script a bit more intelligent.


**pouptmux**
```shell
if [ "$(tmux display-message -p -F "#{session_name}")" = "popup" ];then
    tmux detach-client
else
    tmux popup -KER "tmux attach -t popup || tmux new -s popup"
fi
```

With this script, when you are in a session called `popup`(which you are when you have the floating window open) we detach,
otherwise we create a popup with a session named `popup` and attach to it.

Btw, if you want a bigger floating window, you can always just ask tmux.

**pouptmux**
```shell
width=${2:-80%}
height=${2:-80%}
if [ "$(tmux display-message -p -F "#{session_name}")" = "popup" ];then
    tmux detach-client
else
    tmux popup -d '#{pane_current_path}' -xC -yC -w$width -h$height -K -E -R "tmux attach -t popup || tmux new -s popup"
fi
```

>Checkout the discussion on [reddit](https://www.reddit.com/r/tmux/comments/itonec/floating_scratch_terminal_in_tmux/),
>have a great workflow with floating terminals by [/u/KevinHwang91](https://www.reddit.com/user/KevinHwang91/)
>in [there](https://www.reddit.com/r/tmux/comments/itonec/floating_scratch_terminal_in_tmux/g5jxke4).

All good, now we can just go on hitting <kbd>\<prefix\></kbd><kbd>j</kbd> to open and close the floating window.
Although we do have this now, the performance ain't that good. So at the end of the day if you open and close it a lot, this might not be for you.
