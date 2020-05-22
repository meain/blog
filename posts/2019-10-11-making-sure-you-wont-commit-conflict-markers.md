---
date: 2019-10-11
layout: layouts/post.njk
description: Adding a git hook to warn you when you commit code with conflict markers
keywords: git,hooks,git-hooks,conflict,conflict-markers
title: Making sure you won't commit conflict markers
---

Recently I made a mistake of committing a conflict marker and pushing that code to Github.

That is when I thought that I could have a easily avoided this if I had added a `git-hook` to warn me if the code that I
commit had conflict markers. Here is how you would set up something like that.

# What are git-hooks?

In case you are new to `git-hooks`, it is a way by which git lets to hook into the different things that git does.
You can write `git-hooks` to do a lot of things. You can modify a commit message to add some additional info using a git
hook. You can print out extra stuff on commit(what we will be using) or push or any such operation.

Git hooks are small executables that you place in `.git/hooks` directory of your repo. If you were to check your
`.git/hooks` directory right now for any repo, you can see a few files which ends with `*.sample`. Those are samples
that git by default puts there so that you can see what it can probably do.

# Our solution

What we are going to do is to create a pre-commit hook which will show something like this.
It will give us a big bold red warning when we try to commit a piece of code that contains conflict markers in it.

![conflict-marker](/images/conflict-marker.png)


### tldr;

Place this piece of code as `.git/hook/pre-commit` and make it executable using `chmod +x .git/hooks/pre-commit`

```shell
#! /bin/sh

RED=$(tput setab 1)
NORMAL=$(tput sgr0)

CONFLICT_MARKERS='<<<<<<<|=======|>>>>>>>'
CHECK=$(git diff --staged | grep "^+" | grep -Ei "$CONFLICT_MARKERS" -c)
if [ "$CHECK" -gt 0 ]
then
    echo "$RED WARNING $NORMAL Conflict markers sill preset"
    git diff --name-only -G"$CONFLICT_MARKERS"
    # uncomment the below line if you need the commit to not go through at all
    # exit 1
fi
```

### Explanation

OK, that might look like a mess, but let me explain.

After the usual `shebang`, we define a variable called `CONFLICT_MARKERS` with the possible conflict markers separated
by `|`. The reason why we are separating the markers by `|` is because we use them in `grep` and in `regex` land it
means, match one of `<<<<<<<`, `=======`, `>>>>>>>`.

On the next line we do the actual check to see if the conflict markers are present in the code using `grep`. In this
line what we do is we pipe the diff of staged commits through `grep '^+'` which will filter out only the lines which
were added and that in turn gets passed to the next `grep` which counts the number of times any of those conflict markers
appear in the added lines in the diff and store the count to a variable `CHECK`.

Next line is an `if` check to see if the value in variable `CHECK` is greater than `0`.
And if it is greater than `0`, we show the warning and a list of files which has conflict markers in them.

You can prevent the commit from ever happening if you uncomment `exit 1`. But I would personally not recommend this
unless you add a way to bypass this, maybe using something like and env variable. In some rare cases where you might
need one of those conflict markers in your code, you will not be able to make the commit without modifying this code.

### Usage

As mentioned above, you can put this code in `.git/hooks/pre-commit` of any git repo where you need this check.

You can also put this in `$HOME/.git_template/hooks/pre-commit` to enable this is all the new git repos you create. Any
hooks you place here will be copied over to the hooks dir in the new git repos you create.
