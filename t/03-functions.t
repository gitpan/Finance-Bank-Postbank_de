#!/usr/bin/perl -w
use strict;
use FindBin;
use Data::Dumper;

use Test::More tests => 3;

use_ok("Finance::Bank::Postbank_de");

# Check that we have SSL installed :
SKIP: {
  skip "Need SSL capability to access the website",2
    unless LWP::Protocol::implementor('https');

  my $account = Finance::Bank::Postbank_de->new(
                  login => '9999999999',
                  password => '11111',
                  status => sub {
                              shift;
                              diag join " ",@_
                                if ($_[0] eq "HTTP Code") and ($_[1] != 200);
                            },
                );

  # Get the login page:
  my $status = $account->get_login_page(&Finance::Bank::Postbank_de::LOGIN);

  # Check that we got a wellformed page back
  SKIP: {
    unless ($status == 200) {
      diag $account->agent->res->as_string;
      skip "Didn't get a connection to ".&Finance::Bank::Postbank_de::LOGIN."(LWP: $status)",2;
    };
    skip "Banking is unavailable due to maintenance", 2
      if $account->maintenance;
    $account->new_session;

    my @links = $account->agent->links;
    my $error;
    for my $function (keys %Finance::Bank::Postbank_de::functions) {
      is( scalar(grep({ $_->text =~ /$Finance::Bank::Postbank_de::functions{$function}/ }@links)), 1, "Function $function is present on the page") or $error++;
    };
    if ($error) {
      diag $_->text for @links;
    };
  };
};
