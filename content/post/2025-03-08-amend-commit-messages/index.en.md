---
title: "Amending the Git commit message of a previous commit (that isn't the most recent) in GitHub Desktop without performing an interactive rebase"
author: Package Build
date: '2025-03-08'
slug: amend-commit-messages
categories:
  - Blog
tags:
  - Git
  - GitHub Desktop
  - R
subtitle: "A trick with an empty commit!"
summary: "How to amend previous Git commit messages, that aren't for the most recent commit, in GitHub Desktop without performing an interactive rebase."
authors: []
lastmod: '2025-03-08T12:00:00+00:00'
featured: no
image:
  caption: ''
  focal_point: 'Center'
  preview_only: no
  alt_text: 'Screenshot of dragging an empty commit onto the commit whose commit message you want to amend in GitHub Desktop.'
projects: []
toc: true
---

## Introduction

As R developers I think we can all agree that Git is hard. There won't be many of us who at some time haven't broken a Git repository in some way or other, I know that I have (several times ... ahem).

A task I sometimes need to achieve when working on a branch is amending a commit message. I use [GitHub Desktop](https://github.com/apps/desktop) to help me with Git, and I recommend it to all my students. If the commit you want to amend the message of is the most recent commit you can simply right click on it and select _Amend Commit..._.

<img src="/post/2025/amend-commit-messages/img/01-right-click-amend-commit.png" alt="Screenshot of amending a commit in GitHub Desktop." width="630" style="display: block; margin: auto;">

This is providing a user friendly interface to running

```sh
git commit --amend
```

in the terminal for us. This is all covered in the [GitHub documentation](https://docs.github.com/en/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/changing-a-commit-message).

However, what if the commit is not the most recent. If your commits after your target commit don't touch the same lines in the same file/s you could reorder your commits such that your target commit is the most recent and then right click and _Amend Commit..._ again. However, what if you can't easily or don't want to reorder your commits? At this point you might start questioning your life choices; how did I end up using the same tools as the Linux kernel developers! Anyway, the proper answer is to perform an interactive rebase, but that is relatively advanced and not without stress. Luckily I have a simple trick in GitHub Desktop to achieve our goal without performing an interactive rebase.

## The trick: squashing an empty commit onto the target commit

GitHub Desktop allows us to squash to commits together. When it does this it allows us to amend the commit message of the resulting commit. Therefore, to achieve our goal of amending previous commit messages we need to:

* Identify the commit you want to amend the message of. Here I have made a typo and want to fix the message to say _Use test-rcpp.R_

<img src="/post/2025/amend-commit-messages/img/02-commit-to-amend.png" alt="Screenshot of squashing commits GitHub Desktop." width="630" style="display: block; margin: auto;">

* Create an empty commit

  For this you will need command line [Git](https://git-scm.com/) installed (GitHub Desktop has a version of Git bundled within it, so not everyone who has GitHub Desktop installed has Git installed separately). Run the following (you don't have to include the message).
  
  ```sh
  git commit --allow-empty -m "Empty commit for purposes of trick"
  ```

* Perform a squash in GitHub Desktop by dragging and dropping the empty commit onto your target commit. See the screenshot at the [top](#top) of this post. Of course the empty commit has no content, so it does not affect the content of your target commit.

* Enter your amended commit message in the _Summary_ box and delete the text in the _Description_ box.

<img src="/post/2025/amend-commit-messages/img/06-squashing-commits.png" alt="Screenshot of squashing commits GitHub Desktop." width="630" style="display: block; margin: auto;">

* Click _Squash 2 Commits_.
  
<img src="/post/2025/amend-commit-messages/img/07-new-commit-message.png" alt="Screenshot of finalising squashed commit in GitHub Desktop." width="630" style="display: block; margin: auto;"> 

* That's it, we're finished! You can now push your branch upto GitHub (or in my case in the screenshot force push because I had previously pushed this branch to the remote).

<img src="/post/2025/amend-commit-messages/img/08-final-state.png" alt="Screenshot of your amend Git history ready to the pushed to GitHub in GitHub Desktop." width="630" style="display: block; margin: auto;">

## The proper method: performing an interactive rebase

If you want to do achieve this the proper way or amend the contents of previous commits you'll need to perform an interactive rebase. That is a little bit tricky to perform in the terminal, although there are lots of helpful YouTube videos and blogposts showing how to do it.

If you ever need to do this I recommend using the [Lazygit](https://github.com/jesseduffield/lazygit) terminal user interface, which has the best interface to interactive rebasing I've seen. To start the process, navigate to the _Reflog_ pane (by pressing <kbd>Tab</kbd> twice), then use your up and down arrows to select your target commit, and either press <kbd>r</kbd> to reword (i.e., amend the commit message) or <kbd>e</kbd> to edit the commit itself (or choose one of the other options listed at the bottom).

<img src="/post/2025/amend-commit-messages/img/09-lazygit.png" alt="Screenshot of starting to amend a commit message in the Lazygit TUI." width="630" style="display: block; margin: auto;">

## Summary

I have shown how to amend commit messages for commits that aren't the most recent commit in GitHub Desktop without performing an interactive rebase.
