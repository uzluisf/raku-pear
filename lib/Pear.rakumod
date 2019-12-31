use Pear::Utils;
use Pear::Template;

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

########################################
# public methods
########################################

submethod TWEAK() {
    $!template = Template.new(
        templates-dir => $!config.templates-dir,
        include-dir => $!config.include-dir
    );
}

method parse-metadata {

    for dir($!config.posts-dir) -> $post {
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
                %!tags{$tag}.push(%post-meta)
            }
        }
    }

    # sort posts based by date (ascending order).
    @!posts .= sort(-> $post { $post<date> });

    # sort tags based on date (ascending order).
    for %!tags.keys -> $tag {
        %!tags{$tag} .= sort(-> $post { $post<date> })
    }

    # include post's tags. Also include previous and next urls for a given post.
    for @!posts.kv -> $post-num, $post is rw {
        my @post-tags;

        if $post<tags> {
            for $post<tags>.flat -> $name is rw {
                my $url = '/tag'.IO.add($name).Str;
                @post-tags.push(%(:$name, :$url, :posts(%!tags{$name})));
            }
        }

        $post<tags> = @post-tags;
        $post<id>   = $post<url>;

        my ($previous, $next) = ($post-num + 1, $post-num - 1);
        $post<previous> = $previous < @!posts.elems ?? @!posts[$previous] !! Nil;
        $post<next>     = $next >= 0 ?? @!posts[$next] !! Nil;
    }

    # TODO: pagination

}

method generate-posts {
    for @!posts -> $post {
        my $html = $!template.render-page($post, $!config.settings);
        my $post-url = $!config.output-dir.IO.add($!config.posts-dir)
                .add($post<url>.substr(1, *)).resolve;
        my $post-file = $post-url.add('index.html');
        self!write-html($post-file, $html);
    }
}

#| Generate whatever pages inside content except posts.
method collect-pages {
    for dir($!config.content-dir) -> $page {
        next if $page.IO.d;

        next if $page.basename.starts-with('.');

        my %page-meta = Pear::Utils::get-metadata($page);
        # post's url under post's directory
        %page-meta<url> = '/' ~ %page-meta<filename>.IO.basename.split('.', *).first;
        @!pages.push(%page-meta);
    }
}

method generate-pages {
    for @!pages -> $page {
        my $html = $!template.render-page($page, $!config.settings);
        my $post-file;
        if $page<url>.contains('index') {
            $post-file = $!config.output-dir.IO.add($page<url> ~ '.html');
        }
        else {
            $post-file = $!config.output-dir.IO.add($page<url>).add('index.html');
        }

        self!write-html($post-file, $html);
    }
}

########################################
# private methods
########################################

method !write-html( $post-file, $html ) {
    try mkdir $post-file.dirname;
    $post-file.spurt($html);
}
