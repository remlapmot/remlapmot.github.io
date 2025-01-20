---
title: "Fuller reproducibility in Stata ado-files and programs: setting the version and user version"
author: Tom Palmer
date: '2023-08-24'
slug: stata-reproducibility
categories:
  - Blog
tags:
  - Stata
subtitle: ''
summary: "For fuller reproducibility in Stata ado-files and programs set both the version and the user version."
authors: []
lastmod: '2023-09-10T20:43:29+01:00'
featured: no
image:
  caption: ''
  focal_point: 'Centre'
  preview_only: no
projects: []
bibliography: refs.bib
link-citations: true
toc: true
---

Most proficient Stata users have come across the `version` command. This is an incredibly powerful command, which simply by issuing say

``` stata
version 18
```

at the top of a do-file or within a program (typically in an ado-file) means that you have pretty much guaranteed your code will run in the same way when you come to run it later (most likely in a newer version of Stata). But it turns out there’s a subtle difference between issuing `version` in a do-file/interactively compared to within a program or ado-file.

Several years ago I wrote the **reffadjust** package ([Palmer et al. 2014](#ref-palmer-sj-2014)) as part of some work using random effects models ([Macdonald-Wallis et al. 2012](#ref-mcdw-sim-2012)). It has two programs `reffadjustsim` and `reffadjust4nlcom` which use the output of various random effects commands, including those from MLwiN, run from Stata using the user-written `runmlwin` command ([Leckie and Charlton 2013](#ref-leckie-jss-2013)).

The **reffadjust** package doesn’t have many users and over the years I hadn’t regularly checked if the programs were still working. But in the ado-files I had set `version 13`, which gave me some residual confidence that the programs might still work.

However, a few years ago, when I eventually did run some test code I saw that the `reffadjustsim` tests were failing for MLwiN/`runmlwin` models. I didn’t have time to investigate further at this point, and I didn’t have any intuition whether the error resulted from a change in MLwiN, `runmlwin`, or Stata.

At the beginning of this year one of my colleagues mentioned that they were using **reffadjust** in their work and had observed the same error with `reffadjustsim`. My guilt kicked in, and I eventually found some time to investigate. I discovered that since I wrote the package, Stata processes matrix row and column stripes (essentially the row and column names) in a more advanced way. This meant that the row and column stripes for covariance elements in the `e(V)` matrix (the variance-covariance matrix of parameter estimates) from MLwiN/`runmlwin` models were being renamed when I hadn’t intended them to be, which caused the error.

But wait … I had specified `version 13` at the top of my program, so why was this update in later versions of Stata taking effect?

I couldn’t work it out, so I had to ask Stata Technical Support. They were kind enough to tell me that there’s an additional method of invoking the `version` command which controls what is known as the “user version”. There are some modifications in new versions of Stata which are exempt from the basic invocation of the `version` command (but only in programs and ado-files). In do-files issuing `version` sets both the version and the user version, however, in programs and ado-files the “user version”, is set by `version #, user`, and holds these additional modifications in Stata to the required version.

Naturally, this is explained in the `version` helpfile and [manual entry](https://www.stata.com/manuals/pversion.pdf), which I admit I had not read until this point. Hence, simply editing the top of my program to

``` stata
version 13
version 13, user
```

fixed my error. So in a program or ado-file, we require both lines, whereas in a do-file we’d only require `version 13`.

We can see the different operation of `version` by the following short example.

``` stata
/* Do-file/interactive code to set both the version and the user version */
version 13
display c(version), c(userversion), c(stata_version)
// 13 13 18.5
```

``` stata
/* Ado-file/program code to set both the version and the user version */
program mytest
version 13
display c(version), c(userversion), c(stata_version)
version 13, user
display c(version), c(userversion), c(stata_version)
end

mytest
// 13 18.5 18.5
// 13 13 18.5
```

In summary, my `reffadjustsim` command works again for MLwiN/`runmlwin` models. The updated version is available from [its GitHub repo](https://github.com/remlapmot/reffadjust). And if you ever need *fuller* reproducibility in your Stata ado-file or program remember to set both the version and the user version.

## References

<div id="refs" class="references csl-bib-body hanging-indent" entry-spacing="0">

<div id="ref-leckie-jss-2013" class="csl-entry">

Leckie, George, and Chris Charlton. 2013. “<span class="nocase">runmlwin: A Program to Run the MLwiN Multilevel Modeling Software from within Stata</span>.” *Journal of Statistical Software* 52 (11): 1–40. <https://doi.org/10.18637/jss.v052.i11>.

</div>

<div id="ref-mcdw-sim-2012" class="csl-entry">

Macdonald-Wallis, Corrie, Debbie A. Lawlor, Tom Palmer, and Kate Tilling. 2012. “Multivariate Multilevel Spline Models for Parallel Growth Processes: Application to Weight and Mean Arterial Pressure in Pregnancy.” *Statistics in Medicine* 31 (26): 3147–64. <https://doi.org/doi.org/10.1002/sim.5385>.

</div>

<div id="ref-palmer-sj-2014" class="csl-entry">

Palmer, Tom M., Corrie M. Macdonald-Wallis, Debbie A. Lawlor, and Kate Tilling. 2014. “<span class="nocase">Estimating adjusted associations between random effects from multilevel models: The reffadjust package</span>.” *The Stata Journal* 14 (1): 119–40. <https://doi.org/10.1177/1536867X1401400109>.

</div>

</div>
