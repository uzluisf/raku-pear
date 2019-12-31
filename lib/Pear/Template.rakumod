use Template::Mustache;

unit class Pear::Template;

has $.templates-dir; # directory where templates are located
has $.include-dir;   # directory where assets are located
has %!templates;     # template's name to template's location hash

########################################
# public methods
########################################

submethod TWEAK() {
    self!load-templates;
}

method render-page( %page, $site ) {

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

    my %context = %(
        :%page,
        #:$posts,
        #:$settings,
    );

    return self!render-template:
        :%context,
        :content($template.IO.slurp),
        :from[%partials]
    ;
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