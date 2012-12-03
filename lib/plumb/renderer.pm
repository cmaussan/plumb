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

    # http://test1204.rtgi.eu/graphite/render/?width=950&height=400&from=-36h&fontSize=10&title=Radar%20Prod%20-%20Global%20memory&targets=&until=&vtitle=&fontName=DroidSans&lineMode=slope&thickness=2&bgcolor=000000&fgcolor=CCCCCC&majorGridLineColor=%23ADADAD&minorGridLineColor=%23E5E5E5&yMin=&yMax=&areaMode=stacked&hideLegend=&target=alias(scale(color(monitoring.nagios.node4.mem_used%2C%22red%22)%2C1024)%2C%22used%22)&target=alias(scale(color(monitoring.nagios.node4.mem_buffers%2C%22blue%22)%2C1024)%2C%22buffers%22)&target=alias(scale(color(monitoring.nagios.node4.mem_cached%2C%22orange%22)%2C1024)%2C%22cached%22)&target=alias(scale(color(monitoring.nagios.node4.mem_free%2C%22green%22)%2C1024)%2C%22free%22)&_timestamp_=1348659987009#.png

    my $path = '/render/?';

    while( my ( $option, $value ) = each %{ $struct->{ global } } ) {
        $path .= "&$option=" . ( ( $value ) ? uri_escape( $value ) : '' ); 
    }

    for my $target ( @{ $struct->{ targets } } ) {
        my $sonde = join( ',', map {   
            my $st = $_;
            my $so = $struct->{ pattern } . 
                ( ( $target->{ sonde } ) ?  '.' . $target->{ sonde } : '' );
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
