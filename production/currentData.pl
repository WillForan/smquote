#!/usr/bin/env perl
use strict; use warnings; use feature qw/say/;
use Finance::Quote;
my $q=Finance::Quote->new();
my $t=uc('googl');
my $s=$q->fetch('usa',$t);
