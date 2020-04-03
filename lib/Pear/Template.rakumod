use Template::Mustache;
use Log;

unit class Pear::Template;

has $.templates-dir; # directory where templates are located
has $.include-dir;   # directory where assets are located

has %!templates;     # template's name to template's location hash
has %!globals;       # global variables made available to a template

has Log $!log .= new;

########################################
# public methods
########################################

submethod TWEAK() {
    self!load-templates;
}

method render-page( %page --> Str ) {

    # make sure each page specifies a template (index, blog, etc.).
    if %page<template>:!exists {
        my $msg = "Page «{%page<url>}» specifies no template in its YAML metadata.";
        $!log.warn($msg);
        return self!htmlify-message: $msg;
    }

    # make sure each page specifies only one template.
    unless %page<template>.elems == 1 and %page<template> ~~ Str {
        my $msg = "Page «{%page<url>}» specifies more than a single template";
        $!log.warn($msg);
        return self!htmlify-message: $msg;
    }

    # make sure template specified in a page exists.
    unless self.template-exist(%page<template>) {
    #if %!templates{ %page<template> }:!exists {
        my $msg = "Template «{%page<template>}» in page doesn't exist in the «{$!templates-dir}» directory";
        $!log.warn($msg);
        return self!htmlify-message: $msg;
    }

    # template seems to exists so get a hold of it.
    my $template = %!templates{ %page<template> };

    # get partials
    my %partials = self!get-partials;

    =begin comment
    Context make the following variables available to a template:
        * site, user defined variables from the YAML file. Thus, anything that
          isn't under 'directories'.
        * page, content specific to the current page. Outside of `posts`,
        a post is just another page so `page.title` to access the post's title
        for instance.
        * posts, a list of all the posts.
        * tags, a list of tags.
    =end comment
    my %context = :%page, |%!globals;

    # make the global variable 'tag' only to the template 'tag'.
    if %page<template> eq 'tag' {
        %context<tag> = %page<tag>;
    }

    return self!render-template:
        :%context,
        :content($template.IO.slurp),
        :from[%partials]
    ;
}

method update-globals( *%global-vars --> Nil ) {
    for %global-vars.keys -> $var {
        %!globals{$var} = %global-vars{$var};
    }
}

method get-globals {
    %!globals
}

method template-exist( Str:D $template-name --> Bool ) {
    %!templates{ $template-name }:exists
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
    if %context<page><filename> {
        $!log.info("Rendering file '{%context<page><filename>}'");
    }
    elsif %context<tag> {
        $!log.info("Rendering tag file '{%context<tag><name>}'");
    }

    quietly {
        Template::Mustache.render: $content, %context, :@from;
    }
}

method !load-templates {
    my $ext = 'mustache';
    if $!templates-dir ~~ :e && $!templates-dir ~~ :d {
        for dir($!templates-dir) -> $template {
            my $template-name = $template.basename.Str.subst(/\.$ext/, '');
            %!templates{$template-name} = $template.absolute;
        }
    }
    else {
        $!log.warn("No such '$!templates-dir' directory");
        exit;
    }
}

method !htmlify-message( Str $msg ) {
    qq:to/END/;
    <head>
    <style>
    body \{
        background: #161616;
        font-size:  20px;
        color: #fff;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        align-items: center;
    \}

    .section \{
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: flex-start;
        margin: auto 0;
        height: 100vh;
        width: 50%;
    \}
    </style>
    </head>

    <body>
        <div class="section">
            <div><p>{$msg}</p></div>
        </div>
    </body>
    END
}