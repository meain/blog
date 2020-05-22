---
date: 2020-05-16
layout: layouts/post.njk
description: A simpler method for a reactive UI
keywords: react, javascript, callback, lit-html, UI, reactive, frontend
title: A simpler method for a reactive UI
---

Hola¡

I have been doing frontend for a long time. I started off with vanilla JS, then used jQuery and after that moved
directly onto using pretty much React. I have tried out a lot of others and most of them seem to have this idea of
having the UI as a pure function of your data at the core.

I really liked the idea of having your UI as a function of your data. This idea really stuck with me that I loved using
React for just that reason alone that I started using React in really tiny projects. But started moving away from it
using this.

_Also, unpopular opinion, I do like JSX. It lets me write my HTML in my JS instead of the wrong way._

This is nothing new, just a workflow that works really well for me. You might wanna still reach out for libraries
when you are building something big. This works best for small side projects.

As you might expect, there are two main peices. The data and the rendering logic.

Your data lies in a global dict, to which you get and set using a function. You could probably even set up getters and
setters to each key in the dict for what we are doing here to work. This is what Vue does instead of React's `setState()`.

A sample signature of your `update()` function will look like this:

```javascript
update("key.name", object);
```

So the idea is that, you set your object using a key. You can go down to a child using a `.`. Well, this is not the most
optimal since you loose the ability to have dots in your object keys, but I don't really care about that.

Now for rendering this global object that you are setting , it can have different callbacks assigned to each key.
You could technically call this a library, but here is the gist of what you will need.

```javascript
const global_object = {};
const callbacks = {};

function process_callbacks(key, value) {
  if (key in callbacks) for (let callback of callbacks[key]) callback(value);
}

export function register(key, callback) {
  if (key in callbacks) callbacks[key].push(callback);
  else callbacks[key] = [callback];
  callback(get(key));
}

export function update(key, value) {
  // handle nested keys
  global_object[key] = value;
  process_callbacks(key, value);
}

export function get(key) {
  // handle nested keys
  return global_object[key];
}
```

So, each and every render function you write, you can attach a callback on the global callback dict.

Well, now to writing our templates. You can actually just write it with just [template
literals](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals), but you might wanna look
into [lit-html](https://lit-html.polymer-project.org/).

## Sample code

[Here](https://codesandbox.io/s/exciting-nobel-n0z9v?file=/src/index.js) is a CodeSandbox link to a hello world clicker demo,
and [here](https://codesandbox.io/s/solitary-violet-1fy4z?file=/src/index.js) is a lit-html version.

```html
<div><button id="clicker">Click me</button></div>
```

```javascript
const clicker = document.getElementById("clicker");
clicker.onclick = () => {
  update("counter", get("counter") + 1);
};
register("counter", value => {
  clicker.innerHTML = `<span>${value === 0 ? "Click me" : value}</span>`;
});
```
