---
title: Command line
date: 2019-02-11
template: post
---

**Command**: `pear render`

Render the site at the current working directory.

**Flags**:

* `--skip-pages`, skip pages generation. (Default = False)
* `--skip-blog`, skip blog generation. (Default = False)
* `--skip-tags`, skip tags generation. (Default = False)
* `--skip-feed`, skip atom feed generation. (Default = False)
* `--config-name=<Str>`, name of configuration file. (Default = config.yaml)
* `--feed-template=<Str>`, template for atom feed, must be located under the template directory.

**Command**: `pear serve`

Start local web server and serve rendered site.

**Flags**:

* `-p|--port=<Int>`, port in which the server should run. (Default = 3000)

**Command**: `pear watch`

Start local web server and re-render site on content/template modification.

**Flags**:

* `-p|--port=<Int>`, port in which the server should run. (Default = 3000)
* `--config-name=<Str>`, name of configuration file. (Default = config.yaml)
* `--no-livereload`, disable livereload when running pear watch. (Default = False)

**Command**: `pear -h|--help`

Display the program's usage message.
