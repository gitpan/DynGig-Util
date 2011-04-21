=head1 NAME

DynGig::Util::CLI::OpsDB - CLI for a simple operations database

=cut
package DynGig::Util::CLI::OpsDB;

use warnings;
use strict;
use Carp;

use Socket;
use YAML::XS;
use IO::Select;
use Pod::Usage;
use Getopt::Long;
use Sys::Hostname;

use DynGig::Util::CLI;
use DynGig::Util::EZDB;
use DynGig::Util::Sysrw;
use DynGig::Range::String;

$| ++;

=head1 EXAMPLE

 use DynGig::Util::CLI::OpsDB;

 DynGig::Util::CLI::OpsDB->main
 (
     master => 'hostname',
     database => '/database/path',
 );

=head1 SYNOPSIS

$exe B<--help>

$exe B<--range> range [B<--delete>] [B<--format> format]

[echo YAML |] $exe YAML [B<--delete>] [B<--format> format]

[echo YAML |] $exe YAML B<--update>

e.g.

To read help menu

 $exe --help

To display record of host001 to host004, in CSV form by name,colo,rack

 $exe -r host001~4 -f '"%s,%s,%s",name,colo,rack'

To display the records of hosts in area A, cab 6, in raw YAML form

 $exe '{area: A, rack: 6}'

To delete the above records

 $exe '{area: A, rack: 6}' -d

To add/update host008,

 $exe 'host008: {area: A, rack: 6, ..}' -u

=cut
sub main
{
    my ( $class, %option ) = @_;

    map { croak "$_ not defined" if ! defined $option{$_} }
        qw( master database );

    my $menu = DynGig::Util::CLI->new
    (
        'h|help',"print help menu",
        'u|update','update database',
        'd|delete','delete from database',
        'r|range=s','range of nodes',
        'f|format=s','display format',
    );

    my %pod_param = ( -input => __FILE__, -output => \*STDERR );

    Pod::Usage::pod2usage( %pod_param )
        unless Getopt::Long::GetOptions( \%option, $menu->option() );

    if ( $option{h} )
    {
        warn join "\n", $menu->string(), "\n";
        return 0;
    }

    if ( $option{u} || $option{d} )
    {
        my %addr;
        my %host =
        ( 
            master => $option{master},
            local => Sys::Hostname::hostname()
        );

        if ( $host{local} ne $host{master} )
        {
            map { croak "Cannot resolve host '$host{$_}'.\n" unless
                $addr{$_} = gethostbyname( $host{$_} ) } keys %host;

            croak "Update must be made on master host '$host{master}'."
                if $addr{local} ne $addr{master};
        }
    }

    croak "poll: $!\n" unless my $select = IO::Select->new();

    my ( $buffer, $length );

    $select->add( *STDIN );

    map { $length = DynGig::Util::Sysrw->read( $_, $buffer ) }
        $select->can_read( 0.1 );

    @ARGV = ( $buffer ) if $length;

    Pod::Usage::pod2usage( %pod_param ) unless @ARGV || $option{r};

    my @input = YAML::XS::Load $ARGV[0] if @ARGV;
    my $error = "Invalid input. Operations aborted.\n";

    map { croak $error if ref $_ ne 'HASH' } @input;

    if ( $option{u} ) ## update
    {
        my %table;

        for my $input ( @input )
        {
            while ( my ( $table, $input ) = each %$input )
            {
                croak $error if ref $input ne 'HASH';
                map { croak $error if ref $_ } values %$input;
                $table{$table} = 1;
            }
        }

        my $db = DynGig::Util::EZDB
            ->new( $option{database}, table => [ keys %table ] );

        for my $input ( @input )
        {
            while ( my ( $table, $input ) = each %$input )
            {
                while ( my ( $key, $val ) = each %$input )
                {
                    $db->set( $table, $key, $val );
                }
            }
        }

        return 0;
    }

    my $db = DynGig::Util::EZDB->new( $option{database} );
    my @table = $db->table();
    my %record;

    if ( $option{r} ) ## by range
    {
        my $range = DynGig::Range::String->new( $option{r} );
        my $table = DynGig::Range::String->new( @table );

        $range &= $table;

        map { $record{$_} = $db->dump( $_ ) } $range->list();
    }
    else              ## by query
    {
        for my $table ( @table )
        {
            my $record = $db->dump( $table );

            for my $query ( @input ) ## or->and
            {
                map { next unless $record->{$_}
                    && $record->{$_} eq $query->{$_} } keys %$query;

                $record{$table} = $record;
                last;
            }
        }
    }

    return 0 unless %record;

    if ( $option{d} ) ## delete
    {
        $class->_dump( \%record );

        map { $db->truncate( $_ ) } keys %record;
        print STDERR "\nThe records above have been deleted.\n";
    }
    else              ## search
    {
        $class->_dump( \%record, $option{f} );
    }

    return 0;
}

sub _dump
{
    my ( $this, $record, $format ) = @_;

    if ( $format )
    {
        my @format = $format =~ /^\s*(".+?")\s*,\s*([^"]+)$/;
        my @field = split /\s*,\s*/, $format[1];

        $format = eval $format[0];

        for my $table ( sort keys %$record )
        {
            my $record = $record->{$table};

            $record->{name} = $table;

            printf $format,
                map { defined $record->{$_} ? $record->{$_} : '' } @field;

            print "\n";
        }
    }
    else
    {
        YAML::XS::DumpFile \*STDOUT, $record;
    }
}

=head1 NOTE

See DynGig::Util

=cut

1;

__END__
