---
title: "How to widen the accordion on a Blackboard page"
author: Package Build
date: '2025-05-30'
slug: blackboard-accordion
categories:
  - Blog
tags:
  - Blackboard
  - HTML
  - CSS
subtitle:
summary: "How to make the accordion element on a Blackboard webpage wider."
authors: []
lastmod: '2025-05-30T10:00:00+00:00'
featured: no
image:
  caption: ''
  focal_point: 'Center'
  preview_only: no
  alt_text: 'TODO:Alt text!.'
projects: []
toc: true
---

## Introduction

My university uses the Blackboard online learning environment (there are others, e.g., Moodle and Canvas, etc.). On several of the Unit (aka Module) and short course sites we have an accordion containing the table with the timetable of the teaching. Unfortunately I find the default width too narrow.

<img src="/post/2025/blackboard-accordion/img/accordion-expanded.png" alt="Screenshot of expanded accordion." width="630" style="display: block; margin: auto;">

This post shows how to make this accordion element wider.

## Widening the accordion

First we need to work out what type of element it is. To do this in Google Chrome right click on a part of the accordion and click _Inspect_.

<img src="/post/2025/blackboard-accordion/img/devtools-inspect.png" alt="Screenshot of expanded accordion." width="630" style="display: block; margin: auto;">

We can see that the accordion is a div of class deo-accordion. And we can see that it's `max-width` is currently set to 40em which is 640 pixels.

Therefore to modify this we need to write the CSS for this with a larger `max-width`. It turns out Blackboard does not allow us to put CSS in a `<style>` tag directly in a component's source code. Therefore, we put the following in a file called _mystyles.css_. The 60em is equivalent to 960 pixels.

```css
.deo-accordion {
  max-width: 60em;
}
```

We then upload this file to our Blackboard site's _Content_ area. Once uploaded we obtain the _Permanent URL_ of the file by clicking the dropdown arrow to the right of the filename and selecting _360° View_. Copy the permanent URL to the clipboard.

<img src="/post/2025/blackboard-accordion/img/360-degree-view.png" alt="Screenshot of 360° View of our CSS file." width="630" style="display: block; margin: auto;">

Within the content of the item on your Blackboard page which contains the accordion, click edit, then click the `<>` symbol to enter editing source code mode. At the bottom of the code enter the following line -- replacing the `PERMANENT_URL` with what we just copied and save the changes.

```html
<link href="PERMANENT_URL" rel="stylesheet">
```

And you should find that you have a wider accordion.

<img src="/post/2025/blackboard-accordion/img/wider-accordion.png" alt="Screenshot of 360° View of our CSS file." width="630" style="display: block; margin: auto;">

## Summary

I have shown how to widen the accordion on a Blackboard page with some simple CSS.
