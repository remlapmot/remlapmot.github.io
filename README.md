# GitHub Pages website source code

[![Website remlapmot.github.io](https://img.shields.io/website-up-down-green-red/https/remlapmot.github.io.svg)](https://remlapmot.github.io/)

This repo contains the source files and built site for my personal [website](https://remlapmot.github.io) made with the [**blogdown** package](https://bookdown.org/yihui/blogdown/) in R, Hugo, and the Academic theme.

To build the site

* Install the **blogdown** package
    ``` r
    install.packages("blogdown")
    ```
* Install Hugo
    ``` r
    blogdown::install_hugo(version = "0.99.1")
    ```
* Create a new directory called `GITHUB_USERNAME.github.io` and initialise this as a Git repo
* Within this empty repo create a new Academic site
    ``` r
    blogdown::new_site(theme = "gcushen/hugo-academic")
    ```  
    * This now downloads the contents from their new **wowchemy** repos [here](https://github.com/wowchemy/starter-hugo-academic) and [here](https://github.com/wowchemy/wowchemy-hugo-modules)
* Add an RStudio project file to the repo (run these commands within RStudio with the working directory as the repo directory)  
    ```r
    rstudioapi::initializeProject()
    rstudioapi::openProject(path = '.')
    ```  
* Edit the content as required
  * The content goes in the `content/` directory
  * PDF files etc. go in the `static/` directory
* Serve the site as you build it (nb. simply opening `index.html` in a browser doesn't render correctly because a web server is required to be running)
    ``` r
    blogdown::serve_site()
    ```  
  * In a browser go to the address printed in the R console, `http://localhost:####`
  * The locally served site will updated when you resave relevant content files
* To stop the served site run  
    ```r
    blogdown::stop_server()
    ```  
* To build the site for use with GitHub Pages there are 2 choices

1. Build the site with a GitHub Action workflow, see [`blogdown.yaml`](.github/workflows/blogdown.yaml) which is edited from the r-lib/actions version [here](https://github.com/r-lib/actions/blob/v2-branch/examples/blogdown.yaml)
    * Commit `blogdown.yaml` into the repo in the `.github/workflows` directory
    * Create a new branch called `gh-pages` and push that upto GitHub
        ```bash
        git checkout --orphan gh-pages
        git reset --hard
        git commit --allow-empty -m "Initializing gh-pages branch"
        git push origin gh-pages
        git checkout master
        ```  
    * In the repo settings enable GitHub Pages (Pages tab) and select the Source as the `gh-pages` branch from its `root/` directory
    * The GitHub Action workflow builds the site and puts those files into the `public` folder. These are then moved to the `gh-pages` branch, which GitHub Pages serves as the website.
    * Push your commits on the master branch upto GitHub, which will trigger the GHA to build the site
    * You can view the workflow on the Actions page of your repo (e.g. [here](https://github.com/remlapmot/remlapmot.github.io/actions))
2. Build the site locally
    * With earlier versions of the Academic theme add the following line to `config.toml`  
        ```toml
        publishDir = "docs"
        ```  
    * With more recent versions of theme add the following line to `config/_defaults/config.yaml`
        ```yaml
        publishdir: docs
        ```  
    * This is required because GitHub Pages only allows `root/` or `docs` as the directory for its source on the `master` branch, i.e., the default of the `public` directory is not allowed. In the repo settings change the GitHub Pages source to the `master` branch and its `docs` directory.
    * Then build the site locally with 
        ``` r
        blogdown::build_site()
        # or: rmarkdown::render_site(encoding = 'UTF-8')
        ```  
    * This creates the `docs` directory (instead of `public`) with the contents of the site. Note, this will not render correctly when opened locally in browser because it needs a web server running. Commit the `docs` folder into the repo. Delete the `public` folder if you have previously created that.
    * Push up to GitHub
* (If the _pages build and deployment_ workflow completes successfully) your site will be served at `https://GITHUB_USERNAME.github.io/`