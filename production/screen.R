#!/usr/bin/env Rscript

#library(plyr)
#library(dplyr)
library(DBI)
library(sqldf)
library(smquote)
library(data.table)

#con <- dbConnect(RSQLite::SQLite(),"stock.db")
#quotesdf <- dbFetch(res <- dbSendQuery(con,'select * from history'))
#dbClearResult(res)
#dbDisconnect(con)

### Attempt 2
#quotesdf <- tbl(sqldb <- src_sqlite(path = "stock.db"),"history")
#
## "sym" becomes "Name", "day" -> "Date", etc
#names(quotesdf) <- c("Name","Date","Open","Close","High","Low","Volume")
#quotesdf$Adj.Close <- quotesdf$Close
#quotesdf$Date <- as.Date(quotesdf$Date)
#alldf <- make.history(quotesdf,20)
#
#alldf %>% filter(Date==max(Date),pb) %>%head
#
## print stocks we might want to grab
#write.table(file="screened.txt",alldf %>% filter(Date==max(Date),pb,slope>0) %>% select(Name,low.1sd,Volume,slope,Close),quote=F,sep="\t",row.names=F)


# get history data
# TODO: limit to 25 rows per sym?
stockhist <- as.data.table(sqldf("SELECT rowid as symday, * FROM history", dbname = "stock.db"))
# get stats
stat      <- stockhist[haveEnoughSamples(sym)][order(sym,day)][,c("slope20","low1sd20","mu20","win.sd","RSI20"):=getStats(open,close),by=sym]
# close column is confused with the command close, rename
setnames(stat,'close','Close')
# set potential, make up MACD20 b/c it doesn't exist but the table wants it
# TODO: limit stats to only new days
stat[,`:=`(buynext=buypotential(Close,low1sd20,slope20),MACD20=NA)]
# write the table, function returns the connection (so we can close it) 
con <- writepotential(stat[,list(symday,buynext,slope20,low1sd20,mu20,RSI20,MACD20)])

print( stat[buynext==T & max(day)==day,] )

# symday   real primary key,
# buynext boolean,
# RSI20   real,
# slope20 real,
# low1sd20 rea,


# best range (5e+05,1e+06]   (20,50]
# print.data.frame( alldf %>% filter(sell) %>% mutate(blv=cut(lbvol,breaks=c(0,10^5,5*10^5,10^6,5*10^6,Inf)), bp = cut(buy, breaks=c(0,1,5,10,20,50,100,Inf))) %>% group_by(blv,bp) %>% summarise(mg=mean(gprct),n=n(),max(gprct),min(gprct)) %>% ungroup %>% arrange(desc(mg)) )  
#
