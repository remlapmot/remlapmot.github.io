---
title: "Seven accessibility tips for Quarto and R Markdown users"
author: Package Build
date: '2025-08-15'
slug: quarto-accessibility
categories:
  - Blog
tags:
  - Quarto
  - R
  - R Markdown
subtitle: ''
summary: "Seven top tips for Quarto and R Markdown users on document accessibility, including; document format, adding alt text, creating tagged pdfs, table accessibility, different accessibility checkers, custom Word document templates, and how to upload complex html documents into Blackboard Ultra."
authors: []
lastmod: '2025-08-15T07:00:00+00:00'
featured: no
image:
  caption: ''
  focal_point: 'Center'
  preview_only: no
  alt_text: 'Screenshot of selecting the Ally Accessibility Checker within Blackboard online learning environment.'
projects: []
toc: true
---

## Introduction

When teaching, for my practicals/tutorials and for about half of my lectures I find myself preparing them using R Markdown and laterly Quarto. I enjoy preparing the material in R Markdown and Quarto because it gives me a reproducible way of regenerating my material every year and I can track changes in the Rmd/qmd files very precisely with Git.

Recently, the subject of accessibility has become more prominent within Universities. In the UK, and in many other countries, we are legally obliged to produce accessible learning materials that do not disadvantage disabled students.

My University uses Blackboard for its online learning environment (OLE)/learning management system (LMS). There are other OLEs, e.g., Moodle, Canvas, etc. They all work in essentially the same way in that they provide a website per Unit/Module/Course within a secure online system.

