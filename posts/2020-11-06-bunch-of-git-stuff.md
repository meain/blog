---
title: Just a bunch of git stuff
description: Just a random collection of git stuff that you might not have known about
keywords: git
date: 2020-11-06
layout: layouts/post.njk
permalink: "{{ page.date | date: '%Y' }}/{{ page.fileSlug }}/"
---


Hey,

Been a while since I have wrote a blog and thought I would write about something that I really like, git. I really like git, almost all of my important data is text and almost all of them are versioned using git. Here is a bunch of things in git that I think are not that widely known.

# Worktree

Worktrees are useful if you work on a bunch of branches at the same time. It really comes in handy when you are in the middle of something in one branch have to switch to another branch to do a "urgent" bugfix.

I used to just clone the repo again, and work there and push, and delete that after it. It is kinda similar to this workflow, but better.

I also used to use another script which I call [`howwasit`](https://github.com/meain/dotfiles/blob/master/scripts/.bin/howwasit) which would technically checkout a branch in to a temporary directory so that I can see how something was at a commit. It is simliar to Github's browse repo at commit thing.
![Github screnshot](https://img.vim-cn.com/c0/7e42a5b8a7075aea5ef077964c36846d51e5d3.png)

Enough preamble, lets get to the actual feature.
Here is how you can use it:

``` shell
git worktree add <folder-name> <branch-name>  # existing branches
git worktree add -b <new-branch> <folder-name> <tracking-branch>  # new branches
```


What the following command does is creates a "clone" of the repo at the branch that you specify to the folder that you specify.

``` shell
$ git worktree add -b new-branch new-stuff 0.1.0
```

Once you have a bunch of worktrees you can use the following command to see where all the worktrees are located.

``` shell
$ git worktree list
projects/lsd             3537575 [master]
projects/lsd/new-stuff   0fd07cb [new-branch]
projects/lsd/tree-stuff  0c53060 [tree-d]
```

From here, inorder to delete your worktrees, you can just delete the folder in which the worktree was created and call `git worktree prune` command. Calling `git worktree prune` will drop all the metadata that git had created for the deleted worktrees. Git will however keep the branch that you were using with the worktree however btw. You can drop that with `git branch -D <branch>` as usual.

``` shell
$ rm new-stuff
$ git worktree prune
```

# Subtree

Next item on the list is `git sutree`. Think of this as `submodules` in git, but instead of just linking to an external repo, you pull in the code to your repo and add it as via a commit. This can kinda be used as a low tech dependency managemnt tool like submodules, but you don't have to deal with any of the submodule issues. I always end up having issues with submodules in CI stuff.

``` shell
git subtree add --prefix=<folder> <repository> <ref>
```

OK, let me show you an exmaple. Let us say that I am trying to create a very important JS library.

Here is the current state of the repo:

``` shell
$ git log --oneline
e234947 (HEAD -> master) initial commit
```

Now that we have that, I want to add my dependency [jezen/is-thirteen](https://github.com/jezen/is-thirteen). Here is how I would go about it.

``` shell
$ git subtree add --prefix deps/is-thirteen https://github.com/jezen/is-thirteen master --squash
git fetch https://github.com/jezen/is-thirteen master
remote: Enumerating objects: 13, done.
remote: Counting objects: 100% (13/13), done.
remote: Compressing objects: 100% (13/13), done.
remote: Total 1353 (delta 6), reused 1 (delta 0), pack-reused 1340
Receiving objects: 100% (1353/1353), 4.79 MiB | 69.00 KiB/s, done.
Resolving deltas: 100% (825/825), done.
From https://github.com/jezen/is-thirteen
 * branch            master     -> FETCH_HEAD
Added dir 'deps/is-thirteen'
```

The above command will add `is-thirteen` to `deps/is-thirteen`. My dir structure would look something like this.

```
.
├── deps
│  └── is-thirteen
└── index.js
```

And this will be my commit log:

``` shell
$ git log --oneline
29e241b (HEAD -> master) Merge commit '05c2be39de99d98d8053c9531d63d1b449fec6e3' as 'deps/is-thirteen'
05c2be3 Squashed 'deps/is-thirteen/' content from commit ce004f9
e234947 initial commit
```

If you check the commit log, you can see that the current state of the is-thirteen repo was squashed into that one commit and merged into our local repo. The squash happend becaused of the `--squash` flag in our command. If you were to avoid that, you will have the entire repo history of the `is-thirteen` repo in your repo as well.

Another usecase of git subtree is to split up something that you are working on into differnt repo. You can run something like below to do that.

``` shell
git subtree split --prefix=<prefix> <commit>
```

Here is an example. The following command will split your current repo's `ci` directory into its own branch with only those contents.

``` shell
git subtree split --prefix=ci --branch ci-stuff
```

Now if you check the logs of the `ci-stuff` branch, you will only see commits that changed the `ci` directory. Technically this is new "repo". You can push this alone to a separate remote and continue from there. Comes in handly if you wanna split up some module for so that it can be used in multiple repos.

# `log -L`

OK, now here is something amazing that git can do. I don't know if you have noticed it before but you might have seen that git when it shows diffs is actually able to show a context line at top which is usually a function or a class or something important like that. I initially thought it was just indent based, but turns out there is parsers for common things in common languages built into git.

In case you don't remember, let me remind you of that first.

``` diff
@@ -41,22 +43,20 @@ class Helper:
                 return data
 
-    def read_file(self, source, dataset):
+    def read_file(self, source, dataset, no_split=False):
         if source.lower() == "fake_thing":
             source = "unfake_thing_nah_just_kidding"
```

If you check the above diff, you can see that it acutally gave me the class name as the context line.

This in itself is pretty neat, but turns out you can actually use this info to check the logs for just what has changed in that one function/class in all the commits. You can call `git log` with the `-L` flag and pass a specific function/class in a specific file and git will show what changes that specific thing has had.

For our examle here, we have to call it using something like below:

``` shell
git log -L :Helper:project/subdir/helper.py
```

This will show all the changes that has happened to that python class and just that class alone.

# Notes

OK, next one. `git notes`. No, this is not a note taking app with a git backend. We have enough of them already.

Well, I take a lot of notes. I really like taking notes. So, the idea with a note in git is that you can use it to add additional stuff to a commit message withouht adding anything to the actual commit message.

OK, I am pretty sure that confused you. Let me explain.
You can "attach" a note to any commit in your git history. Changing the note does not change the commit id(which means you can go on changing the note without having to rewording your commit). This is by default only stored locally but can be synced upstream if you prefer.

OK, enough gibberish. Let me show you how this actually works.
Let us work on our awesome js lib.

I will add a new note using the following command:

``` shell
$ git notes add
```

Once I have added, I can see all of my notes by doing `git notes`.

``` shell
$ git log --oneline
29e241b (HEAD -> master) Merge commit '05c2be39de99d98d8053c9531d63d1b449fec6e3' as 'deps/is-thirteen'
05c2be3 Squashed 'deps/is-thirteen/' content from commit ce004f9
e234947 initial commit

$ git notes
34d30ee23154a1b060a523720c86a6e06a8c04bb 29e241b66ba494f4a31d7e9485f2afee4823f3bf
```

This shows us that we added in a note with id `34d30ee23154a1b060a523720c86a6e06a8c04bb` to the commit `29e241b66ba494f4a31d7e9485f2afee4823f3bf` which is the merge commit. We can see our note using `git notes show <id>`

``` shell
$ git notes show 29e241b66ba494f4a31d7e9485f2afee4823f3bf
So yeah, this is a note.
Just wanted to say we added in is-thirteen as a dependency.
```

Git also shows you the note when you just look at the commit message.

``` shell
$ git show 29e241b
commit 29e241b66ba494f4a31d7e9485f2afee4823f3bf (HEAD -> master)
Merge: e234947 05c2be3
Author: Abin Simon <abinsimon10@gmail.com>
Date:   Fri Nov 6 22:07:55 2020 +0530

    Merge commit '05c2be39de99d98d8053c9531d63d1b449fec6e3' as 'deps/is-thirteen'

Notes:
    So yeah, this is a note.
    Just wanted to say we added in is-thirteen as a dependency.
```

Neat, right?

# `commit --interactive`

Here is something that will let you do a bunch of stuff "interactively".
Well, I would not say that this is all that useful, at least was not to me personally. I would rather write a bunch of tiny scripts which lets me do this much more efficiently but this is a thing. Here is tiny preview into what this can do.

``` shell
$ git commit --interactive
           staged     unstaged path
  1:    unchanged        +2/-0 index.js

*** Commands ***
  1: status       2: update       3: revert       4: add untracked
  5: patch        6: diff         7: quit         8: help
What now> 5
           staged     unstaged path
  1:    unchanged        +2/-0 index.js
Patch update>> i
           staged     unstaged path
* 1:    unchanged        +2/-0 index.js
Patch update>> 
diff --git a/index.js b/index.js
index e69de29..26786f1 100644
--- a/index.js
+++ b/index.js
@@ -0,0 +1,2 @@
+const isThirteen = require('is-thirteen')
+isThirteen('പതിമനന')
(1/1) Stage this hunk [y,n,q,a,d,e,?]? y

*** Commands ***
  1: status       2: update       3: revert       4: add untracked
  5: patch        6: diff         7: quit         8: help
What now> 1
           staged     unstaged path
  1:        +2/-0      nothing index.js

*** Commands ***
  1: status       2: update       3: revert       4: add untracked
  5: patch        6: diff         7: quit         8: help
What now> 
```

Well, I am not sure what else to explain about other that it lets you "interactively" do stuff. Try it out next time when you have to do a commit. At any point just type `?` to get help as to what to do at that point.

# Bonus

Woo, bonus. Well, these are some other things which are neat but are not technically within git. That is why I thought I would add this in a bonus section.

## spinoff

I think this is a somewhat known thing to a lot of people, but I thougt I would include it anyways. Ever created a bunch of commits on master and was like, woops, should have created a new branch and submitted a PR for this instead of pushing directly to master. Well, this lets you do exactly that.

What this does is, creates a new branch at the current poinnt and rewinds the current branch back to what is in origin. I think this actually came from [magit](https://magit.vc/) which btw is a sick frontend to git. Apparently this is popular thing now(it is pretty useful). [Here](https://github.com/nvie/git-toolbelt/blob/master/git-spinoff) is a bash script which does the same thing.

## absorb

Another entry in random useful stuff. [tummychow/git-absorb](https://github.com/tummychow/git-absorb) is the repo where you have the "thing" that you need to do this.

Let me explain a sample situation in which you would be using this. You are going on a committing spree. It is all fun, but after a while you have to make a tiny edit which was ideally supposed to go into a previous commit and not a separate new commit.

What you could do with base git is that you will have to create a fixup commit with the proper commit to "absorb" these changes into. With this tool, all you have to do is to stage the commits that you wanna "absorb" and then call this tool. It will pick the correct commit to fixup this against.

From what I can tell, this looks for which commit changed the same parts of the file and creates a fixup commit against that. Kinda handy at times.

K. Thx. Bye.
