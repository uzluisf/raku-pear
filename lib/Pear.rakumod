use Pear::Utils;
use Pear::Template;
use Pear::Paginator;

unit class Pear;

########################################
# public attributes
########################################

has $.work-dir is required;
has $.config   is required;

########################################
# private attributes
########################################

has @!pages;
has @!posts;
has %!tags;
has $!template;

has %!include;

########################################
# public methods
########################################

submethod TWEAK {
    $!template = Template.new(
        :templates-dir($!config.templates-dir), :include-dir($!config.include-dir)
    );

    self!copy-to-site($!config.include-dir);
}

method generate-posts {
    # we must collect posts before generating them.
    self!collect-posts();

    # now let's generate the posts.
    my $post-dir = 'posts';
    for @!posts -> $post {
        my $html = $!template.render-page($post);
        my $post-url = $!config.output-dir.IO.add($post-dir)
                .add($post<url>.substr(1, *)).resolve;
        my $post-file = $post-url.add('index.html');
        self!write-html($post-file, $html);
    }
}

method generate-pages {
    # we must collect pages before generating them.
    self!collect-pages();

    # now let's generate the posts.
    for @!pages -> $page {
        my $html = $!template.render-page($page);
        my $post-file = $page<url>.contains('index')
            ?? $!config.output-dir.IO.add($page<url> ~ '.html')
            !! $!config.output-dir.IO.add($page<url>).add('index.html');

        # create the HTML page.
        self!write-html($post-file, $html);
    }
}

#| Generate tag pages.
method generate-tags {
    for %!tags -> $tag-to-posts {
        my $name   = $tag-to-posts.key.lc; # get tag's name.
        my @posts := $tag-to-posts.value;  # get posts with given tag.
        my %page-meta = template => 'tag', tag => %(:$name, :@posts);
        my $html      = $!template.render-page(%page-meta);

        my $tag-page-url = $!config.output-dir.IO.add('tag').add($name);
        my $tag-file = $tag-page-url.IO.add('index.html');
        # create the HTML page.
        self!write-html($tag-file, $html);
    }
}

########################################
# private methods
########################################

method !collect-posts {
    my $post-dir = $!config.content-dir.add('posts');
    for dir($post-dir) -> $post {
        next if $post.basename.starts-with('.');

        my %post-meta    = Pear::Utils::get-metadata($post);
        %post-meta<date> = Pear::Utils::format-date(%post-meta<date>, 'mm/dd/yyyy');

        # post's url under post's directory
        %post-meta<url> = ('/' ~ %post-meta<date>.Str).IO.add(
            %post-meta<filename>.IO.basename.split('.', *).first
        ).Str;

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

    # sort posts based by date (ascending order).
    @!posts .= sort(-> $post { $post<date> });

    # sort tags based on date (ascending order).
    for %!tags.keys -> $tag {
        %!tags{$tag} = %!tags{$tag}.sort(-> $post { $post<date> }).Array
    }

    # include post's tags. Also include previous and next urls for a given post.
    for @!posts.kv -> $post-num, $post is rw {
        my @post-tags;

        if $post<tags> {
            for $post<tags>.flat -> $name is rw {
                my $url = '/tag'.IO.add($name.lc).Str;
                @post-tags.push(%(:$name, :$url, :posts(%!tags{$name})));
            }
        }

        $post<tags> = @post-tags;
        $post<id>   = $post<url>;

        my ($previous, $next) = ($post-num + 1, $post-num - 1);
        $post<previous> = $previous < @!posts.elems ?? @!posts[$previous] !! Nil;
        $post<next>     = $next >= 0 ?? @!posts[$next] !! Nil;
    }

    # collect tags made available to the templates.
    my @tags;
    for %!tags.keys -> $name {
        my $url = '/tag'.IO.add($name.lc).Str;
        @tags.push(:$name, :$url, :posts(%!tags{$name}));
    }

    # collect site's settings made available to the templates.
    my %site = %(time => DateTime.now, $!config.include-dir.basename.Str => %!include);
    %site    = %site, |$!config.settings;

    # update global variables for the templates.
    $!template.update-globals(:@!posts, :@gtags, :%site);
}

method !collect-pages {
    for dir($!config.content-dir) -> $page {
        next if $page.IO.d;

        next if $page.basename.starts-with('.');

        my %page-meta = Pear::Utils::get-metadata($page);
        # post's url under post's directory
        %page-meta<url> = '/' ~ %page-meta<filename>.IO.basename.split('.', *).first;
        @!pages.push(%page-meta);
    }
}

method !write-html( $post-file, $html ) {
    try mkdir $post-file.dirname;
    $post-file.spurt($html);
}

method !copy-to-site( $dir ) {
    # TODO: This method needs some cleanup.
    my %dir-to-files = Pear::Utils::walk($!config.include-dir);

    for %dir-to-files.keys -> $dirname {
        for %dir-to-files{$dirname}.flat -> $file {

            %!include{$dirname.IO.basename}.push(
                $!config.include-dir.basename.IO.add($dirname.IO.basename).add($file).Str
            );

            my $from = $dirname.IO.add($file);
            my $to-dirname = $!config.output-dir.IO.add($dirname);
            mkdir $to-dirname;
            my $to = $to-dirname.add($file).resolve;
            copy $from, $to;
        }
    }
}
