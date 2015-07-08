#' calcbuyval: calculate gain from selling
#' 
#' given a dataframe with a buy value and Close
#'  (and columns allocated for sell,gain, buydate, and gprct)
#' calculate when to sell
#' * buy should be NA or a number
#'   - NAs in a buy window will be populated with the original buy value
#' @param df: a dataframe with buy value,adj.close, and initialized sell,gain,gprct
#' @param maxloss: ratio of maximum loss, default .25
#' @param maxhold: how many days to hold for
#' @export 
#' @examples
#'  quotes <- lapply(Sys.glob('data/*csv'),read.table,header=T,sep=",")
#'  # collapse list into 1 dataframe, calculations
#'  quotesdf <- rbind.fill(quotes) 
#'  # remove stocks that have too few time points
#'  quotesdfms <- make.history(quotesdf,20)
#'
calcbuyval <- function(df,maxloss=.10,maxhold=5,minhold=1){

  df$count=0
  df$lbvol=NA
  df$buydate=NA
  # maxloss: how much of a hit can we take (decimal percent)
  # maxhold: how long to hold a stock before considering it a wash (even though we didn't hit max loss)
  #   change to e.g. 1 to always sell the same day (practial limit of code is day after if still loosing)

  # initialize some values
  # we'll change these in a the loop as we have stocks to sell
  buyval=NA
  buydate = NA
  count=0
  loss=0
  lbvol=0

  # go through each day of the stock
  for (i in 1:nrow(df)) {

    # set buyval if we are buying
    if(!is.na(df[i,'buy'] ) ){
      buyval = df[i,'buy']
      lbvol = df[i-1,'Volume']
      buydate = df[i,'Date'] # why is this a number?
      #cat('settting buydate ',buydate,'\n')

      # if stock is small, don't sit on it for very long
      #if buyval<2 maxhold=2
    }
    
    # if this is a buy, or we've bought and not sold
    if(!is.na(buyval)) {
       count=count+1
       loss= 1 - df[i,'Close']/buyval
    }
    
    # should we sell?
    # made money, hit count or loss threshold
    s= (df[i,'Close'] > buyval || count >= maxhold || loss>=maxloss) && count >= minhold

    # NA to F
    if(is.na(s)) s=F

    # we sold!
    if(s){

      # all days over the buy period
      sidx=(i-count) + 1:(count) 

      # check for unsafe dates (missing data/date)
      unsafe=any(!df[sidx,'safedate'])
      if(unsafe) {
        # reset buy to NAs
        df[sidx,'buy']<-NA
        # set sell to NA (instead of t,f)
        df[sidx,'sell']<-NA
        df[sidx,'count']<-0
        df[sidx,'lbvol']<-NA
        s=NA

      } else {
        # is safe, calc gain and percent
        df[i,'buy'] = buyval
        df[i,'gain'] = df[i,'Close'] - buyval
        df[i,'gprct'] = (df[i,'Close'] - buyval)/buyval*100
        df[i,'buydate'] = buydate
        df[i,'count'] = count
        df[i,'lbvol'] = lbvol
      }
      
      # reset our global counters
      buyval=NA
      buydate = NA
      count=0
      loss=0
      lbvol=0
    }

    # we aren't ready to sell but have bought
    # set buy value, and go onto the next day
    else {
     df[i,'buy'] = buyval
     df[i,'buydate'] = buydate
    }

    df[i,'sell'] = s  
  } # end row loop

  return(df)
}

#' make buy sell data frame
#' 
#' make a dataframe suitable for calcbuyval
#' @param buy: vector of buy values (expect NA or value)
#' @param adjclose: values at close of day
#' @param safedate: can the date be used? Default: vector of True
#' @export 
#' @examples
#'  calcbuyval( mkbsdf(1,2),maxhold=1 )
mkbsdf <- function(buy,adjclose,safedate=T){
 df<-data.frame( buy=buy, Close=adjclose,safedate=safedate)
 df$sell <- F
 df$gain <- df$gprct <- 0
 return(df)
}
