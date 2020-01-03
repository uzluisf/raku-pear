use Template::Mustache;

unit class Pear::Template;

has $.templates-dir; # directory where templates are located
has $.include-dir;   # directory where assets are located

has %!templates;     # template's name to template's location hash
has %!globals;       # global variables made available to a template

########################################
# public methods
########################################

submethod TWEAK() {
    self!load-templates;
}

method render-page( %page ) {

    # make sure each page specifies a template (index, blog, etc.).
    if %page<template>:!exists {
        say "=> Page has no template";
    }

    # make sure each page specifies only one template.
    unless %page<template>.elems == 1 and %page<template> ~~ Str {
        say "Each page should have a single template";
    }

    # make sure template specified in a page exists.
    if %!templates{ %page<template> }:!exists {
        say "Template {%page<template>} in page doesn't exist in the {$!templates-dir} directory";
    }

    # template seems to exists so get a hold of it.
    my $template = %!templates{ %page<template> };

    # get partials
    my %partials = self!get-partials;

    =begin comment
    Context make the following variables available to a template:
        * site, user defined variables from the YAML file. Thus, anything that
          isn't under 'directories'.
        * page, content specific to the current page.
        * posts, a list of all the posts.
        * tags, a list of tags.
    =end comment
    my %context = :%page, |%!globals;

    # make the global variable 'tag' to the template 'tag'.
    if %page<template> eq 'tag' {
        %context<tag> = %page<tag>;
    }

    return self!render-template:
        :%context,
        :content($template.IO.slurp),
        :from[%partials]
    ;
}

method update-globals( *%global-vars ) {
    for %global-vars.keys -> $var {
        %!globals{$var} = %global-vars{$var};
    }
}

########################################
# private methods
########################################

method !get-partials {
    my $partials = $!templates-dir.add('partials');
    my %partials;
    for dir($partials) -> $partial {
        %partials{$partial.basename.subst(/\.mustache/,'')} = $partial.IO.slurp;
    }
    return %partials;
}

method !render-template( :%context, Str :$content, :@from --> Str:D ) {
    quietly {
        Template::Mustache.render: $content, %context, :@from;
    }
}

method !load-templates {
    my $ext = 'mustache';
    for dir($!templates-dir) -> $template {
        my $template-name = $template.basename.Str.subst(/\.$ext/, '');
        %!templates{$template-name} = $template.absolute;
    }
}