---
title: "Speeding up Stan model builds for R package developers"
author: Tom Palmer
date: '2026-05-26'
slug: stan-compile-speedup
categories:
  - Blog
tags:
  - R
  - Stan
subtitle: ''
summary: "Tips to help speed up Stan model compilation times in R packages, including; setting MAKEFLAGS, using ccache, and using clang."
lastmod: '2026-05-26T15:00:00+00:00'
featured: false
image:
  caption: ''
  focal_point: 'Center'
  preview_only: false
  alt_text: '...'
projects: []
toc: true
---

## Introduction

In my previous job my work computer was a Windows desktop -- yes, those were the days before laptops and hotdesking!

My PhD student was interested in Bayesian methods and we put together an R package which included some [Stan](https://mc-stan.org/) models. I was always frustrated by how slowly these compiled on our Windows machines. A few years later, when I got a MacBook Air I was shocked how much faster they compiled.

On my Windows machine our [mrbayes](https://okezie94.github.io/mrbayes/) package takes 3 minutes 55 seconds to compile and install. On my M4 MacBook Air it takes 1 minute 16 seconds.

The following tips show how to improve those timings.

To generate the timings I used

```sh
time R CMD INSTALL --preclean .
```

## Big win 1: Enable parallel compilations with the `MAKEFLAGS` environment variable

Set the `MAKEFLAGS` environment variable in your _~/.Renviron_ file. This controls how many `make` jobs run concurrently. Choose a number no larger than the number of processing cores your machine has. To find this run

```sh
# Windows - in a Git Bash shell
echo $NUMBER_OF_PROCESSORS
```

```sh
# macOS
sysctl -n hw.logicalcpu
```

```sh
# Ubuntu Linux
nproc
```

A reasonable starting point is your core count, or a few fewer to leave headroom for whatever else you're doing during a compilation. For example,

```sh
# In ~/.Renviron
MAKEFLAGS=-j6
```

Close and restart R/RStudio after making this change.

On my Windows machine this reduced the build from 3:55 to 1:15. To find your own sweet spot empirically, see the example at the end of Big win 2.

## Big win 2: Enable C/C++ compiler cache using `ccache`

Install [`ccache`](https://ccache.dev/), I find it easiest to use a package manager, e.g.,

```sh
# macOS
brew install ccache
```

```sh
# Ubuntu/Debian Linux
apt install ccache
```

```sh
# Windows
winget install ccache
```

Whichever installation method you use make sure `ccache` is on your `PATH` after installation. You can test with, say,

```sh
ccache --version
```

To enable `ccache`, on macOS and Linux this goes in _~/.R/Makevars_; on Windows it's _~/.R/Makevars.win_ (create the directory and file if they don't exist), set

```sh
# macOS
CC = ccache clang
CXX = ccache clang++
CXX17 = ccache clang++
```

```sh
# Windows and Linux
# Most Linux users will be on gcc by default
# Change to clang if you're using that
CC = ccache gcc
CXX = ccache g++
CXX17 = ccache g++
```

After a first compilation run for the cache to be generated, subsequent compilations are much faster. 

* Windows, second compilation: 18 seconds
* M4 MacBook Air, second compilation: 5 seconds

Perhaps more importantly, if, say, your package has 5 models and you only amend the code for one of them, `ccache` knows to use the cache for the 4 unchanged models.

* Windows, second compilation, only 1 model edited: 1 minute 10 seconds
* M4 MacBook Air, second compilation, only 1 model edited: 19 seconds

You can verify `ccache` is working, by observing the timing decrease and by checking the output of

```sh
ccache -s
```

It is also useful to zero the ccache statistics before a timing run with

```sh
ccache -z
```

### Testing which of your models takes the longest to compile

Here's a quick script to test which model takes the longest to compile. Save it as say _test.sh_ at the top level of your repo and add `^test\.sh$` to your _.Rbuildignore_ file (to avoid an `R CMD check` NOTE about unknown files at the top level).

```sh
for model in inst/stan/*.stan; do
  cp "$model" "$model.bak"
  # Insert at the top of the file
  sed -i "1i // benchmark $(date +%s%N)" "$model"
  ccache -z
  SECONDS=0
  R CMD INSTALL --preclean . >/dev/null 2>&1
  echo "$(basename $model): ${SECONDS}s"
  ccache -s | grep -E "Hits|Misses" | head -2
  mv "$model.bak" "$model"
done
```

### Finding your `MAKEFLAGS` sweet spot

With `ccache` installed you can now benchmark different `-jN` values cleanly (the `ccache -C` calls ensure each run is a cold compile, so you measure raw compilation cost rather than cache hits). You can increase the number sequence up to the number of processing cores your machine has.

```sh
for j in 1 2 3 4 6 8 10; do
  ccache -C >/dev/null
  echo "=== -j$j ==="
  SECONDS=0
  MAKEFLAGS=-j$j R CMD INSTALL --preclean . >/dev/null 2>&1
  echo "elapsed: ${SECONDS}s"
done
```

The timings on my MacBook Air were

```plaintext
=== -j1 ===
elapsed: 76s
=== -j2 ===
elapsed: 48s
=== -j3 ===
elapsed: 35s
=== -j4 ===
elapsed: 36s
=== -j6 ===
elapsed: 27s
=== -j8 ===
elapsed: 27s
=== -j10 ===
elapsed: 28s
```

My MacBook Air has 10 cores, but only 4 of those are performance cores, so I settled on `-j6` as that is where my timings plateaued — and it leaves headroom for me inevitably checking my email during a compilation.

## Big win 3: Combining these in GitHub Actions workflows

In my _.github/workflows/R-CMD-check.yaml_ I have steps for these speedups. Firstly, to set `MAKEFLAGS`.

```yaml
      - name: Set parallel compilation flags (Linux and macOS)
        if: runner.os != 'Windows'
        shell: bash
        run: |
          NCPUS=$(nproc 2>/dev/null || sysctl -n hw.logicalcpu)
          echo "Detected ${NCPUS} processors"
          echo "MAKEFLAGS=-j${NCPUS}" >> ~/.Renviron

      - name: Set parallel compilation flags (Windows)
        if: runner.os == 'Windows'
        shell: pwsh
        run: |
          Write-Output "Detected $env:NUMBER_OF_PROCESSORS processors"
          Add-Content -Path "$HOME\.Renviron" -Value "MAKEFLAGS=-j$env:NUMBER_OF_PROCESSORS"
```

You can also use ccache in GitHub Actions, as follows:

```yaml
      # ccache speeds up Stan model compilation dramatically on warm cache.
      # Note: Windows support via ccache-action is documented as "probably works"
      # rather than fully stable; if it causes issues, scope this step to non-Windows.
      - name: Setup ccache
        uses: hendrikmuhs/ccache-action@v1.2.23
        with:
          # Key invalidates when Stan models or DESCRIPTION change.
          # Older caches partially seed new ones via restore-keys.
          key: ccache-${{ matrix.config.os }}-R-${{ matrix.config.r }}-${{ hashFiles('inst/stan/**/*.stan', 'DESCRIPTION') }}
          restore-keys: |
            ccache-${{ matrix.config.os }}-R-${{ matrix.config.r }}-
            ccache-${{ matrix.config.os }}-R-
          max-size: "2G"

      - name: Configure R to use ccache (Linux and macOS)
        if: runner.os != 'Windows'
        shell: bash
        run: |
          mkdir -p ~/.R
          if [ "$RUNNER_OS" = "macOS" ]; then
            cat >> ~/.R/Makevars <<'EOF'
          CC = ccache clang
          CXX = ccache clang++
          CXX14 = ccache clang++
          CXX17 = ccache clang++
          CXX20 = ccache clang++
          EOF
          else
            cat >> ~/.R/Makevars <<'EOF'
          CC = ccache gcc
          CXX = ccache g++
          CXX14 = ccache g++
          CXX17 = ccache g++
          CXX20 = ccache g++
          EOF
          fi
          echo "--- ~/.R/Makevars ---"
          cat ~/.R/Makevars

      - name: Configure R to use ccache (Windows)
        if: runner.os == 'Windows'
        shell: pwsh
        run: |
          New-Item -ItemType Directory -Force -Path "$HOME\.R" | Out-Null
          $makevars = @"
          CC = ccache gcc
          CXX = ccache g++
          CXX14 = ccache g++
          CXX17 = ccache g++
          CXX20 = ccache g++
          "@
          Add-Content -Path "$HOME\.R\Makevars.win" -Value $makevars
          Write-Output "--- ~/.R/Makevars.win ---"
          Get-Content "$HOME\.R\Makevars.win"
```

You can see the [full file in my repo](https://github.com/okezie94/mrbayes/blob/master/.github/workflows/R-CMD-check.yaml).

This reduced my ubuntu-latest run for r-release from 7 minutes 30 seconds to 4 minutes 49 seconds.

## Big win 4: Switch to `clang`

I found that switching from `gcc` to `clang` gives a noticeable speedup; the single core compile time dropped from 3 minutes 55 seconds to 3 minutes flat on my Windows machine.

To do this you need to install `clang`. On Windows you install `clang` within RTools45 — more involved than on Linux, but doable.

```sh
# Windows within RTools45 Bash shell
# Launch C:\rtools45\ucrt64.exe
# You may need to close and reopen the shell after the first command
pacman -Syu
pacman -S mingw-w64-ucrt-x86_64-clang
```

```sh
# Ubuntu/Debian Linux
sudo apt install clang
```

At this point on Windows running

```sh
which clang
```

should return `/ucrt/bin/clang`.

Switch to `clang` in _~/.R/Makevars_ (if you're not using `ccache` delete that prefix)

```sh
# On Linux
CC = ccache clang
CXX = ccache clang++
CXX14 = ccache clang++
CXX17 = ccache clang++
CXX20 = ccache clang++
```

and in _~/.R/Makevars.win_ on Windows

```sh
# On Windows
CC = ccache C:/rtools45/ucrt64/bin/clang.exe
CXX = ccache C:/rtools45/ucrt64/bin/clang++.exe
CXX17 = ccache C:/rtools45/ucrt64/bin/clang++.exe
```

Windows users will need to add the following to `PATH`

```plaintext
C:\rtools45\ucrt64\bin
C:\rtools45\usr\bin
```

You can verify things are working by running

```sh
R CMD config CXX17
```

I believe you need `clang` version 18 or later to see the speedups.

## Small win 1: WSL users should use the native file system

Within WSL it is possible to access files from within its native Linux filesystem, i.e., within `/home/user/...`, and also on the Windows filesystem, e.g., in `/mnt/c/...`. I believe file operations are noticeably faster within `/home/user/...`.

## Naive guesses that made no difference

I had wondered whether running a non-debug compilation with say

```r
pkgbuild::compile_dll(debug = FALSE)
```

would speed things up. It turns out it does not. For Stan models, most of the time is spent in C++ template instantiation by the compiler, not in optimisation passes — so disabling debug flags or lowering the optimisation level barely helps.

I also wondered whether using R on Windows Subsystem for Linux would speed things up just by virtue of being on Linux. It did not, timings using `gcc` on Windows and WSL Ubuntu were essentially identical. The advantage of using WSL is that it is easier to switch to using `clang` on Linux.

## (Money no object) Big win 5: Switch to an Apple Silicon Mac

Apple silicon Macs have excellent single threaded performance, their unified memory architecture has very high bandwidth, they have large L1 and L2 caches, and fast NVMe SSDs. Together these produce very fast Stan model compilation times, even on the lowest end Apple Silicon Macs.

## Summary

In summary, five big wins and one small win for speeding up Stan model compilation in R packages.
