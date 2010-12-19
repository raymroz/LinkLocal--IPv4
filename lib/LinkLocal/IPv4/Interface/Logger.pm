package LinkLocal::IPv4::Interface::Logger;

our $VERSION = '0.16';

require 5.010_000;

use LinkLocal::IPv4::Interface::Types;
use Sys::Syslog qw/ :standard :macros /;
use Moose;
use MooseX::Params::Validate;

use feature ':5.10';

# Log level constants
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
has '_logger' => (
    isa     => 'Sys::Syslog',
    is      => 'bare',
    lazy    => 1,
    builder => '_build_logger',
);

# Builder
sub _build_logger {
    my $class = shift;
    my $this  = ref Sys::Syslog();

    bless $this, $class;
    return $this->_logger;
}

# Modifier
after '_build_logger' => sub {
    my $this = shift;

    $this->_set_log_mask();
};

# Methods
sub open_log {
    my ( $self, %params ) = validated_hash(
        \@_,
        indent => { isa => 'Str', optional => 1, default => 'LinkLocal--IPv4' },
        options  => { isa => 'Str', optional => 1, default => 'pid,cons' },
        facility => { isa => 'Str', optional => 1, default => 'user' }
    );

    openlog( $params{indent}, $params{options}, $params{facility} );
}

sub _set_log_mask {
    my $this = shift;

    setlogmask( ~( &Sys::Syslog::LOG_MASK(NOTICE) ) );
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

  $logger->open_log( indent => 'IPv4' );
  $logger->error("This is an error test");
  $logger->emerg("This is an emerg test");
  $logger->close_log();
  
  $logger->open_log( indent => 'IPv4--Test', facility => 'local3' );
  $logger->debug("This is a debug test");
  $logger->notice("This is a notice test");
  $logger->close_log();

=head1 DESCRIPTION

This package provides for a Moose'ish encapsulation of basic syslog functionality.  It is in most
ways a simple delegation or mapping to those calls and macros present via L<Sys::Syslog>, but does
so in an OOPish and Moose'ish way.

=head2 ATTRIBUTES

=over 4

=head3 Public Attributes

=item C<N/A>

=head3 Private Attributes

=item C<_logger>

The wrapped logger object instance.

=back

=head2 METHODS

=over4

=head3 Constructors

=item C<new>

The default constructor takes no arguments and returns an instance of the Logger
object.

=head3 Public Methods

=item C<open_log>

Opens up the syslog instance for writing. Can take optional indent, options and
facility arguments although sane defaults are provided by L<MooseX::Params::Validate>.

=item C<emerg>

=item C<alert>

=item C<critical>

=item C<error>

=item C<warning>

=item C<notice>

=item C<info>

=item C<debug>

Each of the above public methods take a message argument and logs it at the appropriate
level.

=item C<close_log>

Close the syslog instance for writing.

=head3 Private Methods

=item C<_set_log_mask>

This private method is used to set a default log level mask. Called by the logger's builder
method modifier.

=item C<_build_logger>

Builds a logger object instance from the L<Sys::Syslog> interface and wraps it as a L<Moose>
class type.

=back

=head1 SEE ALSO

Refer to RFC-3927, I<Dynamic Configuration of IPv4 Link-Local Adresses>, the complete
text of which can be found in the top level of the package archive.

L<perl>, L<Moose>, L<MooseX::Params::Validate>, L<Sys::Syslog>

This project is also hosted on github at:
	git@github.com:raymroz/LinkLocal--IPv4.git

=head1 BUGS

What's a bug???

=head1 AUTHOR

Tony Li Xu, E<lt>tonylixu@gmail.comE<gt>, Ray Mroz, E<lt>mroz@cpan.orgE<gt>

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

