---
title: "Creating effectively multi-engine Quarto documents using Quarto's embed shortcode"
author: Package Build
date: '2025-02-15'
slug: multi-engine-quarto
categories:
  - Blog
tags:
  - Quarto
  - R
  - Stata
  - Python
  - Julia
  - Jupyter
subtitle: ''
summary: "Have you ever wanted to include different language engines within the same Quarto document such that the code chunks are executed when the document is rendered? I describe how to achieve this using Quarto's embed shortcode."
authors: []
lastmod: '2025-02-16T12:00:00+00:00'
featured: no
image:
  caption: ''
  focal_point: 'Center'
  preview_only: no
  alt_text: 'Screenshot of a tabset showing code and output in different languages.'
projects: []
toc: true
---

## Introduction

Have you ever needed to present the code and output for several languages in the same document or website? I work in (non-infectious disease) Epidemiology and so it is common that researchers would like to present R and Stata code in the same document. However, a Quarto document can only run a single engine. There are already several work around solutions, which include:

* writing out the different language code cells but making them unevaluated/not executed chunks (this is done alot on the [Quarto documentation website](https://quarto.org/docs/reference/)). One can also include saved plots from the different languages;
* if your document has a combination of languages from which you can call one from the other, such as using [**reticulate**](https://rstudio.github.io/reticulate/) from within R to run Python, or using [**Statamarkdown**](https://cran.r-project.org/package=Statamarkdown) from within R to run Stata, or using [**JuliaCall**](https://cran.r-project.org/package=JuliaCall) from within R to run Julia, then these can be combined in a Quarto document;
* or for some languages like R and Python we could even embed full WebAssembly implementations of the language ([WebR](https://docs.r-wasm.org/webr/latest/) and [Pyodide](https://pyodide.org/en/stable/#) respectively) within a webpage (which admittedly seems a little overkill for my work).

I've found an alternative solution allowing you to use the native engines for each language. I recently stumbled across [Quarto's embed shortcode](https://quarto.org/docs/authoring/notebook-embed.html). This allows another (or selected cells from another) Quarto document to be embedded in a Quarto document. A thought occurred to me, what if the embedded Quarto document/s used a different engine? Would that work? This isn't explicitly mentioned on the documentation page, so I gave it a go. Remarkably, the answer turns out to be that it works! Let's find out what to do.

## Using the embed shortcode to create an effectively multi-engine Quarto document

In the example below I'm using a [tabset](https://quarto.org/docs/output-formats/html-basics.html#tabsets) in a html document using the knitr engine. We embed the documents using the alternative engines for Python, Stata, and Julia using the `{{</* embed */>}}` shortcode as shown below. For each language I just show printing a string and a basic plot.


```` markdown
---
title: An effectively multi-engine Quarto document using the embed shortcode
format:
  html:
    embed-resources: true
engine: knitr
---

::: {.panel-tabset .nav-pills}
## R

```{r}
print("Hello World, from R")
```

```{r}
#| fig-align: "center"
x <- seq(-10,10, by = 0.1)
y <- x ^ 3
plot(x, y, type = "l")
```

## Python

{{</* embed python-code-using-jupyter-python3-engine.qmd echo=true */>}}

## Stata

{{</* embed stata-code-using-jupyter-nbstata-engine.qmd echo=true */>}}

## Julia

{{</* embed julia-code-using-julia-engine.qmd echo=true */>}}

:::
````

* the *python-code-using-jupyter-python3-engine.qmd* document uses the `jupyter: python3` engine ([documentation for using Python in Quarto](https://quarto.org/docs/computations/python.html));
* the *stata-code-using-jupyter-nbstata-engine.qmd* document uses the `jupyter: nbstata` engine ([documentation for nbstata](https://hugetim.github.io/nbstata/));
* and the *julia-code-using-julia-engine.qmd* uses `engine: julia`. Alternatively, it should be possible to use the [IJulia](https://julialang.github.io/IJulia.jl/stable/) Jupyter kernel ([documentation for using Julia in Quarto](https://quarto.org/docs/computations/julia.html))

Of course, I assume that you have setup each engine beforehand.

Rendering the Quarto document above results in the embedded documents being executed and embedded within it. I've included the output below (and the full source code is in [this repository](https://github.com/remlapmot/quarto-multi-engine-using-embed-example)). Click the tabs to show the code and output for each language.

<p align="center">
<iframe src="https://remlapmot.github.io/quarto-multi-engine-using-embed-example/" height="750" width="700">
</iframe>
</p>

In the code above, in each case, I embed the whole Quarto document but you can also specify a specific code block id (or if the embedded document is a Jupyter Notebook, *.ipynb* file, you can specify a cell id, label, or tag).

## Summary

I have shown how to use the Quarto embed shortcode to embed Quarto documents using alternative engines to create an effectively multi-engine Quarto document.
