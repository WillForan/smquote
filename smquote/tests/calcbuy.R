# work as expected for small lists
#
# make a buy/sell data frame
#   bsdf <- mkbsdf(buy,close,safedate)
# calcluate when to sell, gain from sell
#   gain <- calcbuyval(bsdf)
# what is the percent gain when stock is sold
#   exptval <- gain$gprct[ gain$sell ]
# test we get what we expect
#  expect_that(exptval, equals(100) )

test_that("calcbuyval_small", {

 # buy at 1, close at 2 => 100% gain
 doublegain <- calcbuyval( mkbsdf(1,2),maxhold=1 )
 expect_that(doublegain$gprct,equals(100))

 # buy at 1, close at 2 => 100% gain (have 3 days of data, trade only on 2nd)
 df <- calcbuyval( mkbsdf(c(NA,1,NA),c(1,2,1)),maxhold=1 )
 doublegaininlist <- df$gprct[df$sell]
 expect_that(doublegaininlist ,equals(100))
 
 # buy at 1, close at 0 => -100% gain
 df <- calcbuyval( mkbsdf(c(NA,1,NA),c(1,0,0)),maxhold=1 )
 doubleloss <- df$gprct[df$sell]
 expect_that(doubleloss,equals(-100))

 # buy at 1, close at 2 => 100% gain 
 # buy at 2, close at 3 => 50% gain
 #(have 3 days of data, trade only on 2nd and 3rd)
 df <- calcbuyval( mkbsdf(c(NA,1,2),c(1,2,3)),maxhold=1 )
 doublegaininlist <- df$gprct[df$sell]
 expect_that(doublegaininlist ,equals(c(100,50)))
})

test_that("calcbuyval_unsafe", {
 # cannot buy/sell if only date is unsafe
 doublegain <- calcbuyval( mkbsdf(1,2,F),maxhold=1 )
 expect_that(doublegain$sell,equals(NA))

 # as long as sell date is safe, should work
 df <- calcbuyval( mkbsdf(c(NA,1,NA),c(1,2,1), c(F,T,F)),maxhold=1 )
 doubleloss <- df$gprct[df$sell]
 expect_that(doubleloss,equals(100))
 
 # if sell date is false, should not sell (no sells -> no gains to report)
 df <- calcbuyval( mkbsdf(c(NA,1,NA),c(1,0,0),c(T,F,T)),maxhold=1 )
 dl2 <- df$gprct[df$sell]
 expect_that(dl2,equals(NA))
})
