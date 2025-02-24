---
title: "Checking your R packages and practicals on a schedule using GitHub Actions"
author: Package Build
date: '2025-02-24'
slug: checking-packages-and-practicals
categories:
  - Blog
tags:
  - R
  - R Markdown
  - Quarto
  - GitHub
  - GitHub Actions
subtitle:
summary: How to setup automated checks on a repository containing an R package or R practical using GitHub Actions.
authors: []
lastmod: '2025-02-24T08:00:00+00:00'
featured: no
image:
  caption: ''
  focal_point: 'Center'
  preview_only: no
  alt_text: 'Screenshot of '
projects: []
toc: true
---

## Introduction

Do you have a R package that's just on GitHub? How often do you check it? CRAN follows a rolling release model, so any day one of your package's dependency packages could be updated - breaking your package!

Or maybe you teach a course that runs once a year and it has some R practical sessions? It can be very frustrating when you rerun your practical after a year to find that several of the R packages it uses have been updated, and now you have to work out how to fix things. For this situation we might use [**renv**](https://rstudio.github.io/renv/index.html) to record the packages and their versions. But then your course participants will need to use **renv** which might lead to a room full of 30 students all having **renv** problems. Alternatively, you might install all your packages from a single date, meaning you can restore them using the a snapshot date from the [Public Posit Package Manager](https://packagemanager.posit.co/client/#/repos/cran/setup) but you might find your course participants wondering why you use packages that are a year out of date. Another superb solution is to provide course participants with an R environment you have defined and tested your practical works in. Such a solution is offered by creating the practical as a project in a [Posit Cloud](https://posit.cloud/) workspace, indeed Posit Cloud is so good it almost makes running R practicals boring.

My solution to these problems is to regularly run `R CMD check` on your package/run your practical with the latest versions of the required packages throughout the year. This way you'll hopefully pick up any changes in dependency packages long before the next running of your course (although you might still be unlucky).

If I had a server I could suggest setting up a [`cron`](https://linux.die.net/man/8/cron) job to check the package or practical. However, most of us don't have a server. Luckily if your package or practical is in a public GitHub repository then we can run GitHub Actions on it. It turns out GitHub Actions has a [scheduling facility that uses `cron` syntax](https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows#schedule).

Next I'll show how to run R code on a schedule on GitHub Actions for these two cases.

## Checking packages on a schedule

I use the actions and example workflows from the [r-lib/actions](https://github.com/r-lib/actions) repository. For checking a package there are several examples, in the _examples_ directory of that repository, that we can copy then amend. Let's use the [check-full.yaml](https://github.com/r-lib/actions/blob/v2-branch/examples/check-full.yaml) example.

Copy this file into a _.github/workflows_ directory in the repository for your package. Now we need to enable scheduled running. Amend the first `on:` block to include the two lines I have inserted below.

```yaml
on:
  ...
  schedule:
    - cron: "00 9 * * TUE"
```

What does this syntax mean? Luckily there are many websites which will decipher that for us, such as [crontab guru](https://crontab.guru/). (Nb. you can see a full version of this file in [one of my repositories](https://github.com/remlapmot/OneSampleMR/blob/main/.github/workflows/R-CMD-check.yaml).)

<img src="/post/2025/checking-packages-and-practicals/img/cron-tab-guru-screenshot.png" alt="Screenshot from the crontab guru website." width="630" style="display: block; margin: auto;">

From the crontab guru screenshot above, we see this means run at 9:00 am (UTC) on Tuesdays. Once you have committed this file to your repo and pushed it to GitHub on your main/master branch then your automated checking is taken care of. If a check fails GitHub will send a notification and you can then investigate further.

## Running practicals on a schedule

Let's say we have prepared a practical worksheet in a Quarto document. In this case we'll additionally use the actions and examples in the [quarto-dev/quarto-actions](https://github.com/quarto-dev/quarto-actions) repository.

The workflow file I ended up with is shown below and is in this [example repository](https://github.com/remlapmot/example-exercise-to-run-on-schedule). It is essentially an amended version of the [R Markdown rendering example in r-lib/actions](https://github.com/r-lib/actions/blob/v2-branch/examples/render-rmarkdown.yaml).

```yaml
on:
  push:
    branches:
      - main
  workflow_dispatch:
  schedule:
    - cron: "0 0 1 * *" # run on 1st day of month

name: Render

permissions: 
  contents: write

jobs:
  build-deploy:
    runs-on: ${{ matrix.config.os }}
    
    name: ${{ matrix.config.os }}

    strategy:
      fail-fast: false
      max-parallel: 1
      matrix:
        config:
          - { os: macos-latest }
          - { os: windows-latest }
          - { os: ubuntu-latest }
    
    env:
      GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}
    
    steps:
      - name: Check out repository
        uses: actions/checkout@v4
        
      - name: Setup R
        uses: r-lib/actions/setup-r@v2

      - name: Set up Quarto
        uses: quarto-dev/quarto-actions/setup@v2

      - name: Setup R packages
        uses: r-lib/actions/setup-r-dependencies@v2
        with:
          upgrade: 'TRUE'

      - name: Render practical and commit output documents into repo
        shell: bash
        run: |
          # Render questions
          Rscript -e 'quarto::quarto_render("exercise-01.qmd", output_file = "exercise-01-questions-${{ matrix.config.os }}.html", execute_params = list(solutions = FALSE, title = "Example exercise: Questions"))'
          # Render solutions
          Rscript -e 'quarto::quarto_render("exercise-01.qmd", output_file = "exercise-01-solutions-${{ matrix.config.os }}.html")'
          # Commit output documents
          git config --local user.name $GITHUB_ACTOR
          git config --local user.email $GITHUB_ACTOR@users.noreply.github.com
          git pull
          git add "*.html"
          git commit * -m "Render practical on ${{ matrix.config.os }}" || echo 'No changes to commit'
          git push origin || echo 'No changes to commit'
```

Crikey, that's alot, let's break that down.

* The `on:` section defines this will run
  * on pushes to the main branch,
  * if the workflow dispatch button is clicked in the GitHub interface,
  * and once per month (at midnight on the first day on the month) as defined by our `cron` syntax
* The `jobs:` section specifies
  * we will run this on 3 different operating systems, Windows (most of my students/course participants have Windows laptops, followed by macOS), macOS, and Ubuntu Linux. [More info about GitHub Actions runners is available](https://docs.github.com/en/actions/using-github-hosted-runners/using-github-hosted-runners/about-github-hosted-runners);
  * `max-parallel: 1` says that each job will run in turn (this isn't really needed but just to be safe since I will commit the output documents back into the repository)
  * `env:` specifies that we grant the jobs permission with out GitHub token
  * `steps:` defines what will run, which is
    * we checkout the repo
    * we then install R and Quarto using the relevant actions
    * we setup the R dependency packages. I am not using **renv**, so the action knows how to do this because I have included a _DESCRIPTION_ file in the repo (to the action we are faking that the repo is an R package - this is a trick from Hadley Wickham). The [full file is in the repository](https://github.com/remlapmot/example-exercise-to-run-on-schedule/blob/main/DESCRIPTION) but the key entry is the _Imports_ list of hard depdenency packages.

      ```plaintext
      ...
      Imports:
          knitr,
          quarto,
          sessioninfo
      ...
      ```
   * we specify `upgrade: 'TRUE'` to always install the latest version of the dependency packages.
   * then we finally render the two versions of our Quarto document. Here we append the operating system name into the output document filenames and we commit these files back into the repository for our records. We have to specify `shell: bash` because otherwise the Windows runner will use Powershell and the environment variable syntax in the `git config` commands would be incorrect. Also we need a `git pull` before making the commit because we have 3 jobs running in series, so there will new/amended files in the repo after the first and second jobs.

Phew!

It's worth pointing out that instead of a Quarto document our practical could be in an R Markdown document or an R script (we'd just need to make the relevant changes in the workflow file above such as adding Pandoc and amending the render commands).

Note, GitHub Actions only works for free in a public repository; so obviously this can't be used for any material that is assessed.

## Surprise benefits

A nice side effect of using the `r-lib/actions/setup-r` and `quarto-dev/quarto-actions/setup` actions is that they update to the release version of R/Quarto as updates are released. So you don't have to worry about updating the version of R/Quarto.

## GitHub Actions woes

At this point I acknowledge that sometimes GitHub Actions can be more trouble than they are worth. This is because they often fail for reasons which are not problems with your code. For example, I had one repository in which the Windows runner would regularly lose internet connection (I have no idea why) half way through installing the R dependency packages and hence would regularly notify me of a failed check. Also you need to keep the code in your workflow file up-to-date. Usually a quick comparison to the current version of the example in the r-lib/actions repo is enough to show you what you need to change.

## Summary

I have shown how to use GitHub Actions scheduling feature to automatically run scheduled checks on R packages and R scripts/R Markdown/Quarto documents for practicals enabling you to keep on top of any changes in your dependency packages and indeed in any changes in the release version of R itself.
