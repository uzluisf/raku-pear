Pear
====

Pear is a simple static site generator written in [Raku](https://raku.org/).

**NOTE**: `MODDOC.md` is generated from `doc/Pear.rakudoc` with `raku --doc=Markdown doc/Pear.rakudoc > MODDOC.md`. Any update to the module's documentation should be made to `doc/Pear.rakudoc`.

Synopsis
========

Usage
=====

    $

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

The configurations for a site are controlled by the YAML file in the site's root directory.

Authors
=======

  * [Luis F. Uceta](https://uzluisf.gitlab.io/), [Gitlab](https://gitlab.com/uzluisf)/[Github](https://github.com/uzluisf)

  * Ivan Hinson, [Github](https://github.com/ivan-hinson)

License
=======

Pear is free software; you can redistribute it and/or modify it under the terms of the Artistic License 2.0. See the file LICENSE for details.

