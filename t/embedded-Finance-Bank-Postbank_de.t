#!D:\Programme\indigoperl-5.6\bin\perl.exe -w

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

my $Original_File = 'D:lib\Finance\Bank\Postbank_de.pm';

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

#line 220 lib/Finance/Bank/Postbank_de.pm

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
is($@, '', "example from line 220");

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
#line 220 lib/Finance/Bank/Postbank_de.pm

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
  is($::_STDOUT_,'New Finance::Bank::Postbank_de created
Connecting to https://banking.postbank.de/anfang.jsp
Logging into function ACCOUNTBALANCE
Getting account statement (default or only one there)
Downloading print version
Balance : 2500.00 EUR
20030520;20030520;GUTSCHRIFT;KINDERGELD                 KINDERGELD-NR 234568/133;ARBEITSAMT BONN;;154.00
20030520;20030520;ÜBERWEISUNG;FINANZKASSE 3991234        STEUERNUMMER 007 03434     EST-VERANLAGUNG 99;FINANZAMT KÖLN-SÜD;;-328.75
20030513;20030513;LASTSCHRIFT;RECHNUNG 03121999          BUCHUNGSKONTO 9876543210;TELEFON AG KÖLN;;-125.80
20030513;20030513;SCHECK;;EC1037406000003;;-511.20
20030513;20030513;LASTSCHRIFT;TEILNEHMERNUMMER 123456789 RUNDFUNK VON 1099 BIS 1299;GEZ KÖLN;;-84.75
20030513;20030513;LASTSCHRIFT;STROMKOSTEN                KD-NR 1462347              JAHRESABRECHNUNG;STADTWERKE MUSTERSTADT;;-580.06
20030513;20030513;INH.SCHECK;;2000123456789;;-100.00
20030513;20030513;SCHECKEINR;EINGANG VORBEHALTEN;GUTBUCHUNG 12345;;1830.00
20030513;20030513;DAUER ÜBERW;DA 100001;;MUSTERMANN, HANS;-31.50
20030513;20030513;GUTSCHRIFT;BEZÜGE                     PERSONALNUMMER 700600170/01;ARBEITGEBER U. CO;;2780.70
20030513;20030513;LASTSCHRIFT;MIETE 600,00 EUR           NEBENKOSTEN 250,00 EUR     OBJEKT 22/328              MUSTERPFAD 567, MUSTERSTADT;EIGENHEIM KG;;-850.00
Closing session
','Retrieving an account statement works');

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
