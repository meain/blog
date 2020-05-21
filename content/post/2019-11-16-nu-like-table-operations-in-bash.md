---
comments: true
date: "2019-11-16T00:00:00Z"
description: How to do most of the table operations that you can do in Nu Shell in
  good ol' BASH
keywords: shell, bash, nu-shell, nu, zsh, awk, sort, column
title: Table operations like in Nu shell in BASH
---

Hi, another installment of why people should just write more bash.
I am not sure if you are aware of it. There is a new shell written in Rust called [Nu Shell](https://www.nushell.sh/).
One of the main ideas of it is that you treat every data as table data and then work on top if as if
you were working with SQL queries.

I am not a big fan of this approach personally. I would stick to treating data as a text stream than a tabular list.
Sure, it will let you put some abstraction on top of which might make your life a bit simpler in some case, but you are
missing out the power of just treating is as a simple text stream.

I was inspired to write this blog after seeing this [tweet](https://twitter.com/nixcraft/status/1195665338416787456?s=09) from nixcraft.
You can do a lot of stuff listed in [working with tables in nushell](https://book.nushell.sh/en/working_with_tables) right in BASH.

I don't wanna BASH(pun intended) Nu shell. A lot of people seem to love it, plus Nu helps with making items into a table
in the first place easier. I just want people to understand that you don't need Nu shell to do a lot of the things that
they are mentioning.

OK, enough blabbering, lets get to the actual content.

I just decided to take a few examples that they have in their [book](https://book.nushell.sh/) and show how you would
achieve the same thing in BASH.

I am gonna use `ls` as the data input here as they seem to use it for their demo in [working with tables](https://book.nushell.sh/en/working_with_tables).
In `ls`, the data is already in columns, so I guess you could say that it already looks like a table but without
borders (lets tare down the borders).

# Basics

## Setting baseline - bare bones `ls` (not exactly)

This is the output from my `blog` directly. Its in `jekyll`, nothing fancy.

```
total 64
-rw-r--r--   1 meain  staff  1077 Aug 10 17:59 LICENSE.md
-rw-r--r--   1 meain  staff   139 May 27  2017 README.md
-rw-r--r--   1 meain  staff  1605 Aug 10 18:47 _config.yml
drwxr-xr-x  13 meain  staff   416 Nov 13 10:56 _includes
drwxr-xr-x   6 meain  staff   192 Nov 12 21:43 _layouts
drwxr-xr-x  26 meain  staff   832 Nov 16 17:49 _posts
drwxr-xr-x  12 meain  staff   384 Nov 16 17:15 _site
-rw-r--r--   1 meain  staff   533 Aug 10 17:59 about.md
drwxr-xr-x   6 meain  staff   192 Mar 20  2018 assets
-rwxr-xr-x   1 meain  staff  2166 Nov 13 10:55 favicon.png
-rw-r--r--   1 meain  staff  1291 May 23  2017 feed.xml
-rw-r--r--   1 meain  staff   863 Aug 27  2017 index.html
-rwxr-xr-x   1 meain  staff    13 Oct 11 20:16 run-dev
```

Actually we are going to use `ls | tail -n+2` from here on out as there is that `total 64` thingy on top and we need to
get rid of that when working with "table" ish data.


You might know about `tail` already but if you pass in a value like `tail -n+<value>` it will actually show everything
except that many `lines-1`. So with that, my output will look something like this.

```
-rw-r--r--   1 meain  staff  1077 Aug 10 17:59 LICENSE.md
-rw-r--r--   1 meain  staff   139 May 27  2017 README.md
-rw-r--r--   1 meain  staff  1605 Aug 10 18:47 _config.yml
drwxr-xr-x  13 meain  staff   416 Nov 13 10:56 _includes
drwxr-xr-x   6 meain  staff   192 Nov 12 21:43 _layouts
drwxr-xr-x  26 meain  staff   832 Nov 16 17:53 _posts
drwxr-xr-x  12 meain  staff   384 Nov 16 17:15 _site
-rw-r--r--   1 meain  staff   533 Aug 10 17:59 about.md
drwxr-xr-x   6 meain  staff   192 Mar 20  2018 assets
-rwxr-xr-x   1 meain  staff  2166 Nov 13 10:55 favicon.png
-rw-r--r--   1 meain  staff  1291 May 23  2017 feed.xml
-rw-r--r--   1 meain  staff   863 Aug 27  2017 index.html
-rwxr-xr-x   1 meain  staff    13 Oct 11 20:16 run-dev
```

btw a Nu shell output of `ls` will look something like this


```
---+---------------+------+----------+---------+------------+------------
 # | name          | type | readonly | size    | accessed   | modified 
---+---------------+------+----------+---------+------------+------------
 0 | add.rs        | File |          | 2.7 KB  | 2 days ago | 2 days ago 
 1 | sum.rs        | File |          | 3.0 KB  | 2 days ago | 2 days ago 
 2 | inc.rs        | File |          | 11.8 KB | 2 days ago | 2 days ago 
 3 | str.rs        | File |          | 21.4 KB | 2 days ago | 2 days ago 
 4 | skip.rs       | File |          | 1.7 KB  | 2 days ago | 2 days ago 
 5 | textview.rs   | File |          | 9.4 KB  | 2 days ago | 2 days ago 
 6 | binaryview.rs | File |          | 13.0 KB | a day ago  | a day ago 
 7 | edit.rs       | File |          | 2.7 KB  | 2 days ago | 2 days ago 
 8 | tree.rs       | File |          | 3.0 KB  | 2 days ago | 2 days ago 
 9 | sys.rs        | File |          | 9.2 KB  | 2 days ago | 2 days ago 
---+---------------+------+----------+---------+------------+------------
```

> For the below commands, assume I am doing `ls -l | tail -n+2` when I type `ls`

## Selecting specific columns

Lets say you just wanna see only the name and the size, what you can do is

```bash
ls | awk '{print $9,$5}'  # bash
ls | pick name size  # nu
```

What this does is that it selects the 9th and 5th column from the above output separated by spaces.
The output of this will look kinda like below.

```
LICENSE.md 1077
README.md 139
_config.yml 1605
_includes 416
_layouts 192
_posts 832
_site 384
about.md 533
assets 192
favicon.png 2166
feed.xml 1291
index.html 863
run-dev 13
```

Now, if you need this in column format you can just pipe the output into `column`

```bash
ls | awk '{print $9,$5}' | column -t
ls | pick name size  # nu
```

and you output will become

```
LICENSE.md   1077
README.md    139
_config.yml  1605
_includes    416
_layouts     192
_posts       832
_site        384
about.md     533
assets       192
favicon.png  2166
feed.xml     1291
index.html   863
run-dev      13
```

> caveat: if there are spaces in filenames, this will not work

## Sorting the data

OK, lets say we need to sort the files by size or by name. What would you do?
For both the use cases you can make use of the `sort` command.


If you need to sort by size, you just give the following command.

- `-n`: say that it is a numerical sort
- `-k`: specify which column to use for sort

```bash
ls | sort -nk5  # bash
ls | sort-by size  # nu
```

This will give you something like the following

```
-rwxr-xr-x   1 meain  staff    13 Oct 11 20:16 run-dev
-rw-r--r--   1 meain  staff   139 May 27  2017 README.md
drwxr-xr-x   6 meain  staff   192 Mar 20  2018 assets
drwxr-xr-x   6 meain  staff   192 Nov 12 21:43 _layouts
drwxr-xr-x  12 meain  staff   384 Nov 16 17:15 _site
drwxr-xr-x  13 meain  staff   416 Nov 13 10:56 _includes
-rw-r--r--   1 meain  staff   533 Aug 10 17:59 about.md
drwxr-xr-x  26 meain  staff   832 Nov 16 17:59 _posts
-rw-r--r--   1 meain  staff   863 Aug 27  2017 index.html
-rw-r--r--   1 meain  staff  1077 Aug 10 17:59 LICENSE.md
-rw-r--r--   1 meain  staff  1291 May 23  2017 feed.xml
-rw-r--r--   1 meain  staff  1605 Aug 10 18:47 _config.yml
-rwxr-xr-x   1 meain  staff  2166 Nov 13 10:55 favicon.png
```

You could the probably just pick only the name and size from it. The command for that would be same as above.

```bash
ls | sort -nk5 | awk '{print $9,$5}' | column -t  # bash
ls | sort-by size | pick name size  # nu
```

and this would give you

```
run-dev      13
README.md    139
assets       192
_layouts     192
_site        384
_includes    416
about.md     533
_posts       832
index.html   863
LICENSE.md   1077
feed.xml     1291
_config.yml  1605
favicon.png  2166
```

**Pretty neat, huh?**

Instead if you where to sort by name, you would have one less parameter to sort. You will not have the `-n` flag as it
is not a numerical column.

So, if you need to do that, the command would be:

```bash
ls | sort -k9  # bash
ls | sort-by name  # nu
```

## `first` and `skip`

Well, this is pretty much `head` and `tail`.

- To take the first n items, you would to `head -n<number>`
- To take the last n items, you would do `tail -n<number>`
- To skip the first n items, you would do `tail -n+<number+1>`

As simple as that. Lets say you wanna sort by size and take the first 5 and skip the first two after that.
It would look something like this.

```bash
ls | sort -k9 | head -n5 | tail -n+3  # bash
ls | sort-by size | first 5 | skip 2 # nu
```

> If you really wanna go there you can always use `sed 11q` instead of `head`. One for the memes.

## Picking the `nth` item

Nu shell has this command called `nth` which lets you pick the nth line in a list.
You can do something similar by using awk.

Lets say you wanna pick the 5th element

```bash
ls | awk '5 == NR'  # bash
ls | nth 5
```

but awk is actually even more powerful, lets say you wanna pick every even item, you can do

```bash
ls | awk '0 == NR % 2'  # bash
```

> `NR` in awk is a special variable, it give you the current line number. You can do any math operation on it.
> In here we just take the modulus of it with 2 and prints if it is 0.


## Check if column value greater than a specific value


Nu shell provides this command called `where` which you can use to compare values like an SQL where clause.
You can actually do that with awk.

```bash
ls | awk '$5 > 1000'  # bash
ls | where size > 1000  # nu
```

Ideally the command would look more like


```bash
ls | awk '$5 > 1000 {print $0}'
```

but the `{print $0}` part will be put there if we do not have anything in there.


## Sum up values in a column

Again, you can just use awk for this. Maybe this is a blog about awk than bash?

So, lets say you wanna view how much cpu each process takes and sum it up.
If you run the ps command it will give you this data. For our use let us just get the command name and the cpu usage.

Running

```bash
ps axhc -o command,%cpu -r
```

will give you something like the following

```
COMMAND           %CPU
firefox           67.3
-zsh              13.0
WindowServer       6.9
hidd               1.4
plugin-container   1.1
tmux               0.9
karabiner_grabbe   0.9
...
```

Now, if we needed to sum up the values of cpu, we can use the following command

```bash
ps axhc -o command,%cpu -r | awk '{s+=$2} END {print s}'
```

OK, let me explain. We just create a variable `s` and add all the values of `$2` which is the second column item (cpu)
and once we are done, we print out `s`. Its as simple as that.



# Meta

## What if the separator is not space?

Well, in most common cases, the separator will be space. But what if it is not?
You can pass in a argument to most of the commands to say what the separator is.

I am going to use a file which looks like below for demo. Just pulled from their page.

```
Octavia | Butler | Writer
Bob | Ross | Painter
Antonio | Vivaldi | Composer
```

###  For `column` you can use `-s`.

If you wanna see this in columns, you can just do

```bash
column -s'|' -t people.txt  # bash
open people.txt | lines | split-column "|"  # nu
```

The output for this will be like what you would expect for it.

```
Octavia    Butler     Writer
Bob        Ross       Painter
Antonio    Vivaldi    Composer
```

### For `awk` you have `-F`

You can just pass the separator using the flag `-F`.

Lets say you just wanna view to the first column, you can just do.

```bash
awk -F'|' '{print $1}' people.txt
```

The output will be, as you expect

```
Octavia
Bob
Antonio
```

Just as a reminder, this is not the only way to do it. Here are a few other possible ways.

```bash
cut -d'|' -f1 people.txt
sed 's/\ |.*//' people.txt
grep -o "^\w*\b" people.txt
grep -Eo '^[^|]+' people.txt
```

### For `sort` you have `-t`

If you wanna sort by the third column, you can run

```
sort -t '|' -k3 people.txt
```

you will essentially get you

```
Antonio | Vivaldi | Composer
Bob | Ross | Painter
Octavia | Butler | Writer
```

Now pass it to column for a cleaner output

```
sort -t '|' -k3 people.txt | column -s'|' -t
```

and that will give you

```
Antonio    Vivaldi    Composer
Bob        Ross       Painter
Octavia    Butler     Writer
```

---

And that is a wrap, I guess I convinced you that BASH is really powerful.
Hopefully, I got at least a few more people to write more BASH.
