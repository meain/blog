---
layout: post
title: "How Emacs took over my Vim life"
description: "My journey of switching from Vim to Emacs"
comments: true
keywords: "vim, emacs, evil mode, switching from vim"
---

I was a fanatic Vim user for about two years and use to believe that Vim is the only text editor that was `cool`. But, now I use `Emacs`.

> My [emacs](https://github.com/meain/dotfiles/tree/master/emacs) and [neovim](https://github.com/meain/dotfiles/blob/master/nvim/.config/nvim/init.vim) config

# What is the problem with `Vim`?

Well, Vim was a great tool for editing `text`, not for editing code. The one main issue I was facing with Vim was due to its synchronous nature of plugins. It really got show when I had quite a bit of stuff going on. Yeah I know about `Neovim` and now with Vim 8 we have got async processing but its not on par with `Emacs` on that. We have [ale](https://github.com/w0rp/ale) and [deoplete](https://github.com/Shougo/deoplete.nvim) which are awesome but it lot of other things was messy in the plugin landscape.

The main issue with Vim was if I had any large file opened in Vim when I have a long lis of plugins( which I do ) I was having a really hard time getting anything done. Kudos to [Sublime Text](https://www.sublimetext.com) on handling that so well. This was once and issue when I had a big LaTeX file which I could **not** edit in Vim because it was too slow after adding the LaTeX plugin.

Now, another reason for switching from Vim is due to its lack of good gui support. Yeah we have gvim, macvim ect but those don't provide anything more than more colors. `Emacs` could do images inline and that was really something for me.

Now comes the biggest pain with using Vim was when I had to work with `Vue`. Vim has a really hard time dealing with templates. You have [Vue plugin](https://github.com/posva/vim-vue) in Vim but its not that good. You lack on good autocompletion and commenting. I used to use tpope's [commentary](https://github.com/tpope/vim-commentary) but I could not use that in Vue files and had to switch to [NERD Commenter](https://github.com/scrooloose/nerdcommenter) and do [this](https://github.com/posva/vim-vue#how-can-i-use-nerdcommenter-in-vue-files) to get the commenting working and still it was a slow and got the comment type wrong at times for some reason.

# What is there to gain with Emacs?

**Oh you bet there is**

One of the best plugins you will ever see is [Magit](https://github.com/magit/magit) and `Emacs` is home to it. I used to use `Emacs` just to use `Magit` even when I was a Vim use due to its ability to do chunked commits.

Well, lets get to more obvious benefits.

`Elisp` though more daunting at first is a much better and powerful language than `Vimscript`. You will learn to love elisp and its self documenting nature.

You gain a lot of things GUI. Like inline images, different fon't sizes in a buffer etc.

Also the whole community arround `Emacs` is different from that of `Vim`. In `Emacs` plugins work together rather than messing up the other one. You can do that with `Vimscript` but nobody actually does that. `Elisp` feels more like a proper language and everybody plays nicely with each other.

The biggerst gain for me was the async nature of `Emacs`. That in itself was a big win for me.

# What you won't lose?

Well, you won't lose most of the core Vim stuff. You have [Evil mode](https://github.com/emacs-evil/evil). It is `Vim` emulation layer on top of `Emacs` and is really good. It emulates almost everything that `Vim` does. I have not had any issues with the emulation but just saying *almost everything* to be on the safe side.

Another thing you won't lose is [Tim Pope's](https://github.com/tpope) plugins. Everybody loves @tpope and even people in `Emacs` community and we have similar to plugins to `commentary`, `surround` and others. You will feel right at home with it.


# What you will lose?

Well, you ought to lose something right? It might not be a big deal to some but you kinda lose the whole unixy feel. With `Vim` the whole philosophy is to provide a good editing environment in `Vim` and hand over other things to other programs. One main example for this is to sort in vim you select a region of text and call the sort unix function on that. Maybe its just me, but the `Emacs` community felt a bit different and wanted everything inside `Emacs`. Not that it is a bad experience or that `Emacs` can't pipe out to shell and do stuff. You don't feel like doing it. Apart from that I don't have felt like I lost a whole lot.

# Any other editor you would suggest?

Well, `Emacs` and `Vim` might not be the best editor for everyone. If you are not really sold into customizing your editor a lot and wan't something that works awesome out of the box go with [VS Code](https://code.visualstudio.com/). Microsoft really has done a lot of work to make it awesome.


# How hard is the switch?

Well it is not the smoothest ride ever. It is bit hard in the begining. You have to learn a bit of `elisp` which by the way is a great language. Also you need to go hunt for the plugins you wan't to use in the begining which is kinda fun. Well another good thing here is that in the case of `Emacs` we don't have a lot of plugins that do the same thing, but one very mature plugin and some other which are a fair bit different. Well, don't worry its not that hard.

# Can I get ...... plugin in Emacs?

Oh you can, don't worry!

# Lets Switch!

## Install `Emacs`

Well, just install `Emacs` using `homebrew`, `apt` or `pacman` or whatever that you have. They do also have a windows binary. It not like you need to compile with python or anything like that in `Vim`

## Learn some basic `Emacs`

Well, `Evil` is great but there are some amount of `Emacs` you have to learn. You can actually remap all of this later but a knowing this in the start is good.

As a momento to fact that you don't have to learn a lot of `Emacs` I would like to say that I still don't know how to save a file in `Emacs`. That is how good the emulation is.

Well, here are the thing you have to learn:

* `M-x` - it like `cmd-shift-p` in `Sublime` or `Atom` or `VSCode`
* `C-g` - if you are in anything and you can't exit just use this
* `C-x C-c` - quit `Emacs`

That's it!

## How to get help?

`Emacs` and `elisp` is really serious about documentation and you have a really good help system.
Here are a few ways you can get help

These are the commands you can type to get help. Type these after you typed `M-x`.

* `describe-function` - shows the functions's docstring, the file it is in etc.
* `describe-variable` - shows data about a variable and its current value
* `describe-key` - shows what the key you press is bound to

These are the main ones that you will use. You also have commands to describe `major-mode`, `minor-mode`, `theme`, `symbol` and the list goes on and on.

And at the end of the day you will always have the Emacs community and Stack Overflow.

## Woah, `modes`?? What??

Well, `modes` are essentially modes. Not the best explanation I guess.
`Emacs` has two kinds of modes. `major` mode and `minor` mode.
`major` mode in `Emacs` is closest to `filetype` in Vim. So for example you have `python-mode`, `js-mode` etc.
`minor` mode in `Emacs` is the other plugins you load on top of that. For example a plugin to do commenting in `python-mode` is a minor mode.
Well, that is pretty much what modes are.

## Setting up `Evil mode`

This is a good starting point. Add the following to your `~/.emacs` file.
And you have a simple `Evil mode` setup.

```elisp

(require 'package)

; List the packages you want
(setq package-list '(evil
                     evil-leader))

; Add Melpa as the default Emacs Package repository
; only contains a very limited number of packages
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)

; Activate all the packages (in particular autoloads)
(package-initialize)

; Update your local package index
(unless package-archive-contents
  (package-refresh-contents))

; Install all missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

(require 'evil)
(evil-mode t)

(require 'evil-leader)
(global-evil-leader-mode)
(evil-leader/set-leader "<SPC>")
(evil-leader/set-key
  "b" 'switch-to-buffer
  "w" 'save-buffer)
```

What this does is the next time you start `Emacs` it download the packages `evil-mode` and `evil-leader` (it is a plugin that helps you emulate the leader key functionality in emacs) and sets you two bindings for you.

* `<leader>b` - open a buffer list so that you can switch to a different one
* `<leader>w` - save-file

Oh, btw leader key is mapped to `space`.

## Fixing some rough edges

Not everything in emacs will be useful with `Evil mode` and you might disable it in some but it is great to have the same key letting you to jump from one buffer to another. So remap the C-hjkl keys to do buffer switching globally.

```elisp
(define-key global-map (kbd "C-h") `windmove-left)
(define-key global-map (kbd "C-j") `windmove-down)
(define-key global-map (kbd "C-k") `windmove-up)
(define-key global-map (kbd "C-l") `windmove-right)
```

As `Vim` users we wan't `ESC` to quit out of everything. And here is how you do it.
```elisp
(defun minibuffer-keyboard-quit ()
  "Abort recursive edit.
        In Delete Selection mode, if the mark is active, just deactivate it;
        then it takes a second \\[keyboard-quit] to abort the minibuffer."
  (interactive)
  (if (and delete-selection-mode transient-mark-mode mark-active)
      (setq deactivate-mark  t)
    (when (get-buffer "*Completions*") (delete-windows-on "*Completions*"))
    (abort-recursive-edit)))
(define-key evil-normal-state-map [escape] 'keyboard-quit)
(define-key evil-visual-state-map [escape] 'keyboard-quit)
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)
(global-set-key [escape] 'evil-exit-emacs-state)

```

In `Emacs` you often get many prompts asking you for yes or no. Make then y or n
```elsip
(fset 'yes-or-no-p 'y-or-n-p)
```

With this you are pretty much good to go with `Evil mode`. Now its all about finding the right plugins and using them.

*Good luck! :)*
Ping me if you need help. I will be glad to help you out.