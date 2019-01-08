---
layout: post
title: "Quickly go to project root"
description: "How to cd to a git project root from anywhere in the project"
comments: true
keywords: "git, project, bash"
---

Let us say you wen't it deep in to a highly nested project structure and want to get back to the project root.

Sure you could go `cd ../<TAB>`, nah not here `cd ../../<TAB>`, not here either .....
But there is a much better way to do this.

You can leverage `git` to find where the project root is.

```sh
git rev-parse --show-toplevel 2> /dev/null
```

This gives you the project root location.
Now you can make this into a fuction and source it.

```sh
root(){
    cd $(git rev-parse --show-toplevel 2> /dev/null)
}
```

Now you can type `root` and go to your project root.

*Sweet right?*