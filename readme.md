# Concept

SM: Simple moving av 20, bollinger bands 20,1

[http://stockcharts.com/h-sc/ui](here)

# Deps
```
pip install ystockquote
```
# Usage
 1. edit `stocks.txt` to include stocks of interest
   - one stock per line, prefix # to skip stock (if yahoo api panics)
 2. run `./getquotes.py` to populate data/
 3. TODO: get moving average (in R?)

# stocks
 - 100 NASDAQ
 - invenstor bus. daily, top sector stocks
 - invenstor bus. daily, stock spotlight 
 - largetst cap healthcare
 - largetst cap tech

# algorithm
 - buy
   - previous day > 1sd below mean 
   - & curernt day > 1sd below mean
   - & not trending down
 - sell at close of curernt day
   - above buy 
   - || past loss threshold (5%)
   - || close of 20 days
