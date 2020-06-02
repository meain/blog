---
title: Copy file opened in macOS preview to working directory
description: How to copy last file opened with macOS preview utility to current shell directory
keywords: finder, preview, macOS, copy, shell
date: 2020-06-02
layout: layouts/post.njk
permalink: "{{ page.date | date: '%Y' }}/{{ page.fileSlug }}/"
---

Another random script I pieced together recently.

I generally have a bunch of temp folders that I keep around for files to go in. And at times, I have pull some files
into the current folder I am working on in my shell. If those are pdf of image files, I usually have them open in macOS
preview which btw is a neat tool. Anyhow, when I now have to copy the file to my current location inside the terminal I
have to look up the folder, filename and God help us if there are spaces in the filename in which case I have to go back
and add quotes.

So I decided to just write a script to do just that. It looks up the file in the last opened preview window and copies
that file to my current directory and gives me an option to change the name just in case. Here is the script.


```shell
FILE="$(osascript -e 'tell application "Preview" to return path of back document')"
printf "New filename(%s): " "$(basename "$FILE")"
read -r
[ -n "$REPLY" ] && NEW="$REPLY" || NEW="$(basename "$FILE")"
cp "$FILE" "$NEW"
```

### Explanation

First we get the name of the file using `applescript`. This is the important part.


```applescript
tell application "Preview" to return path of back document
```

Once we have that we just ask for a new name and then copy the file from current location to here.
`basename` lets use get just the filename from a file path.


### Extra

Usually you could also make use of the directory of the last `Finder` window. Like, cd into last open `Finder` location.
This is how you would go about getting the folder location.


```applescript
tell application "Finder" to set currentDir to target of Finder window 1 as alias
log POSIX path of currentDir
```

This will return you the path of the topmost Finder window. If no finder window is open it will just error out.
