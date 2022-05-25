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
* Serve the site as you build it (nb. just opening the `index.html` doesn't render correctly)
    ``` r
    blogdown::serve_site()
    # and then open browser at address printed in R console
    ```  
* To stop the served site run  
    ```r
    blogdown::stop_server()
    ```  
* Build site
    ``` r
    blogdown::build_site()
    # or: rmarkdown::render_site(encoding = 'UTF-8')
    ```
* This will create a directory called *public* which is rendered by GitHub Pages as https://github.com/remlapmot/remlapmot.github.io
