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

use IO::File;
use Config;

use LinkLocal::IPv4::Interface;
use LinkLocal::IPv4::Interface::Cache;

use Data::Dump qw/ ddx /;

main();

# ========
# = main =
# ========
sub main {

    my $interface  = 'eth0';
    my $address    = '169.254.150.123';
    my $cache_file = LinkLocal::IPv4::Interface::Cache->new();
    $cache_file->cache_this_ip( $interface, $address );
	my $last_ip = $cache_file->get_last_ip($interface);
	print("last IP is ", $last_ip, "\n");
}

__END__


