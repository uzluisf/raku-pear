use YAMLish;

unit class Pear::Config;

has $!default-config = q:to/YAML/;
directories:
  templates: templates
  include: include
  posts: posts
  output: public
YAML

has $.posts-dir;
has $.templates-dir;
has $.include-dir;
has $.output-dir;
has %.settings;

#| Load the configuration from the working directory.
method get-config( ::?CLASS:U: $working-dir, $config-name = 'config.yaml' ) {
    my $config-file = $working-dir.IO.add($config-name);

    unless $config-file.e {
        my $prompt = prompt 'No configuration file found. Use default config? [Y/n]: ';
        my $use-default = $prompt.lc.substr(0, 1) eq 'y' ?? True !! False;
        if $use-default {
            say 'Using default config file. Writing...';
            $config-file.spurt($!default-config);
        }
    }

    my %config = load-yaml($config-file.slurp);

    my $pd = $working-dir.IO.add(%config<directories><posts>).Str;
    my $td = $working-dir.IO.add(%config<directories><templates>).Str;
    my $id = $working-dir.IO.add(%config<directories><include>).Str;
    my $od = $working-dir.IO.add(%config<directories><output>).Str;
    my $s  = %config.grep(*.key ne 'directories');

    return self.new:
        posts-dir => $pd,
        templates-dir => $td,
        include-dir => $id,
        output-dir => $od,
        settings => $s
    ;
}
