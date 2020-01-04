use HTTP::Server::Tiny:ver<0.0.2>;

unit class Pear::Preview::HTTP;

has      $.build-dir;
has Int  $.port;
has Str  $.host;
has Bool $.no-livereload;
has Bool $.omit-html-ext;

has Pair $!ct-json = 'Content-Type' => 'application/json';
has Pair $!ct-text = 'Content-Type' => 'text/plain';

method webserver( --> Array ) {
    my Promise @servers;

    push @servers, start {
        # Use for triggering reload staging when reload is triggered
        my $reload = Channel.new;

        # START http server
        my &app = sub (%env) {
            given %env<PATH_INFO> {
                # When accessed, sets $reload to True
                # Routes
                when  '/reload' {
                    $reload.send(True);
                    put "GET /reload";
                    return 200, [$!ct-json], ['{ "reload": "Staged" }'];
                }
            
                # If $reload is True, return a JSON doc instructing
                # uzu/js/live.js to reload the browser.
                when '/live' {
                    return 200, [$!ct-json], ['{ "reload": "True" }'] if $reload.poll;
                    return 200, [$!ct-json], ['{ "reload": "False" }'];
                }
            
                # Include live.js that starts polling /live for reload instructions
                when '/uzu/js/live.js' {
                    put "GET /uzu/js/live.js";
                    my Str $livejs = q:to|END|; 
                    // Uzu live-reload
                    function live() {
                        var xhttp = new XMLHttpRequest();
                        xhttp.onreadystatechange = function() {
                            if (xhttp.readyState == 4 && xhttp.status == 200) {
                                var resp = JSON.parse(xhttp.responseText);
                                if (resp.reload == 'True') {
                                    document.location.reload();
                                };
                            };
                        };
                        xhttp.open("GET", "/live", true);
                        xhttp.send();
                        setTimeout(live, 1000);
                    }
                    setTimeout(live, 1000);
                    END
            
                    return 200, [$!ct-json], [$livejs];
                }
            
                default {
                    my $file = $_;
            
                    # Trying to access files outside of build path
                    return 400, [$!ct-text], ['Invalid path'] if $file.match('..');
            
                    # Handle HTML without file extension
                    my $index = 'index' ~ ($!omit-html-ext ?? '' !! '.html');
            
                    my IO::Path $path = do given $file {
                        when '/' {
                            $!build-dir.IO.add($index)
                        }
                        when so * ~~ / '/' $ / {
                            $!build-dir.IO.add($file.split('?')[0].IO.add($index))
                        }
                        default {
                            $!build-dir.IO.add($file) ~~ :d
                            ?? $!build-dir.IO.add($file.IO.add($index))
                            !! $!build-dir.IO.add($file.split('?')[0])
                        }
                    }
                    
                    given $path {
                    
                        when !*.IO.e {
                            # Invalid path
                            put "GET $file (not found)";
                            return 400, [$!ct-text], ['Invalid path'];
                        }
            
                        default {
                            # Return any valid paths
                            my %ct = self!detect-content-type($path);
            
                            put "GET $file";
            
                            # HTML
                            if %ct<type> ~~ 'text/html;charset=UTF-8' {
                                return 200, ['Content-Type' => %ct<type> ], [
                                    self.process-livereload(
                                        :content(slurp($path)),
                                        :$!no-livereload
                                    )];
                            }
                            # UTF8 text
                            return 200, ['Content-Type' => %ct<type> ], [slurp($path)] unless %ct<bin>;
                            # Binary
                            return 201, ['Content-Type' => %ct<type> ], [slurp($path, :bin)];
                        }
                    }    
                }
                put "uzu serves [http://localhost:{$!port}]";
            }
        }
        # END http server
      
        HTTP::Server::Tiny.new(:$!host, :$!port).run(&app);
    }

    return @servers;
}

