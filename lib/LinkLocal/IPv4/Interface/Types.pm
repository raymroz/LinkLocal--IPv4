package LinkLocal::IPv4::Interface::Types;

require 5.010000;

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

use Moose;
use Moose::Util::TypeConstraints;
use Regexp::Common qw/net/;
use Net::Frame::Layer::ARP qw/:consts/;
use IO::Interface::Simple;

subtype 'ArpPacket' 
	=> as class_type('Net::Frame::Layer::ARP');

coerce 'ArpPacket' 
	=> from 'HashRef' 
	=> via { Net::Frame::Layer::ARP->new( %{$_} ) };

subtype 'LinkLocalInterface' 
	=> as class_type('IO::Interface::Simple');

coerce 'LinkLocalInterface' 
	=> from 'Str' 
	=> via { IO::Interface::Simple->new($_) };

subtype 'IpAddress' 
	=> as 'Str' 
	=> where { /^$RE{net}{IPv4}/ } 
	=> message { "$_: Invalid IPv4 address format." };
	
subtype 'LinkLocalAddress'
	=> as 'IpAddress'
	=> where { /^/ }
	=> message { "$_: Invalid IPv4 Link-Local Address" };

no Moose;

__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

LinkLocal::IPv4::Interface::Types - A collection of shared Moose type definitions and coercions.

=head1 SYNOPSIS

  use LinkLocal::IPv4::Interface::Types;

  has 'ip_address' => (
      is  => 'ro',
      isa => 'IpAddress',
  );

  has 'packet' => (
      is  => 'ro',
      isa => 'ArpPacket',
  );

=head1 DESCRIPTION

This Moose-based wrapper object provides a collection of shared types compliant with and dependant
upon the Moose type and constraint system. All type coercions are also present here. Client code 
only need 'use' this file and it has access to all custom types in a system wide fashion.

=head1 SUBTYPES

=over 4

=item B<ArpPacket> 
 From base type Object, isa L<Net::Frame::Layer::ARP>. ArpPacket provides the basis for both
 ARP Probes and Announce messages, both of which are required in the implementation of
 RFC-3927.

=item LinkLocalInterface
 From base type Object, isa L<IO::Interface::Simple>. LinkLocalInterface is a custom object
 wrapper of a hardware network interface on the system being configured for dynamic link-local
 addressing. It provides an entry point to this auto-ip framework.

=item B<IpAddress>
 From base type Str, uses L<Regexp::Common> to provide a type constraint for IPv4 dotted-decimal 
 notation addresses.

=item B<LinkLocalAddress>
 From base type IpAddress, this type provides for a type constraint for IPv4 dotted-decimal
 notation addresses as is specified in RFC-3927; The prefix 169.254/16 is reserved by IANA for
 the exclusive use of link-local address allocation (noting that the first 256 and last 256 
 addresses in the 169.254/16 prefix are reserved for future use and MUST NOT be selected by 
 a host using this dynamic configuration mechanism).

=back

=head1 COERCIONS

=over 4

=item B<ArpPacket>
Type coercion of a Moose HashRef into an ArpPacket type via a L<Net::Frame::Layer::ARP>
object type.

=item B<LinkLocalInterface>
Type coercion of a Moose Str type representing a network device name into an object of
type L<IO::Interface::Simple>.

=back

=head1 SEE ALSO

Refer to RFC-3927, "Dynamic Configuration of IPv4 Link-Local Adresses", the complete
text of which can be found in the top level of the package archive.

L<perl>, L<Net::Frame::Layer::ARP>, L<IO::Interface::Simple>, L<Regexp::Common>, L<Moose>

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