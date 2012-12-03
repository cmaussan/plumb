package plumb;

use Dancer ':syntax';
use File::Spec;
use plumb::renderer qw( struct2path );
use YAML::XS qw( LoadFile );

our $VERSION = '0.1';

sub dashboard_desc {
    my $dashboard_file = File::Spec->catfile( setting( 'dashboard_file' ) );
    LoadFile( $dashboard_file );
}

get '/' => sub {

    my $groups = {};
    my $dashboard_desc = dashboard_desc();
    for ( keys %$dashboard_desc ) {
        push @{ $groups->{ $dashboard_desc->{ $_ }->{ group } } }, { name => $_, url => "/$_" };
    }
    for ( keys %$groups ) {
        $groups->{ $_ } = [ sort { $a->{ name } cmp $b->{ name } } @{ $groups->{ $_ } } ]
    }

    template 'index', {
        groups  => $groups,
    };
};

get '/:dashboard' => sub {
    my $dashboard = params->{ dashboard }; 

    my $options = {};
    $options->{ width }  = params->{ width }  if( params->{ width } );
    $options->{ height } = params->{ height } if( params->{ height } );
    $options->{ from }   = params->{ from }   if( params->{ from } );

    template 'dashboard', {
        dashboard       => $dashboard,
        graphs          => _graph_urls( $dashboard, $options ),
        default_options => setting( 'default_options' ),
    };
};

get '/urls/:dashboard' => sub {
    my $dashboard = params->{ dashboard }; 

    my $options = {};
    $options->{ width }  = params->{ width }  if( params->{ width } );
    $options->{ height } = params->{ height } if( params->{ height } );
    $options->{ from }   = params->{ from }   if( params->{ from } );

    to_json( _graph_urls( $dashboard, $options ) );
};

sub _graph_urls {
    my $dashboard = shift;
    my $options = shift;

    my $dashboard_desc = dashboard_desc();
    my $stations = $dashboard_desc->{ $dashboard }->{ stations };
    my $graphs   = [];

    my $i = 0;
    for my $graph ( @{ $dashboard_desc->{ $dashboard }->{ graphs } } ) {
        if( ref $graph eq 'HASH' ) {
            my ( $name, $arg ) = each %$graph;
            if( ref $arg eq 'ARRAY' ) {
                push @$graphs, { name => $name . '_' . $i++, url => _graph_url( $arg, $name, $options ) };
            }
            elsif( $arg = 'foreach' ) {
                push @$graphs, { name => $name . '_' . $i++ . '_' . $_, url => _graph_url( [ $_ ], $name, $options ) } for( @$stations );
            }
        }
        else {
            push @$graphs, { name => $graph, url => _graph_url( $stations, $graph, $options ) };
        }
    }

    $graphs;
}

sub _graph_url {
    my $stations = shift;
    my $graph    = shift;

    my $options = shift || {};
    $options = { %{ setting( 'default_options' )->{ standard } }, %$options };

    my $graph_file   = File::Spec->catfile( setting( 'graph_path' ), "$graph.yaml" );
    my $graph_struct = LoadFile( $graph_file );

    my $options_string = join( '&', map { "$_=" . $options->{ $_ }  } keys %$options );
    my $path = struct2path( $stations, $graph_struct );
    $path =~ s/\?\&/?$options_string&/;

    return setting( 'graphite_baseurl' ) . $path;
}

true;
