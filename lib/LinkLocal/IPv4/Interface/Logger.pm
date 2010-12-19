package LinkLocal::IPv4::Interface::Logger;

our $VERSION = '0.16';

require 5.010_000;

use LinkLocal::IPv4::Interface::Types;
use Sys::Syslog qw/ :standard :macros /;
use Moose;
use MooseX::Params::Validate;
use MooseX::SemiAffordanceAccessor;

use feature ':5.10';

# Log level hash, hold codes and integer values
use constant {
    EMERG  => 0,
    ALERT  => 1,
    CRIT   => 2,
    ERROR  => 3,
    WARN   => 4,
    NOTICE => 5,
    INFO   => 6,
    DEBUG  => 7,
};

# Attributes
has '_logger',
  isa        => 'Sys::Syslog',
  is         => 'ro',
  lazy_build => 1;

has 'log_indent',
  isa     => 'Str',
  is      => 'rw',
  default => 'LinkLocal--IPv4';

has 'log_opt',
  isa     => 'Str',
  is      => 'rw',
  default => 'pid,cons';

has 'log_facility',
  isa     => 'Str',
  is      => 'rw',
  default => 'local3';

sub _build__logger {
    my $class = shift;
    my $this  = ref Sys::Syslog();

    bless $this, $class;
    return $this->_logger;
}
after '_build__logger' => sub {
    my $this = shift;

    $this->set_log_mask();
};

sub open_log {
    my $this = shift;

    openlog( $this->log_indent, $this->log_opt, $this->log_facility );
}

sub set_log_mask {
    my $this = shift;

    setlogmask( ~( &Sys::Syslog::LOG_MASK( NOTICE ) ) );
}

sub emerg {
    my $this = shift;
    my ($message) = pos_validated_list( \@_, { isa => 'Str' } );

    syslog( 'emerg', "%8s: %s", "Emerg", $message );
}

sub alert {
    my $this = shift;
    my ($message) = pos_validated_list( \@_, { isa => 'Str' } );

    syslog( 'alert', "%8s: %s", "Alert", $message );
}

sub critical {
    my $this = shift;
    my ($message) = pos_validated_list( \@_, { isa => 'Str' } );

    syslog( 'crit', "%8s: %s", "Critical", $message );
}

sub error {
    my $this = shift;
    my ($message) = pos_validated_list( \@_, { isa => 'Str' } );

    syslog( 'err', "%8s: %s", "Error", $message );
}

sub warning {
    my $this = shift;
    my ($message) = pos_validated_list( \@_, { isa => 'Str' } );

    syslog( 'warning', "%8s: %s", "Warning", $message );
}

sub notice {
    my $this = shift;
    my ($message) = pos_validated_list( \@_, { isa => 'Str' } );

    syslog( 'notice', "%8s: %s", "Notice", $message );
}

sub info {
    my $this = shift;
    my ($message) = pos_validated_list( \@_, { isa => 'Str' } );

    syslog( 'info', "%8s: %s", "Info", $message );
}

sub debug {
    my $this = shift;
    my ($message) = pos_validated_list( \@_, { isa => 'Str' } );

    syslog( 'debug', "%8s: %s", "Debug", $message );
}

sub close_log {
    my $this = shift;

    closelog();
}

no Moose;

__PACKAGE__->meta->make_immutable;

=head1 NAME

LinkLocal::IPv4::Interface::Logger - A Moose-wrapped syslog interface.

=head1 SYNOPSIS

  my $logger = LinkLocal::IPv4::Interface::Logger->new();

  $logger->set_log_indent("IPv4");
  $logger->set_log_mask();
  $logger->open_log();
  $logger->error("This is a error test");
  $logger->emerg("This is a emerg test");

=head1 DESCRIPTION

This package provides for a Moose'ish encapsulation of basic syslog functionality.  It is in most
ways a simple delegation or mapping to those calls and macros present via L<Sys::Syslog>, but does
so in an OOPish and Moose'ish way.

=head2 ATTRIBUTES

=over 4

=head3 Public Attributes

=item C<log_indent>

Some stuff here

=item C<log_opt>

Foo foo

=item C<log_facility>

Fo Foo Fooo

=head3 Private Attributes

=item C<_logger>

Foo Foo Foo Foo

=back

=head2 METHODS

=over4

=head3 Constructors

=item C<new>

The default constructor takes no arguments and returns an instance of Logger.

=head3 Public Methods

=item C<open_log>

To be done

=item C<set_log_mask>

To be done

=item C<emerg>

To be done

=item C<alert>

To be done

=item C<critical>

To be done

=item C<error>

To be done

=item C<warning>

To be done

=item C<notice>

To be done

=item C<info>

To be done

=item C<debug>

To be done

=item C<close_log>

To be done

=head3 Private Methods

=item C<_build__logger>

Foo Foo Foo

=back

=head1 SEE ALSO

Refer to RFC-3927, I<Dynamic Configuration of IPv4 Link-Local Adresses>, the complete
text of which can be found in the top level of the package archive.

L<perl>, L<Net::Frame::Layer::ARP>, L<IO::Interface::Simple>, L<Regexp::Common>, L<Moose>

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

