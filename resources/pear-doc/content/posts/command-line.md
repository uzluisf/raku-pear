---
title: Command Line
summary: Usage of Pear in the command line.
template: post
date: 2017-10-01
---

    Usage:
      bin/pear render [--skip-pages] [--skip-blog] [--skip-tags] [--config-name=<Str>] -- Render the site.
      bin/pear serve [-p|--port=<Int>] -- Start local web server and serve rendered site.
      bin/pear watch [-p|--port=<Int>] [--no-livereload] [--config-name=<Str>] -- Start local web server and re-render site on content/template modification.

        --skip-pages           Skip pages generation. (Default = False)
        --skip-blog            Skip blog generation. (Default = False)
        --skip-tags            Skip tags generation. (Default = False)
        --config-name=<Str>    Name of configuration file. (Default = config.yaml)
        -p|--port=<Int>        Port in which the server should run. (Default = 3000)
        --no-livereload        Disable livereload when running pear watch. (Default = False)


