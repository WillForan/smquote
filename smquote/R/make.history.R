require(dplyr) # %>%
require(zoo) # rollaply
require(RcppRoll) # window/roll functions

#' Make History from historical stock data
#' 
#' @param quotesdf: a stock quotes dataframe with columns Date, Open, and Adj.Close
#' @param windowwidth: window size for moving average/standard dev.
#' @export 
#' @examples
#'  calcbuyval( mkbsdf(1,2),maxhold=1 )
#'
make.history <- function(quotesdf,windowwidth=20){
   # remove stocks that do not have enough samples (b/c they are too new)
   newstocks <- quotesdf %>% group_by(Name) %>% summarise(n=n()) %>% filter(n<=windowwidth) %>% select(Name)
   quotesdfm <- quotesdf %>%
       mutate(Date = as.Date(as.character(Date)  ) ) %>%
       mutate(dd  = decimal_date(Date ) ) %>%
       arrange(Name,dd) %>% 
       filter( !(Name %in% unlist(newstocks)) )
   # or just play with some we know work
   #   filter(Name %in% c('AAPL','GOOGL','YHOO'))

   quotesdfm <- quotesdfm %>%
        # bad day for the stock?
        mutate(closeunder=Adj.Close<Open) %>%
        # work only within one stock (ordered by date)
        group_by(Name) %>%  
        # calculate rolling stats
        mutate( win.mu = c(rep(NA,windowwidth-1), rollapply(Adj.Close,width=windowwidth,FUN=mean,na.rm=T) ) ) %>%
        mutate( win.sd = c(rep(NA,windowwidth-1), rollapply(Adj.Close,width=windowwidth,FUN=sd,na.rm=T) ) ) %>%
        mutate( low.1sd = win.mu-win.sd) %>%
        mutate( safedate = safedates(Date,lag(Date)) ) %>%
        #mutate( safedate = lead(Date) - lag(Date) <=(1/365.25)*6  ) %>%
        # red is when we want to buy
        # - yesterday's close is below the stnd dev
        # - today's open is also below
        # - and it opened above a dollar (so we dont loose big) -- & Open>1 
        # - also make sure we have sorted data
        mutate( bs    = lag(Adj.Close) < lag(low.1sd) & Open < lag(low.1sd) & safedate) %>%
        mutate( redudantbs    = lag(bs) & bs )  #%>%
        #mutate( DD = format(undecimate(Date),"%a %Y-%m-%d") )

   quotesdfm <- quotesdfm %>%
        # buy value is value of close first entering into red
        ungroup %>% 
        mutate( buy    = ifelse(bs&!redudantbs, Open, NA ) ) %>%
        mutate(sell=F,gain=0,gprct=0) #%>%
       #  # broke after here ?
       #  # simulate sell just before close (when close was good)
       #  mutate( buycost   = na.locf(buy) ) %>%
       #  mutate( sell   = Adj.Close > buycost ) %>%
       #  mutate( sell   = ifelse(lag(sell) & sell,F,sell )) %>% 
       #  # calc return
       #  mutate( profit   = ifelse(sell,Close-buycost,0) ) 
       #### more junk
       #  %>%
       #  #
       #  mutate( buy    = na.locf( buy ) )  %>%
       #  mutate( buy    = ifelse(bs,buy,NA) ) %>%
       #  # when to sell
       #  mutate( sell   = lag(bs) & Open > buy )
      

   quotesdfms <- ddply(quotesdfm,.(Name),calcbuyval)
}

# undo decimal_date
undecimate <- function(x) {
  # get the year and then determine the number of seconds in the year so you can
  # use the decimal part of the year
  x.year <- floor(x)
  # fraction of the year
  x.frac <- x - x.year + .001
  # number of seconds in each year
  x.sec.yr <- unclass(ISOdate(x.year+1,1,1,0,0,0)) - unclass(ISOdate(x.year,1,1,0,0,0))
  # now get the actual time
  x.actual <- ISOdate(x.year,1,1,0,0,0) + x.frac * x.sec.yr 
  return(x.actual)
}
