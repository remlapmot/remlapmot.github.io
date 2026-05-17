start:
    R -q -e "blogdown::serve_site()" &

stop:
    R -q -e "blogdown::stop_server()"
