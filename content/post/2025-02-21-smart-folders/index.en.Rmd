---
title: "Creating a Finder Smart Folder of your RStudio Project files to enable super fast project launching"
author: Package Build
date: '2025-02-21'
slug: smart-folders
categories:
  - Blog
tags:
  - R
  - RStudio
  - Positron
  - VSCode
  - macOS
subtitle:
summary: Create a Finder Smart Folder showing all your RStudio (and/or your VSCode/Positron) project files so you can switch between your projects fast and conveniently.
authors: []
lastmod: '2025-02-21T12:00:00+00:00'
featured: no
image:
  caption: ''
  focal_point: 'Center'
  preview_only: no
  alt_text: 'Screenshot of macOS Finder window showing the saved Smart Folder of RStudio project files.'
projects: []
toc: true
---

## Introduction

When I'm switching projects I naturally start with Finder. I'm sure if I became a Terminal warrior there are faster ways of searching for files (e.g. the [Television](https://github.com/alexpasmantier/television) fuzzy finder TUI). And I know there are other ways to avoid using Finder, e.g., using Spotlight, [Alfred](https://www.alfredapp.com/), or [Raycast](https://www.raycast.com/); and indeed I do have [this fantastic tip](https://rstats.wtf/projects#tricks-for-opening-projects) that allows Alfred to find RStudio project files setup. But something to do with how I learnt to use a computer just naturally means I'm wedded to Finder, but navigating through my mess of nested directories wastes time and clicks.

I realised that Finder on macOS has a helpful feature called Smart Folders. We can use this to setup a saved search of RStudio Project _.Rproj_ files (and/or VSCode/Positron _.code-workspace_ files) to allow us to see all the _.Rproj_ files on our computer. This makes finding and opening projects from within Finder fast and convenient.

## Setting up a Smart Folder of your RStudio project files

In Finder;

* navigate to the folder you want your search to start in, either your home folder or your Documents folder are obvious candidates
* click File | New Smart Folder

<img src="/post/2025/smart-folders/img/new-smart-folder.png" alt="Screenshot of creating a new Smart Folder in macOS Finder." width="630" style="display: block; margin: auto;">

* near the top right corner click the plus button next to the _Save_ button.

<img src="/post/2025/smart-folders/img/plus-to-right-of-save.png" alt="Screenshot of creating a new condition as part for a new Smart Folder in macOS Finder." width="630" style="display: block; margin: auto;">

* we need to add the _File extension_ attribute to the choices, click _Name_ near the top left, then _Other..._

<img src="/post/2025/smart-folders/img/name-other.png" alt="Screenshot of adding a new attribute as part for a new Smart Folder in macOS Finder." width="630" style="display: block; margin: auto;">

* Then search for _File extension_ and check the box on the right handside

<img src="/post/2025/smart-folders/img/adding-file-extension-attribute.png" alt="Screenshot of adding the file extension attribute as part for a new Smart Folder in macOS Finder." width="630" style="display: block; margin: auto;">

* enter _Rproj_ in the box (it doesn't seem to matter if you include the . first)

<img src="/post/2025/smart-folders/img/entering-file-extension.png" alt="Screenshot of adding the file extension condition as part for a new Smart Folder in macOS Finder." width="630" style="display: block; margin: auto;">

* click _Save_ (near top right corner) and give it a sensible name, e.g., _Rproj.savedSearch_

<img src="/post/2025/smart-folders/img/saving.png" alt="Screenshot of saving the new Smart Folder in macOS Finder." width="630" style="display: block; margin: auto;">

And you'll see the new virtual folder appear on the left Finder sidebar - [see the screenshot at the top of this post](#top).

You can create additional Smart Folders for other useful file extensions, for example, VSCode/Positron project files (_.code-workspace_ files).

## Summary

I have shown how to create a Smart Folder of your RStudio Project files for fast and convenient project launching.
