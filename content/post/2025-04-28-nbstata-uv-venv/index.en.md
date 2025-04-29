---
title: "Running the nbstata Jupyter kernel within a uv virtual environment"
author: Package Build
date: '2025-04-29'
slug: nbstata-uv-venv
categories:
  - Blog
tags:
  - GitHub
  - Stata
  - Jupyter
  - nbstata
  - Quarto
subtitle:
summary: "How to setup a uv virtual environment to run the nbstata Jupyter kernel."
authors: []
lastmod: '2025-04-29T07:00:00+00:00'
featured: no
image:
  caption: ''
  focal_point: 'Center'
  preview_only: no
  alt_text: 'Screenshot of a shell script to setup the nbstata Jupyter kernel within a uv virtual environment.'
projects: []
toc: true
---

## Introduction

Any new project using Python or Jupyter is very stongly recommended to use a virtual environment. A virtual environment is a directory (usually at the top level; often called either _.venv_ or _venv_) within your project directory which contains the dependency Python packages and perhaps the Python installation (or pointers to the Python installation on your system).

There are many Python project managers, in this post I will use the new and extremely fast project manager [uv](https://docs.astral.sh/uv/). I will show how to use the [nbstata](https://hugetim.github.io/nbstata/) Jupyter kernel by Tim Huegerich within a uv virtual environment on macOS, Windows, and Linux. The aim is to be able to conveniently and reproducibly render Quarto documents using the [`jupyter: nbstata`](https://hugetim.github.io/nbstata/user_guide.html#quarto-tips) engine from within the virtual environment.

At this point it's worth saying that I am a contributor to the excellent [Statamarkdown](https://cran.r-project.org/package=Statamarkdown) R package by Doug Hemken. This can be used in Quarto documents using the knitr engine. In this post I'll be using nbstata because nbstata uses [pystata](https://www.stata.com/python/pystata/) which is StataCorp's official Python package (included in each Stata installation) and is their official way of integrating Stata in Python. As such pystata and hence nbstata have more features than Statamarkdown can provide.

And it is worth emphasizing how useful virtual environments are because it is very easy to get oneself in a complete mess with regards Python, as you will likely end up with many different versions installed. Chaos can then accidentally ensue regarding which versions of dependency packages your different projects require given a certain Python version, as always XKCD have a comic illustrating the problem.

<figure>
<img src="https://imgs.xkcd.com/comics/python_environment.png" alt="XKCD 1987, a diagram showing the chaos of not using Python virtual environments." width="630" style="display: block; margin: auto;">
<figcaption>XKCD 1987, Python Environment. <a href="https://xkcd.com/license.html">XKCD license</a></figcaption>
</figure>

## Setup basics

On your machine you need to have

* Stata installed and know the location of the installation
  * and check that within the installation there is the _utilities_ directory containing the _pystata_ directory
* uv must be installed, see [its docs for installation instructions](https://docs.astral.sh/uv/getting-started/installation/)
* and of course a text editor and a terminal.
* On Windows I would recommend using Git Bash as your shell (this is bundled with [Git for Windows](https://git-scm.com/downloads/win)) for running the setup script in the next section.

## A shell script to setup the uv virtual environment

What follows are the shell commands we need to run to setup our virtual environment. The script is for macOS but I have included comments in the places where amendments are required for either Windows or Linux. 

Note that currently on macOS and Linux there cannot be any spaces in the filepath to your virtual environment.

* On Linux we need to ensure that the directory containing our stata/stata-mp binary is on `PATH`.

```bash
# export PATH=$PATH:/usr/local/stata18
```

* We then need to ensure that our Python installation will be able to find the pystata package. We can do this by defining the `PYTHONPATH` environment variable.

```bash
# Required so Python can find pystata package
export PYTHONPATH=/Applications/Stata/utilities
# Linux: export PYTHONPATH=/usr/local/stata18/utilities
# Windows: export PYTHONPATH="C:/Program Files/Stata18/utilities"
```

* We then setup the virtual environment. This will create a directory in our project called _.venv_. I prefer to explicitly set the version of Python I am using.

```bash
uv venv --python 3.13
```

* We then activate the virtual environment

```bash
source .venv/bin/activate
# Windows: source .venv/Scripts/activate
```

* Now we can install the required Python dependency packages as per the [nbstata docs](https://hugetim.github.io/nbstata/user_guide.html#install-nbstata).

```bash
# Install nbstata dependency Python packages
uv pip install jupyterlab nbstata jupyterlab_stata_highlight2

# Additional Python packages if using parameterised Quarto documents
# uv pip install papermill python-dotenv jupyter-cache
```

* Then we setup the nbstata Jupyter kernel

```bash
python -m nbstata.install
```

The nbstata docs states that the `--sys-prefix` flag may be required in a virutal environment but I haven't found that to be the case.

* Then we run commands to do our actual work; for example rendering a Quarto document using the `jupyter: nbstata` engine.

```bash
quarto render index.qmd --execute --execute-daemon-restart
```

An example Quarto document, say _index.qmd_, could be:


```` plaintext
---
title: My example nbstata document
jupyter: nbstata
---

```{stata}
display "Hello, World!"
```
````

Note that Quarto documents using the nbstata kernel can also be embedded within other Quarto documents, [as I have described in a previous post](https://remlapmot.github.io/post/2025/multi-engine-quarto/).

* And that's it. When you have finished your work you can deactivate the virtual environment

```bash
deactivate
```

## Summary

I have shown how to setup and run the nbstata Jupyter kernel within a uv virtual environment on macOS, Windows, and Linux; in order to conveniently and reproducibly render Quarto documents using the `jupyter: nbstata` engine.
