#!D:\perl\5.8.2\bin\perl.exe -w

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

my $Original_File = 'lib\Finance\Bank\Postbank_de\Account.pm';

package main;

# pre-5.8.0's warns aren't caught by a tied STDERR.
$SIG{__WARN__} = sub { $main::_STDERR_ .= join '', @_; };
tie *STDOUT, 'Catch', '_STDOUT_' or die $!;
tie *STDERR, 'Catch', '_STDERR_' or die $!;

    undef $main::_STDOUT_;
    undef $main::_STDERR_;
eval q{
  my $example = sub {
    local $^W = 0;

#line 212 lib/Finance/Bank/Postbank_de/Account.pm

  use strict;
  use Finance::Bank::Postbank_de::Account;
  my $statement = Finance::Bank::Postbank_de::Account->parse_statement(
                number => '9999999999',
                password => '11111',
              );
  # Retrieve account data :
  print "Statement date : ",$statement->balance->[0],"\n";
  print "Balance : ",$statement->balance->[1]," EUR\n";

  # Output CSV for the transactions
  for my $row ($statement->transactions) {
    print join( ";", map { $row->{$_} } (qw( tradedate valuedate type comment receiver sender amount ))),"\n";
  };




;

  }
};
is($@, '', "example from line 212");

{
    undef $main::_STDOUT_;
    undef $main::_STDERR_;
#line 212 lib/Finance/Bank/Postbank_de/Account.pm

  use strict;
  use Finance::Bank::Postbank_de::Account;
  my $statement = Finance::Bank::Postbank_de::Account->parse_statement(
                number => '9999999999',
                password => '11111',
              );
  # Retrieve account data :
  print "Statement date : ",$statement->balance->[0],"\n";
  print "Balance : ",$statement->balance->[1]," EUR\n";

  # Output CSV for the transactions
  for my $row ($statement->transactions) {
    print join( ";", map { $row->{$_} } (qw( tradedate valuedate type comment receiver sender amount ))),"\n";
  };




  isa_ok($statement,"Finance::Bank::Postbank_de::Account");
  $::_STDOUT_ =~ s!^Statement date : \d{8}\n!!m;
  my $expected = <<EOX;
Balance : 2500.00 EUR
20030520;20030520;GUTSCHRIFT;KINDERGELD                 KINDERGELD-NR 234568/133;ARBEITSAMT BONN;;154.00
20030520;20030520;�BERWEISUNG;FINANZKASSE 3991234        STEUERNUMMER 007 03434     EST-VERANLAGUNG 99;FINANZAMT K�LN-S�D;;-328.75
20030513;20030513;LASTSCHRIFT;RECHNUNG 03121999          BUCHUNGSKONTO 9876543210;TELEFON AG K�LN;;-125.80
20030513;20030513;SCHECK;;EC1037406000003;;-511.20
20030513;20030513;LASTSCHRIFT;TEILNEHMERNUMMER 123456789 RUNDFUNK VON 1099 BIS 1299;GEZ K�LN;;-84.75
20030513;20030513;LASTSCHRIFT;STROMKOSTEN                KD-NR 1462347              JAHRESABRECHNUNG;STADTWERKE MUSTERSTADT;;-580.06
20030513;20030513;INH.SCHECK;;2000123456789;;-100.00
20030513;20030513;SCHECKEINR;EINGANG VORBEHALTEN;GUTBUCHUNG 12345;;1830.00
20030513;20030513;DAUER �BERW;DA 100001;;MUSTERMANN, HANS;-31.50
20030513;20030513;GUTSCHRIFT;BEZ�GE                     PERSONALNUMMER 700600170/01;ARBEITGEBER U. CO;;2780.70
20030513;20030513;LASTSCHRIFT;MIETE 600,00 EUR           NEBENKOSTEN 250,00 EUR     OBJEKT 22/328              MUSTERPFAD 567, MUSTERSTADT;EIGENHEIM KG;;-850.00
EOX
  for ($::_STDOUT_,$expected) {
    s!\r\n!!gsm;
    # Strip out all date references ...
    s/^\d{8};\d{8};//gm;
  };
  is_deeply([split /\n/, $::_STDOUT_],[split /\n/, $expected],"Retrieved the correct data");

    undef $main::_STDOUT_;
    undef $main::_STDERR_;
}

    undef $main::_STDOUT_;
    undef $main::_STDERR_;

    undef $main::_STDOUT_;
    undef $main::_STDERR_;
eval q{
  my $example = sub {
    local $^W = 0;

#line 360 lib/Finance/Bank/Postbank_de/Account.pm

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
is($@, '', "example from line 360");

    undef $main::_STDOUT_;
    undef $main::_STDERR_;

