use YAMLish;
use Log;

unit class Pear::Config;

########################################
# public attributes
########################################

has $.working-dir is required;
has $.config-name is rw = 'config.yaml';

########################################
# private attributes
########################################

has IO::Path $!content-dir;
has IO::Path $!templates-dir;
has IO::Path $!include-dir;
has IO::Path $!output-dir;
has          %!settings;

has Log $!log .= new;

########################################
# public methods
########################################

submethod TWEAK {
    self.load-config();
}

#| Load the configuration from the working directory.
method load-config {
    my $config-file = $!working-dir.IO.add($!config-name);

    unless $config-file.e {
        my $prompt = prompt 'No configuration file found. Use default config? [Y/n]: ';
        my $use-default = $prompt.lc.substr(0, 1) eq 'y' ?? True !! False;

        if $use-default {
            $!log.info("Writing default config at '{$!config-name}'");
            $config-file.spurt(%?RESOURCES<config.yaml>.slurp);
        }
    }

    my %config = load-yaml($config-file.slurp);

    given $!working-dir {
        $!content-dir   = $_.IO.add(%config<directories><content>);
        $!templates-dir = $_.IO.add(%config<directories><templates>);
        $!include-dir   = $_.IO.add(%config<directories><include>);
        $!output-dir    = $_.IO.add(%config<directories><output>);
        %!settings      = %config.grep(*.key ne 'directories');
    }
}

method content-dir   { $!content-dir   }
method templates-dir { $!templates-dir }
method include-dir   { $!include-dir   }
method output-dir    { $!output-dir    }
method settings      { %!settings      }
