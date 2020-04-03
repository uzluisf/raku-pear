# Pear

Pear is a simple static site generator written in [Raku](https://raku.org/). It
uses [Mustache](https://mustache.github.io/) for its templating.

# Installation

From source:

```
$ git clone https://github.com/uzluisf/pear-raku.git
$ cd pear-raku
$ zef install .
```

# Getting started

After installing Pear, give the
[quickstart](https://uzluisf.github.io/pear-doc/docs/quickstart/) and related
pages a read. The source for the documentation (and demo) site can be found at
https://github.com/uzluisf/pear-doc.

Alternatively, after cloning/downloading the repo you can follow the following
command to generate the documentation site:

```
$ cd raku-pear/resources/pear-doc/
$ pear render
$ pear serve
```

These are the same source files at Github
[uzluisf/pear-doc](https://github.com/uzluisf/pear-doc) so you might need to
change the base-url in the config file to `/` (e.g., `base-url: "/"`) in order
to serve the generated site locally.

# Requirements and dependencies

First of all, the [Rakudo compiler](https://rakudo.org/) must be installed on
the machine. As for dependencies, Pear depends directly on the following
modules:

* [`Template::Mustache`](https://github.com/softmoth/p6-Template-Mustache) for
  parsing the Mustache templates.

* [`Text::Markdown`](https://github.com/softmoth/p6-Template-Mustache) to
  generate HTML from Markdown.

* [`YAMLish`](https://github.com/Leont/yamlish) for parsing the YAML
  configuration file.

* [`Log`](https://github.com/whity/perl6-log) for logging messages while Pear is
  running.

* [`HTTP::Server::Tiny`](https://github.com/tokuhirom/p6-HTTP-Server-Tiny) for
  the server functionality.

If not installed, all these modules will be installed automatically by `zef`
during the installation of Pear. They can all be found in the Raku ecosystem at
[https://modules.raku.org/](https://modules.raku.org/)

# See also

* [Mustache](https://mustache.github.io/)

* [YAML](https://yaml.org/)

# Authors

* [Luis F. Uceta](https://uzluisf.gitlab.io/)

* Ivan Hinson, [Github](https://github.com/ivan-hinson)

# License

Pear is free software; you can redistribute it and/or modify it under the terms
of the Artistic License 2.0. See the file LICENSE for details.