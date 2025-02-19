---
title: "Creating R, Python, Stata, and Julia tutorial worksheets (with and without solutions) using Quarto"
author: Package Build
date: '2025-02-18'
slug: quarto-conditional-content
categories:
  - Blog
tags:
  - Quarto
  - R
  - R Markdown
  - Stata
  - Python
  - Julia
  - Jupyter
subtitle: 'Programmatically including conditional content for Quarto engines that allow inline code'
summary: "How to programmatically include conditional content for several Quarto engines (knitr, jupyter: python3, jupyter: nbstata, and engine: julia) using parameters or environment variables to toggle inline code to write Markdown in the Quarto documents. I use this to write exercise/tutorial documents in which a single Quarto document is used to output both the questions and solutions documents."
authors: []
lastmod: '2025-02-18T11:00:00+00:00'
featured: no
image:
  caption: ''
  focal_point: 'Center'
  preview_only: no
  alt_text: 'Screenshot of programmatically including conditional content in a Quarto document using the Jupyter python3 engine.'
projects: []
toc: true
---

## Introduction

I regularly need to produce exercises/tutorials for my students. One fantastic feature of R Markdown is that it allows me to create one R Markdown document which can be rendered to both the question document and the solutions document. This is achieved by toggling knitr chunk options such as eval, echo, and include, and using asis chunks to include the text for the solutions. I wrote a little package, [**knitexercise**](https://remlapmot.github.io/knitexercise/) to help with this.

The toggling of the knitr chunk options can be parameterised making it possible to have an R script which contains the code to conveniently produce both questions and solutions documents. An example R Markdown file, _exercise.Rmd_, might look like the following.


```` plaintext
---
title: "`r params$title`"
output: html_document
params:
  solutions: TRUE
  title: "Example exercise: Solutions"
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(include = params$solutions)
```

1. This is question 1. Which might have some R code you always want to show.

   ```{r, include=TRUE}
   # example code for the question
   ```

   ```{asis}
   Paragraph text for the solution can be kept in the document in an `asis` chunk.
   And solution R code in an `r` chunk.
   Both of these will use the `include` value from the `setup` chunk.
   ```
    
   ```{r}
   # example code for the solution
   ```

2. This is question 2 ...
````

And the rendering script might look like this.

```r
rmarkdown::render("exercise.Rmd",
  output_file = "exercise-questions",
  params = list(solutions = FALSE, title = "Example exercise: Questions")
)

rmarkdown::render("exercise.Rmd",
  output_file = "exercise-solutions"
)
```

### Inline code

Inline code has been a [feature of R Markdown](https://bookdown.org/yihui/rmarkdown-cookbook/r-code.html) for a while. Yihui Xie and Christophe Dervieux have used it to pull off some fantastic tricks. My favourite trick is using it to programmatically write out R Markdown/Markdown code within an R Markdown document when a certain condition is met.


``` plaintext
`r if (knitr::is_latex_output()) "...some_Markdown_to_include_when_rendering_to_pdf..."`
```

### The problem

R Markdown is incredibly flexible because we can include R objects as document and chunk options. When translating this to a pure Quarto version we can do this in a document using in the knitr engine using the [`! expr ...` YAML tag literal](https://quarto.org/docs/tools/rstudio.html#knitr-engine). As far as I am aware, this is not yet possible for any other Quarto engine. Despite this my aim was to see whether I could achieve parameterised conditional content inclusion/exclusion in a Quarto document using other engines.

## Programmatically including conditional content in Quarto documents

### R: knitr and Quarto

I have already shown the R Markdown approach above.

For Quarto using the knitr engine, in a blog post [Nicola Rennie](https://nrennie.rbind.io/blog/r-tutorial-worksheets-quarto/) used inline code to write out Quarto's [conditional content classes](https://quarto.org/docs/authoring/conditional.html).


``` plaintext
---
format: html
params:
  hide_answers: true
engine: knitr
---

`r if (params$hide_answers) "::: {.content-hidden}"`

Text and code for answers.

`r if (params$hide_answers) ":::"`
```

Note that if you use the curly braces around the `r` to write you inline code then you need to enclose the output string in the [`I()` function](https://quarto.org/docs/computations/inline-code.html#markdown-output) as follows. 


``` plaintext
`{r} if (params$hide_answers) I("::: {.content-hidden}")`
```

Then we can have a shell script to render our questions and solutions documents as follows.

```plaintext
quarto render exercise-r.qmd -o exercise-r-questions.html
quarto render exercise-r.qmd -P hide_answers:false -o exercise-r-solutions.html
```

### Python

I realised I could adapt Nicola Rennie's approach for other engines. For the `jupyter: python3` engine we can do so as follows, the following code uses [Quarto's parameters feature](https://quarto.org/docs/computations/parameters.html#jupyter).


```` plaintext
---
format: html
jupyter: python3
---

```{python}
#| include: false
#| tags: [parameters]
hide_answers = True
```

```{python}
#| include: false
from IPython.display import Markdown
```

`{python} Markdown("::: {.content-hidden}") if hide_answers else Markdown(" ")`

```{python}
print("Hidden in questions")
```

`{python} Markdown(":::") if hide_answers else Markdown(" ")`
````

The shell script to render our questions and solutions documents is as follows.

```plaintext
quarto render exercise-python.qmd -o exercise-python-questions.html
quarto render exercise-python.qmd -P hide_answers:False -o exercise-python-solutions.html
```

The only problem with this is that currently the Papermill output cell about the injected parameters is printed in the document. 

<img src="/post/2025/quarto-conditional-content/img/injected-parameters-cell.png" alt="Screenshot of the injected parameters cell in a Quarto document." width="630" style="display: block; margin: auto;">

In Jupyter this can apparently be suppressed by passing the `--report-mode` flag, but I couldn't work out how to do that in Quarto. I believe it will be possible to suppress this output in future versions of Quarto (I'm using the current latest release version of Quarto 1.6.40).

### Stata

The Stata case involved two additional tricks. First, the [nbstata Jupyter kernel](https://hugetim.github.io/nbstata/) allows inline code, however this must be a [`display` command](https://www.stata.com/manuals/pdisplay.pdf), so we cannot write the if statement within the inline code. I found I can overcome this by saving the different strings in scalars (because the inline code can't use local macros) at the top of the document as follows. Second, I didn't try but I suspect the nbstata kernel doesn't support parameters, and so I achieved the toggling of the code using an environmental variable, e.g. `HIDE_ANSWERS_STATA`.


```` plaintext
---
format: html
jupyter: nbstata
---

```{stata}
*| include: false
local hide_answers : env HIDE_ANSWERS_STATA
if (`hide_answers') {
    scalar hide_answers_open = "::: {.content-hidden}"
    scalar hide_answers_close = ":::"     
}
else {
    scalar hide_answers_open = " "
    scalar hide_answers_close = " "
}
```

`{stata} scalar(hide_answers_open)`

```{stata}
display "Hidden in questions"
```

`{stata} scalar(hide_answers_close)`
````

The shell script to render the documents is then as follows, here we define the environment variable before the call to `quarto`.

```plaintext
HIDE_ANSWERS_STATA=1 quarto render exercise-stata.qmd -o exercise-stata-questions.html
HIDE_ANSWERS_STATA=0 quarto render exercise-stata.qmd -o exercise-stata-solutions.html
```

### Julia

For the native Julia engine I found that Quarto's parameterisation worked and that I could avoid the inclusion of the injected parameters cell output by leaving the chunk with the `parameters` tag empty.


```` plaintext
---
format: html
engine: julia
---

```{julia}
#| tags: [parameters]
```

```{julia}
#| include: false
using Markdown
```

`{julia} hide_answers ? md"::: {.content-hidden}" : md""`

```{julia}
println("Hidden in questions")
```

`{julia} hide_answers ? md":::" : md""`
````

The shell script to render the documents is then as follows.

```plaintext
quarto render exercise-julia.qmd -P hide_answers:true -o exercise-julia-questions.html
quarto render exercise-julia.qmd -P hide_answers:false -o exercise-julia-solutions.html
```

## Problems with environment variables

I found that passing environment variables, to the `jupyter: python3` and `engine: julia` is unreliable/broken. Admittedly, I was not using Quarto in project mode with an [*_environment* file](https://quarto.org/docs/projects/environment.html), but honestly it doesn't feel to me I should need to do that for a single document. 

The problem I found was that after a first render the value of the environment variable seems to be cached within the Quarto output document and I couldn't change it on subsequent renders. I also found that using the [**dotenv** package](https://pypi.org/project/python-dotenv/) to access was broken in the same way.

For `engine: julia` I also found that passing environment variables is unreliable and like for the `jupyter: python3` engine I experienced environment variable values being stuck after the first render. However, using the Julia [**DotEnv** package](https://juliapackages.com/p/dotenv) did seem to be reliable.

## Summary

I have shown how to programmatically include conditional content for several Quarto engines (`knitr`, `jupyter: python3`, `jupyter: nbstata`, and `engine: julia`) using parameters or environment variables to toggle inline code to write Quarto Markdown in the Quarto documents. I use this to write exercise/tutorial documents in which a single Quarto document is used to output both the questions and solutions documents.
