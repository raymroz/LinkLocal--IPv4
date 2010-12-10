package LinkLocal::IPv4::Interface::Cache;

our $VERSION = '0.16';

require 5.010_000;

# Copyright (C) 2010 Raymond Mroz, Tony Li Xu
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use LinkLocal::IPv4::Interface::Types;
use Moose;
use MooseX::Params::Validate;
use IO::File;
use Try::Tiny;

use feature ':5.10';

# Attributes
has '_cache' => (
    is      => 'bare',
    isa     => 'IO::File',
    builder => '_build_cache',
    lazy    => 1,
    reader  => 'get_cache',
    handles => {
        _slurp_file    => 'getlines',
        _record_ip     => 'printf',
        _refresh_cache => 'seek',
    },
    init_arg => undef,
);

sub _build_cache {
    my $filename;    # Cache file name

    try {

        # Determine the file name based on OS
        given ($^O) {
            when ( m/linux/ || m/bsd/ ) {    # Linux || (Free|Open|Net)BSD
                $filename = "/var/cache/link-local/link-local.tab";
            }
            when (m/darwin/) {               # Mac OS X
                $filename = "/Library/Caches/org.cpan.cache.link-local";
            }
            when (m/solaris/) {              # SunOS
                $filename = "/etc/link-local/link-local.tab";
            }
            when (m/MSWin32/) {              # Windows
                $filename = "%ALLUSERSPROFILE%\\link-local\\link-local.tab";
            }
            default {
                die "Unsupported OS type";
            }
        }

        # Create IO::File object and return
        return new IO::File( "$filename", O_RDWR | O_CREAT );
    }
    catch {
        die "Error while opening cache file: $!";
    };
}

sub get_last_ip {
    my $this = shift;
    my ( @buffer, %cache ) = ();

    # Validate parameters tyeps
    my ($given_ifc) = pos_validated_list( \@_, { isa => 'Str' } );

    # Slurp the contents of buffer into a file
    try {
        $this->_refresh_cache( 0, 0 );
        @buffer = $this->_slurp_file();
    }
    catch {
        die "Error while slurping cache file: $!\n";
    };

    my $size = @buffer;
    if ( $size > 0 ) {

        # Build a hash from if/ip current cache
        foreach my $line (@buffer) {
            chomp($line);
            my ( $if, $ip ) = split( '\t', $line );
            $cache{$if} = $ip;
        }
        return $cache{$given_ifc};
    }
    else {    # Empty buffer
        return undef;
    }
}

sub cache_this_ip {
    my $this = shift;

    # Validate parameters tyeps
    my ( $if, $ip ) =
      pos_validated_list( \@_, { isa => 'Str' }, { isa => 'LinkLocalAddress' } );

    # Get cached IPs if exists
    my %cache = $this->_get_hash_from_cache();

    # Adding IP to hash, creating or overwriting entry as need be.
    $cache{$if} = $ip;

    # Re-position the file-handle to the beginning of the file
    $this->_refresh_cache( 0, 0 );
    foreach my $key ( sort ( keys(%cache) ) ) {
        $this->_record_ip( "%s\t%s\n", $key, $cache{$key} );
    }
}

sub _get_hash_from_cache {
    my $this = shift;
    my ( @buffer, %cache ) = ();

    # Slurp the contents of buffer into a file
    try {
        $this->_refresh_cache( 0, 0 );
        @buffer = $this->_slurp_file();
    }
    catch {
        die "Error while slurping cache file: $!\n";
    };

    # Build a hash from if/ip current cache
    foreach my $line (@buffer) {
        chomp($line);
        my ( $if, $ip ) = split( '\t', $line );
        $cache{$if} = $ip;
    }

    return %cache;
}

no Moose;

__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

LinkLocal::IPv4::Interface::Cache - IPv4 link-local address caching object.

=head1 SYNOPSIS

  use LinkLocal::IPv4::Interface::Cache;

  # Create a cache file object
  my $cache = LinkLocal::IPv4::Interface::Cache->new();
  
  # Get the last IP cached for a given interface
  my $last_address = $cache->get_last_ip('eth0');
  
  # Update the cache when an interface has successfully
  # configured a link-local address
  $cache->cache_this_ip( 'eth0', '169.254.100.150' );

