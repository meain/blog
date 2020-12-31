---
title: My workflow hacks
description: A bunch of things that I use to simplify my workflow
keywords: workflow, macos, hammerspoon, karabiner-elements
date: 2020-12-31
layout: layouts/post.njk
permalink: "{{ page.date | date: '%Y' }}/{{ page.fileSlug }}/"
---

Well, the year is about to end. It was a fun year, no shit. I wanted to write something like this for quite some time. I was like, "too lazy today, tomorrow" and the year is almost over. I did not want to keep this pending for next year and so started working on it.

Well, I just wanted to mention a bunch of thing that I have in my workflow to make my life a bit less miserable. I don't think anything specifically will be all that useful, but wanted to give an idea on the kind of things that you can do.

**Before we get into it, almost all of code for the things that gets mentioned in here will be available at [meain/dotfiles](https://github.com/meain/dotfiles).**

With the "preface" done, lets get into the content.

I am gonna break this into a bunch of categories, but they are just vague markers. Almost all of them are interlinked in some way or the other.

> I use macOS, so some of these things will be more or less macOS specific.

# Karabiner-Elements

> Link to webpage: https://karabiner-elements.pqrs.org/

First item in the list is [Karabiner-Elements](https://karabiner-elements.pqrs.org/). It lets you do key remaps, some seriously crazy useful remaps might I add. It is kinda like [qmk](https://github.com/qmk/qmk_firmware) but works on a OS level.

For starters, it lets you do simple key remaps, for example you can remap <kbd>caps lock</kbd> to <kbd>esc</kbd>. Very useful in Vim. But wait, don't do that yet. There is better things that you can do.
You can actually map the <kbd>caps lock</kbd> key to <kbd>esc</kbd> and <kbd>ctrl</kbd>. Well, the idea here is that if you just hit <kbd>caps lock</kbd>, it sends escape. But if you hold <kbd>ctrl</kbd> and hit a key like <kbd>x</kbd>, it will send out <kbd>ctrl</kbd>+<kbd>x</kbd>.

Well, this is where I started. After that I mapped all modifier keys to something else when hit alone. For example <kbd>ctrl</kbd> key send up arrow when hit alone. *I have to do this since I don't really have arrow keys on my keyboard (I use a 64 key keyboard).* But I don't use it that often, only if I only have one hand available like when watching Netflix while eating. I have <kbd>cmd</kbd>+<kbd></kbd><kbd>h</kbd>j<kbd>k</kbd><kbd>l</kbd> to be my arrow keys for the most part.

Btw, you can have any key do this, for example I have <kbd>'</kbd> mapped to send <kbd>ctrl</kbd> when pressed with another key. I don't have right <kbd>ctrl</kbd> as I have use it for something else plus even if I had it, it would be weird to reach that key.

There are even more stuff that you can do with [Karabiner-Elements](https://karabiner-elements.pqrs.org/). You can make <kbd>cmd</kbd>+<kbd>q</kbd> work only if you press and hold it and not just press it. It helps you from accidentally quitting something you were working in.

You can even just use two modifier keys. For example I have it so that if I hold left <kbd>shift</kbd> and hit right <kbd>shift</kbd> it switches me to the right monitor and if I hold right <kbd>shift</kbd> and hit left <kbd>shift</kbd> it switches me to the left monitor.

Btw, it can also control your mouse. You can control your mouse with just the keyboard if you want to. It gets crazy after a while. You can checking all kinds of configuration examples at https://ke-complex-modifications.pqrs.org/ .


# Hammerspoon

> Link to webpage: https://www.hammerspoon.org/

If you thought [Karabiner-Elements](https://karabiner-elements.pqrs.org/) was awesome, wait for [Hammerspoon](https://www.hammerspoon.org/). It is a way to control a lot of macOS "stuff" via lua. It lets you move windows, rearrange spaces, click on things, type things out, check bluetooth, wifi, kbd, mouse status and notify.... and a lot of other things.

Again, lets start with a bunch of simple things. You can map a keybinding to open/focus an app. From my personal collection I have <kbd>cmd</kbd>+<kbd>shift</kbd>+<kbd>k</kbd> to focus firefox.

*Btw, just in case for anyone who is wondering(as if anyone reads my blog) where the `k` for firefox comes from it does not stand for anything. I just have `j`, `k`, `l` mapped to my text editor, browser and terminal respectively.*

What I have for <kbd>cmd</kbd>+<kbd>shift</kbd>+<kbd>k</kbd> currently is a bit more involved. When I press, <kbd>cmd</kbd>+<kbd>shift</kbd>+<kbd>k</kbd> it focuses firefox if it is already open, if not launch it plus moves my cursor to the monitor in which it currently is on. Along with that, it retains which app I was on previously so that if I hit <kbd>cmd</kbd>+<kbd>shift</kbd>+<kbd>k</kbd> again when I am in firefox it switches me back to the app that I was on previously. It helps with quickly switching to the browser to check the docs and back with just hitting <kbd>cmd</kbd>+<kbd>shift</kbd>+<kbd>k</kbd> twice. Fun stuff right, I know.

Sometimes there is an action that you always do in a specific app, like open a new tab in a browser. I found my self hitting <kbd>cmd</kbd>+<kbd>t</kbd> when I am in my editor to open a new tab to search for some stupid thing that I was supposed to know. So I made <kbd>cmd</kbd>+<kbd>t</kbd> do exactly that. Now, it does not matter which app I am in when I hit <kbd>cmd</kbd>+<kbd>t</kbd>, it just pops me into the browser if I am not already in there and opens a new tab ready for me to type in a stupid query. I have a bunch of things like this. Another really good use for this is for Slack. Every time I get a new message, I have to switch to Slack, look up the the chat or even worse, use my mouse to click on the notification. Now all I have to do is hit <kbd>cmd</kbd>+<kbd>t</kbd> and from wherever I am and I end up in slack with a search window to open the "recent"(the one with the new message) chats.

Here is a small section dedicated to how I am dealing with Zoom calls aka "quick call that lasts 2 hours". First of all, about muting myself on a call. This is very important to me, if I am not talking, I am on mute. I work from home and well my home is not a workplace and so there is a lot of chance for a lot of noise. Plus I don't want anyone hearing me say, "woosh, when does this call get over". As you might have guessed, I use hammerspoon for this. [Hammerspoon](https://www.hammerspoon.org/) has this concept of [Spoons](https://github.com/Hammerspoon/hammerspoon/blob/master/SPOONS.md) which are essentially plugins and I got most of the code from the [MicMute](http://www.hammerspoon.org/Spoons/MicMute.html) spoon. After some edits from my end, with a keybinding it lets me mute my mic from anywhere plus it shows me my current mic status in my status bar area along with a tiny alert every time I switch between mute and unmute. You can find my version of the code [here](https://github.com/meain/dotfiles/blob/master/hammerspoon/.config/hammerspoon/Spoons/MicMute.spoon/init.lua). Well, I have a bunch of other things for zoom like opening links directly in the app than going through browser, joining the meeting that is happening now with just one keybind etc but one other things that I do with purely hammerspoon is start new meetings. For me, with <kbd>alt</kbd>+<kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>z</kbd> (this might look like it is hard to press, but I have remaps <kbd>alt</kbd>+<kbd>shift</kbd>) it opens zoom, starts a new meeting with my personal zoom id and drop the meeting link to the chat that I am in. Think of how many steps of pain and agony that reduces(at least 6-7). Well, gonna stop with Zoom stuff here.

One more thing under the hammerspoon section. I have a script/module called [quick-edit](https://github.com/meain/dotfiles/blob/006b958b5ea2431bcb6e736b6ed5ebf5033d7103/hammerspoon/.config/hammerspoon/init.lua#L324). The idea behind this is that, if you are in a text field and you hit a keybinding. It opens up the content of that text field in my editor, with markdown syntax highlight and let me edit with all the vim keybinding goodness(in [Emacs](https://www.gnu.org/software/emacs/) using evil-mode. Huh, gotcha).

# Fun with clipboard

Clipboard is something that you should not take for granted, it is a really powerful tool. It might look simple, but this is what will let you bridge a lot of gaps as everybody reads the clipboard and writes to it(it is a security nightmare, but it is useful). For example for a while I had a cron job which would drop the meetings ids from my calendar every time it is time to join a call. And so, if I do decide to join that call, all I have to do is press a single keybind. In this case <kbd>alt</kbd>+<kbd>backspace</kbd>. Well, the exact thing that I have mapped to <kbd>alt</kbd>+<kbd>backspace</kbd> is more of a link opener. If the link is associated with an app, it will open that app with the link or open that in a browser. If it is not a link, it searches for that thing in the browser with the search engine of your choice. A note on this is that you can always do transformation half way through. For example if what I have in the clipboard is a git ssh url, it converts that to https and opens that.

Btw, it is not like you are restricted to opening things. If I had a git ssh url in the clipboard and I called a command, it would to clone the repo to a temp folder and start a [tmux](https://github.com/tmux/tmux) session there for me to work on that. The options are endless, you just have to figure out what you need to do.

Another thing you could do is just plain open up a list of things that you could do what is in the clipboard with options like bas64 decode or custom search engine list or something.


# Note taking and bookmarking

Well, this is something that I have been constantly evolving. At the end of the day, it is mostly just a bunch of plain text files that I grep, sed and do other unspeakable things to. I, like a lot of other people have my own note taking script that they wrote in bash. For the most parts, it is a bunch of files with some sort of categorization. To look for a file, I just more or less use [fzf](https://github.com/junegunn/fzf) as a completion system and open that file up in my editor. I use git + gitlab to backup my useless notes. I initially used to use git to keep my notes in sync with my phone as well, but now I just use [Syncthing](https://syncthing.net/). It is how syncing should be, just clean simple stuff, no BS.

Similarly for bookmarks, it is kind of a same deal. In this case it is a bunch of files with vauge categorization. Each line in a file is a bookmark and contains the link and a description that I put in. Again, I have [fzf](https://github.com/junegunn/fzf) let me filter through this list. One addition that I think I should mention is that I have something that will go though all my links and curl the title from their webpage automatically. This lets me help "fzf" for it as well.

> "fzf for it" should be a thing like "grep for it".

Another classification of "notes" that I have is scratchpads. These are essentially one off file(or so I thought) which I don't really backup. The idea is same for this as well. I have script called `vime` which will open up a text file with a random name(the name for the one used to write this blog's bullet points is `_6d5b`) in my text editor. I have, as you might have guessed it keybinds for this as well. No matter what useless things I am doing, I can jot down stuff about them.

# Todo/task management

> Link to webpage: https://taskwarrior.org/

Let me introduce to you another gem, [Taskwarriror](https://taskwarrior.org/). I am not a big GTD guy, but this kinda helps with "getting tings done" or at least reminding that you have things to be done. The best part about this is that this is a cli app, so how you choose to actually use it is up to you. I use taskwarrior a lot, but I never really use the cli. I have a bunch of hammerpoon "UIs" on top of it. I wanted to attach a screenshot here, but it right now has a lot of my personal and work tasks and I am really not in the mood to create a lot of dummy tasks to get a screenshot. I will link to the [code](https://github.com/meain/dotfiles/blob/master/hammerspoon/.config/hammerspoon/taskwarrior.lua) though and you should be able to try it out. It essentially is just list of tasks plus an add button but a bit more intelligent on how tasks are added or marked as done.
I also make use of `hs.canvas` to have a desktop widget which list my most important tasks on my secondary monitor.

Btw, since this is a cli app. I have tasks that get automatically completed from a cron job or a script. A simple example is that it will automatically mark my task of writing a journal complete as soon I save and quit the journal file in my editor. Forgot to mention about my Journaling system. It is just the same as notes, but just that it will encrypted with gpg as soon as I am done editing. Not that it contains anything sensitive, just that I was paranoid that someone might read about me gushing over my cursh. And it is synced with Gitlab for backup btw.

And for the last part of syncing tasks/todo. Even though I am not really all that much of a going out all the time person, if a task management solution does not sync between all your devices, it is not all that useful for me. [Taskwarriror](https://taskwarrior.org/) has a relatively good syncing setup. I use [Freecinc](https://freecinc.com/) to sync [Taskwarriror](https://taskwarrior.org/) stuff with my phone. I have used a bunch of mobile taskwarrior clients and to be frank, most of them look ugly as shit. Been experimenting with a few now, nothing that I would fully use. As of now, I use the [Taskwarriror](https://taskwarrior.org/) cli in Termux. There is a lot to discuss about termux as well, but I am gonna leave that to the future me(I am guessing in another 30 mins). It works, plus I am able to share something like a link to termux and have it automatically added my reading list.

There is a lot more to this, I am gonna stop here though.

# Email workflow

I love email. It is awesome. The best part about it is that nobody expects you to respond immediately. If you don't like email, it is not a problem with email, it a problem with how you consume email. My email workflow includes [notmuch](https://notmuchmail.org/) and [Emacs](https://www.gnu.org/software/emacs/). [Notmuch](https://notmuchmail.org/) is really useful. In its base form is a mail indexing thingy. It lets you filter, search, assign tags etc to your email. And since it is a cli application, you can script in a lot of things(notice the theme here). For starters, I have file which contains a lot of known addresses and these will get automatically tagged. Well, it is not like you have to add something to a file or update the script to tag stuff for every new email. You can automate that from your email viewer. For example in my case, if I have some special tags which if I ever mark an email with it, all future emails from them will go to that tag. I could have this filter on full email, domain or whatever I choose. An example use case of this would be for mailing lists. Not everything is interesting and you can just have it filter out a regex in the title with a tag and you never have to see any of those things again. Also, I have hammerspoon bindings for this to notify me on new email, or quickly view what/who I have email from, mark them as read and all that kinda stuff.

Another things which ideally deserves its own spot is RSS feeds, they are useful but for some reason not a lot of people seem to know/care about it anymore. They are a good way to subscribe to things/events. I don't want to get an email every time someone writes a blog article, I rather have this in my rss feeds for me to go through when I have time.

# KDE Connect

This is something that I discovered recently. Well, I knew this existed, but never knew this was available for mac. But it is. It lets you connect your phone and your laptop a bit more. Like sync clipboard, send commands, send a receive files and all that kind of stuff. One awesome thing that this lets me do is if I am reading an article on my phone, I can share the link to the KDE Connect app on my phone and it will open that link in my computer. Just magical. Plus it does clipboard sync, and you know what I think about clipboards.

It also lets me run commands on my system with my phone. My primary usecases for this is to disconnect my headphone from my laptop when I am lying down my couch. My headphones can connect to two devices at a time, but I hate when it switches to the laptop audio when I get a completely useless message and I am watching something on my phone. Well, recude the annoying things. That is kinda the idea.

# Termux

Termux is a useable terminal on your Android phone. Well, when I first heard about it, this sounded like a stupid idea. Don't get me wrong, I love terminals, but on a phone? Well, you see the point to the terminal is automating things. Plus maybe ssh into your laptop to check on something on run a script. I primarily use it for taskwarrior, bookmarks and ssh. The best part is that you get to use the tools that you have created good workflows with, like [fzf](https://github.com/junegunn/fzf) on your phone. Ain't that sweet? Plus you can share links to this app and have it do something with it which again you can script.

Here is a "hypothetical" workflow. You have a link to a youtube video, you can send that to termux. Termux now ssh into some server, download that, encode it to a different video format or like speed it up and send it to you on telegram/matrix or just drop it direcly in the phone filesystem. Think of all the possibilities.

# Byee

It is not one single things that make it useful. It is the fact that I can combine all of these tools together that help it make the final workflow powerful. I am gonna end it here, but I would welcome you to checkout my [dotfiles](https://github.com/meain/dotfiles) repo. That will contain most of the stuff that I experiment on.

There are two other items that I did not specifically mention but are really important to my workflow. That is [Emacs](https://www.gnu.org/software/emacs/) and [Tmux](https://github.com/tmux/tmux). These are really useful and is more or less involved in most of the things that I do. Just had to drop that in there. A lot of cli programs as well, but don't wanna list them all here now.

The idea was to introduce you to the kind of things that you can do and the tools that are available. Hopefully I have convinced at least someone to <s>use these things</s> think that I am not completely crazy for doing this.
