---
layout: post
title: "Automatically list files after cd"
description: "How to automatically run ls after changing into a directory in zsh"
comments: true
keywords: "cd, ls, zsh, shell, automatically"
---


Almost everybody does an `ls` after they `cd` into a folder.
So why not let your shell automatically do it?


<p align="center">
  <img src="https://i.imgur.com/00UyQyj.png">
</p>

This will guide you through on how to do it.

### The simple way

Well, you might know the simple way.
Just change `cd` to do `cd` and `ls`.

```zsh
cd() { builtin cd "$@";ll;}
```


### The grown up way (in `zsh`)

Well, even though the previous one works well for most cases, there might be some situations in which it will not work.
The cases in which it might not work is when you don't actually use `cd` change dir, but some other command.


Here is the code that you will be using. Just add this to your `.zshrc` and you should be good.

```zsh
function list_all() {
  emulate -L zsh
  ls
}
if [[ ${chpwd_functions[(r)list_all]} != "list_all" ]];then
  chpwd_functions=(${chpwd_functions[@]} "list_all")
fi
```

OK, if that looks like some weird mess, don't worry. Let me explain.

So, `zsh` lets you run functions after running a command that will run after any command that will change directory.
That is listed in this variable called `chpwd_functions`.

So what we do here in the code is create a function `list_all` which just does an ls and add it to the list of commands
that will be run after a change in dir happens.

There is just some check happening to make sure that the function is not already in the list before we add it. That is
what that if condition does.

Well, that is it. Happy `cd`ing.
