#!/usr/bin/env perl

use strict;
use warnings;

use 5.010;

use File::Spec;
use Getopt::Long;
use plumb::renderer qw( struct2path );
use YAML::XS qw( LoadFile );

GetOptions(
    "conf|c=s"     => \my $conf_file,
    "station|s=s"  => \my $station,
    "graph|g=s"    => \my $graph,
);

sub usage {
    say "Usage: plumb-geturl -c CONF -s STATION -g GRAPH";
    exit;
}

usage unless( $conf_file && $station && $graph );

my $conf         = LoadFile( $conf_file );
my $graph_file   = File::Spec->catfile( $conf->{ graph_path }, "$graph.yaml" );
my $graph_struct = LoadFile( $graph_file ); 

say $conf->{ graphite_baseurl } . struct2path( $station, $graph_struct );
