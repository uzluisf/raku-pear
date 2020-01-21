---
title: 'Markdown Syntax Guide'
summary: An overview of Markdown syntax.
date: 2020-01-18
template: post
tags: ["markdown", "css", "html"]
---

This post offers a sample of basic Markdown syntax that can be used in
Pear content files.

## Headers

The following HTML `<h1>`—`<h6>` elements represent six levels of section
headings. `<h1>` is the highest section level while `<h6>` is the lowest.

```
# H1
## H2
### H3
#### H4
##### H5
###### H6
```

## Paragraph

A paragraph is simply one or more consecutive lines of text, separated by one
or more blank lines. (A blank line is any line that looks like a blank
line — a line containing nothing but spaces or tabs is considered blank).
Normal paragraphs should not be indented with spaces or tabs.

[More about paragraphs](https://daringfireball.net/projects/markdown/syntax#p).


## Blockquotes

The blockquote element represents content that is quoted from another source,
optionally with a citation which must be within a `footer` or `cite` element,
and optionally with in-line changes such as annotations and abbreviations.
Markdown uses email-style `>` characters for blockquoting. For instance:

```
> This is a witty quote because I deem it so.
```

might be rendered as

> This is a witty quote because I deem it so.



## Tables

Tables aren't part of the core Markdown spec. However, you can always drop
HTML into a Markdown file.

```
<table style="width:100%">
  <tr>
    <th>Firstname</th>
    <th>Lastname</th>
    <th>Age</th>
  </tr>
  <tr>
    <td>Jill</td>
    <td>Smith</td>
    <td>50</td>
  </tr>
  <tr>
    <td>Eve</td>
    <td>Jackson</td>
    <td>94</td>
  </tr>
</table>
```

might render as

<table style="width:100%">
  <tr>
    <th>Firstname</th>
    <th>Lastname</th>
    <th>Age</th>
  </tr>
  <tr>
    <td>Jill</td>
    <td>Smith</td>
    <td>50</td>
  </tr>
  <tr>
    <td>Eve</td>
    <td>Jackson</td>
    <td>94</td>
  </tr>
</table>

## List Types

#### Ordered List

1. First item

2. Second item

3. Third item

#### Unordered List

* List item
* Another item
* And another item


## Code Blocks

To produce a code block in Markdown, simply indent every line of the block
by at least 4 spaces or 1 tab. For example, given this input:

        sub multiplier(Int $times, *@numbers) {
            @numbers.map(* * $times)
        }
        my &triple = &multiplier.assuming(3, *);
        say &triple(5, 7, 9);     #=> (15 21 27)

Markdown will generate:

    <pre><code>sub multiplier(Int $times, *@numbers) {
            @numbers.map(* * $times)
        }
        my &amp;triple = &amp;multiplier.assuming(3, *);
        say &amp;triple(5, 7, 9);     #=&gt; (15 21 27)
    </code></pre>


## Other Elements — abbr, sub, sup, kbd, mark

<abbr title="Graphics Interchange Format">GIF</abbr> is a bitmap image format.

H<sub>2</sub>O

X<sup>n</sup> + Y<sup>n</sup> = Z<sup>n</sup>

Press <kbd><kbd>CTRL</kbd>+<kbd>ALT</kbd>+<kbd>Delete</kbd></kbd> to end the session.

Most <mark>salamanders</mark> are nocturnal, and hunt for insects, worms,
and other small creatures.

---

For a more in-depth overview of Markdown syntax, read John Gruber's
[Markdown Syntax](https://daringfireball.net/projects/markdown/syntax). Gruber
is the creator of Markdown.

It's worth noting that implementations of Markdown may vary across the
board with some only supporting the original Markdown spec and others
adding new features (e.g., support for tables, fenced code blocks, etc.).