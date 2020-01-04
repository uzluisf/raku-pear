use Pear::Preview::HTTP;
use File::Find;

unit class Pear::Preview::Watch;

has $.writer;
has $.config;
has Int:D $.port           = 3000;
has Str:D $.host           = '0.0.0.0';
has Bool:D $.no-livereload = False;

method build-and-reload( --> Bool ) {
    $!writer.?write();
    self.reload-browser();
}

method user-input( Array :$servers --> Bool ) {
    loop {
        print q:to/USER-PROMPT/;
        `r enter` to [rebuild]
        `c enter` to [clear] build directory and rebuild
        `q enter` to [quit]
        USER-PROMPT

        given prompt('') {
            when 'r' {
                put "Rebuild triggered";
                self.build-and-reload;
            }
            when 'c' {
                put "Clear build directory and rebuild triggered";
                self.build-and-reload;
            }
            when 'q'|'quit' {
                exit 1;
            }
        }
    }
}

method start( --> Bool ) {
    # Initialize build
    put "Initial build";
    $!writer.write;
   
    # Track time delta between File events. 
    # Some editors trigger more than one event per edit. 
    my List $exts = ('css', 'md', 'html', 'yml', 'mustache');#%config<extensions>;
    #my List $dirs = (
    #    |$!config.directories.grep({$_.key ne 'output'}).hash.values
    #).grep(*.IO.e).List;
    my List $dirs = (.content-dir, .templates-dir, .include-dir) given $!config;

    $dirs.map(-> $dir {
        put "Starting watch on {$dir.subst("{$*CWD}/", '')}"
    });

    # Start server
    my @servers = Pear::Preview::HTTP.new(
        :build-dir($!config.output-dir),
        :$!port,
        :$!host,
        :$!no-livereload,
        :!omit-html-ext
    ).webserver;

    # Keep track of the last render timestamp
    state Instant $last_run = now;

    # Watch directories for modifications
    start {
        react {
            whenever self!file-change-monitor($dirs) -> $e {
                # Make sure the file change is a 
                # known extension; don't re-render too fast
                if so $exts (cont) $e.path.IO.extension and (now - $last_run) > 2 {
                    put "Change detected [{$e.path()}]";
                    self.build-and-reload();
                    $last_run = now;
                }
            }
        }
    }

    # Listen for keyboard input
    self.user-input(:@servers);
}

method reload-browser( --> Bool() ) {
    unless $!no-livereload {
        my $request = "GET /reload HTTP/1.0\r\nContent-length: 0\r\n\r\n";
        Pear::Preview::HTTP.new(:$!port, :$!host, :$!no-livereload).inet-request($request);
    }
}

method !find-dirs( IO::Path $p --> Slip ) {
    slip ($p.IO, slip find :dir($p.path), :type<dir>);
}

method !file-change-monitor( List $dirs --> Supply ) {
    supply {
        my &watch-dir = -> $p {
            whenever IO::Notification.watch-path($p.path) -> $c {
                if $c.event ~~ FileRenamed && $c.path.IO ~~ :d {
                    self!find-dirs($c.path).map(watch-dir $_);
                }
                emit $c;
            }
        }
        watch-dir(~$_.path.Str) for $dirs.map: { self!find-dirs($_.IO) };
    }
}