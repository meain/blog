---
title: Just a simple markdown previewer
description: Preview markdown documents in Github's format offline
keywords: github, markdown, markdown-preview, blog
date: 2021-04-27
layout: layouts/post.njk
permalink: "{{ page.date | date: '%Y' }}/{{ page.fileSlug }}/"
---

I really like markdown. I write everything in markdown be it blogs, presentations, emails, todo lists, documentation, everything is in markdown. For the most part I can parse and render markdown in my head and don't need anything more than a simple [text editor](https://www.gnu.org/software/emacs/) that will let me write stuff down. But, from time to time, I do like to render the markdown out and see how it would look.

I also use git a lot and as a result use Github a lot. So most of the markdown that I have seen rendered is in the Github format. It is simple and clean. I have previously used multiple things to render markdown when I wanted to view the rendered version but thought I need a good solution which I can use to render and view the markdown file locally. This is my journey to find/build that tool.

For those who need something that just works, checkout [grip](https://github.com/joeyespo/grip). It is great and the markdown that it generates looks exactly like what Github would generate. This is actually because it is Github that is genrating the markdown. `grip` *send a request to github and gets it rendered* and that is what gets displayed. This was a deal breaker for me for two reasons.
- It send everything that I write to Github
- It has rate limiting ([ref](https://github.com/joeyespo/grip/issues/35))

What I wanted was grip, but it does things offline. Before we dip into this, let me lay down what the things that I looking for was.
- Editor independent script
- Does not need external service to render markdown
- Automatically refresh page on save
- Looks like Github's rendered version

Let me show you how I went about it.

> **Code mentioned here are available on my Github. [script](https://github.com/meain/dotfiles/blob/08bad8a5749cc6c61cad572a73100f853292c321/scripts/.bin/markdown-preview) and [template](https://github.com/meain/dotfiles/blob/08bad8a5749cc6c61cad572a73100f853292c321/datafiles/.config/datafiles/pandoc-github-template.html)**

# Generating the html for the markdown

I am pretty sure I knew how to do this. I have been using [pandoc](https://pandoc.org/) for quite a while now. I love it and it should work great here as well. What I could do is just let pandoc take the raw markdown and render it to html. A simple conversion would go something along the lines of:

``` bash
pandoc -f gfm -t html5 --output document.html document.md
```

What this command is doing is taking `document.md` which is in `gfm`(Github flavoured markdown) and converting that to `html5` and storing in document.html. This step does get us the html that we need. Next step would be to style the thing to look like Github's rendering.

> Checkout pandoc even if you don't plan to use it for this. It is a great tool which you can use to convert from a lot of formats to lot of other formats. You can even convert markdown to Word/PDF documents to be sent to your product teams.

![Screenshot with just html conversion](/img/just-html.png)

This is how it would look like after this step. It gives us semantic html, but does not look all that pretty.

# Styling markdown

This part was relatively easy. I just had to find some css that I can apply to the html doc to make it look like Github's. There was quite a few of these out there. What I ended up using was:

```
https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/3.0.1/github-markdown.min.css
```

There was some extra templating that I had to add in as well to get it to look like it and center it. Pandoc actually lets us pass in the template and I made use of that here. This is the template that I used.


```html
<!DOCTYPE html>
<html>
  <title>Markdown preview</title>
  <link
    rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/3.0.1/github-markdown.min.css"
  />
  <body>
    <article
      class="markdown-body"
      style="
        box-sizing: border-box;
        min-width: 200px;
        max-width: 980px;
        margin: 0 auto;
        padding: 45px;
      "
    >
$body$
    </article>
  </body>
</html>
```

The `$body$` piece is where pandoc would dump the converted html. This get us a bit more further. To use a template in with pandoc we can call the binary like so.

```shell
pandoc --template template.html -f gfm -t html5 --output document.html document.md
```

![Screenshot with styled html](/img/md-styled.png)

Things are stating to look good, but where is my syntax highlighting.

# Syntax highlight

Next piece is syntax highlight. This is something that still does not match 100% with what Github does, but it is pretty close. For this I make use of [highlight.js](https://highlightjs.org/). What this does is it pull down code parsers written in javascript and parses and highlights all the code blocks in the html. Pandoc acutally can do the code parsing as well and that is an option that I explored initially but decided to settle with this.

For this to work, we need to add two files to our template. A css file which will have the theme and a js file which wil be able to pull the other language specific js files needed for parsing. All we need to add here is just two more items to template.

```html
<link rel="stylesheet" href="https://unpkg.com/@highlightjs/cdn-assets@10.7.2/styles/github-gist.min.css"/>
<script src="https://unpkg.com/@highlightjs/cdn-assets@10.7.2/highlight.min.js"></script>
```

*If you want to make everything offline, you can just download these scripts and just have them load from local sources.*

But this alone does not give us syntax highlighting. The issue is that `highlight.js` expects the `<code>` block to have the classes `hljs` and the language name but what pandoc does is put the language name as class name in `<pre>` block. We can just write some javascript to fix this.

```javascript
let ci = [].slice.call(document.getElementsByTagName("pre"));
ci.forEach((i) => {
let children = i.children;
if (children.length === 1 && children[0].tagName === "CODE") {
    const cn = i.className;
    if (cn.length > 0) i.children[0].classList.add("hljs");
    if (cn.length > 0) i.children[0].classList.add(cn);
}
});
hljs.highlightAll();
```

The above code pretty much goes through all `<pre>` tags and for all them that has a `<code>` block as its child applies the class `hljs` as well as whatever was on `<pre>` tag(which would be the language name). This would get it to the format that we need. At the end we also need to call `hljs.highlightAll()` to let hljs go and start highlighting the code blocks.

![Screenshot with syntax highlight](/img/md-syntax-highlighted.png)

Finally, things are stating to look good.

# Automatic refresh

This includes two pieces. One is listening for changes in the markdown file and regenerating the html file. Second one is to refresh the browser tab that is displaying the content.

First one is simple, all we need to use is a simple file watcher. I use [meain/on-change](https://github.com/meain/on-change), but there are a lot of great tools out there. My suggestions would be [entr](https://github.com/clibs/entr) or [watchexec](https://github.com/watchexec/watchexec). These tools will let us run a command every time a file gets updated.

With `meain/on-change` what I can do would be:

```shell
on-change document.md "pandoc --template template.html -f gfm -t html5 --output document.html document.md"
```

What this means is every time `document.md` changes, rerun the command.

Now, for the second piece of this puzzle. Usually the patten here is to run a server and notify the browser through an open socket that there are updates and ask it to reload. But I did not want to bother running a server.

I kinda went for hacky approach for this. I have a script running in the page which will run every second. Every second, it pull the file and check if there is any change from what it got the previous time. If so, it updates the page.

About updating the page, initially if I found that there was a difference what I did was to just reload the browser. But this was causing some jitter. So a better way that I found was to just replace the entire `<html>` block in docuemnt with what I got as a response from fetch. This actually works pretty darn well. Below is the core of this code.

```javascript
setInterval(() => {
    fetch(window.location)
    .then((d) => d.text())
    .then((con) => {
        // content will have the previous content
        if (content !== con) {
        content = con;
        document.getElementsByTagName("html")[0].innerHTML = con;
        fixCodeBlocks();  // runs the code that fixes <code> tags for hljs
        }
    });
}, 1000);
```

Now with this, all I have to do is to open up the file in the browser. I don't have to run any servers.
I can just add `open docuemnt.html` in the script and it would open up `file://document.html` in the browser and we are good to go.

Well, that is it for this one. Bye. Stay safe.
