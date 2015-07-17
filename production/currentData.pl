#!/usr/bin/env perl
#
# get current price quotes from stocks i.d. by 
# screen.R
#

use strict; use warnings; use feature qw/say/;
use autodie;
use Finance::Quote;

 use Data::Dumper::Perltidy;
use DBI;
use DateTime;
use POSIX;
my $q=Finance::Quote->new();

# prepare db
my $dbh=DBI->connect("dbi:SQLite:dbname=./stock.db","","",{
 PrintError =>1, RaiseError =>1, AutoCommit=>1});
my $screened=$dbh->prepare("select h.rowid,* from history as h join metrics as m on m.symday=h.rowid where buynext==1 and day == (select max(day) from history)");
$screened->execute();

# colums we care about
my @ps=qw/price open close low high bid ask vol/;
say join("\t",qw/retrievedtimedate dblastday sym low1sd close lastquotedtimedate/,@ps);
while(my $row = $screened->fetchrow_hashref()) {
  my $qtime=strftime("%Y-%m-%d %H:%M",localtime(time));
  my $s=$q->fetch('usa',$row->{sym});
  my $lastdate="1900-01-01 ";
  
  # get colums we care about
  my %p=();
  map {$p{$_} = $s->{$row->{sym},$_} || 'NULL'  } (@ps);

  # last stock date time
  # from 07/16/2015
  $lastdate  = "$3-$1-$2 " if $s->{$row->{sym},'date'} =~ m:(\d{2})/(\d{2})/(\d{4}):;
  $lastdate .= $s->{$row->{sym},'time'};

  #my $price =  $p{ask} || $p{last} || $p{bid};
  say join "\t", $qtime, $row->{day}, $row->{sym}, $row->{low1sd20}, $row->{close}, $lastdate, @p{@ps};
}

##  use strict; use warnings; use feature qw/say/;
##  use Finance::Quote;
##  use Data::Dumper::Perltidy;
##  #use List::Util qw/max/;
##  use POSIX;
##  my $q=Finance::Quote->new();
##  
##  
##  # header read in from file (written by screen.R)
##  # Name    low.1sd   Volume        slope  Close
##  my $header=<>; chomp $header;
##  my @header=(split/\s+/,$header);
##  
##  # bail if we've run this too many times
##  my $runno= scalar(grep {/CurPrice/} @header);
##  exit if $runno >1;
##  
##  # we can feed the results of this back into itself
##  # to get an update
##  @header = map {s/CurPrice/BuyPrice/;$_} @header;
##  
##  my @ps=qw/ask bid last/;
##  say join("\t",'Name','qtime','ltime',@ps,@header[1..$#header]);
##  while($_ = <>) {
##    chomp;
##    my $qtime=strftime("%H:%M",localtime(time));
##    my %l;
##    @l{@header}=split/\s+/;
##    #my $t=uc('googl');
##    my $s=$q->fetch('usa',$l{Name});
##  
##    #say Dumper(%l);
##    #say Dumper($s);
##    my %p=();
##    map {$p{$_} = $s->{$l{Name},$_} || ' '  } (@ps);
##    my $price =  $p{ask} || $p{last} || $p{bid};
##    # should buy if ask price is less than 1 sd below mean
##    say join("\t",$l{Name},$qtime,$s->{$l{Name},'time'},@p{@ps},@l{@header[1..$#header]}); #if $price < $l{'low.1sd'} || $runno > 0;
##  }
