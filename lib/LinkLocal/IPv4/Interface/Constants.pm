package LinkLocal::IPv4::Interface::Constants;

our $VERSION = '0.10';

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

"Farmer Tedd was here";
__END__

