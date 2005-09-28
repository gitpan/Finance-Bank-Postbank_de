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

my $Original_File = 'lib/Finance/Bank/Postbank_de/Account.pm';

package main;

# pre-5.8.0's warns aren't caught by a tied STDERR.
$SIG{__WARN__} = sub { $main::_STDERR_ .= join '', @_; };
tie *STDOUT, 'Catch', '_STDOUT_' or die $!;
tie *STDERR, 'Catch', '_STDERR_' or die $!;

SKIP: {
    # A header testing whether we find all prerequisites :
      # Check for module Crypt::SSLeay
  eval { require Crypt::SSLeay };
  skip "Need module Crypt::SSLeay to run this test", 1
    if $@;

  # Check for module Finance::Bank::Postbank_de::Account
  eval { require Finance::Bank::Postbank_de::Account };
  skip "Need module Finance::Bank::Postbank_de::Account to run this test", 1
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

#line 261 lib/Finance/Bank/Postbank_de/Account.pm

  use strict;
  require Crypt::SSLeay; # It's a prerequisite
  use Finance::Bank::Postbank_de::Account;
  my $statement = Finance::Bank::Postbank_de::Account->parse_statement(
                number => '9999999999',
                password => '11111',
              );
  # Retrieve account data :
  print "Balance : ",$statement->balance->[1]," EUR\n";

  # Output CSV for the transactions
  for my $row ($statement->transactions) {
    print join( ";", map { $row->{$_} } (qw( tradedate valuedate type comment receiver sender amount ))),"\n";
  };




;

  }
};
is($@, '', "example from line 261");

};
SKIP: {
    # A header testing whether we find all prerequisites :
      # Check for module Crypt::SSLeay
  eval { require Crypt::SSLeay };
  skip "Need module Crypt::SSLeay to run this test", 1
    if $@;

  # Check for module Finance::Bank::Postbank_de::Account
  eval { require Finance::Bank::Postbank_de::Account };
  skip "Need module Finance::Bank::Postbank_de::Account to run this test", 1
    if $@;

  # Check for module strict
  eval { require strict };
  skip "Need module strict to run this test", 1
    if $@;


    # The original POD test
    {
    undef $main::_STDOUT_;
    undef $main::_STDERR_;
#line 261 lib/Finance/Bank/Postbank_de/Account.pm

  use strict;
  require Crypt::SSLeay; # It's a prerequisite
  use Finance::Bank::Postbank_de::Account;
  my $statement = Finance::Bank::Postbank_de::Account->parse_statement(
                number => '9999999999',
                password => '11111',
              );
  # Retrieve account data :
  print "Balance : ",$statement->balance->[1]," EUR\n";

  # Output CSV for the transactions
  for my $row ($statement->transactions) {
    print join( ";", map { $row->{$_} } (qw( tradedate valuedate type comment receiver sender amount ))),"\n";
  };




  isa_ok($statement,"Finance::Bank::Postbank_de::Account");
  my $expected = <<EOX;
Balance : 5314.05 EUR
.berweisung;111111/1000000000/37050198 FINANZKASSE 3991234 STEUERNUMMER 00703434;Finanzkasse K.ln-S.d;PETRA PFIFFIG;-328.75
.berweisung;111111/3299999999/20010020 .BERTRAG AUF SPARCARD 3299999999;Petra Pfiffig;PETRA PFIFFIG;-228.61
Gutschrift;BEZ.GE PERS.NR. 70600170/01 ARBEITGEBER U. CO;PETRA PFIFFIG;Petra Pfiffig;2780.70
.berweisung;DA 1000001;Verlagshaus Scribere GmbH;PETRA PFIFFIG;-31.50
Scheckeinreichung;EINGANG VORBEHALTEN GUTBUCHUNG 12345;PETRA PFIFFIG;Ein Fremder;1830.00
Lastschrift;MIETE 600+250 EUR OBJ22/328 SCHULSTR.7, 12345 MEINHEIM;Eigenheim KG;PETRA PFIFFIG;-850.00
Inh. Scheck;;2000123456789;PETRA PFIFFIG;-75.00
Lastschrift;TEILNEHMERNR 1234567 RUNDFUNK 0103-1203;GEZ;PETRA PFIFFIG;-84.75
Lastschrift;RECHNUNG 03121999;Telefon AG Köln;PETRA PFIFFIG;-125.80
Lastschrift;STROMKOSTEN KD.NR.1462347 JAHRESABRECHNUNG;Stadtwerke Musterstadt;PETRA PFIFFIG;-580.06
Gutschrift;KINDERGELD KINDERGELD-NR. 1462347;PETRA PFIFFIG;Arbeitsamt Bonn;154.00
EOX
  for ($::_STDOUT_,$expected) {
    s!\r\n!!gsm;
    # Strip out all date references ...
    s/^\d{8};\d{8};//gm;
    s![\x80-\xff]!.!gsm;
  };
  is_deeply([split /\n/, $::_STDOUT_],[split /\n/, $expected],"Retrieved the correct data")
    or do {
      diag "--- Expected";
      diag $expected;
      diag "--- Got";
      diag $::_STDOUT_;
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
SKIP: {
    # A header testing whether we find all prerequisites :
      # Check for module Finance::Bank::Postbank_de::Account
  eval { require Finance::Bank::Postbank_de::Account };
  skip "Need module Finance::Bank::Postbank_de::Account to run this test", 1
    if $@;

  # Check for module FindBin
  eval { require FindBin };
  skip "Need module FindBin to run this test", 1
    if $@;

  # Check for module List::Sliding::Changes
  eval { require List::Sliding::Changes };
  skip "Need module List::Sliding::Changes to run this test", 1
    if $@;

  # Check for module MIME::Lite
  eval { require MIME::Lite };
  skip "Need module MIME::Lite to run this test", 1
    if $@;

  # Check for module Tie::File
  eval { require Tie::File };
  skip "Need module Tie::File to run this test", 1
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

#line 415 lib/Finance/Bank/Postbank_de/Account.pm

  #!/usr/bin/perl -w
  use strict;

  use Finance::Bank::Postbank_de::Account;
  use Tie::File;
  use List::Sliding::Changes qw(find_new_elements);
  use FindBin;
  use MIME::Lite;

  my $filename = "$FindBin::Bin/statement.txt";
  tie my @statement, 'Tie::File', $filename
    or die "Couldn't tie to '$filename' : $!";

  my @transactions;

  # See what has happened since we last polled
  my $retrieved_statement = Finance::Bank::Postbank_de::Account->parse_statement(
                         number => '9999999999',
                         password => '11111',
                );

  # Output CSV for the transactions
  for my $row (reverse @{$retrieved_statement->transactions()}) {
    push @transactions, join( ";", map { $row->{$_} } (qw( tradedate valuedate type comment receiver sender amount )));
  };

  # Find out what we did not already communicate
  my (@new) = find_new_elements(\@statement,\@transactions);
  if (@new) {
    my ($body) = "<html><body><table>";
    my ($date,$balance) = @{$retrieved_statement->balance};
    $body .= "<b>Balance ($date) :</b> $balance<br>";
    $body .= "<tr><th>";
    $body .= join( "</th><th>", qw( tradedate valuedate type comment receiver sender amount )). "</th></tr>";
    for my $line (@{[@new]}) {
      $line =~ s!;!</td><td>!g;
      $body .= "<tr><td>$line</td></tr>\n";
    };
    $body .= "</body></html>";
    MIME::Lite->new(
                    From     =>'update.pl',
                    To       =>'you',
                    Subject  =>"Account update $date",
                    Type     =>'text/html',
                    Encoding =>'base64',
                    Data     => $body,
                    )->send;
  };

  # And update our log with what we have seen
  push @statement, @new;

;

  }
};
is($@, '', "example from line 415");

};
SKIP: {
    # A header testing whether we find all prerequisites :
    
    # The original POD test
        undef $main::_STDOUT_;
    undef $main::_STDERR_;

};
