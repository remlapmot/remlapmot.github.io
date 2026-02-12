---
title: "How Posit's Public Package Manager manylinux_2_28 repository can help you if your R project is stuck on Ubuntu Focal Fossa"
author: Package Build
date: '2026-02-12'
slug: manylinux-packages
categories:
  - Blog
tags:
  - R
subtitle: ''
summary: "How to use manylinux_2_28 binary packages in R running on Ubuntu Focal Fossa."
authors: []
lastmod: '2026-02-12T07:00:00+00:00'
featured: no
image:
  caption: ''
  focal_point: 'Center'
  preview_only: no
  alt_text: 'Image of inspeting the version of glibc within Ubuntu Focal Fossa.'
projects: []
toc: true
---

## Introduction

I am a massive fan of repositories making binary R packages available. This includes the canonical CRAN repositories, [r-universe](https://r-universe.dev/), [r2u](https://eddelbuettel.github.io/r2u/), and the [Posit (Public) Package Manager](https://packagemanager.posit.co/), and there are others. R-universe is outstanding because it builds binaries of GitHub only packages. The Posit Public Package Manager is outstanding due to its incredible breadth (it makes binaries for 14 Linux distros) and also its depth (its almost daily snapshotting service is remarkably useful for quickly making reproducible R environments).

Today I wanted to highlight how the manylinux_2_28 packages in the Posit Public Package Manager helped me out. Posit released this in [June 2025](https://packagemanager.posit.co/cran/__linux__/manylinux_2_28/latest). Ironically, I was using another Posit service, Posit Cloud (formerly RStudio Cloud). Within this I have quite a few projects in workspaces which are over 3 years old. Behind the scenes these are running on Ubuntu Focal Fossa Linux. I believe that if I create a new Posit Cloud RStudio project that will be running on Ubuntu Noble Numbat and so users of new projects won't need this tip.

Unfortunately, Focal Fossa is out of support (except if you have Ubuntu Pro) and hence Posit have removed their Focal repository packages from the Posit Public Package Manager, which is fair enough. Within the Posit Cloud project workspace Posit kindly make available a private version of what I think was that Focal repository. However, for reasons I don't fully understand a fair number of the packages I required weren't built as binaries.

That got me thinking, could the manylinux_2_28 packages help here? In the name the 2.28 refers to the minimum version of the glibc library that the Linux distro needs to come with. I realised that I didn't know what version of glibc Ubuntu Focal Fossa came with. A quick

```sh
ldd --version
```

revealed

```plaintext
ldd (Ubuntu GLIBC 2.31-0ubuntu9.17) 2.31
Copyright (C) 2020 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
Written by Roland McGrath and Ulrich Drepper.
```

And hence I was in luck as version 2.31 is after 2.28. Therefore, in my Posit Cloud workspace I simply switched my syntax to installing packages to

```r
install.packages(
  'tidyverse',
  repos = 'https://packagemanager.posit.co/cran/__linux__/manylinux_2_28/latest'
)
```

and all the packages came in as binaries. If you are not running this from within RStudio your syntax would need to be the following as per [the setup page](https://packagemanager.posit.co/client/#/repos/cran/setup)

```r
options(repos = 
  c(
    CRAN = sprintf("https://packagemanager.posit.co/cran/latest/bin/linux/manylinux_2_28-%s/%s",
    R.version["arch"], 
    substr(getRversion(), 1, 3))
  )
)
install.packages('tidyverse')
```

<img src="/post/2026/manylinux-packages/img/installing-manylinux-packages.png" alt="Screenshot of installing packages in a Posit Cloud RStudio project running on Ubuntu Focal Fossa." width="630" style="display: block; margin: auto;">

My other solution could have been to create a new RStudio project, which as I said would be running on Noble Numbat.

## Summary

In summary, manylinux_2_28 binary packages in the Posit Public Package Manager can be used in Ubuntu Focal Fossa. Thanks again to Posit for this great resource.
