#!/usr/bin/env perl
use strict; use warnings; use feature qw/say/;
use Finance::Quote;
use Data::Dumper::Perltidy;
my $q=Finance::Quote->new();


# Name    low.1sd   Volume        slope  Close
my $header=<>; chomp $header;
my @header=(split/\s+/,$header);

# bail if we've run this too many times
my $runno= scalar(grep {/CurPrice/} @header);
exit if $runno >1;

# we can feed the results of this back into itself
# to get an update
@header = map {s/CurPrice/BuyPrice/;$_} @header;

say join("\t",'Name','CurPrice',@header[1..$#header]);
while($_ = <>) {
  chomp;
  my %l;
  @l{@header}=split/\s+/;
  #my $t=uc('googl');
  my $s=$q->fetch('usa',$l{Name});

  #say Dumper(%l);
  #say Dumper($s);
  my $price = $s->{$l{Name},'ask'} || $s->{$l{Name},'last'};
  # should buy if ask price is less than 1 sd below mean
  say join("\t",$l{Name},$price,@l{@header[1..$#header]}) if $price < $l{'low.1sd'} || $runno > 0;
}
