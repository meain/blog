---
title: Highlight yanked region in Emacs
description: Highlight the region that was just yanked with pulse.el
keywords: emacs, yank, neovim, highlight
date: 2020-11-20
layout: layouts/post.njk
permalink: "{{ page.date | date: '%Y' }}/{{ page.fileSlug }}/"
---

OK, so I recently switched over to Emacs just becuse I woke up one day and got the itch to write some lisp.
It has been pretty fun so far.

Now with that out of the way, let me tell you about what I was actually planning to write about.
The idea is to show you a small example of how I am able to hack together stuff in Emacs.

> I know someone will ask for it, so here are my [dotfiles](https://github.com/meain/dotfiles). Steal away.

Before switching to Emacs I have been a very heavy (neo)vim user for a long time.
And at some point I had the following snippet added from some reddit thread to my vimrc.

``` vim
autocmd TextYankPost * silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=200})
```
What this script did was to highlight the region that I just yanked. This was pretty useful in my transition from doing `viwy` to `yiw`.
Just a way to verify that I yanked the correct thing. Let me show you what I am talking about.

![GIF of highlight on yank](/img/highlight.gif)

In the above GIF, I yank the word under the cursor with `yiw` and so it highlights that. I have tweaked `word` to mean `symbol` in evil mode.
That is why it is selecting the full symbol and not just `-` which would have been the case in vim.

So, ever since I switch to Emacs, I have wanted to recreate this.
Recenly I came accross an [article](https://karthinks.com/software/batteries-included-with-emacs/) by Karthinks which introduced me to [`pulse.el`](https://www.emacswiki.org/emacs/PulseRegion).
This was pretty much what I was looking for. Now I just need to make this do the highlight on yank thing.

OK, so here is how I approached it.
In the blog, he mentions about `pulse-momentary-highlight-one-line` and I knew there had to be a pulse region command.

I started typing `pulse-momentary-` and by then Emacs had shown me `pulse-momentary-highlight-region` as as autocomplete option.
Cool, that looks like what I want. I opened up the documentation for that I saw that it takes a `begin` and `end` and an optional `face` in case you wanna change that.

``` emacs-lisp
(pulse-momentary-highlight-region START END &optional FACE)
```

Now with that figured out, I had to find how evil figures out the start and end location when I do a yank.
I started off with checking out what command gets called when do something with yank.

Hit <kbd>C-h</kbd><kbd>k</kbd><kbd>y</kbd> and there you go.
This told me that the function that I need to use is `evil-yank` and the params for that are as follows.

``` emacs-lisp
(evil-yank BEG END &optional TYPE REGISTER YANK-HANDLER)
```

Cool, looks like I can just add an advice to it. For those who don't know what an `advice` is, it pretty much just lets you wrap aroud a function with another.
Kinda like a python wrapper function.

Let me show you what the idea behind an advice is.
First you create a function which you use to add as an advice.

``` emacs-lisp
(defun my-advice-fun (orig-fn arg1 arg2)
  ;; Do things you wanna do before calling the function
  (apply orig-fn arg1 arg2) ;; Call the original function
  ;; Do thing you wanna do after calling the function
  )
```

Now you ask the function to be added as an advice to some other function using `advice-add`.

``` emacs-lisp
(advice-add the-function :around #'my-advice-fun)
```

This will add `my-advice-fun` as an advice to `the-function`.
OK, with that out of the way, let me show you what we need to do to get a highlight on yank.

First we create the function to be added as an advice.

``` emacs-lisp
(defun meain/evil-yank-advice (orig-fn beg end &rest args)
  (pulse-momentary-highlight-region beg end)
  (apply orig-fn beg end args))
```

Here we create an function called `meain/evil-yank-advice` which first calls `pulse-momentary-highlight-region` with the `begin` and `end` params
and after that calls the `orig-fn` with the same `begin` and `end`. One other thing we have here is `&rest args` which pretty much means you collect everything that is not `orig-fn`, `beg` or `end` to `rest`.
This way we can easily pass all those optional arguments that `evil-yank` will need to it without being aware of them explicitly.

Now to add this advice:

``` emacs-lisp
(advice-add 'evil-yank :around 'meain/evil-yank-advice)
```

Voilà, you have highlight on yank.
