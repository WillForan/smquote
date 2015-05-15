#!/usr/bin/env python
import ystockquote
import datetime
import pickle
import os
import csv
import time
from pprint import pprint

"""
where to save files
"""
def getsavename(stk,ext):
    return 'data/' + stk + ext

"""
get historical data from a stock ticker name
 - save in pickle format
 - update (and save) if already exists

"""
def getsavedata(stk):
    firstday = '2013-01-01'
    today    = datetime.date.today().strftime('%Y-%m-%d')

    savename=getsavename(stk,'.p')

    #did we dl anything? do we need to wait
    dl=0

    # TODO: make path for savename
    # mkdir(dirname(savename))

    # load (and update if needed)
    if os.path.exists(savename):
      quotes=pickle.load( open(savename, "rb") )
      lastquote = sorted(quotes.keys())[-1]

      # update with new values
      prevdate = datetime.datetime.strptime(today,'%Y-%m-%d') - datetime.timedelta(days=1)
      prevdate=prevdate.strftime('%Y-%m-%d')
      if lastquote != prevdate:
         nextdate = datetime.datetime.strptime(lastquote,'%Y-%m-%d') + datetime.timedelta(days=1)
         nextdate=nextdate.strftime('%Y-%m-%d')
         pprint([prevdate, lastquote,nextdate,today])
         quotes.update( ystockquote.get_historical_prices(stk,nextdate,today) )
         savestock(stk,quotes)
         dl=1

    # get all new
    else:
      quotes  = ystockquote.get_historical_prices(stk,firstday,today)
      savestock(stk,quotes)
      dl=1

    if dl: time.sleep(10)
    return quotes



"""
ystockquote format to csv ( for R)

"""
def ystocktoCSV(stk,quotes):
   savename=getsavename(stk,'.csv')
   columns=['Adj Close','Close','High','Low','Open','Volume']
   # date, 'Close', 'High', 'Low', 'Open', 'Volume','Adj Close'
   twod = [  [k]+[v[c] for c in columns] for k,v in quotes.items() ]
   with open(savename,'w',newline='') as csvfile:
     w = csv.writer(csvfile,quoting=csv.QUOTE_MINIMAL)
     w.writerow(['Name','Date'] + columns)
     for line in twod:
       w.writerow([stk]+line)

"""
save stocks in pickle and csv format
"""
def savestock(stk,quotes):
     pickle.dump(quotes, open( getsavename(stk,'.p') , "wb") )
     ystocktoCSV(stk,quotes)



"""
main
 for all stocks in stocks.txt
 get historical data from 2013 onward, save in data/stock.csv
"""

for l in open('stocks.txt','r'):
  stk=l.strip()
  pprint(stk)
  getsavedata(stk)




