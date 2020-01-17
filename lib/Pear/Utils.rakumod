use YAMLish;
use Text::Markdown;

unit module Pear::Utils;

my regex post {
    '---'
    $<meta> = (.*?)
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

=begin comment
Functions are borrowed from
DateTime::Format (https://github.com/supernovus/perl6-datetime-format/)
Reference: http://man7.org/linux/man-pages/man3/strftime.3.html
=end comment

## Default list of Month names.
## Add more by loading DateTime::Format::Lang::* modules.
our $month-names = {
    en => <
        January
        February
        March
        April
        May
        June
        July
        August
        September
        October
        November
        December
    >
};

## Default list of Day names.
## Add more by loading DateTime::Format::Lang::* modules.
## ISO 8601 says that Monday is the first day of the week,
## which I think is wrong, but who am I to argue with ISO.
our $day-names = {
    en => <
        Monday
        Tuesday
        Wednesday
        Thursday
        Friday
        Saturday
        Sunday
    >
};

## Returns the language-specific day name.
sub day-name ($i, $lang) is export(:ALL) {
    # ISO 8601 says Monday is the first day of the week.
    $day-names{$lang.lc}[$i - 1];
}

## Returns the language-specific month name name.
sub month-name ($i, $lang) is export(:ALL) {
    $month-names{$lang.lc}[$i - 1];
}

# Format date and time.
our sub strftime(
  $dt,
  Str $format is copy,
  Str :$lang = 'en',
  Bool :$subseconds,
) {
    my %substitutions =
        # Standard substitutions for yyyy mm dd hh mm ss output.
        'Y' => { $dt.year.fmt(  '%04d') },
        'm' => { $dt.month.fmt( '%02d') },
        'd' => { $dt.day.fmt(   '%02d') },
        'H' => { $dt.hour.fmt(  '%02d') },
        'M' => { $dt.minute.fmt('%02d') },
        'S' => { $dt.whole-second.fmt('%02d') },
        # Special substitutions (Posix-only subset of DateTime or libc)
        'a' => { day-name($dt.day-of-week, $lang).substr(0,3) },
        'A' => { day-name($dt.day-of-week, $lang) },
        'b' => { month-name($dt.month, $lang).substr(0,3) },
        'B' => { month-name($dt.month, $lang) },
        'C' => { ($dt.year/100).fmt('%02d') },
        'e' => { $dt.day.fmt('%2d') },
        'F' => { $dt.year.fmt('%04d') ~ '-' ~ $dt.month.fmt(
                  '%02d') ~ '-' ~ $dt.day.fmt('%02d') },
        'I' => { (($dt.hour+23)%12+1).fmt('%02d') },
        'j' => { $dt.day-of-year.fmt('%03d') },
        'k' => { $dt.hour.fmt('%2d') },
        'l' => { (($dt.hour+23)%12+1).fmt('%2d') },
        'n' => { "\n" },
        'N' => { (($dt.second % 1)*1000000000).fmt('%09d') },
        'p' => { ($dt.hour < 12) ?? 'AM' !! 'PM' },
        'P' => { ($dt.hour < 12) ?? 'am' !! 'pm' },
        'r' => { (($dt.hour+23)%12+1).fmt('%02d') ~ ':' ~
                  $dt.minute.fmt('%02d') ~ ':' ~ $dt.whole-second.fmt('%02d')
                  ~ (($dt.hour < 12) ?? 'am' !! 'pm') },
        'R' => { $dt.hour.fmt('%02d') ~ ':' ~ $dt.minute.fmt('%02d') },
        's' => { $dt.posix.fmt('%d') },
        't' => { "\t" },
        'T' => { $dt.hour.fmt('%02d') ~ ':' ~ $dt.minute.fmt('%02d') ~ ':' ~ $dt.whole-second.fmt('%02d') },
        'u' => { ~ $dt.day-of-week.fmt('%d') },
        'w' => { ~ (($dt.day-of-week+6) % 7).fmt('%d') },
        'x' => { $dt.year.fmt('%04d') ~ '-' ~ $dt.month.fmt('%02d') ~ '-' ~ $dt.day.fmt('%2d') },
        'X' => { $dt.hour.fmt('%02d') ~ ':' ~ $dt.minute.fmt('%02d') ~ ':' ~ $dt.whole-second.fmt('%02d') },
        'y' => { ($dt.year % 100).fmt('%02d') },
        '%' => { '%' },
        '3N' => { (($dt.second % 1)*1000).fmt('%03d') },
        '6N' => { (($dt.second % 1)*1000000).fmt('%06d') },
        '9N' => { (($dt.second % 1)*1000000000).fmt('%09d') },
        'z' => {
            my $o = $dt.offset;
            $o
            ?? sprintf '%s%02d%02d',
               $o < 0 ?? '-' !! '+',
               ($o.abs / 60 / 60).floor,
               ($o.abs / 60 % 60).floor
            !! 'Z'
        },
        'Z' => {
            my $o = $dt.offset;
            $o
            ?? sprintf '%s%02d%02d',
               $o < 0 ?? '-' !! '+',
               ($o.abs / 60 / 60).floor,
               ($o.abs / 60 % 60).floor
            !! '+0000'
        },
    ; ## End of %substitutions

    $format .= subst( /'%'(\dN|\w|'%')/, -> $/ { (%substitutions{~$0}
            // die "Unknown format letter '$0'").() }, :global );
    return ~$format;
}
