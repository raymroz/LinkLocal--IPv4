package LinkLocal::IPv4::Interface;

require 5.010000;

# require Exporter;
# our @ISA         = qw(Exporter);
# our %EXPORT_TAGS = ();
# our @EXPORT_OK   = ();
# our @EXPORT      = qw();

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
#
# Requires:
#	Moose
#	Moose::Util::TypeConstraints
#	IO::Interface::Simple
#	Regexp::Common

use Moose;
use Moose::Util::TypeConstraints;
use LinkLocal::IPv4::Interface::Types;

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
sub _get_next_address {
    my $this = shift;

    # TODO Fix this, it will break after 10 pulls
    return shift( @{ $this->_get_address_list() } );
}

# =============
# = if_config =
# =============
sub if_config {
	my $this = shift;
	
	# TODO Call back end code here 
}

no Moose;

__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

LinkLocal::IPv4::Interface - Moose-based network interface object wrapper

=head1 SYNOPSIS

  use LinkLocal::IPv4::Interface;
  
  my $if_obj = LinkLocal::IPv4::Interface->new('eth0');
  
  # TODO: finalize method signature and process
  $if_obj->if_config( $arg_a, $arg_b ); 

=head1 DESCRIPTION

This package represents a lightweight, pure Perl implementation of the specification
as outlined in F<RFC-3927>, I<Dynamic Configuration of IPv4 Link-Local Addresses>.
This standard details a mechanism which provides a means of enabling automatic IPv4
address allocations to network addressible entities and devices which by happenstance
or design find themselves on an unmanaged, ad hoc IP network with no other means of
aquiring a fully routable, unicast IPv4 address. As the name implies, link-local IPv4
addresses are non-routable with all participating devices connected to the same physical
link; this fact all but dictates that such networks are typically small. Home networks or
other such small environments are well suited to the deployment of this standard. While 
there are, in theory, upwards of 65,024 addresses available in the range for allocations,
the reality is that as more addresses from the reserved range are allocated to hosts on
the local link the number of collisions necessarily increases as well which degrades 
overall performance. Products such as QIP meet this need in the enterprise.

This standard is widely implemented in most major operating systems, most of which "more 
or less" adhere to this specification. While I have remained true to the specification
and to the algorithms detailed therein I have in some ways made "enhancements"; one
example being my pseudorandom address selection will generate link-local addresses in
blocks of ten. This is similar to the implementation found in OS X and some of the 
various offerings by Microsoft. This decision was simply a matter of convenience and 
nothing more.

This module, C<LinkLocal::IPv4::Interface> provides the main entry point into this
implementation. Because the specification recommends that link-local address are generated
in a pseudorandom fashion using something unique to the particular host on which they
are being generated such as a MAC address, I have by design coupled the selection of 
addresses closely with the interface object itself; given that I am indeed using the 
interface hardware MAC as a seed to C<srand()> this just made good sense to me. The primary
gateway into this process is the call to the C<if_config()> method. This method will step
through the various steps in the address selection process and will configure the interface
with a fully compliant IPv4 link-local address upon completion.

There are some things I would like to note here. First, this implementation makes absolutely
no assumptions about the current state of the interface at any time. Client code should
know this. The specification is quite clear that IPv4 link-local addresses are to be used
only in the absence of a fully routable IPv4 address. The dynamic configuration of an
IPv4 link-local address is to never interfere with the operation of any of the other
processes whereby a host can aquire a standard, routable address such as a DHCP state
machine or static assignments under the direction of a network administrator. This 
implementation is B<only> to be used at such a time that a determination has been made that
there are no operable and routable addresses configured on the interface. This library
does not at any time make any assumptions about the operability of any addresses assigned
to any interfaces on the host, nor does it in any way attempt to determine the management
status of any network in which it participates. This is an important point to consider here 
as small networks have become ubiquitous and "network hopping" with portable devices is 
certainly a scenario that is much more common today than it was ten or even years ago.
Secondly, the configuration of an IPv4 link-local address is not something which is a
static thing; the implementation does not just probe the local physical link for the
address, configure the interface and forget about it. At any time an address conflict may
occur at which time the selection process may begin again. I have addressed this fact in my
design in a broad way. Client code will be expected to register a callback on a hook I 
provide. Furthermore, I will also expose an optional pure Perl eventing mechanism which can be
set to monitor ARP on the local link for any requests or replies which contain the currently
configured link-local address. The other option here is that client code may wish to bring
its own eventing mechanism to the party. As such I have met both needs by way of Marc
Lehmann's AnyEvent module which has been described as the DBI of event loops. For those
not familiar with Marc's AnyEvent and Coro material, you might want to run over and check
out his stuff. In the world of asynchronous Perl eventing and coroutines, Marc is Master Yoda.

