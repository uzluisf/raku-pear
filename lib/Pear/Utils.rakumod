use YAMLish;
use Text::Markdown;

unit module Pear::Utils;

my regex post {
    '---'
    $<meta> = (.*)
    '---'
    $<body> = (.*)
}

our sub get-metadata( $filename ) {
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

    %meta<filename> = $filename.Str;
    return %meta;
}

our sub format-date($date, $format) {
    my %subs = %(
        'mm/dd/yyyy' => sub ($date) { sprintf "%02d/%02d/%04d", .month, .day, .year given $date},
        'dd/mm/yyyy' => sub ($date) { sprintf "%02d/%02d/%04d", .day, .month, .year given $date},
    );

    return Date.new($date, formatter => %subs{$format}).Str;
}
