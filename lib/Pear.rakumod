use Pear::Utils;
use Pear::Template;
use Pear::Preview;
use Pear::Config;
use Log;

unit class Pear;

########################################
# public attributes
########################################

has IO::Path $.working-dir is required;
has Config   $.config      is required;

########################################
# private attributes
########################################

has Hash @!pages;
has Hash @!posts;
has      %!tags;
has Template $!template;

has %!include;

has Log $!log .= new;

########################################
# public methods
########################################

submethod TWEAK {
    $!log.info("Pear working in directory '{$!working-dir.basename}'");

    $!template = Template.new(
        :templates-dir($!config.templates-dir), :include-dir($!config.include-dir)
    );

    unless $!config.output-dir.e {
        $!log.debug("Creating '{$!config.output-dir.basename}'");
        mkdir $!config.output-dir;
    }

    $!log.debug("Creating '{$!config.output-dir.basename}'");
    self!copy-to-site($!config.include-dir);
}

#| Generate post pages.
method generate-posts( --> Nil ) {
    @!posts = Empty;

    # we must collect posts before generating them.
    self!collect-posts();

    $!log.info("Generating posts from '{$!config.content-dir.basename}'");

    # now let's generate the posts.
    my Str $post-dir = 'posts';
    for @!posts -> $post {
        my Str $html = $!template.render-page($post);
        my IO::Path $post-url  = $!config.output-dir.add($post<url>);
        my IO::Path $post-file = $post-url.add('index.html');

        my $d = $post-file.subst("{$!working-dir}/", '');
        $!log.debug("Generating post '$d'");

        self!write-html($post-file, $html);
    }
}

#| Generates regular pages.
method generate-pages( --> Nil ) {
    @!pages = Empty;

    # we must collect pages before generating them.
    self!collect-pages();

    $!log.info("Generating pages from '{$!config.content-dir.basename}'");

    # now let's generate the pages.
    for @!pages -> $page {
        my Str $html = $!template.render-page($page);
        my IO::Path $post-file = $page<url>.contains('index')
            ?? $!config.output-dir.IO.add($page<url> ~ '.html')
            !! $!config.output-dir.IO.add($page<url>).add('index.html');

        my $d = $post-file.subst("{$!working-dir}/", '');
        $!log.debug("Generating page '$d'");

        # create the HTML page.
        self!write-html($post-file, $html);
    }
}

#| Generate tag pages.
method generate-tags( --> Nil ) {
    $!log.info("Generating tags");

    for %!tags -> $tag-to-posts {
        my Str $name = $tag-to-posts.key.lc; # get tag's name.
        my @posts := $tag-to-posts.value;    # get posts associated to given tag.
        my %page-meta = template => 'tag', tag => %(:$name, :@posts);
        my Str $html  = $!template.render-page(%page-meta);

        my IO::Path $tag-page-url = $!config.output-dir.add('tags').add($name);
        my IO::Path $tag-file = $tag-page-url.IO.add('index.html');

        my $d = $tag-page-url.subst("{$!working-dir}/", '');
        $!log.debug("Generating tag '$name' in path '$d'");

        # create the HTML page.
        self!write-html($tag-file, $html);
    }

    # We don't want to append the same tags next time this method is called.
    %!tags = Empty;
}

########################################
# private methods
########################################

method !collect-posts( --> Nil ) {
    # at the moment, posts live under the 'posts' directory beneath whatever
    # directory content maps to in  the configuration file (e.g., /content/posts).
    my $post-dir = 'posts';

    for dir $!config.content-dir.add($post-dir) -> $post {
        # ignore hidden files under the content directory.
        next if $post.basename.starts-with('.');

        my %post-meta    = Pear::Utils::get-metadata($post);
        %post-meta<date> = do given %post-meta<date> {
            when Str   { Pear::Utils::format-date(%post-meta<date>, $!config.settings<date-format> // 'mm/dd/yyyy') }
            when Array { Pear::Utils::format-date(|%post-meta<date>) }
        }

        # this assumes a filename has no dot other than the one for its extension.
        my $base = %post-meta<filename>.subst(/'.' .* $/, '');
        # post's url under post's directory
        %post-meta<url> = $post-dir.IO
            .add(%post-meta<date>)
            .add($base)
            .Str;

        @!posts.push(%post-meta);

        # if post has tags, create tag cloud.
        if %post-meta<tags> {
            for %post-meta<tags>.flat -> $tag {
                # associate current post with tag. Either the tag already
                # exists or a new tag entry will be added to the hash of tags.
                %!tags{$tag.lc}.push(%post-meta)
            }
        }
    }

    # sort posts based by date (newest to oldest).
    @!posts .= sort(-> $post { $post<date> });
    @!posts .= reverse.Array;

    # sort posts by tag based on date (ascending order).
    for %!tags.keys -> $tag {
        %!tags{$tag} = %!tags{$tag}.sort(-> $post { $post<date> }).Array
    }

    # include post's tags. Also include previous and next posts for a given post.
    for @!posts.kv -> $post-num, $post is rw {
        my @post-tags;

        if $post<tags> {
            for $post<tags>.flat -> $name {
                my $url = 'tags'.IO.add($name.lc).Str;
                my %tag = :$name, :$url, posts => |%!tags{$name};
                @post-tags.push(%tag);
            }
        }

        $post<tags> = @post-tags;
        $post<id>   = $post<url>;

        my ($previous, $next) = ($post-num + 1, $post-num - 1);
        $post<previous> = $previous < @!posts.elems ?? @!posts[$previous] !! False;
        $post<next>     = $next >= 0 ?? @!posts[$next] !! False;
    }

    # collect tags made available to the templates.
    my @tags;
    for %!tags.keys -> $name {
        my $url = 'tags'.IO.add($name.lc).Str;
        my %tag = :$name, :$url, posts => |%!tags{$name};
        @tags.push(%tag);
    }

    # sort tags lexicographically.
    @tags .= sort({$^tag<name>}).Array;

    # collect site's settings made available to the templates.
    my %site = %(time => DateTime.now.Str, include => %!include);
    %site    = %site, |$!config.settings;

    # update global variables for the templates.
    $!template.update-globals(:@!posts, :@tags, :%site);
}

method !collect-pages( --> Nil ) {
    for dir($!config.content-dir) -> $page {
        # ignore directories. For the moment, only files directly under
        # the 'content' directory are considered.
        next if $page.IO.d;

        # ignore hidden file.
        next if $page.basename.starts-with('.');

        my %page-meta = Pear::Utils::get-metadata($page);
        %page-meta<url> = (%page-meta<filename>).IO.basename.split('.', *).first;

        @!pages.push(%page-meta);
    }
}

method !write-html( IO::Path:D $post-file, Str:D $html ) {
    try mkdir $post-file.dirname;
    $post-file.spurt($html);
}

method !copy-to-site( IO::Path:D $dir --> Nil ) {
    my %dir-to-files = Pear::Utils::walk($dir.basename);
    for %dir-to-files.keys -> $dirname {
        for %dir-to-files{$dirname}.flat -> $file {
            # ignore hidden files
            next if $file.starts-with('.');
            # collect the files into the 'include' directory. This will be
            # made available to the templates as the global variable "include".
            %!include{$dirname.IO.basename}.push($dirname.IO.add($file).Str);
            # file to be copied.
            my $from = $dirname.IO.add($file);
            # directory in which file will be copied to.
            my $to-dirname = $!config.output-dir.add($dirname);
            # let's create the directory.
            mkdir $to-dirname;
            # create full file path.
            my $to = $to-dirname.add($file).resolve;
            # copy the file.
            copy $from, $to;
        }
    }
}
