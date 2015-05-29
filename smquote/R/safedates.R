require(lubridate)
require(Holidays)
#' safedates: are dates continous
#'
#' function to check dates are continious (before adding a buy signal)
#' that is, only at most a holiday separates them
#' first input should be newer date, the date we will determine is safe or not
#' -- it's okay if we have data on a holiday. weird, but okay (maybe not NYSE tradded stock)
#' 
#' @param d1: new date to test if safe 
#' @param d2: prev date that should be followed by d1 if d1 is safe
#' @export 
#' @examples
#'  safedates(as.Date('2015-01-03'),as.Date('2015-01-02') )
safedates <- function(d1,d2) {

  # if we skipped a friday b/c of holiday, add to prev date
  ud2 <- wday(d2+1)==6 & isHoliday(d2+1,'NYSE')
  d2<-ifelse(ud2,d2+1,d2) 
  class(d2) <- "Date" # because ifelse strips class info

  # if prev date was a friday (or friday was a holiday), pretend we have a sunday date
  d2<-ifelse(wday(d2)==6,d2+2,d2)
  class(d2) <- "Date" # because ifelse strips class info

  # is the date difference a day (or plus one if it's a holiday)
  dd <- d1-d2
  dd == 1 | dd == 1 + ifelse(isHoliday(d1-1,'NYSE'),1,0)  
}