=head1 DESCRIPTION

Implementations of the IPv4 link-local protocol stack will always cache the most recent successfully
configured IPv4 link-local addresses in cases where the host has some form of persistant storage. In
doing so, the next time that implementation begins the address selection process it will read from its
address cache first and attempt to use the last successfully configured address it had previously
used on that interface. This has two benefits; the first is that address collision and conflict are 
less likely during the address selection phase and second is that host interfaces will try and first 
use link-local addresses which have been successfully configured on them in the past which provides a
degree of continuity and address stability in the otherwise unmanaged environment.

This caching object wraps an L<IO::File>, the path to which is determined by the OS on which it is
run. At present Linux, Solaris, OS X, Windows and the BSD derivatives are supported. Each cache maintains
an IPv4 link-local address for each interface which has been successfully configured with one in the past.

=head2 ATTRIBUTES

=over 4

=head3 Public Attributes

=item C<N/A>

=head3 Private Attributes

=item C<_cache>

The private _cache attribute is an L<IO::File> object which represents the IPv4 link-local address
cache for the current implementation. According to the specification, all past successfully configured 
link-local addresses are cached on an interface by interface basis.

=back

=head2 METHODS

=over 4

=head3 Constructors

=item C<new>

This constructor takes no arguments and returns an instance of a link-local address cache file 
object which contains all of the most recent successfully configured link-local addresses, by
interface, on the system.

=head3 Public Methods

=item C<get_last_ip>

get_last_ip() is a public method which takes one argument, a network interface device name 
(such as 'eth0' for example) and it returns the last successfully configured IPv4 link-local address
which was configured on that interface or undef if this interface has never been dynamically
configured with a link-local address. L<MooseX::Params::Validate> is in effect on all arguments.

=item C<cache_this_ip>

cache_this_ip() is a public method which takes two arguments, a network interface device name 
(such as 'eth0' for example) and the link-local IPv4 address in dotted-decimal format which is 
to be cached for that interface as the currently configured IPv4 link-local address but only after
it has been successfully probed and configured as per RFC-3927. L<MooseX::Params::Validate> is in 
effect on all arguments.

=head3 Private Methods

=item C<_get_hash_from_cache>

_get_hash_from_cache() is a private method which builds a hash from the current link-local cache
file containing the most recent successfully configured IPv4 link-local addresses. The hash is
structured in an interface => address key/value format. For example:
  
  eth0 => 169.254.150.120
  eth1 => 169.254.134.288

=item C<_build_cache>

This builder method handles the proper initialization of the private L<_cache> attribute, which is
iself an L<IO::File> object. It detects the OS on which the implementation is being run and from
that, configures the application cache to use the proper location for its environment according 
to current system type.

=item C<_slurp_file>

_slurp_file() is a method delegate on the getlines() method of an L<IO::Handle> object via L<IO::File>.
When called, _slurp_file() returns a list containing the contents of the cache file

=item C<_record_ip>

_record_ip() is a method delegate on the printf() method of an L<IO::Handle> object via L<IO::File>.
This delegate is used to update the cache with the new interface/address mapping.

=item C<_refresh_cache>

_refresh_cache() is a method delegate on the seek() method of an L<IO::Seekable> object via L<IO::File>.
The _refresh_cache() delegate is used to reset the file pointer so that the stream is at the beginning of
the file. This ensures that the next read from the file will have its stream set to the start of the
file.

=back

=head1 SEE ALSO

Refer to RFC-3927, I<Dynamic Configuration of IPv4 Link-Local Adresses>, the complete
text of which can be found in the top level of the package archive.

L<perl>, L<LinkLocal::IPv4::Interface>, L<MooseX::Params::Validate>, L<IO::File>, 
L<Try::Tiny>, L<Moose>

This project is also hosted on github at:
	git@github.com:raymroz/LinkLocal--IPv4.git

=head1 BUGS

What's a bug???

=head1 AUTHOR

Tony Li Xu, E<lt>tonylixu@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 Ray Mroz, Tony Li Xu

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.


=cut
