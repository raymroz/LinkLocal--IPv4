package LinkLocal::IPv4::Interface::Logger;

our $VERSION = '0.16';

require 5.010_000;

use LinkLocal::IPv4::Interface::Types;
use Sys::Syslog qw(:standard :macros);
use Moose;
use MooseX::Params::Validate;
use MooseX::SemiAffordanceAccessor;

use feature ':5.10';

# Log level hash, hold codes and integer values
my %loglvl = ( "EMERG"  => 0,
			   "ALERT"  => 1,
			   "CRIT"   => 2,
			   "ERROR"  => 3,
			   "WARN"   => 4,
			   "NOTICE" => 5,
			   "INFO"   => 6,
			   "DEBUG"  => 7,
	);
	
# Attributes
has '_logger',
	isa        => 'Sys::Syslog',
	is  	   => 'ro',
	lazy_build => 1;
	
has 'log_indent',
	isa => 'Str',
	is  => 'rw',
	default => 'LinkLocal--IPv4';
	
has 'log_opt',
	isa => 'Str',
	is  => 'rw',
	default => 'pid,cons';
	
has 'log_facility',
	isa => 'Str',
	is  => 'rw',
	default => 'local3';
	
sub _build__logger {
	my $class = shift;
	my $this = ref Sys::Syslog();
	bless $this, $class;
	return $this->_logger;
}
after '_build__logger' => sub {
	my $this = shift;
	$this->set_log_mask();
};

sub open_log {
	my $this = shift;
	openlog($this->log_indent, $this->log_opt, $this->log_facility);
}

sub set_log_mask {
	my $this = shift;
	setlogmask( ~(&Sys::Syslog::LOG_MASK( $loglvl{"NOTICE"} )) );
}

sub emerg {
	my $this = shift;
	my $message = shift;
	syslog('emerg', "%8s: %s", "Emerg", $message);
}

sub alert {
	my $this = shift;
	my $message = shift;
	syslog('alert', "%8s: %s", "Alert", $message);
}

sub critical {
	my $this = shift;
	my $message = shift;
	syslog('crit', "%8s: %s", "Critical", $message);
}

sub error {
	my $this = shift;
	my $message = shift;
	syslog('err', "%8s: %s", "Error", $message);
}

sub warning {
	my $this = shift;
	my $message = shift;
	syslog('warning', "%8s: %s", "Warning", $message);
}

sub notice {
	my $this = shift;
	my $message = shift;
	syslog('notice', "%8s: %s", "Notice", $message);
}

sub info {
	my $this = shift;
	my $message = shift;
	syslog('info', "%8s: %s", "Info", $message);
}

sub debug {
	my $this = shift;
	my $message = shift;
	syslog('debug', "%8s: %s", "Debug", $message);
}

sub close_log {
	my $this = shift;
	closelog();
}

no Moose;

__PACKAGE__->meta->make_immutable;

