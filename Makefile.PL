use 5.010000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'LinkLocal::IPv4::Interface',
    VERSION_FROM      => 'lib/LinkLocal/IPv4/Interface.pm', # finds $VERSION
    PREREQ_PM         => { Moose => 1.20, Moose::Util::TypeConstraints => 1.20, IO::Interface::Simple => 1.05, Regexp::Common => 2010010201, 
        Net::Frame::Layer::ARP => 1.06, MooseX::Params::Validate => 0.15, IO::File => 0.14, Try::Tiny => 0.09, Test::More => 0.96  }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/LinkLocal/IPv4/Interface.pm', # retrieve abstract from module
       AUTHOR         => 'Ray Mroz <mroz@cpan.org>') : ()),
);
