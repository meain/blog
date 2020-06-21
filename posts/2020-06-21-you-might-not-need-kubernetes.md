---
title: What you need might not be Kubernetes
description: What you need might not be Kubernetes
keywords: kubernetes, serverless, sclaeable, deployment
date: 2020-06-21
layout: layouts/post.njk
permalink: "{{ page.date | date: '%Y' }}/{{ page.fileSlug }}/"
---

Let me get this out first. There is small chance that what you need is Kubernetes, but it is highly unlikely.

> What you need is not Kubernetes. What you need is scaleable deployments.

If you haven't already been able to tell, this is more of a rant blog.  
Just my opinions. Yup, I have them.

Let me explain how this went for me. I was dealing with a lot of scaleablility issues related to deploying stuff. There
was very little automated deployment setup for most of what I did as well. So when I initially heard about Kubernets I was excited as it
was about time I fix the automated deployment pipeline as well as scaleability issues.

Initially when I heard about Kubernetes, I was pretty much expecting to write a yaml file and have all my scaleability
problems vanish. But, the more I worked with Kubernetes, the more I realized that this is not true. Sure, Kubernetes is
one layer of abstraction on top just spinning up VMs and deploying your software on them. But it is not the final
solution to all of your problems.

# An example situation

OK, in order to better explain this, let us consider a "hypothetical" situation. You have a frontend which is written in
the latest and greatest javascript framework (obviously). You also have a backend which is written is Python, nah Rust. Whatever is that you like.

You had a fun time developing them in your local machine and now you wanna deploy them.

## Naive approach

Well, let us assume we go back in time(well Rust and that shiny js framework is not available in this time, but let us just ignore that time travel mess for now).
Here is how we would go about deploying our stuff. We buy a computer... Wait, maybe not that back in time. We spin up a
new VM on GCP or EC2. We install everything that you need to run the stuff. Node to build your static assests, or you
might even just only copy over the static files. You start your backend after installing python reqs if it is python.
After all this, you start your nginx reverse proxy and maybe even certbot for that sweet sweet https.

This works, and if we are not really concerned about scaling to a huge audience, this is more or less what you need.
But you had bigger plans for your app. You need to make sure it scales.

## Kubernetes

Let us come back to current time period. Now we have Kubernetes, and we decide to deploy the app our new cluster.

You watch a bunch of tutorials and write that yaml file, or just copy paste it from somewhere and change some values.
You create yaml files for both frontend and backend.

Now you do `k apply -f myapp.yaml` and you are good. You see pods starting, stuff getting setup. You make a request, it work. You spam it with requests, it scales.

Well, at this point you think you have figured it all. But it is just starting.

# Issues you will run into

## Scaling factor

Well, when you wrote that yaml file before, you did not just specify that it should scale, but by what metric that it should scale as well.
One common metric that you see getting used is by CPU usage. This works for a lot of stuff. But(there is always a but),
this is not always the case. What if you have a service that pretty much just calls a few other services and aggregates
results and return them back(well, async.. shhh...). In this case, you would not see a CPU spike, so Kubernetes would not scale and you would not get any response back if your backend can only serve a few connection at a time.
This is only one situtaion, you will run into a lot of similar class of problems.

## Adding more resources

Just because you have Kubernetes does not mean you have infinite resoureces.
I know you can spin up and attach new VMs to your cluster, but spinning up new VMs take some time and you cannot wait
on it if you have a really spikey traffic situation.

Also scaleing down to zero is something which is not directly available in Kubernetes.

## It is just a lot of yaml copy pasting

Well, this is not in itself a big problem, but this should be an indicator that there is a problem. In a lot of cases, for
a backend deployment most of what you are doing with kubernetes is asking it to run a docker container and expose a
port. Attach a service to it and expose that to the internet.

So, if you keep stuff like ports consistent, you are pretty much only changing which docker image to use.
Nobody should be asked to write yaml for doing something like this.

# Better solutions

This is not an exhaustive guide. Just some things I ended up using.

## Functions and infinite scaling

Well, Kubernetes is pretty freaking awesome. But most of times, it is not enough abstraction for most people. What you
need is a way to say "Take this app and deploy it. PS: make it automatically scale". We are almost there, we can say.
"Deploy this docker image and auto scale it.", which I would argue is pretty close. For stuff like this what you
need is not Kubernetes, what you need is something like cloud-run or a similar service.
You might have have heard about stuff like knative, faas, riff which are pretty much this. They abstract away most of
that kube yaml from you and give you something better. There are other tools like Rancher which pretty much take all the yaml out of the equation.

## Dedicated tools

Also, there are lot of people working on specialized tools to do specialized tasks. I would like to give you the
example of something like Netlify or Vercel for static assets like our frontend app.

In our sweet little app, once you are done with the build step, all you have remaining is to just serve static files.
You could technically put all of this static assets into and nginx container and ask stuff like cloud-run to scale that
nginx container image. But there are better options.

For example, if you were to you a service like Netlify, all you need to do is to specify what is the command to build your project, and which dir all your assets will be in after the build.
Once you have that done, they take you app, "scale" the crap out of it using their global CDNs. You are not beating that with anything on you Kube cluster.
Also in the case of Netlify, they recently introduced plugins which you can add to your build step to do tasks like
optimize images etc. And you even get live previews for PRs which is freaking epic.

This is only one example. In the case of Vercel, you can actually use Next.js and also have backend logic which they
scale as if each route was a function. Pretty neat, huh?

# Appendix

There is more to this obviously, just wanted to let you know that Kubernetes is not the best option for all the problems out there.

Also there are a lot of things that help improve your k8s experience like helm.

It kinda feels weird saying this, but Kubernetes is a low level abstraction. But in case of most people it really is the truth.

That said, as I mentioned in the start there are reasons why you would need to use Kubernetes itself. But in most
cases, it is if you need more fine grained control over how, when and where things run.


# External links

Here are a few things that that realated:

### Tools:

- Helm: https://helm.sh/
- Knative: https://knative.dev/
- cloud-run: https://cloud.google.com/run/
- Rancher: https://rancher.com/
- riff: https://projectriff.io/
- Netlify: https://www.netlify.com/
- Vercel: https://vercel.com/

### Youtube & Podcast:

- https://softwareengineeringdaily.com/2020/05/29/kubernetes-vs-serverless-with-matt-ward/
- https://realpython.com/podcasts/rpp/14/
- https://kubernetespodcast.com/episode/102-helm-graduation/
- https://www.youtube.com/watch?v=8age_72M_NE
- https://www.youtube.com/watch?v=E0GBU8Q-VFY
- https://www.youtube.com/watch?v=6sDTB4eV4F8
- Anything by Kelsey Hightower
