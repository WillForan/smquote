#!/usr/bin/env perl
use strict; use warnings; use feature qw/say/;
use Finance::Quote;
use Data::Dumper::Perltidy;
my $q=Finance::Quote->new();


# Name    low.1sd   Volume        slope  Close
my $header=<>; chomp $header;
my @header=('row',split/\s+/,$header);

say join("\t",'Name','CurPrice',@header[2..$#header]);
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
  say join("\t",$l{Name},$price,@l{@header[2..$#header]}) if $price < $l{'low.1sd'};
}
