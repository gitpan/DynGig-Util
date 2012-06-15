=head1 NAME

DynGig::Util - A collection of Utility modules

=cut
package DynGig::Util;

=head1 VERSION

Version 0.08

=cut
our $VERSION = '0.08';

=head1 MODULES

=head2 DynGig::Util::CLI 

An easy-to-print CLI menu for Getopt

=head2 DynGig::Util::LockFile::Time

timed lock with an advisory file

=head2 DynGig::Util::LockFile::PID

pid lock with an advisory file

=head2 DynGig::Util::Setuid

Become a user by Setting uid/gid or invoking sudo

=head2 DynGig::Util::EZDB

Interface to a single-schema SQLite DB

=head2 DynGig::Util::Logger

Thread-safe logging

=head2 DynGig::Util::Sysrw

sysread/syswrite wrappers reliable on EAGAIN

=head2 DynGig::Util::Time

Interpret time expressions

=head2 DynGig::Util::TCPServer

A generic multithreaded TCP Server interface.

=head2 DynGig::Util::MapReduce 

A Map Reduce Job Launcher

=head2 DynGig::Util::MultiPhase

A multi-phase task launcher

=head2 DynGig::Util::CLI::OpsDB

CLI for a simple operations database

=head2 DynGig::Util::CLI::Service

CLI for daemontools service

=head1 AUTHOR

Kan Liu

=head1 COPYRIGHT and LICENSE

Copyright (c) 2010. Kan Liu

This program is free software; you may redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

__END__
