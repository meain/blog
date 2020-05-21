---
comments: true
date: "2018-11-09T00:00:00Z"
description: How to deploy a simple react app using docker
keywords: docker, react
title: Docker basics
---

Hi, the idea here is to introduce you to how docker works in very basic terms.

We will go through how to create a docker file and how to run it and stuff like that. But just the basics, just enough
to get you started on docker so that you can take on from there by yourself.


I am not going to discuss as to how to install docker. Just go and look it up on their website.

# What is a `Dockerfile`?

It is a file which will let you configure how you need the project to be set up to be used.
This file specifies stuff like the operating system to the dependencies we need to run our project.

In order to understand what a docker file contains let us see a sample docker file

```docker
FROM node:11.1.0

COPY . /code
WORKDIR /code

RUN npm i
CMD npm start
```

This will be one of the most minimal docker files that you will see, but does introduce you to the basics concepts that
you need to build your own `Dockerfile`.

# Dude, what the heck do the stuff in there mean?

Well, any `Dockerfile` is composed of multiple commands that you use to set up the environment for your project to run.

## `FROM`

The initial command `FROM` is used to choose the base image. You could actually go with something like ubuntu and then
install node on top of it, but the node community provides a simple small image of node with any of the node version
that you need. It makes your life much easier if you are relying just on `node`.
The same applies for stuff like `python` or even for thing like `mysql` and stuff.

So, here you just choose the version `11.1.0` of node.

## `COPY`

This command copies over a file or folder to a specific location inside the container.

There are other commands like `ADD` and `VOLUME`.

`ADD` is essentially `COPY` but you can "copy" over a link in which case it download it. Also, you can "copy" over an
archive, in which case it extracts it. But if all you want is just a file or folder copy, just stick to `ADD`.

In the line `COPY . /code` we copy over all the content in the current directory to `/code` inside the container.

And `VOLUME` is use to mount directories. In the case of `VOLUME`, the data will be in sync between host and container.

## `WORKDIR`

This command is used to switch over to a different directory. Just think about it as a simple `cd` but inside the docker
container.

Here we just switch over to the `/code` directory.

## `RUN` and `CMD`

Well, the next two lines specifies commands for docker to run, and since we have set the working directory to be `/code`, we
run the commands in that directory.

**But why two commands.**

I'll explain. `RUN` command is executed when you build the docker container. Well, I guess now is a good time to tell you
that docker running thingy happens in two steps. But more on that later. You first build the container and in the next
step you run the container.

`CMD` is only triggered when you run the container.

## There are more...

There are more commands that you will use in a `Dockerfile`, but this should be good enough for now.

# Hmm, OK. Got the `Dockerfile` ready. How to run it?

Well, as I said, docker thingy is composed of two parts. One to build the container, another one to run the
container.

## Building the docker container

To do that you do

```sh
docker build .
```

Well, this will build your container and give you and image id. Buttt... it is better you give your image a name (`tag`
as it is called). For that you do

```sh
docker build -t name .
```

This will build your container with the `tag` of name.

## Running the image that you built

To do this, you run

```sh
docker run -t name
```

This is why you had to give your image a `tag`. It comes in handy when you have to run it.

Well, now you have it running, but how do you access it?? Good question.

Well, you have to map the port inside the docker container to one outside.
Let us say that your node app starts at `8000`. You can map the `8000` inside the container to `3000` outside by doing

```sh
docker run -t name -p 3000:8000
```

Now if you head over to [localhost:3000](http://localhost:3000) you can see your site live.

# Extras

Well, this section is mainly why I wanna write this blog in the first place. But thought I would give an introduction
since I am gonna write this anyway.

## `.dockerignore`

This is more or less like `.gitignore`. Well add all the files and folder that we want docker to ignore into this.

A sample `.dockerignore` file will look something like

```
dist
node_modules
.cache
.git
```

Having something like this will make sure that docker does not care about these files.

## Docker caching

Docker caches the container after each build step.

Let us see a trivial example where we can put this to good use.

Instead of writing a `Dockerfile` like above, we do something like this

```docker
FROM node:11.1.0

COPY package.json /code/package.json
COPY package-lock.json /code/package-lock.json

WORKDIR /code
RUN npm i

COPY . /code

CMD npm start
```

By doing this, you will not have to do an `npm install` unless the files `package.json` or `package-lock.json` changes.
Any other file in the current directory can change but docker will not rebuild everything, it will just rebuild from copying `/code`
part.
