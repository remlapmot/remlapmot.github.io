start:
    R -q -e "blogdown::serve_site()" &

stop:
    R -q -e "blogdown::stop_server()"

render:
    R -q -e "blogdown::build_site()"

post dir=invocation_directory():
    R -q -e "rmarkdown::render_site('{{ dir }}/index.en.Rmd', encoding = 'UTF-8')"
