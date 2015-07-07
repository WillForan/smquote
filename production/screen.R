#!/usr/bin/env Rscript

library(plyr)
library(dplyr)
library(DBI)
library(smquote)

con <- dbConnect(RSQLite::SQLite(),"stock.db")
quotesdf <- dbFetch(res <- dbSendQuery(con,'select * from history'))
dbClearResult(res)
# "sym" becomes "Name"
names(quotesdf) <- c("Name","Date","Open","Close","High","Low","Volume")
quotesdf$Adj.Close <- quotesdf$Close
quotesdf$Date <- as.Date(quotesdf$Date)
alldf <- make.history(quotesdf,20)


dbDisconnect(con)