#| Inject livereload JS
method process-livereload( Str :$content, Bool :$no-livereload --> Str ) {
    return '' when !$content.defined;
    unless $no-livereload {
        # Add livejs if live-reload enabled (default)
        my Str $livejs = '<script src="/uzu/js/live.js"></script>';
        if $content ~~ /'</body>'/ {
            return S/'</body>'/$livejs\n<\/body>/ given $content;
        } else {
            return $content ~ "\n$livejs";
        }
    }
    return $content;
}

method wait-port( :$sleep = 0.1, Int :$times = 600 ) {
    LOOP: for 1..$times {
        try {
            my $sock = IO::Socket::INET.new(:$!host, :$!port);
            $sock.close;

            CATCH { default { sleep $sleep; next LOOP } }
        }
        return True;
    }

    die "$!host:$!port doesn't open in {$sleep*$times} sec.";
}

method inet-request( Str $req ) {
    my $client = IO::Socket::INET.new(:$!host, :$!port);
    my $data   = '';
    try {
        $client.print($req);
        sleep .5;
        while my $d = $client.recv {
            $data ~= $d;
        }
        $client.close;
        CATCH { default {} }
    }
    return $data;
}

# From Bailador
method !detect-content-type( IO::Path $file ) {
    my %mapping = (
        appcache => %{ bin => False, type => 'text/cache-manifest' },
        atom     => %{ bin => False, type => 'application/atom+xml' },
        bin      => %{ bin => True,  type => 'application/octet-stream' },
        css      => %{ bin => False, type => 'text/css' },
        eot      => %{ bin => True,  type => 'application/vnd.ms-fontobject' },
        gif      => %{ bin => True,  type => 'image/gif' },
        gz       => %{ bin => True,  type => 'application/x-gzip' },
        htm      => %{ bin => False, type => 'text/html' },
        html     => %{ bin => False, type => 'text/html;charset=UTF-8' },
        ''       => %{ bin => False, type => 'text/html;charset=UTF-8' },
        ico      => %{ bin => True,  type => 'image/x-icon' },
        jpeg     => %{ bin => True,  type => 'image/jpeg' },
        jpg      => %{ bin => True,  type => 'image/jpeg' },
        js       => %{ bin => False, type => 'application/javascript' },
        json     => %{ bin => False, type => 'application/json;charset=UTF-8' },
        mp3      => %{ bin => True,  type => 'audio/mpeg' },
        mp4      => %{ bin => True,  type => 'video/mp4' },
        ogg      => %{ bin => True,  type => 'audio/ogg' },
        ogv      => %{ bin => True,  type => 'video/ogg' },
        otf      => %{ bin => True,  type => 'application/x-font-opentype' },
        pdf      => %{ bin => True,  type => 'application/pdf' },
        png      => %{ bin => True,  type => 'image/png' },
        rss      => %{ bin => False, type => 'application/rss+xml' },
        sfnt     => %{ bin => True,  type => 'application/font-sfnt' },
        svg      => %{ bin => True,  type => 'image/svg+xml' },
        ttf      => %{ bin => True,  type => 'application/x-font-truetype' },
        txt      => %{ bin => False, type => 'text/plain;charset=UTF-8' },
        webm     => %{ bin => True,  type => 'video/webm' },
        woff     => %{ bin => True,  type => 'application/font-woff' },
        woff2    => %{ bin => True,  type => 'application/font-woff' },
        xml      => %{ bin => False, type => 'application/xml' },
        zip      => %{ bin => True,  type => 'application/zip' },
        pm       => %{ bin => False, type => 'application/x-perl' },
        pm6      => %{ bin => False, type => 'application/x-perl' },
        pl       => %{ bin => False, type => 'application/x-perl' },
        pl6      => %{ bin => False, type => 'application/x-perl' },
        p6       => %{ bin => False, type => 'application/x-perl' },
    );

    my $ext = $file.extension.lc;
    return %mapping{$ext} if %mapping{$ext}:exists;
    return %mapping<bin>;
}