---
title: "Creating self-contained R scripts for rendering Quarto documents using the knitr engine – courtesy of the new R package managers ir and uvr"
author: Package Build
date: '2026-08-16'
slug: self-contained-r-script-for-quarto
categories:
  - Blog
tags:
  - ir
  - Quarto
  - R
  - R Markdown
  - rv
  - uv
  - uvr
subtitle: ''
summary: "How to create a self-contained (and optionally executable) R script, which declares the R package dependencies for rendering Quarto documents using the knitr engine. This allows non-technical users to render Quarto documents using the knitr engine without having to install the R packages themselves."
authors: []
lastmod: '2026-08-17T07:00:00+00:00'
featured: false
image:
  caption: ''
  focal_point: 'Center'
  preview_only: false
  alt_text: 'Image of a scroll, representing a script, containing the word Quarto and the R and knitr logos.'
projects: []
toc: true
---

## Introduction

In previous posts I have described how to use the self-contained Python scripts feature in the **uv** Python package manager to create virtual environments to render Quarto documents using the Jupyter [nbstata kernel](https://remlapmot.github.io/post/2025/nbstata-uv-venv/) and the [python3 kernel](https://remlapmot.github.io/post/2025/self-contained-python-script-for-quarto/). In this post I describe how to do the same for R scripts to render Quarto documents running R code using the knitr engine.

I recently discovered that there are now three uv-inspired package managers for R; [ir](https://r-lib.github.io/ir/), [uvr](https://nbafrank.github.io/uvr/), and [rv](https://a2-ai.github.io/rv-docs/) (... maybe there are more?). I will concentrate on the first two because they allow defining self-contained R scripts. I find self-contained scripts a fast and lightweight way to define project dependencies, and I very rarely require a record of the exact package versions.

In the following examples I assume we are creating an R script, _render.R_, which contains one or more calls to `quarto::quarto_render()` for a lecture or tutorial. For the dependency R packages I include the packages the document itself needs, plus the quarto and knitr packages.

## Example self-contained R script using `ir`

To define dependencies for `ir`, at the top of the script begin each comment line with `#| ` then write a list under a `packages` key as follows -- this is the list of packages I require for one of my practicals on missing data.

```r
#| packages:
#|   - gtsummary
#|   - haven
#|   - tidyverse
#|   - VIM
#|   - quarto
#|   - knitr

# Rest of R code follows ...
# ... essentially one or sometimes multiple quarto::quarto_render() calls
```

This script can be run with

```sh
ir run render.R
```

## Example self-contained R script using `uvr`

`uvr` follows the same dependency syntax as `uv`. Each line begins with a `# ` comment, and the dependencies are defined as a TOML array of strings between `# /// script` and `# ///`. So the top of our _render.R_ script looks as follows.

```r
# /// script
# dependencies = [
#   "gtsummary",
#   "haven",
#   "tidyverse",
#   "VIM",
#   "quarto",
#   "knitr",
# ]
# ///

# Rest of R code follows ...
# ... essentially one or sometimes multiple quarto::quarto_render() calls
```

This script can be run with

```sh
uvr run render.R
```

## Automation with `just` in a complex directory structure

For each course I teach I have the lecture or tutorial in a subdirectory. To run each script I could run the shell commands given above. To slightly improve efficiency I find that putting the following [justfile](https://just.systems/) at the top of the directory structure saves a bit of typing. The first recipe, `render`, uses my system R library, the others resolve packages via `ir`/`uvr`.

```makefile
render dir=invocation_directory():
    cd "{{ dir }}" && Rscript render.R

ir dir=invocation_directory():
    cd "{{ dir }}" && ir run render.R

uvr dir=invocation_directory():
    cd "{{ dir }}" && uvr run render.R
```

I can simply type `just ir` or `just uvr` to render the lecture/tutorial given whichever directory I'm in.

## Bonus 1 -- Example self-contained Quarto document using `ir`

`ir` cleverly allows us to alternatively define the dependencies within the YAML header of a Quarto document, under an `ir` key. In this case we can remove the quarto package as we might assume we'd render this document by clicking the _Render_ button in RStudio or using `quarto render ...` in the terminal.

```plaintext
---
title: My lecture/tutorial
ir:
  packages:
    - gtsummary
    - haven
    - tidyverse
    - VIM
    - knitr
---

Rest of Quarto document follows ...
```

Say this Quarto document is _tutorial.qmd_ we would then render it with

```sh
ir render tutorial.qmd
```

More details are given in the [ir Quarto docs](https://r-lib.github.io/ir/quarto.html).

## Bonus 2 -- Making the R script executable

With both [`ir`](https://r-lib.github.io/ir/run.html) and `uvr` (and indeed [`uv`](https://docs.astral.sh/uv/guides/scripts/#using-a-shebang-to-create-an-executable-file)) we can optionally make the _render.R_ script executable, say renaming to simply _render_, by adding the relevant shebang to the very top of the file.

For `ir` we add

```r
#!/usr/bin/env -S ir run
```

and for `uvr` we add

```r
#!/usr/bin/env -S uvr run
```

We then make the script executable

```sh
chmod +x render
```

and run it with

```sh
./render
```

## Summary

I have shown how to make a self-contained, and optionally executable, R script to render Quarto documents using the knitr engine which automatically manages the required R packages. This functionality is provided by both the `ir` and `uvr` R package managers. This approach would also work for RMarkdown documents (of course one would need to swap the quarto package for the rmarkdown package in the list of dependencies).
