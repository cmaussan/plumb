package plumb::renderer;

use strict;
use warnings;

use 5.010;

use URI::Escape::XS qw( uri_escape );

use base 'Exporter';
our @EXPORT = qw(
    struct2path
);

sub struct2path {

    my $stations = shift;
    my $struct   = shift;

    my $path = '/render/?';

    while( my ( $option, $value ) = each %{ $struct->{ global } } ) {
        $path .= "&$option=" . ( ( $value ) ? uri_escape( $value ) : '' ); 
    }

    for my $target ( @{ $struct->{ targets } } ) {
        my $sonde = join( ',', map {   
            my $st = $_;
            my $so = $struct->{ pattern } . '.' . $target->{ sonde };
            $so =~ s/__station__/$st/;            
            $so;
        } @$stations );

        for my $function ( @{ $target->{ functions } } ) {
            if( ref $function eq 'HASH' ) {
                my ( $func, $param ) = each %$function;
                $sonde = "$func($sonde,\"$param\")";
            }
            else {
                $sonde = "$function($sonde)";
            }
        }
        $path = $path . "&target=$sonde";
    }

    my $replace = join( ',', @$stations );
    $path =~ s/__station__/$replace/g;

    return $path;
}


1;
__END__
