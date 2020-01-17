---
title: 'Templates'
date: 2000-01-01
template: post
---

# Data

## Globals

### site

User-defined data from the configuration file (e.g., `config.yaml`).
By default, `site` includes the following variables:

* `include`, list of directories under the directory for static files specified
  in the YAML configuration file. Note that this is always `include` regardless
  of what it's specified in the configuration file.

* `time`, the time at the moment `pear` is executed in the site's root
  directory.

### page

Information about a page (e.g., `page.title`). A post and a tag outside the
global variables `posts` and `tags` respectively are considered regular pages.
Thus, this means a page might contain more attributes than the ones mentioned
below (See `post` and `tag` for their own respective attributes):

* `content`, the post's HTML content.

### posts

List of all the blog posts. See `post` for a post's attributes.

### tags

List of tags from the blog posts. See `tag` for a tag's attributes.

## Locals

The following variables are accessible only via global variables:

### post

Information about a given post and only accessible when iterating over the
global variable `posts`. A post contains the following attributes:

* `content`, the post's HTML content (e.g., `<h2>Say's Phoebe</h2>`).

* `url`, the post's url (e.g., `09/23/2019/dark-secondaries`).

* `id`, the post's identifier (same as `url`).

* `next`, the next post from current post.

* `previous`, the previous post from current post.

* `tags`, the tags associated with the post. See `tag` for the attributes a tag
  holds.

* `template`, the template with which the post is rendered. Note that each post
  must specify a template.

* `date`, the post's date. Its format must be `yyyy-mm-dd`. Nonetheless, you can
  change its formatting by specifying the preferred format. The date format is
  based on `strftime`'s directives; there's a reference for it at
  https://strftime.org/ and for live preview at http://www.strftime.net/. For
  date in the page's metadata, there are the following options:

  * `date: 2019-12-25`, if not format specified in the the configuration file
    (with `date-format`), then the default format `%b %d, %Y` will be used.

  * `date: [2019-12-25, %Y/%m/%d]`, format date according to given format.

* `draft`, is the post a draft? If set to `true`, the post won't appear in the generated HTML for the site.

All the other attributes in a post's frontmatter will be included alongside the
attributes discussed earlier.

### tag

Information about a tag and only accessible when iterating over the global
variable `tags`. A tag contains the following attributes:

* `name`, the tag's name (e.g, `linux`).

* `url`, the tag's url (e.g., `/tags/linux`).

* `posts`, the list of posts associated to that tag.

