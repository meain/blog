---
date: 2019-12-17
layout: layouts/post.njk
description: How to make the switch to DuckDuckGo a bit smoother
keywords: google, duckduckgo, switch, privacy
title: Switching to DuckDuckGo
---

So yeah, recently I decided to switch from Google to DuckDuckGo.
DuckDuckGo is great, don't get me wrong. But at times, Google just has better results.
I usually find myself going back to Google for a *max* of 10%-15% searches.

> DuckDuckGo is really good, just not creepy good.

# If DuckDuckGo fails

I am a lazy person, if I have to do the search two times I will be pissed.
So, I was thinking about having something that will let me quickly search for the same thing in Google if I cannot find
anything useful in DuckDuckGo.

So, here is what I did. I thought I would document it.

I have this Firefox plugin called [Code Injector](https://addons.mozilla.org/en-US/firefox/addon/codeinjector/).
What the plugin does is pretty simple, it lets me inject arbitrary html, css or js into any page.
I decided to just add an anchor tag `useGoogle()` (I was using [React hooks](https://reactjs.org/docs/hooks-overview.html) extensively during that time)
under the DuckDuckGo search bar.

The end result will look something like this:

![screenshot](/images/ddg.png)


If you click on `useGoogle()`, it will just redirect you to a page with the exact search on Google.
If you know some js, and css, it should be pretty simple.

But here is what I am using.


```js
he = document.getElementsByClassName("header__search-wrap")[0];
sb = document.createElement("a");
tex = document.createTextNode("useGoogle()");
sb.setAttribute('style', 'margin-left:10px; color: #ccc;cursor:pointer;')
sb.appendChild(tex);
he.appendChild(sb);
sb.onclick = () => {
  const searchTerm = document.getElementById("search_form_input").value;
  if (searchTerm)
    window.location = `https://www.google.com/search?q=${searchTerm}`;
};
```

*The variable names and stuff could be better, but I was in a hurry the day I set it up*

> This combined with vim mode for Firefox lets me switch to DuckDuckGo even just with my keyboard(or you can always tab
> over to the link).

# Directly search on Google, YouTube or Github

Well, in some cases you know that only Google will have to result, or you directly wanna search on YouTube or Github.

This is where you can use [search shortcuts](https://support.mozilla.org/en-US/kb/assign-shortcuts-search-engines).
I have my YouTube search assigned to `y`. So if I wanna search for something directly on YouTube, I just prepend `y `
in front of my search. You could even add one for Google.

That is all I got for now. I have been moving away from Google bit by bit, this was one of my first steps.
