use YAMLish;
use Text::Markdown;

unit module Pear::Utils;

my regex post {
    '---'
    $<meta> = (.*)
    '---'
    $<body> = (.*)
}

our sub get-metadata( IO::Path $filename --> Hash ) {
    my $content = $filename.slurp;
    my (%meta, $body);

    if $content.match(/<post>/) {
        %meta = load-yaml $/<post><meta>.Str;
        $body = $/<post><body>.Str;

        %meta<content> = Text::Markdown.new($body).render;
        %meta<raw> = $body;
    }
    else {
        %meta<raw> = $content;
    }

    %meta<filename> = $filename.basename;
    return %meta;
}

our sub format-date($date, $format) {
    my %subs = %(
        'mm/dd/yyyy' => sub ($date) { sprintf "%02d/%02d/%04d", .month, .day, .year given $date},
        'dd/mm/yyyy' => sub ($date) { sprintf "%02d/%02d/%04d", .day, .month, .year given $date},
    );

    return Date.new($date, formatter => %subs{$format}).Str;
}

# Walk a directory and return a hash mapping its directories to their files.
our sub walk( $dir, Mu :$test ) {
    =begin comment
    Given a directory 'site' with the following structure:
    site/
    |
    |--contents
    |  |--file1.md
    |  |--file2.md
    |
    |--blog
    |  |--blog1.md
    |  |--blog2.md
    |
    |-extra

    Then the 'read-folder' sub returns the hash:
    %(
        'site/contents' => <file1.md file2.md>,
        'site/blogs' => <blog1.md blog2.md>
    )
    =end comment

    my %dir-to-files.push(
        gather for dir $dir -> $path {
            if $path.IO.f && $path.basename ~~ $test {
                take $path.dirname => $path.IO.basename;
            }
            if $path.d {
                .take for walk $path, :$test
            };
    });
    return %dir-to-files;
}
