package LinkLocal::IPv4::Interface;

use 5.010000;

require Exporter;
our @ISA         = qw(Exporter);
our %EXPORT_TAGS = ();
our @EXPORT_OK   = ();
our @EXPORT      = qw();

# Copyright © 2010 Raymond Mroz
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
#
# Requires:
#	Moose
#	Moose::Util::TypeConstraints
#	IO::Interface::Simple
#	Regexp::Common

use Moose;
use Moose::Util::TypeConstraints;
use IO::Interface::Simple;
use Regexp::Common qw/ net /;

use LinkLocal::IPv4::Interface::Constants;

subtype 'LinkLocalInterface' 
	=> as class_type('IO::Interface::Simple');

coerce 'LinkLocalInterface' 
	=> from 'Str' 
	=> via { IO::Interface::Simple->new($_) };

# =============
# = interface =
# =============
has 'interface' => (
    is      => 'bare',
    isa     => 'LinkLocalInterface',
    handles => {
        get_if_device => 'name',
        get_if_index  => 'index',
        get_if_list   => 'interfaces',
        get_if_addr   => 'address',
        set_if_addr   => 'address',
        get_if_mac    => 'hwaddr',
    },
    coerce => 1,
);

subtype 'IpAddress' 
	=> as 'Str' 
	=> where { /^$RE{net}{IPv4}/ } 
	=> message { "$_: Invalid IPv4 address format." };

# ================
# = address_list =
# ================
has 'address_list' => (
    is       => 'ro',
    isa      => 'ArrayRef[IpAddress]',
    reader   => '_get_address_list',
    builder  => '_build_address_list',
	lazy     => 1,
    init_arg => undef,
);

# =============
# = BUILDARGS =
# =============
around BUILDARGS => sub {
    my $orig = shift;
    my $this = shift;

    if ( @_ == 1 && !ref $_[0] ) {
        return $this->$orig( interface => $_[0] );
    }
    else {
        return $this->$orig(@_);
    }
};

# =======================
# = _build_address_list =
# =======================
sub _build_address_list {
    my $this = shift;

    # Generate srand() seed from mac address
    my $mac       = $this->get_if_mac;
    my @split_mac = split( /':'/, $mac );
    my $seed      = 0;
    foreach my $element (@split_mac) {
        $seed += hex($element);
    }

    # Seed for pseudo-random address generation
    srand($seed);

    # Create a list of 10 pseudo-random Link-Local addresses
    my @llv4_ip_list = ();
    for ( my $iter = 0 ; $iter < 10 ; $iter++ ) {
        $llv4_ip_list[$iter] =
          join( '.', '169.254', ( 1 + int( rand(254) ) ), int( rand(256) ) );
    }

    return \@llv4_ip_list;
}

# ====================
# = get_next_address =
# ====================
sub get_next_address {
    my $this = shift;

    # TODO Fix this, it will break after 10 pulls
    return shift( @{ $this->_get_address_list() } );
}

no Moose;

__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

LinkLocal::IPv4::Interface - Moose-based network interface object wrapper

=head1 SYNOPSIS

  use LinkLocal::IPv4::Interface;
  
  my $if = LinkLocal::IPv4::Interface->new('eth0');
  $if->get_next_address(); 

=head1 DESCRIPTION

Link-Local addresses provide a means for network attached devices to participate in 
unmanaged IP networks. Based upon IETF standard RFC 3927, LinkLocal::IPv4::Interface 
provides a simple and lightweight framework for dynamic configuration of network 
interfaces with IPv4 Link-Local addresses. 

# TODO Add additional/proper POD

=head2 ATTRIBUTES

=over 4

=item 

=back

=head2 EXPORT

	PROBE_WAIT          =>  1 second
	PROBE_NUM           =>  3
	PROBE_MIN           =>  1 second
	PROBE_MAX           =>  2 seconds
	ANNOUNCE_WAIT       =>  2 seconds
	ANNOUNCE_NUM        =>  2
	ANNOUNCE_INTERVAL   =>  2 seconds
	MAX_CONFLICTS       => 10
	RATE_LIMIT_INTERVAL => 60 seconds
	DEFEND_INTERVAL     => 10 seconds


=head1 SEE ALSO

Refer to L<RFC-3927>, "Dynamic Configuration of IPv4 Link-Local Adresses", the complete
text of which can be found in the top level of the package archive.

L<perl>, L<IO::Interface::Simple>, L<Moose>

This project is also hosted on github at:
	git@github.com:raymroz/LinkLocal--IPv4.git

=head1 AUTHOR

Ray Mroz, E<lt>mroz@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 Ray Mroz

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
