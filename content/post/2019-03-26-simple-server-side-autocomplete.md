---
comments: true
date: "2019-03-26T00:00:00Z"
description: Understanding how to effectively do autocomplete when you need to ping
  you backend
keywords: Javascript, autocomplete, react, server, backend
title: How to do server side autocompletion (networking parts)
---

So, recently I had to create an autocompletion for a chat app at work. We did not need anything fancy for the first cut.
Sounded like a simple project. This was in `React` I initially thought of pulling in an existing library for it, but our
requirements needed some special kind of autocompletion menu. 

Let me tell you what I mean by that. We build chatbots and this was the chat input window.
So if we were building something for, lets say `Netflix`, the completion has to be able to something like this.

![completion-sample](https://i.imgur.com/qoPpbus.gif)

*Sorry about the jittery gif*

As in a separate completion for the possible movie titles.

So, I gave up on just taking an existing library because I could not find anything that did what I needed to do.
Initially I built something simple, the one you saw above, and it worked fine for some time. I was loading the whole
possible completions as a `json` to the frontend and the doing your normal string matching thingy on it.

But one fine morning I got a request to make the completions to be routed through the backend so that it can be more
dynamic in nature, and a few another reasons. And yeah, I had to do that.

## Initial doubts

Initially I was skeptical about routing the completions through the backend as I felt like it will feel very very slow
compared to the current implementation. But then again, `Google` was doing it and I was said some delay is expected and
they are fine with that.

So I decided to start working on it. Here is my journey making the change.

## Hit the backend for each keystroke

I started off with this idea, created a simple python backend written using `flask` to test this out.
The `flask` api did nothing more than take the request, find possible completions based on some creiteria and return the
list of possible completions back.

Initially, I was just hitting the backend for each keystroke. It all seemed to be OK until I went to the network tab and
changed the network from `online` to `Slow 3G` ( Chrome lets you simulate different network speeds )

The issue was the when you type a long sentence there will be a lot of requests that will be send and the browser has to
wait on all the previous request to be completed before it can get the response to the final(useful) response. This was
made really bad by the fact that I had just once instance of the flask app running. So all the request had to be
processed one by one.

It looked something like this

![compl-waiting](https://i.imgur.com/5AFICTN.gif)

## Hit backend only if user pauses

Well, this was my next idea. Do not send a request for every keystroke, but just when the user stops typing.
So I put the send request in a `setTimeout` and cancelled the timeout if a new keystroke came in before the previous
timeout had completed. The function looked something like this in code.

```js
if (filterTimeout) clearTimeout(this.state.inputTimer);
filterTimeout = setTimeout(() => {
  this.updateFilteredCompletions(input);
}, 400);
```


This seemed to be good idea initially, but it still was not good enough for a few reasons. The main issue was that We
had a useless wait before we sent a request to the server for completion. In the code example above, we are pretty
much wasting `400ms` which could have been used to send and receive the completion info.

## Cancellable requests

Searing for a better way to do this, I came across something called cancellable
requests. More info [here](https://developers.google.com/web/updates/2017/09/abortable-fetch).

So, essentially the idea was. You send a request but at a later point if you decide that you do not need the response
you can just cancel the request so that you do not have to bother about receiving it nor does the server has to bother
about sending it.

This works if the majority of time taken is in the transmission rather than the actual computation happening in the
backend. For me this was the case as the computation took just like `0.0013s` but the whole transfer with simulated 3G
speeds took like 1.5 - 2 seconds. So I decided to go this route.

I decided to add the cancellation thing. It was just awesome.
See the difference that it makes.

![completion-with-cancellation](https://i.imgur.com/gUxiv9i.gif)

It might feel like it is still slow, but see the difference it makes relative to the previous implementation. Also
remember that this is with `Slow 3G` speeds. If you notice the network tab, you can see that request are getting
cancelled when new one is coming and we are not having a `(pending..)` sign which causes the browser to wait for its
response and the server to send it. This is more of an issue for the server sending as it might be having just one
thread running to do the completion.

This [StackOverflow answer](https://stackoverflow.com/a/47250621/2724649) sums up really well on how to implement 
something like this.

## A few tiny optimisations

With the cancellable requests in place, I was mostly happy with the result. But I decided to add in a few more nice
things.

#### Caching completions

One simple idea was to cache completions. The idea is simple, you just maintain a global dict with `input` ->
`completion` mapping. Also, remember to do cache invalidation properly.

You might think "why would anyone cache the autocompletion result", but the main use of this comes when the user presses
the backspace key. It might feel like a small thing, but it makes a big difference.

### Trim out the input before sending

Another very tiny improvement. In most cases the completion for `Show me the rating for ` and `Show me the rating for  `
and `Show me the rating for      ` will be the same. So just avoid it ( also handle this in caching ).

The end result of the above things will look something like this

```js
if (input.trim() in completionResponses) {
  return completionResponsesCache[input.trim()] // from cache
} else {
  completions = this.getCompletionsFromBackend(input.trim()); // api call ( I am gonna pretend this is a synchronous call )
  completionResponsesCache[input.trim()] = completions
  rturn completions
}
```

After that add in a few nice UI touches and you get a not so bad completion experience. I leave that part to you.
And that is a wrap. Thanks for reading my rant.
