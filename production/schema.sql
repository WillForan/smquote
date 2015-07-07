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
 symday real primary key,
 time text,
 price real,
 open real,
 low real,
 high real,
 bid real,
 ask real,
 vol real
);


-- metrics for a day
drop table if exists metrics;
create table metrics(
 symday   real primary key,
 buynext boolean,
 RSI20   real,
 slope20 real
);
