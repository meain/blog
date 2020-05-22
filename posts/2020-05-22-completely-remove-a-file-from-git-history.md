---
title: Completely remove a file from git history
description: How to completely remove a file from git history
keywords: git, history, prune, file
date: 2020-05-22
layout: layouts/post.njk
permalink: "{{ page.date | date: '%Y' }}/{{ page.fileSlug }}/"
---

Another short one.

Imagine this situation, you committed a file containing passwords into git accidentally.
What do you do?

Pretty easy, you just revert that commit.
The command below show do the trick.

```shell
git reset --soft HEAD^ && git reset
```

But what is you have made multiple commits after doing this? Yeah, this is messier. But you can still do it.
Here is what the code will look like.

```shell
git_prune_file() {
  git filter-branch --force --index-filter \
    "git rm --cached --ignore-unmatch '$1'" \
    --prune-empty --tag-name-filter cat -- --all
}
```

With this in place, you can call `git_prune_file` on the file that you want to be removed from history.
This will go through all the commits and remove that file. Pretty sweet, right?

Just for fun, [here](https://youtu.be/1ariej5xvfc) is it in action.
