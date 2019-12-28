use Pear::Utils;

unit class Pear;

has $.work-dir is required;
has $.config   is required;

has @!posts;

method parse-metadata {
    for dir($!config.posts-dir) -> $post {
        my %post-meta    = Pear::Utils::get-metadata($post);
        %post-meta<date> = Pear::Utils::format-date(%post-meta<date>, 'mm/dd/yyyy');
        @!posts.push(%post-meta);
    }
}
