Pear
====

Pear is a simple static site generator written in [Raku](https://raku.org/).

**NOTE**: `MODDOC.md` is generated from `doc/Pear.rakudoc` with `raku --doc=Markdown doc/Pear.rakudoc > MODDOC.md`. Any update to the module's documentation should be made to `doc/Pear.rakudoc`.

Usage
=====

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

Installation
============

From source:

    $ git clone https://github.com/hunter-classes/winter-2020-codefest-submissions-phoebe.git
    $ cd winter-2020-codefest-submissions-phoebe
    $ zef install .

Requirements and dependencies
=============================

First of all, the [Rakudo compiler](https://rakudo.org/) must be installed on the machine. As for dependencies, Pear depends on the following modules:

  * [`Template::Mustache`](https://github.com/softmoth/p6-Template-Mustache) for parsing the Mustache templates.

  * [`Text::Markdown`](https://github.com/softmoth/p6-Template-Mustache) to generate HTML from Markdown.

  * [`YAMLish`](https://github.com/Leont/yamlish) for parsing the YAML configuration file.

If not installed, all these modules will be installed automatically by `zef` during the installation of Pear. They can all be found in the Raku ecosystem at [https://modules.raku.org/](https://modules.raku.org/)

Example
=======

You can find an example website under TBD directory which can be found live at TBD.

If you'd like to generate the website under TBD, then follow this chain of commands:

    $ cd TBD
    $ pear render

Configuration
=============

The configuration for a site is controlled by the YAML file in the site's root directory. By default, it's named `config.yaml` but a new configuration file can be provided with the option `--config-name` when running `pear`.

    title: Site's title

    directories:
      templates: templates
      include:   static
      posts:     blog
      output:    public

Everything in the configuration file will be provided to the templates in the global variable `site`, except `directories`. For instance, the site's title is available as `site.title`.

Global variables
================

The following variables are made available to the templates:

  * `site`, user defined variables from `config.yaml`. By default, `site` includes the following variables:

    * `include`, list of directories under the include directory specified in the YAML configuration file.

    * `time`, the time at the moment `pear` is executed in the site's root directory.

  * `page`, information about a page. A page contains the following attribute(s):

    * `content`, the post's HTML content.

    * `posts`, list of all your posts.

  * `tags`, list of tags from the blog posts.

Other variables
---------------

The following variables are accessible via global variables:

  * `post`, information about a given post and only accessible when iterating over `posts`. A post contains the following attributes:

    * `content`, the post's HTML content (e.g., `<h2>Say's Phoebe</h2>`).

    * `url`, the post's url (e.g., `09/23/2019/dark-secondaries`).

    * `id`, the post's identifier (same as `url`).

    * `next`, the next post from current post.

    * `previous`, the previous post from current post.

    * `tags`, the tags. See `tag` for the attributes a tag holds.

    * `template`, the template with which the post is rendered. Each post must specify a template.

    * `date`, the post's date. Its format must be `yyyy-mm-dd`. Nonetheless, you can change its formatting by specifying the preferred format. Thus, there are the following possibilities:

      * `date: 2019-12-25`, left as is if not format specified in the configuration file.

      * `date: [2019-12-25, dd/mm/yyyy]`, format date according to given format. Run `pear --date-formats` to get a list of the supported formats.

    * `draft`, is the post a draft? If set to `true`, the post won't appear in the generated HTML for the site.

`date` and `draft` should be set in the post's metadata.

All the other attributes in a post's metadata will be included alongside the attributes discussed earlier. However, Pear won't mess with them. For instance, you can have `title: tHiS iS a TitlE` and `tHiS iS a TitlE` will be the post's title.

  * `tag`, information about a tag and only accessible when iterating over `tags`. A tag contains the following attributes:

    * `name`, the tag's name (e.g, `linux`).

    * `url`, the tag's url (e.g., `/tag/linux`).

    * `posts`, the list of posts using that tag.

See also
========

  * [Mustache](https://mustache.github.io/)

  * [YAML](https://yaml.org/)

Authors
=======

  * [Luis F. Uceta](https://uzluisf.gitlab.io/), [Gitlab](https://gitlab.com/uzluisf)/[Github](https://github.com/uzluisf)

  * Ivan Hinson, [Github](https://github.com/ivan-hinson)

License
=======

Pear is free software; you can redistribute it and/or modify it under the terms of the Artistic License 2.0. See the file LICENSE for details.

