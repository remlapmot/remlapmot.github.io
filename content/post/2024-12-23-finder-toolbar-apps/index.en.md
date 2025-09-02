---
title: 'Launch RStudio, Positron, and other Data Science apps from your Finder Toolbar'
author: Package Build
date: '2024-12-23'
slug: finder-toolbar-apps
categories:
  - Blog
tags:
  - Positron
  - R
  - RStudio
  - VSCode
  - macOS
subtitle: ''
summary: 'Create Automator Apps to launch Data Science apps open in the current Finder window on macOS.'
authors: []
lastmod: '2024-12-23T09:15:00+00:00'
featured: no
image:
  caption: ''
  focal_point: 'Center'
  preview_only: no
  alt_text: 'Screenshot of RStudio, Positron, Visual Studio Code, and R icons in Finder toolbar.'
projects: []
toc: true
---

## Introduction

Have you ever wanted to be able to quickly open a Data Science app, say RStudio Desktop or Positron in the current Finder window at the click of a button? We'll see how to achieve this by creating Automator apps. Here's a screenshot of what we'll end up with.

<img src="/post/2024/finder-toolbar-apps/img/finder-window-with-toolbar-apps.png" alt="Screenshot of a Finder window with app icons in its toolbar." width="630" style="display: block; margin: auto;">

## Creating the Automator apps

Open Automator and select _New_ then _Application_ and click _Choose_. Then in the top left search bar enter _applescript_ and drag and drop the _Run Applescript_ action onto the main window.

<img src="/post/2024/finder-toolbar-apps/img/automator-run-applescript.png" alt="Screenshot of the Automator app." width="630" style="display: block; margin: auto;">

We then need to enter the relevant AppleScript code for launching each app in the current Finder window. Currently, I use [WezTerm](https://wezfurlong.org/wezterm/) for my terminal emulator, [Zed](https://zed.dev/) as my main text editor, [RStudio Desktop](https://posit.co/products/open-source/rstudio/) for most of my R/R Markdown/Quarto coding, [Visual Studio Code](https://code.visualstudio.com/) for other text editing tasks, and I have been starting to try out [Positron](https://positron.posit.co/). My AppleScript code for each app is as follows.

### RStudio Desktop

It is worth noting that RStudio automatically detects whether there is an _.Rproj_ file in the directory and opens in project mode if one is found (note this only works if RStudio is not already open).

```applescript
on run {input, parameters}
  tell application "Finder"
    set myWin to window 1
    set thePath to (quoted form of POSIX path of (target of myWin as alias))
    do shell script "/Applications/RStudio.app/Contents/MacOS/RStudio " & thePath
  end tell
end run
```

We can create an alternative app which specifically opens RStudio project (_.Rproj_) files as follows.

```applescript
on run {input, parameters}
  tell application "Finder"
    try
      set currentFolder to (folder of window 1) as alias
      set workspaceFiles to (every file of currentFolder whose name extension is "Rproj")
      if (count of workspaceFiles) = 0 then
        set thePath to quoted form of POSIX path of (currentFolder as alias)
        do shell script "/Applications/RStudio.app/Contents/MacOS/RStudio " & thePath
      else if (count of workspaceFiles) = 1 then 
        set workspaceFile to item 1 of workspaceFiles
        set workspacePath to POSIX path of (workspaceFile as alias)
        do shell script "open -n -a RStudio " & quoted form of workspacePath
      else if (count of workspaceFiles) > 1 then 
        display dialog "Multiple Rproj files found in directory."
      end if
      on error
        display dialog "No Finder window is open."
      end try
  end tell
end run
```

### WezTerm

```applescript
on run {input, parameters}
  tell application "Finder"
    set myWin to window 1
    set thePath to (quoted form of POSIX path of (target of myWin as alias))
    do shell script "/opt/homebrew/bin/wezterm-gui start --cwd " & thePath & "&> /dev/null &"
  end tell
end run
```

### Zed

```applescript
on run {input, parameters}
  tell application "Finder"
    set myWin to window 1
    set thePath to (quoted form of POSIX path of (target of myWin as alias))
    do shell script "/usr/local/bin/zed -n " & thePath
  end tell
end run
```

### R launched in a WezTerm terminal session

```applescript
on run {input, parameters}
  tell application "Finder"
    set myWin to window 1
    set thePath to (quoted form of POSIX path of (target of myWin as alias))
    do shell script "/opt/homebrew/bin/wezterm-gui start --cwd " & thePath & " -- /usr/local/bin/R &> /dev/null &"
  end tell
end run
```

### Visual Studio Code and Positron

First enable the ability to launch these apps with `code` and `positron` from a Terminal in each app, see [here](https://code.visualstudio.com/docs/setup/mac#_launching-from-the-command-line) and [here](https://positron.posit.co/add-to-path.html). 

This script is more involved because we first check for any _.code-workspace_ files and open one if found. My AppleScript coding is not very proficient, so there may more efficient approaches to coding this. If we didn't explicitly open the _.code-workspace_ file and if one is present in the directory Visual Studio Code/Positron will detect it and pop up a dialogue box asking if we want to reopen the directory as a workspace (I just prefer to skip this step).

```applescript
on run {input, parameters}
  tell application "Finder"
    try
      set currentFolder to (folder of window 1) as alias
      set workspaceFiles to (every file of currentFolder whose name extension is "code-workspace")
      if (count of workspaceFiles) = 0 then 
        set folderPath to POSIX path of currentFolder
        do shell script "/usr/local/bin/positron -n " & quoted form of folderPath
      else if (count of workspaceFiles) = 1 then 
        set workspaceFile to item 1 of workspaceFiles
        set workspacePath to POSIX path of (workspaceFile as alias)
        do shell script "/usr/local/bin/positron -n " & quoted form of workspacePath
      else if (count of workspaceFiles) > 1 then 
        display dialog "Multiple code-workspace files found in directory."  
      end if
      on error
        display dialog "No Finder window is open."
      end try
  end tell
end run
```

(For your Visual Studio Code app simply replace `positron` with `code`.)

### Ghostty

```applescript
on run {input, parameters}
  tell application "Finder"
    set myWin to window 1
    set thePath to (quoted form of POSIX path of (target of myWin as alias))
    do shell script "open -na ghostty --args --title=ghostty-from-finder --working-directory=" & thePath
  end tell
end run
```

### Saving and adding icons

After adding the AppleScript code save each app. I call mine, e.g., _RStudio-openhere.app_.

Next it is helpful to give each app the relevant icon. To do this in Finder bring up the Info boxes for the original app and your _-openhere_ version by selecting each app and pressing <kbd>Cmd</kbd>+<kbd>I</kbd>. Next drag the large icon from the original app onto the small icon of your _-openhere_ app.

<img src="/post/2024/finder-toolbar-apps/img/updating-icon.png" alt="Screenshot of copying the Positron icon onto our openhere app." width="630" style="display: block; margin: auto;">

### Adding the apps to the Finder toolbar

Finally, we need to place shortcuts of these apps onto the Finder toolbar. To do this first hold down <kbd>Cmd</kbd> then drag the app from Finder onto the toolbar to the location you would like. On release the app should now be in the toolbar. (And to remove an icon from the toolbar, again hold <kbd>Cmd</kbd> then drag it off the toolbar.)

<img src="/post/2024/finder-toolbar-apps/img/add-app-to-toolbar.png" alt="Screenshot of moving our Positron-openhere app onto the Finder toolbar." width="630" style="display: block; margin: auto;">

## Summary

I have shown how to create Automator apps to open RStudio Desktop, Positron, and several other Data Science apps from the current Finder window.
