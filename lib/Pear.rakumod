use Pear::Utils;

unit class Pear;

########################################
# public attributes
########################################

has $.work-dir is required;
has $.config   is required;

########################################
# private attributes
########################################

has @!posts;
has %!tags;

########################################
# public methods
########################################

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
        my $html = $post<raw>;
        my $post-url = $!config.output-dir.IO.add($!config.posts-dir)
                .add($post<url>.substr(1, *)).resolve;
        my $post-file = $post-url.add('index.html');

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
