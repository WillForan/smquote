#!/usr/bin/env python
import ystockquote
import datetime
import pickle
import os
import csv
import time
import numpy as np
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
def getsavedata(stk,firstday='2013-01-01',lastday='today',forceupdate=False):
    if lastday == 'today':
      lastday    = datetime.date.today().strftime('%Y-%m-%d')

    savename=getsavename(stk,'.p')

    #did we dl anything? do we need to wait
    dl=0

    # TODO: make path for savename
    # mkdir(dirname(savename))

    # load (and update if needed)
    if os.path.exists(savename):
      quotes=pickle.load( open(savename, "rb") )
      lastquote = sorted(quotes.keys())[-1]

      # what is the last possible day we could have values for 
      # this is only meaningful of lastday is "today"
      prevdate = datetime.datetime.strptime(lastday,'%Y-%m-%d') - datetime.timedelta(days=1)
      prevdate=prevdate.strftime('%Y-%m-%d')

      # if we dont have yestrdays quotes (and we arn't forcing a different date range)
      if lastquote != prevdate and not forceupdate:
         nextdate = datetime.datetime.strptime(lastquote,'%Y-%m-%d') + datetime.timedelta(days=1)
         nextdate=nextdate.strftime('%Y-%m-%d')
         # set the first day of data to retrieve to the 
         # next day (first missing day) in the data we have
         firstday = nextdate
         forceupdate=True

      if forceupdate:
         pprint([prevdate, lastquote,firstday,lastday])
         quotes.update( ystockquote.get_historical_prices(stk,firstday,lastday) )
         savestock(stk,quotes)
         dl=1

    # get all new
    else:
      quotes  = ystockquote.get_historical_prices(stk,firstday,lastday)
      savestock(stk,quotes)
      dl=1

    if dl: time.sleep(10)

    # did we miss anything?
    populateMissing(stk,quotes)
    return quotes


"""
yahoo is a little unreligable in the dates it retrieves
-- find missing dates and retreive them, return a filled in quotes
"""
def populateMissing(stk,quotes):
  # how many days can be missing?
  # weekend plus holiday
  maxmissingdays=4
  dates = sorted([ datetime.datetime.strptime(x,'%Y-%m-%d') for x in quotes.keys() ])
  mi = [ i  for i,x in enumerate( np.diff(np.array(dates)) ) if x>datetime.timedelta(days=maxmissingdays)]
  for i in mi:
    firstday=dates[i].strftime('%Y-%m-%d')
    lastday=dates[i+1].strftime('%Y-%m-%d')
    pprint(['missing dates:', stk,firstday,lastday])
    quotes=getsavedata(stk,firstday,lastday,forceupdate=True)

  return(quotes)

"""
ystockquote format to csv ( for R)
"""
def ystocktoCSV(stk,quotes):
   savename=getsavename(stk,'.csv')
   columns=['Adj Close','Close','High','Low','Open','Volume']
   # date, 'Close', 'High', 'Low', 'Open', 'Volume','Adj Close'
   twod = [  [k]+[v[c] for c in columns] for k,v in sorted(quotes.items()) ]
   with open(savename,'w') as csvfile:
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
def fetch(txtfile):
  for l in open(txtfile,'r'):
    stk=l.strip()
    if stk.startswith("#"): continue
    try:
      pprint(stk)
      getsavedata(stk)
    except:
      pprint('failed to get stock' + stk)
      pass

if __name__ == "__main__":
  fetch('nasdaqtickers.txt')



