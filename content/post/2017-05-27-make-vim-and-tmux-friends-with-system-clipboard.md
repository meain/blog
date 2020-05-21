---
comments: true
date: "2017-05-27T00:00:00Z"
description: Get Vim and Tmux to play nice with the system clipboard once and for all
keywords: vim, tmux, clipboard, mac, iterm
title: How to make Vim and Tmux friends with system clipboard
---

Fist of all, a small apology. The `tmux` solution is a bit specific and works only if you are using `macOS` and `iTerm` as your terminal emulator.

# Get `Vim` to play nice

Getting `Vim` working with the system clipboard is the easy part.

## On macOS ( Sierra )

This is very easy. You will have clipboard support out of the box.
You can get the clipboard contents by using
```
"*p
```

for paste and

```
"*y
```

for copy ( yank )


## On Linux

Well, its a bit harder on Linux, not that much though.
First you will have to install a clipboard manager ( I am not sure its called that ) like [`xclip`](https://github.com/astrand/xclip).
Now, once that's down you can use
```
"+p
```

for paste and

```
"+y
```

for copy ( yank )


# Get `Tmux` to play nice

This is the hard part and I am really sorry that I haven't got time to play around with it on Linux.

## Set up iTerm

This solution is specific to [iTerm](https://www.iterm2.com/), so download and install it first.
Now enable `Applications in terminal may access clipboard` option from iTerm preferences.

![screenshot-iterm-pref](http://i.imgur.com/wo5c6Ev.png)


## Set up Tmux

Now we have to set up Tmux.

First step is to install `reattach-to-user-namespace` using brew:

```bash
brew install reattach-to-user-namespace
```

Now add this line to your tmux config file at `~/.tmux.conf`

```
set-option -g default-command "reattach-to-user-namespace -l bash"
```

Replace `bash` at the end with your shell. For example if your shell is `zsh` do:
```
set-option -g default-command "reattach-to-user-namespace -l zsh"
```

Now you can set `tmux` to use `vim` keys for copy and stuff.
Just add the below lines to your `tmux` config file at `~/.tmux.conf`

```
set-window-option -g mode-keys vi
if-shell "test '\( #{$TMUX_VERSION_MAJOR} -eq 2 -a #{$TMUX_VERSION_MINOR} -ge 4 \)'" 'bind-key -Tcopy-mode-vi v send -X begin-selection; bind-key -Tcopy-mode-vi y send -X copy-selection-and-cancel'
if-shell '\( #{$TMUX_VERSION_MAJOR} -eq 2 -a #{$TMUX_VERSION_MINOR} -lt 4\) -o #{$TMUX_VERSION_MAJOR} -le 1' 'bind-key -t vi-copy v begin-selection; bind-key -t vi-copy y copy-selection'
```

### And you are good to go!

# And a bonus tip

Want to get mouse scrolling on tmux? Add the following to your `tmux` config.

```
bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'copy-mode -e'"
```

This will, as soon as you start scrolling get you into copy mode. You can even select text inside tmux and it will copy as soon you have completed selecting into your clipboard.