B<NOTE:> This is still very much a work in progress. Much of this is pulled from some old 
stuff which I had around, including bits and bobs of some UPnP stuff I had in C and which
I reimplemented in Perl. As such, some design is happening in situ. In addition to this, I
do, unfortunately, have to go to work and feed myself so I am unable to hack on this and
other things 24/7. I decided that I would push to CPAN early and chase my crufty push rather
than keep it in a git repo on my Mac and constantly pick and preen it and never get anything
actually out. So all that said, I will release as quickly and as often as I can and hopefully
I will have something here approaching actually useful before long at all, so please bear
with me and thanks for your patience.

Also, this is fully intended to work along side such other protocols as Multicast Service
Discovery and other lightweight service announcement protocols. The ability to get a
valid address usable in communication with other hosts and devices on an unmanaged network
is not terribly useful if you cannot find anything out about the particular network in 
question. As such I am toying with the idea of integrating, albeit very loosely, one or more
of the service discovery mechanisms out there as this is what makes link-local addressing
actually useful, scenarios such as plugging a laptop and a printer into a network and they
just work. While yes, there are full zero configuration suites out there in C and in other
languages, there is no lightweight equivalent in Perl.... yet.

=head2 DEPENDENCIES

L<Moose>

L<Moose::Util::TypeConstraints>

L<MooseX::Params::Validate>

L<IO::Interface::Simple>

L<Net::Frame::Layer::ARP>

L<Net::Frame::Simple>

L<Regexp::Common>

=head2 ATTRIBUTES

=over 4

=item C<interface>

The interface attribute contains a reference to the C<IO::Interface::Simple> object
type which is instantiated via a C<Moose> type coercion from a string representation of
the interface device name. The interface attribute also provides for a number of 
mappings to the underlying objects methods and attributes by way of the very powerful
C<Moose> delegation feature.

=item C<address_list>

The address_list attribute is set to contain a list of ten MAC seeded, pseudorandomly
generated IPv4 link-local addresses. As interfaces are checked for collison on the 
network by way of ARP probes to determine if they are already in use, they are popped 
off of the list.

=back

=head2 CONSTRUCTORS

=over 4

=item C<new>

This lone constructor takes the name of a network device on the system, as a string
and returns a Moose-wrapped C<IO::Interface::Simple> object.

=back

=head2 METHODS

=over 4

=item C<get_if_device>

This call returns a string representation of the interface.

=item C<get_if_index>

Returns the interface index (only valid on BSD-style systems).

=item C<get_if_list>

Returns a list comprised of all detected interfaces on the system.  Note, this
will not return a member for the loopback interface.

=item C<get_if_addr>

Returns the string representation of the IPv4 address to which the interface is
currently configured. The address is in dotted-decimal notation.

=item C<set_if_addr>

Attempts to set the interface to the IPv4 address string which it takes as its lone
parameter. The address must be in dotted-decimal format.

=item C<get_if_mac>

Returns the string representation of the hardware address of the interface. The
returned hardware address is in standard colon seperated, hexadecimal digit format.

=item C<get_next_ip>

Returns and pops the next available, pseudo-randomly generated IPv4 link-local address
from the attribute list, shrinking that list by one.

=item C<if_config>

General gateway method to this framework. A call to if_config begins the process of
dynamically configuring the specified interface with an IPv4 link-local address. This 
call initiates the process of checking the link-local address cache for the last successfully
configured address otherwise a list of ten, new pseudo-random generated addresses is
created. The implementation fully adheres to the specification as defined in F<RFC-3927>
as it ARP Probes the first address in the list or from the cache to determine if it is
already in use elsewhere on the local link. If it gets no response to its probe packets,
it configures the interface with the address and sends ARP Announce packets announcing
that it has claimed the address as well as to clear stale ARP cache entries which might
exist out on the link. If at any time an ARP packet, request or reply, is detected which
contains the address it has selected, it will either concede the address or make a single
attempt at address defense, depending upon the context of the packet and its current 
state.

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

Refer to F<RFC-3927>, I<Dynamic Configuration of IPv4 Link-Local Adresses>, the complete
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
