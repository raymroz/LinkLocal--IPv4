package LinkLocal::IPv4::Interface::Constants;

our $VERSION = '0.10';

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

