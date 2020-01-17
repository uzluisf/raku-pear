---
title: 'Config'
date: 2019-02-11
template: post
---

* `directories`

This is where you specify the directories Pear must be aware of. Pear is aware
of a content directory, a templates directory, an include directory, and an
output directory. 

```
directories:
    content: content
    templates: templates
    include: static
    output: public
```

Here, Pear will look for content under `content`, for templates under
`templates`, for static files under `static`. It will place the generated
HTML under the `public` directory.

* `date-format`

The format that will be used for a post/page unless it already includes
a formatting of its own.
