---
title: "Running R on Windows on ARM on GitHub Actions"
author: Package Build
date: '2025-04-16'
slug: win-11-arm-gha
categories:
  - Blog
tags:
  - GitHub
  - R
  - Quarto
subtitle:
summary: "How to setup and run the AARCH64/ARM version of R on Windows on ARM on GitHub Actions"
authors: []
lastmod: '2025-04-16T07:00:00+00:00'
featured: no
image:
  caption: ''
  focal_point: 'Center'
  preview_only: no
  alt_text: 'Screenshot of the Windows on ARM runner label in a GitHub Actions workflow file.'
projects: []
toc: true
---

## Introduction

GitHub has recently announced that Windows ARM64 runners are [now available](https://github.blog/changelog/2025-04-14-windows-arm64-hosted-runners-now-available-in-public-preview/) under the `windows-11-arm` label.

I help maintain an R package, [TwoSampleMR](https://mrcieu.github.io/TwoSampleMR/), which has quite alot of users. The package is not on CRAN because several of its dependencies are only on GitHub, and for a package to be on CRAN essentially all of its dependencies must also be on CRAN. As a result I am always interested to try installing the package on new operating systems and architectures.

(In this post I will use ARM and AARCH64 interchangeably.)

## Setting up R AARCH64 on Windows on ARM

### Avoiding confusion with the default runner software

It is important to mention that the x86_64 version of R 4.4.2 and RTools44 are included in the [default software set](https://github.com/actions/runner-images/blob/main/images/windows/Windows2022-Readme.md) for the `windows-latest` GitHub Actions runner. And the directory including its binaries are on the `PATH` environment variable (specifically _C:\Program Files (x86)\R\R-4.4.2\bin\x64_). As a result if you run `R`, `Rscript`, or `R CMD batch` etc. in a shell in the runner you will obtain the x86_64 version of R (which runs under emulation on the ARM runner). Let's say this is not what we want, so to setup the ARM version of R we need to install it ourselves.

### Installing AARCH64 R and RTools45

Tomas Kalibera from the R Core Team has provided several excellent posts ([here](https://blog.r-project.org/2023/08/23/will-r-work-on-64-bit-arm-windows/index.html) and [here](https://blog.r-project.org/2024/04/23/r-on-64-bit-arm-windows/index.html)) about R for Windows on ARM, and installers for it have been available for some time.

The r-hub API does not yet provide the installer information for the AARCH64 version of R, so I came up with the following workflow file - amended from r-lib/actions to install R 4.5.0 and RTools45. Place such a (GitHub Actions workflow) file in a public GitHub repo in a _.github/workflows_ directory, and enable GitHub Actions in the repo settings.

```yaml
on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]
  workflow_dispatch:

name: Check-install-win-11-arm

permissions: read-all

jobs:
  windows-11-on-arm:
    runs-on: windows-11-arm

    name: windows-11-arm

    strategy:
      fail-fast: false

    env:
      GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}
      R_KEEP_PKG_SOURCE: yes

    steps:
      - name: Install R and RTools for Windows on ARM and install TwoSampleMR
        run: |
          $url = "https://www.r-project.org/nosvn/winutf8/aarch64/R-4-signed/R-4.5.0-aarch64.exe"
          Invoke-WebRequest -Uri "$url" -OutFile R-4.5.0-aarch64.exe -UseBasicParsing -UserAgent "NativeHost"
          Start-Process -FilePath R-4.5.0-aarch64.exe -ArgumentList "/install /norestart /verysilent /SUPPRESSMSGBOXES" -NoNewWindow -Wait
          $url = "https://cran.r-project.org/bin/windows/Rtools/rtools45/files/rtools45-aarch64-6536-6492.exe"
          Invoke-WebRequest -Uri "$url" -OutFile rtools45-aarch64-6536-6492.exe -UseBasicParsing -UserAgent "NativeHost"
          Start-Process -FilePath rtools45-aarch64-6536-6492.exe -ArgumentList "/install /norestart /verysilent /SUPPRESSMSGBOXES" -NoNewWindow -Wait
          $rscript = "C:\Program Files\R-aarch64\R-4.5.0\bin\Rscript.exe"
          $arguments = "-e", "print(R.version); # the rest of your R code goes here ..."
          & $rscript $arguments
```

Breaking down the final `steps` section of this;

* we define the url of the R 4.5.0 aarch64 installer;
* we then download the installer using `Invoke-WebRequest` (note that the default shell in Windows is Powershell);
* we then run the installer using `Start-Process`. I am not sure if I need all of the arguments I have specified here but it seems to work.
* We then do the same for RTools45.
* We then define a variable for the path to the _Rscript.exe_ binary;
* we define a variable containing the arguments we want to pass to _Rscript_;
* we then invoke _Rscript_ using our two variables and the `&` call operator.

Then we navigate to our GitHub repo and view the output in the Actions tab under the relevant run.

Of course if you want to run your own R script you'll need an initial step to checkout your repo.

To confirm that we really have launched the AARCH64 version of R we see the output of `print(R.version)` is as follows.

```r
print(R.version)
#>                _                           
#> platform       aarch64-w64-mingw32              
#> arch           aarch64                          
#> os             mingw32                          
#> crt            ucrt                             
#> system         aarch64, mingw32                 
#> status                                          
#> major          4                                
#> minor          5.0                              
#> year           2025                             
#> month          04                               
#> day            11                               
#> svn rev        88135                            
#> language       R                                
#> version.string R version 4.5.0 (2025-04-11 ucrt)
#> nickname       How About a Twenty-Six 
```

## Summary

I have shown how to install the AARCH64 version of R and RTools45 on the recently released Windows on ARM runner in GitHub Actions.

As an aside, I note that we are now in the interesting position in that GitHub Actions now has Windows, macOS, and Ubuntu Linux all available on both x86_64 and ARM architectures.
