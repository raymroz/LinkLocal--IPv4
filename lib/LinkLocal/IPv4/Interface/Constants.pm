package LinkLocal::IPv4::Interface::Constants;

our $VERSION = '0.15';

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

use constant {
	# RFC 3927 defined constants
    PROBE_WAIT          => 1,
    PROBE_NUM           => 3,
    PROBE_MIN           => 1,
    PROBE_MAX           => 2,
    ANNOUNCE_WAIT       => 2,
    ANNOUNCE_NUM        => 2,
    ANNOUNCE_INTERVAL   => 2,
    MAX_CONFLICTS       => 10,
    RATE_LIMIT_INTERVAL => 60,
    DEFEND_INTERVAL     => 10,
};

require Exporter;
our @ISA         = qw(Exporter);
our %EXPORT_TAGS = (
    const => [
        qw(
          PROBE_WAIT
          PROBE_NUM
          PROBE_MIN
          PROBE_MAX
          ANNOUNCE_WAIT
          ANNOUNCE_NUM
          ANNOUNCE_INTERVAL
          MAX_CONFLICTS
          RATE_LIMIT_INTERVAL
          DEFEND_INTERVAL
          )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'const'} } );
our @EXPORT    = qw (
  PROBE_WAIT
  PROBE_NUM
  PROBE_MIN
  PROBE_MAX
  ANNOUNCE_WAIT
  ANNOUNCE_NUM
  ANNOUNCE_INTERVAL
  MAX_CONFLICTS
  RATE_LIMIT_INTERVAL
  DEFEND_INTERVAL
);

"PacMan was here";
__END__

=head1 NAME

LinkLocal::IPv4::Interface::Constants - IPv4 link-local protocol constants as defined in RFC-3927

=head1 SYNOPSIS

  use LinkLocal::IPv4::Interface::Constants qw/:consts/;

=head1 DESCRIPTION

These represent the various timing constants as are defined in Section 9 of RFC-3927 as a part of
the IPv4 link-local protocol.

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

Refer to RFC-3927, I<Dynamic Configuration of IPv4 Link-Local Adresses>, the complete
text of which can be found in the top level of the package archive.

L<perl>, L<LinkLocal::IPv4::Interface>

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

