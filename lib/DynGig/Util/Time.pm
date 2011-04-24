=head1 NAME

DynGig::Util::Time - Interpret time expressions

=cut
package DynGig::Util::Time;

use warnings;
use strict;

use constant { MINUTE => 60, HOUR => 3600, DAY => 86400 };

=head1 METHODS

=head2 rel2sec( expression )

Given a relative time expression, returns seconds.

 $sec = DynGig::Util::Time->rel2sec( '3minutes,-4weeks,+4seconds' );

=cut
sub rel2sec
{
    my ( $class, $time ) = @_;
    my $diff = qr/[+-]?\d+(?:\.\d+)?/;
    my $second = 0;

    return $second unless $time;

    $time =~ s/\s+//;

    for ( split /,+/, $time )
    {
        if ( /^($diff)(?:s|\b)/o ) { $second += $1 }
        elsif ( /^($diff)h/o )     { $second += $1 * HOUR }
        elsif ( /^($diff)d/o )     { $second += $1 * DAY }
        elsif ( /^($diff)w/o )     { $second += $1 * 7 * DAY }
        elsif ( /^($diff)m/o )     { $second += $1 * MINUTE }
    }

    return int $second;
}

=head2 sec2hms( seconds )

Given seconds, returns a HH::MM::SS string.

 $hms = DynGig::Util::Time->sec2hms( 37861 );

=cut
sub sec2hms
{
    my ( $class, $sec ) = @_;
    my $hour = int( $sec / 3600 );
    my $min = int( ( $sec %= 3600 ) / 60 );

    sprintf '%02i:%02i:%02i', $hour, $min, $sec % 60;
}

=head2 hms2sec( string )

Given a HH::MM::SS string, returns seconds.

 $sec = DynGig::Util::Time->hms2sec( '40:23:26' ); ## hour:min:sec
 $sec = DynGig::Util::Time->hms2sec( '23:26' );    ## min:sec
 $sec = DynGig::Util::Time->hms2sec( '26' );       ## sec

=cut
sub hms2sec
{
    my ( $class, $hms ) = @_;
    my @hms = split ':', $hms;

    unshift @hms, 0 while @hms < 3;
    return $hms[0] * 3600 + $hms[1] * 60 + $hms[2];
}

=head1 NOTE

See DynGig::Util

=cut

1;

__END__
