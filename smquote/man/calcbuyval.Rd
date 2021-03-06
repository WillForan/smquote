% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/calcbuyval.R
\name{calcbuyval}
\alias{calcbuyval}
\title{calcbuyval: calculate gain from selling}
\usage{
calcbuyval(df, maxloss = 0.25, maxhold = 1)
}
\arguments{
\item{df:}{a dataframe with buy value,adj.close, and initialized sell,gain,gprct}

\item{maxloss:}{ratio of maximum loss, default .25}

\item{maxhold:}{how many days to hold for}
}
\description{
given a dataframe with a buy value and Adj.Close
 (and columns allocated for sell,gain, and gprct)
calculate when to sell
* buy should be NA or a number
  - NAs in a buy window will be populated with the original buy value
}
\examples{
quotes <- lapply(Sys.glob('data/*csv'),read.table,header=T,sep=",")
 # collapse list into 1 dataframe, calculations
 quotesdf <- rbind.fill(quotes)
 # remove stocks that have too few time points
 quotesdfms <- make.history(quotesdf,20)
}

