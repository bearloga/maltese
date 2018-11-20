context("leads-creation")

x <- data.frame(
  dt = as.POSIXct(c("2016-11-01", "2016-12-01", "2017-01-01", "2017-02-01", "2017-03-01"), tz = "UTC"),
  y = 1:10
)

ml_x <- mlts_transform(x, dt, y, h = 10)

test_that("leads are calculated correctly", {
  expect_equal(ifelse(ml_x$y + 1 > 10, NA, ml_x$y + 1), ml_x$mlts_lead_1)
  expect_equal(ifelse(ml_x$y + 2 > 10, NA, ml_x$y + 2), ml_x$mlts_lead_2)
  expect_equal(ifelse(ml_x$y + 3 > 10, NA, ml_x$y + 3), ml_x$mlts_lead_3)
  expect_equal(ifelse(ml_x$y + 10 > 10, NA_real_, ml_x$y + 10), ml_x$mlts_lead_10)
})
