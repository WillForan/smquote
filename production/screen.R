#!/usr/bin/env Rscript

library(plyr)
library(dplyr)
library(DBI)
library(smquote)

#con <- dbConnect(RSQLite::SQLite(),"stock.db")
#quotesdf <- dbFetch(res <- dbSendQuery(con,'select * from history'))
#dbClearResult(res)
#dbDisconnect(con)

quotesdf <- as.data.frame(tbl(sqldb <- src_sqlite(path = "stock.db"),"history"))

# "sym" becomes "Name", "day" -> "Date", etc
names(quotesdf) <- c("Name","Date","Open","Close","High","Low","Volume")
quotesdf$Adj.Close <- quotesdf$Close
quotesdf$Date <- as.Date(quotesdf$Date)
alldf <- make.history(quotesdf,20)

alldf %>% filter(Date==max(Date),pb) %>%head

# print stocks we might want to grab
write.table(file="screened.txt",alldf %>% filter(Date==max(Date),pb,slope>0) %>% select(Name,low.1sd,Volume,slope,Close),quote=F,sep="\t",row.names=F)



# best range (5e+05,1e+06]   (20,50]
# print.data.frame( alldf %>% filter(sell) %>% mutate(blv=cut(lbvol,breaks=c(0,10^5,5*10^5,10^6,5*10^6,Inf)), bp = cut(buy, breaks=c(0,1,5,10,20,50,100,Inf))) %>% group_by(blv,bp) %>% summarise(mg=mean(gprct),n=n(),max(gprct),min(gprct)) %>% ungroup %>% arrange(desc(mg)) )  
#
