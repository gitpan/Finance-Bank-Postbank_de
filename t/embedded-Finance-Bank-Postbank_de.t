#!/opt/perl58/bin/perl -w

use Test::More 'no_plan';

package Catch;

sub TIEHANDLE {
    my($class, $var) = @_;
    return bless { var => $var }, $class;
}

sub PRINT  {
    my($self) = shift;
    ${'main::'.$self->{var}} .= join '', @_;
}

sub OPEN  {}    # XXX Hackery in case the user redirects
sub CLOSE {}    # XXX STDERR/STDOUT.  This is not the behavior we want.

sub READ {}
sub READLINE {}
sub GETC {}
sub BINMODE {}

my $Original_File = 'lib/Finance/Bank/Postbank_de.pm';

package main;

# pre-5.8.0's warns aren't caught by a tied STDERR.
$SIG{__WARN__} = sub { $main::_STDERR_ .= join '', @_; };
tie *STDOUT, 'Catch', '_STDOUT_' or die $!;
tie *STDERR, 'Catch', '_STDERR_' or die $!;

SKIP: {
    # A header testing whether we find all prerequisites :
      # Check for module Finance::Bank::Postbank_de
  eval { require Finance::Bank::Postbank_de };
  skip "Need module Finance::Bank::Postbank_de to run this test", 1
    if $@;

  # Check for module strict
  eval { require strict };
  skip "Need module strict to run this test", 1
    if $@;


    # The original POD test
        undef $main::_STDOUT_;
    undef $main::_STDERR_;
eval q{
  my $example = sub {
    local $^W = 0;

#line 265 lib/Finance/Bank/Postbank_de.pm

  use strict;
  use Finance::Bank::Postbank_de;
  my $account = Finance::Bank::Postbank_de->new(
                login => '9999999999',
                password => '11111',
                status => sub { shift;
                                print join(" ", @_),"\n"
                                  if ($_[0] eq "HTTP Code")
                                      and ($_[1] != 200)
                                  or ($_[0] ne "HTTP Code");

                              },
              );
  # Retrieve account data :
  my $retrieved_statement = $account->get_account_statement();
  print "Statement date : ",$retrieved_statement->balance->[0],"\n";
  print "Balance : ",$retrieved_statement->balance->[1]," EUR\n";

  # Output CSV for the transactions
  for my $row ($retrieved_statement->transactions) {
    print join( ";", map { $row->{$_} } (qw( tradedate valuedate type comment receiver sender amount ))),"\n";
  };

  $account->close_session;
  # See Finance::Bank::Postbank_de::Account for
  # a simpler example




;

  }
};
is($@, '', "example from line 265");

};
SKIP: {
    # A header testing whether we find all prerequisites :
      # Check for module Finance::Bank::Postbank_de
  eval { require Finance::Bank::Postbank_de };
  skip "Need module Finance::Bank::Postbank_de to run this test", 1
    if $@;

  # Check for module strict
  eval { require strict };
  skip "Need module strict to run this test", 1
    if $@;


    # The original POD test
    {
    undef $main::_STDOUT_;
    undef $main::_STDERR_;
#line 265 lib/Finance/Bank/Postbank_de.pm

  use strict;
  use Finance::Bank::Postbank_de;
  my $account = Finance::Bank::Postbank_de->new(
                login => '9999999999',
                password => '11111',
                status => sub { shift;
                                print join(" ", @_),"\n"
                                  if ($_[0] eq "HTTP Code")
                                      and ($_[1] != 200)
                                  or ($_[0] ne "HTTP Code");

                              },
              );
  # Retrieve account data :
  my $retrieved_statement = $account->get_account_statement();
  print "Statement date : ",$retrieved_statement->balance->[0],"\n";
  print "Balance : ",$retrieved_statement->balance->[1]," EUR\n";

  # Output CSV for the transactions
  for my $row ($retrieved_statement->transactions) {
    print join( ";", map { $row->{$_} } (qw( tradedate valuedate type comment receiver sender amount ))),"\n";
  };

  $account->close_session;
  # See Finance::Bank::Postbank_de::Account for
  # a simpler example




  isa_ok($account,"Finance::Bank::Postbank_de");
  isa_ok($retrieved_statement,"Finance::Bank::Postbank_de::Account");
  $::_STDOUT_ =~ s!^Statement date : \d{8}\n!!m;
  my $expected = <<EOX;
New Finance::Bank::Postbank_de created
Connecting to https://banking.postbank.de/
Activating (?-xism:^Kontoums.*?tze\$)
Getting account statement via default (9999999999)
Downloading text version
Statement date : ????????
Balance : 5314.05 EUR
.berweisung;111111/1000000000/37050198 Finanzkasse 3991234 Steuernummer 00703434;Finanzkasse K.ln-S.d;PETRA PFIFFIG;-328.75
.berweisung;111111/3299999999/20010020 .bertrag auf SparCard 3299999999;Petra Pfiffig;PETRA PFIFFIG;-228.61
Gutschrift;Bez.ge Pers.Nr. 70600170/01 Arbeitgeber u. Co;PETRA PFIFFIG;Petra Pfiffig;2780.70
.berweisung;DA 1000001;Verlagshaus Scribere GmbH;PETRA PFIFFIG;-31.50
Scheckeinreichung;Eingang vorbehalten Gutbuchung 12345;PETRA PFIFFIG;Ein Fremder;1830.00
Lastschrift;Miete 600+250 EUR Obj22/328 Schulstr.7, 12345 Meinheim;Eigenheim KG;PETRA PFIFFIG;-850.00
Inh. Scheck;;2000123456789;PETRA PFIFFIG;-75.00
Lastschrift;Teilnehmernr 1234567 Rundfunk 0103-1203;GEZ;PETRA PFIFFIG;-84.75
Lastschrift;Rechnung 03121999;Telefon AG Köln;PETRA PFIFFIG;-125.80
Lastschrift;Stromkosten Kd.Nr.1462347 Jahresabrechnung;Stadtwerke Musterstadt;PETRA PFIFFIG;-580.06
Gutschrift;Kindergeld Kindergeld-Nr. 1462347;PETRA PFIFFIG;Arbeitsamt Bonn;154.00
Closing session
Activating (?-xism:^Banking beenden\$)
EOX
  for ($::_STDOUT_,$expected) {
    s!\r\n!\n!gsm;
    s![\x80-\xff]!.!gsm;
    # Strip out all date references ...
    s/^\d{8};\d{8};//gm;
  };
  my @got = split /\n/, $::_STDOUT_;
  my @expected = split /\n/, $expected;
  is_deeply(\@got,\@expected,'Retrieving an account statement works')
    or do {
      diag "--- Got";
      diag $::_STDOUT_;
      diag "--- Expected";
      diag $expected;
    };

    undef $main::_STDOUT_;
    undef $main::_STDERR_;
}

};
SKIP: {
    # A header testing whether we find all prerequisites :
    
    # The original POD test
        undef $main::_STDOUT_;
    undef $main::_STDERR_;

};
