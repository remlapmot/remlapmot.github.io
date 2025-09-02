---
title: "Self-contained Python scripts for rendering multi-engine Quarto documents"
author: Package Build
date: '2025-09-02'
slug: self-contained-python-script-for-quarto
categories:
  - Blog
tags:
  - Jupyter
  - Nbstata
  - Quarto
  - R
  - R Markdown
  - Python
  - Stata
  - uv
subtitle: ''
summary: "How to create a self-contained Python script, which declares the dependencies for the virtual environment to run Jupyter, for rendering Quarto documents. This allows non-technical users to simply run a single command to setup and activate a virtual environment and have the Quarto document rendered for them."
authors: []
lastmod: '2025-09-02T07:00:00+00:00'
featured: no
image:
  caption: ''
  focal_point: 'Center'
  preview_only: no
  alt_text: 'Image of a scroll, representing a script, containing the word Quarto and the Python and Jupyter logos.'
projects: []
toc: true
---

## Introduction

In previous posts I have covered creating [effectively multi-engine Quarto documents](https://remlapmot.github.io/post/2025/multi-engine-quarto/) and also how to use [uv virtual environments for the nbstata Jupyter kernel](https://remlapmot.github.io/post/2025/nbstata-uv-venv/) to run Quarto documents with Stata code. Hence by trivial extension we can use `uv` to run Quarto documents using the `jupyter: python3` engine.

The slight inconvenience about this approach is that you end up leaving a README or shell script with the required commands to activate the environment, install the nbstata kernel, and run Quarto. At this point I wonder if on collaborative projects at work whether I am deliberately trying to make my colleagues hate me, so I have been looking for a way to simplify this process for them.

A recent [post by Matt Dray](https://www.rostrum.blog/posts/2025-08-11-uv-standalone/) about using uv to implement self-contained Python scripts got me thinking. Could I produce a similar self-contained Python script to perform the rendering which would avoid my colleagues the trouble of activating the virtual environment etc?

## The self-contained script

I came up with the following script.

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# dependencies = [
#     "jupyterlab>=4.4.3",
#     "jupyterlab-stata-highlight2>=0.1.2",
#     "nbstata>=0.8.3",
# ]
# ///
import subprocess

cmd0 = "python -m nbstata.install --sys-prefix"
retval0 = subprocess.call(cmd0, shell=True)
print('returned value:', retval0)

cmd1  = "quarto render --profile stata-questions"
retval1 = subprocess.call(cmd1, shell=True)
print('returned value:', retval1)

cmd2  = "quarto render --profile stata-solutions"
retval2 = subprocess.call(cmd2, shell=True)
print('returned value:', retval2)
```

* The first line, the shebang ensures it is run by `uv run`
* The Python dependency libraries are declared between the
  ```python
  # /// script
  # ...
  # ///
  ```
  
  * If you don't use Stata, and only use `jupyter: python3` then you can delete the `jupyterlab-stata-highlight2` and `nbstata` entries and the first group of 3 lines for `cmd0`.
  * If you use additional Python packages in your code then you need to add them to the list.
* Then comes the actual code. These are simply system calls using the _subprocess_ module. You can amend the number of calls and the calls themselves inside the string quotes as required. 

Save the script in a file, say _render_, then make it executable with

```sh
chmod +x render
```

Then all my colleagues need to do is run it with

```sh
./render
```

Of course uv and Quarto need to be installed and be on their `PATH`. Also for running Stata code, that is required to be installed. And Windows users need to run this from a Git Bash shell rather than from Powershell or CMD shell.

If you are only using the Quarto knitr engine then you don't need this script. And I don't use the Python quarto package here as it's currently slightly too limited for my use (I'm not sure it can render profiles).

For more information about uv script, the full documentation is [here](https://docs.astral.sh/uv/guides/scripts/#creating-a-python-script).

## Summary

I have shown how to make a self-contained Python script to render Quarto documents within a uv virtual environment without having to do the leg work of creating and activating the environment yourself. Hopefully this is helpful for slightly less technical colleagues.
