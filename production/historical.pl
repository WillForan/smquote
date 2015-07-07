#!/usr/bin/env perl
use strict; use warnings; use feature qw/say/;
use autodie;
use Finance::QuoteHist;
use DBI;
use DateTime;

# prepare db
my $dbh=DBI->connect("dbi:SQLite:dbname=./stock.db","","",{
 PrintError =>1, RaiseError =>1, AutoCommit=>1});
my $uor=$dbh->prepare("INSERT OR REPLACE INTO history (sym,day,open,high,low,close,vol) VALUES (?,?,?,?,?,?,?)");


# prepare quote
my $q=Finance::QuoteHist->new(
  end_date=>'today',
  start_date=> &start_date(),
  symbols=>[ &tickers() ]
 );

# put quotes into the db
foreach my $row ($q->quotes()) {
  my ($symbol, $date, $open, $high, $low, $close, $volume) = @$row;
  # cleanup
  chomp $symbol;
  $date=~s:/:-:g;

  say "$symbol\t$date\t |", DateTime->now();
  $uor->execute($symbol, $date, $open, $high, $low, $close, $volume);
}

########
# funcs
########

# return list of tickers to get
sub tickers {
  # get tickers
  open my $symsfh, '<','nasdaqtickers.txt';
  my @sym;
  push @sym, $_ while(<$symsfh>);
  close $symsfh;
  #@sym=@sym[0..2]; #limit what we do
  say @sym;
  return(@sym);
}

# get start date
sub start_date {
  # get oldest last day from all tickers
  # TODO: drop if too much older than neightbors (dead sym)
  # 'select min(day) from (select max(day) as day from history group by sym)'
  # start_date=>DateTime->now()->subtract(days=>23)->strftime('%m/%d/%Y'),
  my $start_date=DateTime->now()->subtract(days=>35)->ymd('/');
  say $start_date;
  return($start_date);
}
