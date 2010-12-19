use 5.010000;
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'           => 'LinkLocal::IPv4::Interface',
    'VERSION_FROM'   => 'lib/LinkLocal/IPv4/Interface.pm',
    'BUILD_REQUIRES' => {
        'FindBin'          => '0',
        'Moose::Role'      => '0',
        'Test::Exception'  => '0',
        'Test::Moose'      => '0',
        'Test::More'       => '0.89',
        'Test::Pod'        => '0',
        'attributes'       => '0',
        'metaclass'        => '0',
        'namespace::clean' => '0',
    },
    'PREREQ_PM' => {
        'Moose'                        => '1.20',
        'Moose::Util::TypeConstraints' => '0',
        'IO::Interface::Simple'        => '0',
        'Regexp::Common'               => '2010010201',
        'Net::Frame::Layer::ARP'       => '0',
        'MooseX::Params::Validate'     => '0.15',
        'IO::File'                     => '0.14',
        'Try::Tiny'                    => '0.09',
        'Sys::Syslog'                  => '0.27',
    },
    'test' => { 'TESTS' => 't/*.t', },
    (
        $] >= 5.005
        ? (
            'ABSTRACT_FROM' => 'lib/LinkLocal/IPv4/Interface.pm',
            'AUTHOR'        => 'Ray Mroz <mroz@cpan.org>'
          )
        : ()
    ),
);
