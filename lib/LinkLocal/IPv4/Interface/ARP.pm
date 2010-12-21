package LinkLocal::IPv4::Interface::ARP;

our $VERSION = '0.17';

require 5.010_000;

# Copyright (C) 2010 Raymond Mroz
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

use Moose;
use Moose::Util::TypeConstraints;
use LinkLocal::IPv4::Interface::Types;

use Net::Frame::Layer::ETH qw(:consts);
use Net::Frame::Simple;
use Net::Frame::Dump::Online;
use Net::Frame::Device;
use Net::Write::Layer2;
use Net::Netmask;


# ==========
# = packet =
# ==========
has 'packet' => (
    is      => 'ro',
    isa     => 'ArpPacket',
    handles => {
        pack_arp        => 'pack',
        unpack_arp      => 'unpack',
        get_key         => 'getKey',
        get_key_reverse => 'getKeyReverse',
        is_match        => 'match',
        print_arp       => 'print',
        dump_arp        => 'dump',
    },
    coerce => 1,
);


sub send {
    my $this = shift;
    # TODO Handle send, packet object will be passed into a "sender machine"
}

no Moose;

__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

LinkLocal::IPv4::Interface::ARP - An ARP packet wrapper, this class allows for the easy construction
of either link-local Probe or Announce ARP Requests.

=head1 SYNOPSIS

  use LinkLocal::IPv4::Interface::ARP;

  $arp = LinkLocal::IPv4::Interface::ARP->new();

  # Initialize a hash reference for each type of ARP message required.
  my $set_probe    = { srcIp => '000.000.000.000', dstIp => '169.254.100.100' };
  my $set_announce = { srcIp => '169.254.100.100', dstIp => '169.254.100.100' };

  # Setup an ARP Probe packet, testing if link-local address 169.254.100.100 is in use
  $arp->packet( $set_probe );

  # Setup an ARP Announce packet, claiming link-local address 169.254.100.100 on network
  $arp->packet( $set_announce );
  
  # Also valid, if no srcIp hash key, assumes probe and zeroes sender address
  my $set_probe    = { dstIp => '169.254.100.100' };

=head1 DESCRIPTION

This small ARP packet wrapper class plays a critical role in the dynamic configuration of IPv4
link-local addresses. When a new address is pseudo-randomly determined, ARP Probe messages are
sent out over the interface which is being configured with a link-local address. The ARP packets
are of type ARP Request, have the source address zeroed out and the target address (dstIp) set 
to the address which has been selected and is being probed. Three of these ARP Probes are sent 
at randomly spaced intervals and if no conflict is detected during the process, the implementation 
will claim the address for the interface within the unmanaged network.

After an address has been claimed, the implementation requires that three ARP Announce packets 
be broadcast on the network. These packets have both sender and target addresses set to the 
address which has been claimed by the implementation. This is done to clean up any stale ARP
cache's on the local-link.

=head2 ATTRIBUTES

=over 4

=item C<packet>

This attribute holds the custom Moose type ArpPacket which in essence provides and allows for
the Moose class wrapper around the C<Net::Frame::Layer::ARP> object type. The packet attribute
exposes a number of mappings via the Moose attribute handler construct which allow for direct
mapping between them and the object reference type without forcing the additional layer of
indirection upon client code.

=item C<raw>

This attribute is inherited from the original C<Net::Frame::Layer> class and it holds the raw
layer as has just been pulled from the network or has been packed for network transmission (see 
the dump_arp method below).

=back

=head2 METHODS

=over 4

=item C<packet()>

The packet() method provides the most basic means of setting the target and sender addresses
to the desired value, depending upon the type of ARP packet being constructed. packet() takes
both a blessed or non-blessed hash reference, so the return type from object creation can be
passed to this method as long as this blessed reference isa C<Net::Frame::Layer::ARP> object.

=item C<pack_arp()>

Packs all attributes into a raw format suitable for injection into the network. Returns the 
raw packed string on success, undef otherwise. Result is stored into raw attribute. See 
L<Net::Frame::Layer> for further details.

=item C<unpack_arp()>

Unpacks raw data from network and stores attributes into the object. Returns $this on success, 
undef otherwise.

=item C<get_key()> 

=item C<get_key_reverse()>

These two methods are basically used to increase speed when using the recv method from 
C<Net::Frame::Simple> via the packet object attribute. Usually, you use them when you need 
to write an is_match() method.

=item C<is_match()>

This method is mostly used internally. You pass a C<LinkLocal::IPv4::Interface::ARP> packet 
attribute as a parameter, and it returns true if this is a response corresponds with the 
request, otherwise false.

=item C<print_arp()>

Prints a human readable string representation of the packet and its underlying state.

=item C<dump_arp()>

Prints a hexadecimal formatted respresentation of the packet, exactly how this would appear on
the network.

=back

B<Please Note>: While this class does not directly override or map all of the underlying attributes
and methods which are present in the base C<Net::Frame::Layer> type from which the Moose
class is derived, one could, with an extra level of indirection, access the underlying
attributes and methods from that base type. Clients of this module are encouraged to either conform
to the current interface or to extend it via Moose's inheritance mechanism if they wish to access
additional underlying functionality in this way. Please see the relevant POD for further details.

=head1 SEE ALSO

Refer to RFC-3927, "Dynamic Configuration of IPv4 Link-Local Adresses", the complete
text of which can be found in the top level of the package archive.

L<perl>, L<Net::Frame::Layer>, L<Net::Frame::Layer::ARP>, L<Moose>

This project is also hosted on github at:
	git@github.com:raymroz/LinkLocal--IPv4.git

=head1 BUGS

What's a bug???

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
