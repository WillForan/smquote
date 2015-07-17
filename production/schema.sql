-- schema for historical prices
drop table if exists history;
create table history(
 sym    text not null,
 day    text not null,
 open   real,
 close  real,
 high   real,
 low    real,
 vol    real
);

-- updated intra-day
drop table if exists watch;
create table watch(
 symday real,
 time text,
 price real,
 open real,
 low real,
 high real,
 bid real,
 ask real,
 vol real,
 foreign key(symday) references history(rowid)
);


-- metrics for a day
drop table if exists metrics;
create table metrics(
 symday   real primary key,
 buynext boolean,
 slope20 real,
 mu20   real,
 low1sd20 rea,
 RSI20   real,
 MACD20 real,
 foreign key(symday) references history(rowid)
);

-- bought stocks
drop table if exists bought;
create table bought(
  symday real primary key,
  watchid real,
  day text not null,
  time text not null,
  price real not null,
  foreign key(symday) references history(rowid)
  foreign key(watchid) references watch(rowid)
);
