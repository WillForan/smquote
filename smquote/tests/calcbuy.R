require(dplyr)
# given a dataframe with a buy value and Adj.Close
#  (and columns allocated for sell,gain, and gprct)
# calculate when to sell
# * buy should be NA or a number
#   - NAs in a buy window will be populated with the original buy value

# maxloss: how much of a hit can we take (decimal percent)
# maxhold: how long to hold a stock before considering it a wash (even though we didn't hit max loss)
#   change to e.g. 1 to always sell the same day (day after)
#calcbuyval <- function(df,maxloss=.25,maxhold=1){



test_that("calcbuyval_small", {
 doublegain <- calcbuyval( mkbsdf(1,2),maxhold=1 )
 expect_that(doublegain$gprct,equals(100))

 doublegain2 <- calcbuyval( mkbsdf(c(NA,1,NA),c(1,2,1)),maxhold=1 )
 expect_that(doublegain%>%filter(sell)%>%select(gprct),equals(100))
 

 doubleloss <- calcbuyval( mkbsdf(c(NA,1,NA),c(1,0,0)),maxhold=1 )
 expect_that(doubleloss %>%filter(sell)%>%select(gprct),equals(-100))
})

test_that("calcbuyval_unsafe", {
 doublegain <- calcbuyval( mkbsdf(1,2,F),maxhold=1 )
 expect_that(doublegain$gprct,equals(101))

 doublegain2 <- calcbuyval( mkbsdf(c(NA,1,NA),c(1,2,1)),maxhold=1 )
 expect_that(doublegain%>%filter(sell)%>%select(gprct),equals(100))
 

 doubleloss <- calcbuyval( mkbsdf(c(NA,1,NA),c(1,0,0)),maxhold=1 )
 expect_that(doublegain%>%filter(sell)%>%select(gprct),equals(-100))
})
