=begin comment
Pear::Preview and the files under Pear::Preview are adapted
from https://github.com/scmorrison/uzu/blob/master/lib/Uzu/HTTP.pm6
=end comment

use Pear::Preview::Watch;
use Pear::Preview::HTTP;
use Pear::Config;

unit class Pear::Preview;

has Pear::Config $.config is required;
has $.writer              is required;

has Int:D $.port            = 3000;
has Str:D $.host            = '0.0.0.0';
has Bool:D $.no-livereload  = False;

#| Start local web server and re-render site.
method watch {
    Watch.new(:$!writer, :$!config, :$!port, :$!host, :$!no-livereload).start()
}

# Start local web server.
method serve {
    my $build-dir = $!config.output-dir;

    await Pear::Preview::HTTP.new(
        :$build-dir,
        :$!port,
        :$!host,
        :$!no-livereload,
        omit-html-ext => False,
    ).webserver()
}