Every document I upload into Blackboard receives an accessibility score (out of 100%) and each module I teach receives an overall accessibility score. My University uses [Anthology Ally](https://ally.ac/) Accessibility Report to generate these scores. My university doesn't have a rule about what's an acceptable score for either a document or a course.

It turns out accessibility is sometimes abbreviated to a11y, which like k8s (for Kubernetes), is a numeronym, where the 11 stands for the 11 letters in between the starting _a_ and the ending _y_ of _accessibility_.

I should say there are many guides to accessibility for HTML documents online, and indeed for R and R Markdown there are at least two packages on CRAN, [**accessrmd**](https://cran.r-project.org/package=accessrmd) and [**accessr**](https://paulnorthrop.github.io/accessr/), addressing accessibility issues. Also I have not covered topics such as choosing an accessible color palette in say **ggplot2**.

What follows is a set of tips which help improve the accessibility score for individual documents and hence your overall module accessibility score.

## Tip 1: Replace all pdfs with docx, pptx, or html documents

For a pdf to get a high accessibility score it needs to be a special type of pdf called a 'tagged pdf', otherwise it will get a very low score (approx. 6%).

As I will show in the following tips, it is much easier to make Word, Powerpoint, and html documents accessible. If you are looking for the most effective boost to your accessibility scores simply remove all pdf documents from your site and replace them with Word, Powerpoint, or html documents.

## Tip 2: Add alt text to all figures

I guess like many R users the first I remember hearing about accessibility was that there is this thing called alt text and it's best practice for html documents to provide alt text summaries of every image they contain. Then screen readers have a description of the image for visually impaired readers.

It turns out that other types of document can also hold alt text for images; including Word, Powerpoint, and pdf documents.

Let's say we have a Quarto (or R Markdown) document which we render to docx and html output formats. To add alt text to figures in the html document we can use the `fig-alt` chunk option (`fig.alt` in R Markdown). However, it turns out that alt text for a Word document is taken from the `fig-cap` chunk option (`fig.cap` in R Markdown). Therefore, I specify both `fig-alt` and `fig-cap` chunk options in all code chunks generating figures.


```` plaintext
```{r}
#| fig-cap: Kaplan-Meier survival curve.
#| fig-alt: Plot of a Kaplan-Meier survival curve.
# code to generate plot
```
````

## Tip 3: (The surprising headache that is) Creating tagged pdfs 😬🤯

It is possible for a pdf to obtain a perfect accessibility score; but as I said above it must be a tagged pdf.

You can check if a pdf has tags by opening it in Adobe Acrobat Reader then bringing up the document properties window. The information is in the bottom left of the _Description_ tab (on Windows I found that SumatraPDF also reported that information but on macOS I found I couldn't see this reported in the Preview app).

<img src="/post/2025/quarto-accessibility/img/adobe-reader-pdf-info.png" alt="Screenshot of document properties tab in Adobe Acrobat Reader." width="550" style="display: block; margin: auto;">

It turns out that we can create tagged pdfs in a few ways; 

* by exporting a Word or Powerpoint document to pdf within those programs
  * note when exporting to pdf on macOS, users must select the _Best for electronic distribution and accessibility..._ option (the _Best for printing_ option does not generate tagged pdfs)
    <img src="/post/2025/quarto-accessibility/img/powerpoint-macos-pdf-export.png" alt="Screenshot of Powerpoint export to pdf window on macOS." width="630" style="display: block; margin: auto;">  
  * Word and Powerpoint for Windows and Word and Powerpoint online export tagged pdfs by default
* by printing html documents to pdf (Print | Save as pdf) in Chrome (and the other Chromium based browsers such as Edge)
  * In my testing I find that by default Safari and Firefox do not generate tagged pdfs
* The paid for professional version of Adobe Acrobat allows users to [add tags to pdfs](https://helpx.adobe.com/uk/acrobat/using/editing-document-structure-content-tags.html), but I don't have that, and I assuming you don't either.
* And I should note that within Blackboard itself Ally can generate a tagged pdf from Word and Powerpoint documents, under the _Download Alternative Formats_ option for a file.
  <img src="/post/2025/quarto-accessibility/img/download-alternative-formats-1.png" alt="Screenshot of selecting to download alternative document formats in Blackboard." width="630" style="display: block; margin: auto;">
  
  <img src="/post/2025/quarto-accessibility/img/download-alternative-formats-2.png" alt="Screenshot of the alternative document formats in Blackboard." width="450" style="display: block; margin: auto;">

The surprise here is that pdf documents produced by LaTeX and typst by default do not (yet) generate tagged pdfs. Therefore, do not render to `pdf`/`typst` output formats in Quarto nor `pdf_document` in R Markdown (nor `pdf_document2` in bookdown).

### Generating tagged pdfs in LaTeX

It turns out it [is possible to generate a tagged pdf from LaTeX](https://latex3.github.io/tagging-project/documentation/prototype-usage-instructions), but this is extrememly inconvenient from R Markdown and Quarto. First use Quarto/R Markdown to generate the TeX file of your document, e.g. in [Quarto specify either](https://quarto.org/docs/output-formats/pdf-basics.html#latex-output)

```yaml
format:
  pdf:
    keep-tex: true
``` 

or the latex output format.

```yaml
format:
  latex
```

You then require [the following LaTeX packages](https://tex.stackexchange.com/a/605142).

```r
tinytex::tlmgr_install(c('latex-lab', 'pdfmanagement-testphase', 'tagpdf', 'luamml'))
```

You then need to amend the very top of your TeX file to have a `\DocumentMetadata{tagging=on}` entry. And possibly using the _unicode-math_ package is helpful. The beginning of your TeX file will look like the following.

```latex
\DocumentMetadata{tagging=on}
\documentclass{article}
\usepackage{unicode-math}
\begin{document}
% the rest of your document ...
\end{document}
```

When I tried this I found that compiling with LuaLaTeX did generate a tagged pdf.

```sh
lualatex mydocument.tex
```

But I cannot face going through this hassle for every document I produce. So the slightly unexpected take home message here is that if you want to give your students a pdf document, the most convenient way to produce a tagged pdf is to render your Quarto document to docx or html and then export the pdf from within either Word or Chrome or let Ally do the conversion for you.

## Tip 4: Improving table accessibility

I find that tables generated using the Markdown syntax generate warnings in Ally Accessibility Checker. It reports it can't find the header row. However, I find that tables generated using the **gt** package, and other table packages usually pass. So I avoid creating tables using Markdown syntax.

## Tip 5: Different accessibility checkers can report different results

Microsoft has built an accessibility checker into alot of its Office suite. You can access this in Word and Powerpoint from the _Review_ tab then _Check Accessibility_.

<img src="/post/2025/quarto-accessibility/img/microsoft-ribbon-accessibility.png" alt="Screenshot of accessing the accessibility checker within Microsoft Word." width="630" style="display: block; margin: auto;">

Compared to Ally Accessibility Checker I find this checks for more conditions. For the items they both check I find that most of the time they agree. But sometimes they don't agree, e.g., the Microsoft checker reported that the slide numbers in a Powerpoint deck were ok, whereas Ally Accessibility Checker reported that they failed its colour contrast check (even though they were black text on a white slide).

## Tip 6: Improving the accessibility of custom Word document templates

If you want to use a [custom template Word document](https://bookdown.org/yihui/rmarkdown-cookbook/word-template.html) for your docx output it needs to be based on the underlying Pandoc docx template. You can obtain that by running

```sh
pandoc --print-default-data-file reference.docx > reference.docx
```

You can then adjust the formatting of the various styles in Word in the _Styles Pane_, and also if you are in the UK/EU you can amend the layout size from US Letter paper to A4.

Then run the Microsoft Accessibilty checker on this document (_Review_ tab | _Check Accessibility_) and Word will give you the option to upgrade the format of the document so that it can run, so click the _Convert_ button when prompted.

<img src="/post/2025/quarto-accessibility/img/word-accessibility-checker-convert-format.png" alt="Screenshot of Microsoft Word acccessibility checker convert document." width="350" style="display: block; margin: auto;">

Then if you've added an image to the document header you can add alt text to it. Then resave the document. Then specify the use of the reference document in your Quarto YAML header.

```yaml
format:
  docx:
    reference-doc: reference.docx
```

## Tip 7: Uploading Quarto/complex html documents into Blackboard Ultra

My university has upgraded to the latest version of Blackboard - Ultra. Prior to this upgrade I had no trouble uploading any type of document. But now if I try to upload html documents with embedded resources generated from Quarto the upload animation hangs (the 3 squares on the right of the screenshot below simply keep animating) and the file is not uploaded.

<img src="/post/2025/quarto-accessibility/img/upload-hang.png" alt="Screenshot of Blackboard file upload hanging." width="750" style="display: block; margin: auto;">

It turns out this is because Blackboard scans every document we upload, which it calls its content sanitization check. For some reason Quarto html documents, including revealjs html slide decks, are now too complex and fail this check. Annoyingly, Blackboard does not emit any error message to tell us this. However, there is a workaround.

* First, put your html file into a zip archive
* Then from within your module site, go to _Content Collection_ when adding an item
  <img src="/post/2025/quarto-accessibility/img/add-course-content-from-within-site.png" alt="Screenshot of selecting Course Content in Blackboard whn uploading a file." width="630" style="display: block; margin: auto;">
* Then select _Upload_ | _Upload Zip Package_ (choosing any other option will fail)
  <img src="/post/2025/quarto-accessibility/img/blackboard-upload-zip-package.png" alt="Screenshot of uploading a zip package of a Quarto html file." width="630" style="display: block; margin: auto;">
* Make sure to select the button to overwrite an existing file with the same name
* And click _Submit_ and that's it.

This is the only way I can find to bypass the content sanitization check. Note if you attempt to upload the zip archive from your _Content Collection_ accessed not from within the course site - as per screenshot below (don't go here!) - the upload will also fail (confusing I know!).

<img src="/post/2025/quarto-accessibility/img/blackboard-content-collection.png" alt="Screenshot of Blackboard Content Collection selection not from within a course." width="750" style="display: block; margin: auto;">

## Summary

I have described 7 hopefully helpful tips about how to improve the accessibility scores for documents produced from Quarto and R Markdown. Using these tips I have increased the accessibility score for my module from 67% for last year's site to 98% for this year's site.

<img src="/post/2025/quarto-accessibility/img/summary-score.png" alt="Screenshot of Ally Accessibility Checker summary score for my module within Blackboard online learning environment." width="630" style="display: block; margin: auto;">

I hope that you have similar success.
