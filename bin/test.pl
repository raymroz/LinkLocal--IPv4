#!/opt/local/bin/perl

# Script: test.pl
#
# Created by Raymond Mroz on 2010-11-21

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

use strict;
use warnings;
use feature ':5.10';

use FindBin;
use lib "$FindBin::RealBin/../lib";

use LinkLocal::IPv4::Interface;
use LinkLocal::IPv4::Interface::ARP;

use Data::Dump qw/ ddx /;


main();

# ========
# = main =
# ========
sub main {
	say "Testing LinkLocal::IPv4::Interface";

}

__END__


