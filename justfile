start:
    Rscript -e "blogdown::serve_site()" &

stop:
    pkill -f "[h]ugo server" || true

render:
    Rscript -e "blogdown::build_site()"

post dir=invocation_directory():
    Rscript -e "rmarkdown::render_site('{{ dir }}/index.en.Rmd', encoding = 'UTF-8')"
