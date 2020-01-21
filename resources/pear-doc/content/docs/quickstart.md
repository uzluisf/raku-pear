---
title: 'Quickstart'
date: 2000-01-05
template: post
---

The goal of this guide is to get you up and running quickly with Pear.

# Installation

For now, Pear must be installed from source. To install from source, follow
these commands:

```
$ git clone https://github.com/hunter-classes/winter-2020-codefest-submissions-phoebe.git
$ cd winter-2020-codefest-submissions-phoebe
$ zef install .
```

After Pear has been installed, run `pear` to confirm everything completed
successfully. If everything went fine, then the usage message should be printed
to the terminal. You can also display the usage message with `pear --help`.


# Directory structure

## The content directory

The content directory is where all the documents (posts, other pages, etc.)
for the website live. Under this directory, Pear recognizes anything under
a `posts` directory as a post. Everything else is a page which include
files and other directories directly under the content directory.

It's specified as `content: your-content-dir` in the YAML configuration file.
See [Config](https://uzluisf.github.io/pear-doc/docs/config/) for more information.

## The template directory

The template directory is used to store the Mustache templates. This directory
must contain a directory named `partials` which contains the partial templates.

It's specified as `template: your-template-dir` in the YAML configuration file.
See [Config](https://uzluisf.github.io/pear-doc/docs/config/) for more information.

## The include directory

The include directory is used for all the static files such as images, CSS
files, JS files, etc.

It's specified as `template: your-include-dir` in the YAML configuration file.
See [Config](https://uzluisf.github.io/pear-doc/docs/config/) for more information.

It's worth noting that regardless how the include directory is named, Pear
always makes it available to the templates in the global variable `site`
as `site.include`. See [Templates](https://uzluisf.github.io/pear-doc/docs/templates/)
for more information.

## The output directory

The output directory contains the generated HTML for the site.

It's specified as `template: your-output-dir` in the YAML configuration file.
See [Config](https://uzluisf.github.io/pear-doc/docs/config/) for more information.

# Configuration

The configuration of Pear is handled by a single file at the root of your
project, `config.yaml`. If the file doesn't exist at the moment `pear` is run,
then one will be created with some default settings.

One powerful thing about Pear's configuration file, is that everything in it,
Pear setting or not, is made available to templates. This can be taken advantage
of in many ways. For example, you could add a title or author attribute for use
in templates and then if you ever need to change that information, all you have
to do is update it in your site's config rather than in every template.

This also means that the templates must be organized according to how
the data is made available in the configuration file.

# Templates

With your site set up and a general sense of how a Pear site is structured,
let's move on to templates.

In the case of this guide (and also by default) the renderer used is Mustache.
Basically, a renderer takes care of knitting the data from the pages and any
additional data from the configuration file into whatever structure
a template dictates. If you're not already familiar with Mustache, give the
[Mustache](https://mustache.github.io/) documentation a quick read.

You can find the source files for this site at
[Github](https://github.com/uzluisf/pear-doc/tree/source) where you'll find
a `templates` directory used to render the site's content into HTML.

## Globals

Template globals are variables containing site data that are made available
to every template. There are four template globals: `site`, `posts`, `page`,
and `tags`.

# Posts

As mentioned above, Pear picks up posts from a directory named `posts` under the
content directory. Both hidden files and directories under `posts` will be
ignored.

A post's filename can be named anything. However, keep in mind that a post's
filename will also determine the post's url. A post's url will be dictated by
the post's date and its filename (`/2020/01/01/hello`).

## YAML frontmatter

The YAML frontmatter is a block of YAML fenced by three dashes at the start of a
post containing the post's metadata. It looks as follows:

    ---
    template: post
    date: 2020-01-01
    ---

Every post **requires** a YAML frontmater with the `template` attribute set.
The `template` attribute tells Pear which template in the templates directory
it should use to render the post. If a post doesn't specify a template,
the template specified in the post isn't in the template directory, or
the post specifies more than a single template, then the post won't be
rendered correctly. 

There are few other attributes that have a special meaning in the YAML
frontmatter:

* `date`, the post's date. Its format must be `yyyy-mm-dd`. Nonetheless, you can
  change its formatting by specifying the preferred format. The date format is
  based on `strftime`'s directives; there's a reference for it at
  https://strftime.org/ and for live preview at http://www.strftime.net/. For
  date in the page's frontmater, there are two choices: 1) `date: 2019-12-25`,
  if not format specified in the the configuration file (with `date-format`),
  then the default format `%b %d, %Y` will be used and
  2) `date: [2019-12-25, %Y/%m/%d]`, date is formatted according to the given format.

* `draft`, is the post a draft? If set to `true`, the post won't appear in the
generated HTML for the site.

* `tags`, a list of tags for the post.

# Tagging

With templates and posts covered, let's move on to how Pear handles tagging.

Let's start by noting that Pear collects and generates tags only from posts. To
tag a post, simply add the `tags` attribute to the YAML frontmatter containing
a list of the desired tags.

```
---
title: An example post
date: 2020/01/02
template: post
tags: [Foo, pear, tagging]
---
```

Once a post has been tagged, this change is reflected in a couple of ways.
First, all of a post's tags will be available via a `tags` attribute. Second,
that post will be added to each `tag` in the `tags` property of the global 
variable `posts`.

From all the tags, Pear will create a directory named `tags` directly under
the site's root. This directory contains the tags collected from all the posts
and it's made available to templates as the global variable `tags`.

# Pages

Lastly, we have pages. Any file outside the `posts` directory in the content 
directory is a page. Only files and files under other directories in the
content directory are rendered. Hidden files and other directories are ignored.
For instance, from the following file structure for the content
directory:

```
content
│
├── about.md
├── posts
│   ├── hello.md
│   └── blog
├── index.md
├── .ignore-me.md
├── docs
│   ├── example.md
│   ├── blog
│   │   ├── hello.md
│   │   └── blog
│   └── config.md
└── misc.md
```

Neither anything under `content/docs/blog/` nor the file `.ignore-me.md`
will be rendered into a HTML page. Only files directly under `content`
and files at the root of any directory under the `content` directory
(e.g., `docs/example.md` and `docs/config.md`).

# Generation

Now that we have the basics covered, it's time to generate your site.

Generating a Pear site is handled by the command `render` which will generates
the site into the output directory and immediately exit. 

```
$ pear render
```

To serve the generated site, you can use the `serve` command. To view your site
open your browser to http://localhost:3000/.

```
$ pear serve
```

If you want to re-generate the site and also serve it, you can use the `watch`
command.

```
$ pear watch
```