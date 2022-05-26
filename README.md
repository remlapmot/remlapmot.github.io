# GitHub Pages website source code

[![Website remlapmot.github.io](https://img.shields.io/website-up-down-green-red/https/remlapmot.github.io.svg)](https://remlapmot.github.io/)

This repo contains the source files for [my GitHub Pages website](https://remlapmot.github.io) made with the [blogdown package](https://bookdown.org/yihui/blogdown/) in R.

To build the site

* Install the **blogdown** package
    ``` r
    install.packages("blogdown")
    ```
* Install Hugo
    ``` r
    blogdown::install_hugo(version = "0.92.2")
    ```
* Create a new Academic site
    ``` r
    blogdown::new_site(theme = "gcushen/hugo-academic")
    ```
* Edit the content as required
  * The text for the content is in `content/`
  * PDF files etc. are in `static/`
* Serve the site as you build it (nb. just opening `index.html` in a browser doesn't render correctly)
    ``` r
    blogdown::serve_site()
    # Then in a browser go to the address printed in R console
    ```  
* To stop the served site run  
    ```r
    blogdown::stop_server()
    ```  
* To build the site for use with GitHub Pages there are 2 choices

1. Build the site with a GitHub Action workflow, see [_blogdown.yaml_](.github/workflows/blogdown.yaml)
    * Commit _blogdown.yaml_ into the repo in the `.github/workflows` directory
    * Create a new branch called `gh-pages` and push that upto GitHub
        ```bash
        git checkout --orphan gh-pages
        git reset --hard
        git commit --allow-empty -m "Initializing gh-pages branch"
        git push origin gh-pages
        git checkout master
        ```  
    * In the repo settings enable GitHub Pages (Pages tab) and select the Source as the `gh-pages` branch with its `root/` directory
    * The GitHub Action workflow builds the site and puts those files into the `public` folder. These are then moved to the `gh-pages` branch, which GitHub Pages serves as the website.
    * Push your commits on the master branch upto GitHub, which will trigger the GHA to build the site
2. Build the site locally

    * Add the following line to _config.toml_  
        ```toml
        publishDir = "docs"
        ```  
    * This is required because GitHub Pages only allows `root/` or `docs` as its source directory on the `master` branch, i.e., the default of `public` is not allowed. Then in the repo settings change the GitHub Pages source to `docs` on the `master` branch.
    * Then build the site locally with 
        ``` r
        blogdown::build_site()
        # or: rmarkdown::render_site(encoding = 'UTF-8')
        ```  
    * This creates the `docs` directory (instead of `public`) with the contents of the site. Note, this will not render correctly when opened locally in browser because it needs a web server running. Commit the `docs` folder into the repo. Delete the `public` folder if you have previously created that.
    * Push up to GitHub
* Your site should appear at `https://GITHUB_USERNAME.github.io/`
