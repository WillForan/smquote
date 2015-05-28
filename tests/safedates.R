test_that("safedates", {
  # normal continous day
  prevdate=as.Date('2015-06-30')
  testdate=as.Date('2015-07-01')
  expect_that(safedates(testdate,prevdate),is_true()) 

  # normal weekend
  prevdate=as.Date('2015-06-26')
  testdate=as.Date('2015-06-29')
  expect_that(safedates(testdate,prevdate),is_true()) 

  # continous two weeks
  dates=as.Date('2015-05-11')+c(0:4,7:11)
  expect_that(all(safedates(dates,lag(dates)),na.rm=T),is_true()) 
  
  # monday off
  prevdate=as.Date('2015-05-22')
  testdate=as.Date('2015-05-26')
  expect_that(safedates(testdate,prevdate),is_true()) 
  
  # friday off
  prevdate=as.Date('2015-04-02')
  testdate=as.Date('2015-04-06')
  expect_that(safedates(testdate,prevdate),is_true()) 

  # mid week holiday
  prevdate=as.Date('2014-12-31')
  testdate=as.Date('2015-01-02')
  expect_that(safedates(testdate,prevdate),is_true()) 

  # should fail b/c midweek gap
  prevdate=as.Date('2015-05-04')
  testdate=as.Date('2015-05-06')
  expect_that(safedates(testdate,prevdate),is_false()) 

  # should fail b/c friday isn't a holiday
  prevdate=as.Date('2015-05-07')
  testdate=as.Date('2015-05-11')
  expect_that(safedates(testdate,prevdate),is_false()) 

  # should fail b/c monday isn't a holiday
  prevdate=as.Date('2015-05-08')
  testdate=as.Date('2015-05-12')
  expect_that(safedates(testdate,prevdate),is_false()) 

})
