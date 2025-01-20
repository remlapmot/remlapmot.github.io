---
title: 'Supercharge your #rstats web searching in Google Chrome with Site Search Shortcuts'
author: Package Build
date: '2024-06-14'
slug: chrome-site-search-shortcuts
categories:
  - Blog
tags:
  - R
  - Chrome
subtitle: ''
summary: 'Google Chrome site search shortcuts for R and statistics to enable convenient #rstats web searching.'
authors: []
lastmod: '2024-06-14T09:15:00+01:00'
featured: no
image:
  caption: ''
  focal_point: 'Center'
  preview_only: no
  alt_text: 'Screenshot of a Google Chrome site search shortcut for the METACRAN CRAN mirror.'
projects: []
toc: true
---

## Introduction

Have you ever typed `Amazon` into the Google Chrome address bar and seen the address bar indicate that it's now searching the Amazon site? It turns out this is a feature in Google Chrome called site search shortcuts.

We can see what default shortcuts Chrome provides by in the Chrome address bar going to `chrome://settings/searchEngines` and scrolling to the *Site Search* section.

From here we can see that we can define our own shortcuts, so let's define some helpful ones related to R and statistics.[^1]

[^1]: I am following an excellent [blogpost](https://chromeunboxed.com/chrome-site-search-shortcuts) by Chrome Unboxed.

## Helpful Google Chrome site search shortcuts for R and statistics

[METACRAN](https://r-pkg.org/) provides several amazingly useful services around CRAN.

*  A shortcut for searching the METACRAN CRAN mirror on GitHub

```plaintext
Name: CRAN mirror on GitHub
Shortcut: @cran
URL with %s in place of query:
https://github.com/search?q=user%3Acran%20%s&ref=opensearch&type=code
```

On the Chrome settings page click add and enter the information. To use this simply type `@cran` into the address bar

<img src="/post/2024/chrome-site-search-shortcuts/img/cran-shortcut-step1.png" alt="Screenshot of a site search shortcut in the Google Chrome address bar." width="630" style="display: block; margin: auto;">

and then type your search term

<img src="/post/2024/chrome-site-search-shortcuts/img/cran-shortcut-step2.png" alt="Screenshot of a site search shortcut in the Google Chrome address bar." width="630" style="display: block; margin: auto;">

Here are some other shortcuts.

* A shortcut for searching for a package description on METACRAN

```plaintext
Name: METACRAN
Shortcut: @metacran
URL with %s in place of query:
https://r-pkg.org/search.html/?q=%s
```

* A shortcut for searching using [Rseek](https://rseek.org/)

```plaintext
Name: Rseek
Shortcut: @rseek
URL with %s in place of query:
https://rseek.org/?q=%s
```

* A shortcut for searching [R-universe](https://r-universe.dev/)

```plaintext
Name: R-universe
Shortcut: @runi
URL with %s in place of query:
https://r-universe.dev/search/?q=%s
```

* A shortcut for searching the third edition of the Oxford Dictionary of Statistics

```plaintext
Name: Oxford Dictionary of Statistics
Shortcut: @stats
URL with %s in place of query:
https://www.oxfordreference.com/search?source=%2F10.1093%2Facref%2F9780199679188.001.0001%2Facref-9780199679188&q=%s
```

And we could define many more.

## Summary

In summary we have defined several Google Chrome site search shortcuts related to R and statistics.
