use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

eval {
  require 'LWP';
  # If we don't have LWP, it will be in the prerequisites of WWW::Mechanize anyway ...

  die "You don't seem to have SSL capability built into LWP."
    unless LWP::Protocol::implementor('https')
};

WriteMakefile(
    'NAME'    => 'Finance::Bank::Postbank_de',
    'VERSION_FROM'  => 'lib/Finance/Bank/Postbank_de.pm', # finds $VERSION
    'PREREQ_PM'    => { WWW::Mechanize => 0.35,
                        Test::More => 0,
                      }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'lib/Finance/Bank/Postbank_de.pm', # retrieve abstract from module
       AUTHOR     => 'Max Maischein <corion@cpan.org>') : ()),

    clean => { FILES => 'Finance-Bank-Postbank_de-*' },
);