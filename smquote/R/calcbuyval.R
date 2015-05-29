#' calcbuyval: calculate gain from selling
#' 
#' given a dataframe with a buy value and Adj.Close
#'  (and columns allocated for sell,gain, and gprct)
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
calcbuyval <- function(df,maxloss=.25,maxhold=1){

  # maxloss: how much of a hit can we take (decimal percent)
  # maxhold: how long to hold a stock before considering it a wash (even though we didn't hit max loss)
  #   change to e.g. 1 to always sell the same day (day after)

  # initialize some values
  # we'll change these in a the loop as we have stocks to sell
  buyval=NA
  count=0
  loss=0

  # go through each day of the stock
  for (i in 1:nrow(df)) {

    # set buyval if we are buying
    if(!is.na(df[i,'buy'] ) ){
      buyval = df[i,'buy']

      # if stock is small, don't sit on it for very long
      #if buyval<2 maxhold=2
    }
    
    # if this is a buy, or we've bought and not sold
    if(!is.na(buyval)) {
       count=count+1
       loss= 1 - df[i,'Adj.Close']/buyval
    }
    
    # should we sell?
    # made money, hit count or loss threshold
    s=df[i,'Adj.Close'] > buyval || count > maxhold || loss>maxloss

    # NA to F
    if(is.na(s)) s=F

    # we sold!
    if(s){

      # all days over the buy period
      sidx=(i-count) + 1:(count-1) 
      print(sidx)

      # check for unsafe dates (missing data/date)
      unsafe=any(!df[sidx,'safedate'])
      if(unsafe) {
        # reset buy to NAs
        df[sidx,'sell']<-NA
        df[sidx,'buy']<-NA

      } else {
        # is safe, calc gain and percent
        df[i,'buy'] = buyval
        df[i,'gain'] = df[i,'Adj.Close'] - buyval
        df[i,'gprct'] = (df[i,'Adj.Close'] - buyval)/buyval*100
      }
      
      # reset our global counters
      buyval=NA
      count=0
      loss=0
    }

    # we aren't ready to sell but have bought
    # set buy value, and go onto the next day
    else {
     df[i,'buy'] = buyval
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
 df<-data.frame( buy=buy, Adj.Close=adjclose,safedate=safedate)
 df$sell <- F
 df$gain <- df$gprct <- 0
 return(df)
}