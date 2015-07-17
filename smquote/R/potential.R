require(dplyr) # %>%
require(zoo) # rollaply
require(RcppRoll) # window/roll functions
require(TTR) # RSI
require(quantmod)
require(datatable)


#' generate stats for screening: generate slope,RSI,MACD,sd 
#'  returns a data.table with slope, low.1sd, and other metrics
#' @param Open: daily open value of stock
#' @param Close: daily close value of stock
#' @param windowwidth: window size for moving average/standard dev.
#' @export 
#' @examples
#'  p<-potential( open,close ,windowwidth=20 )
#'
# depends on safedate
#potential <- function(quotesdfm,windowwidth=20) {
getStats <- function(Open,Close,windowwidth=20) {

 # calculate rolling stats
 win.mu <- c(rep(NA,windowwidth-1), rollapply(Close,width=windowwidth,FUN=mean,na.rm=T) ) 
 win.sd <- c(rep(NA,windowwidth-1), rollapply(Close,width=windowwidth,FUN=sd,  na.rm=T) )
 slope  <- c(rep(NA,windowwidth-1), rollapply(Close,width=windowwidth,FUN=function(.) mean(diff(.),na.rm=T) ) ) 

 data.table( 
      slope    = slope,
      low.1sd  = win.mu-win.sd,
      win.mu   = win.mu,
      win.sd   = win.sd,
      RSI      = RSI(Close,n=windowwidth)
     # MACD     = MACD(Close)
  )

}

#' @export
buypotential <-function(Close,low.1sd,slope){
   return(Close<low.1sd & slope>0)
}

#' @export
writepotential <-function(stat,con=dbConnect(RSQLite::SQLite(),"stock.db")){
 old<-dbReadTable(con,name='metrics')
 newsms<-setdiff(stat$symday,stat$symday)
 dbWriteTable(con,name='metrics',stat[symday%in%newsms,],append=T)
 return(con)
}

#' @export
haveEnoughSamples <-function(Name,windowwidth=20) {
   r<-rle(sort(Name))
   ! Name %in% r$values[r$lengths<=windowwidth]
   #newstocks <- quotesdf %>% group_by(Name) %>% summarise(n=n()) %>% filter(n<=windowwidth) %>% select(Name)
   #quotesdf %>%  filter( !(Name %in% unlist(newstocks)) )
}

