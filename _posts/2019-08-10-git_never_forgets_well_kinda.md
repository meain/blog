---
layout: post
title: "Git never forgets, well kinda. `git-reflog`"
description: "Git never forgets, well kinda."
comments: true
keywords: "git, reflog, git reflog, github, history, log"
---

Hi, I am gonna let you in on a little secret.
Git never forgets what you do, you can mess up however you want and you will still have all your data available*.

> \* as long as you have committed you code and also only for 90 days

OK, I am not taking about the fact that you can you can see the logs of what changes you have made over a period of
time. I am talking about that fact that you can even recover from something like `git reset --hard HEAD~30`.

Working with git is a little scary for a lot of people. Things like `rebasing`, `resetting` etc.
I know a lot of people who only ever does `git push`, `git commit`, and `git pull`.

![xkcd](https://imgs.xkcd.com/comics/git.png)


I am here to say that you are fine, you can do any kind of weird shit and still have everything there.
Let me introduce you to the magical command:

```
git reflog
```

Here is what a sample output of `git reflog` will look like:

![screenshot]({{site.url}}{{site.baseurl}}/assets/images/gitreflog.png)

This is a rather busy tree. As you can see, every check out, every pull, every reset. All of them are in there.

### OK, so how do I use them?

It is simple, let us consider a simple mistake that you did. Let's say that you accidentally hard reset to `HEAD~30`.

*If you don't know what that does, It resets your git commit to 30 commits behind current commit.
This is different form checking out HEAD~30 as in this case it rewrites the tree.*


```
git reset --hard HEAD~30
```

OK, now what do you do. Delete the folder and clone again is a possibility. But let's do it the right way.

**Run `git reflog`. Mine looks something like this:**

```
dfd1d3e (HEAD -> master) HEAD@{0}: reset: moving to HEAD~30
a4d53b0 (origin/master) HEAD@{1}: commit: post:rust-macros: add output and code link
6cc6335 HEAD@{2}: commit: post:local-file-as-newtab-firefox
b597ae7 HEAD@{3}: commit: config: fix rss link generated
afc0283 HEAD@{4}: commit: post:kubernetes
7bd3eee HEAD@{5}: commit: post:tf-serving:add tf-serving docs link
77462fb HEAD@{6}: commit (amend): post:tf-serving
07fdc2e HEAD@{7}: commit: post:tf-serving
```

You can see that we have everything that I have done in the past listed here.
Also if you check the latest one, it does show that I did reset it to `HEAD~30`.

Now to restore the original state, we just do a hard reset to the one just before I did reset to `HEAD~30`.
In my case it will be to `a4d53b0`.

So I will run:

```
git reset --hard a4d53b0
```

After running this we are back to where we started.
Now, if I were to run `git reflog`, I would get something like:

```
a4d53b0 (HEAD -> master, origin/master) HEAD@{0}: reset: moving to a4d53b0
dfd1d3e HEAD@{1}: reset: moving to HEAD~30
a4d53b0 (HEAD -> master, origin/master) HEAD@{2}: commit: post:rust-macros: add output and code link
6cc6335 HEAD@{3}: commit: post:local-file-as-newtab-firefox
b597ae7 HEAD@{4}: commit: config: fix rss link generated
afc0283 HEAD@{5}: commit: post:kubernetes
7bd3eee HEAD@{6}: commit: post:tf-serving:add tf-serving docs link
77462fb HEAD@{7}: commit (amend): post:tf-serving
```

 t is not only applicable for just resets, whatever you do, you can come here and revert it.
I hope this make git a little less scary.
