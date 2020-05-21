---
comments: true
date: "2018-12-28T00:00:00Z"
description: How to publish a console application to pypi
keywords: pypi, python, console, publish
title: Publishing a console application to pypi
---

Let's say you have a very useful python script that you use and think other people might have some use out of it.

One way is to just share the python snippet, but nah, that is too old school.
Let us publish it to pypi so that anyone can just do a `pip install your-awsome-tool` and get going with it.

# So, how to do it?

Well, let us create a simple project. Maybe a simple countdown timer.

> I am gonna call the project `counterer` because I am too lazy to come up with a better name.

Here is the initial project structure.

```
.
├── README.md
├── counterer
│   └── counterer.py
└── setup.py
```

Pretty simple, the main work comes in `setup.py`.

## Create our `counter` application

Here is a sample `counterer.py`.

```python
import time
import sys


def main():
    count = int(sys.argv[1])
    for i in reversed(range(count)):
        print(i)
        time.sleep(1)


if __name__ == "__main__":
    main()
```

## Configuring `setup.py` file

There is a sample file at the bottom of the blog.

### Setting up a description for `pypi` project page

We can use the `README.md` of our project as the description (`long_description`) of out project.
For that just use python to read the file and use it.
You have to set two values in `setuptools.setup`

The values to be set are:

- `long_description`: read the contents of the `README.md` file and set that
- `long_description_content_type='text/markdown'`: set this if you are using markdown, by default it is `rst`

## Setting up `classifiers`

Pypi uses classifiers as a way to tag projects, it is passed in as the value `classifiers` in `setuptools.setup`
function.
Set the classifiers you need as a list.
More info and a list of classifiers can be found at [https://pypi.org/classifiers/](https://pypi.org/classifiers/).

## Providing requirements for project

You can provide the requirements of your project in `install_requires`. It is just a list of strings.

You could either provide it manually here or just read it from the `requirements.txt` in your project.

It will be something like.

```python
install_requires = ["psutil", "pprint"]
```

You pass that on to `setuptools.setup` as `install_requires`

## Specifying `entry_points`

This is where we define the name of our cli application in `setuptools.setup`.

In our case, the value will be

```json
{ "console_scripts": ["counter = counterer.counterer:main"] }
```

With this defined, you can use the command `counter` and python will call the `main` function in the `counterer` package
in the `counterer` project.


## Calling `setuptools.setup`

Finally you can call `setuptools.setup` will all the values.

A few other values that you have to pass that I did not mention are

- `packages`: list the packages in your project. In our we just have `counterer`
- `name`: project name
- `version`: version of your project
- `author`: your (maintainer's) name
- `author_email`: your (maintainer's) email
- `keywords`: keywords related to your project


## A sample

Let us see what a sample `setup.py` file looks like.

```python
import setuptools

with open("README.md", "r") as fh:  # description to be used in pypi project page
    long_description = fh.read()

classifiers = [
    "Programming Language :: Python :: 3",
    "License :: OSI Approved :: MIT License",
    "Operating System :: OS Independent",
]

install_requires = []  # any requirements your package has

setuptools.setup(
    name="counterer",
    version="0.0.1",
    author="Abin Simon",
    author_email="abinsimon10@gmail.com",
    description="Simple counter",
    url="https://github.com/meain/counterer",
    long_description=long_description,
    long_description_content_type='text/markdown',
    packages=["counterer"],
    install_requires=install_requires,
    keywords=["counter", "python"],
    classifiers=classifiers,
    entry_points={"console_scripts": ["counter = counterer.counterer:main"]},
)
```


# Publishing to Pypi

Now that we have our project ready, we just have to publish it.
Register for an account if you do not have one at [https://pypi.org/account/register/](https://pypi.org/account/register/).

Run the following commands to publish it to pypi.

- `python3 setup.py sdist bdist_wheel`
- `twine upload dist/*`

More info about it at [https://pypi.org/project/twine/](https://pypi.org/project/twine/).

# Aaaand we are done

> You can check out the code [here](https://github.com/meain/counterer).

There you go, now anyone can install your package by using

```pip3 install counterer```

After installation they can call

```
counter 10
```

to set a countdown timer for 10 seconds.
