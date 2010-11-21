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
use Data::Dump qw / ddx /;

use LinkLocal::IPv4::Interface::Constants;
use LinkLocal::IPv4::Interface::Types;
use LinkLocal::IPv4::Interface::Daemon;

subtype 'LinkLocalInterface' 
	=> as class_type('IO::Interface::Simple');

coerce 'LinkLocalInterface' 
	=> from 'Str' 
	=> via { IO::Interface::Simple->new($_) };

has 'interface' => (
    is      => 'bare',
    isa     => 'LinkLocalInterface',
    handles => {
        get_device  => 'name',
        get_index   => 'index',
        get_if_list => 'interfaces',
        get_if_addr => 'address',
        set_if_addr => 'address',
        get_if_mac  => 'hwaddr',
    },
    coerce => 1,
);

subtype 'IpAddress' 
	=> as 'Str' 
	=> where { /^$RE{net}{IPv4}/ } 
	=> message { "$_: Invalid IPv4 address format." };
	
has 'address_list' => (
    is       => 'ro',
    isa      => 'ArrayRef[IpAddress]',
    reader   => '_get_address_list',
    builder  => '_build_address_list',
    init_arg => undef,
);

# ==============================
# = BUILDARGS: method modifier =
# ==============================
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

# =========================
# = _build_address_list() =
# =========================
sub _build_address_list {
    my $this = shift;

    # Generate srand() seed from mac address
    my $mac       = $this->get_if_addr;
    my @split_mac = split( /\./, $addy );
    my $seed      = 0;
    foreach my $element (@split_mac) {
        $sum += hex($element);
    }

    my @llv4_ip_list = ();

    #srand( hex($this->get_if_addr) );
    for ( my $x = 0 ; $x < 10 ; $x++ ) {
        $llv4_ip_list[$x] =
          join( '.', '169.254', ( 1 + int( rand(254) ) ), int( rand(256) ) );
    }

    return \@llv4_ip_list;
}

# ======================
# = get_next_address() =
# ======================
sub get_next_address {
    my $this = shift;

    return shift( @{ $this->_get_address_list } );
}

no Moose;

__PACKAGE__->meta->make_immutable;
1;

# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

LinkLocal::IPv4::Interface - Perl extension for blah blah blah

=head1 SYNOPSIS

  use LinkLocal::IPv4::Interface;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for LinkLocal::IPv4::Interface, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Raymond Mroz, E<lt>rmroz@localE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Raymond Mroz

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
