context("granularity-detection")

seconds <- as.POSIXct(c("2016-12-31 23:59:59", "2017-01-01 00:00:00", "2017-01-01 00:00:01"), tz = "UTC")
minutes <- as.POSIXct(c("2016-12-31 23:59:00", "2017-01-01 00:00:00", "2017-01-01 00:01:00"), tz = "UTC")
hours <- as.POSIXct(c("2016-12-31 23:00:00", "2017-01-01 00:00:00", "2017-01-01 01:00:00"), tz = "UTC")
days <- as.POSIXct(c("2007-03-10", "2007-03-11", "2007-03-12", "2007-03-13"), tz = "America/Los_Angeles")
weeks <- as.POSIXct(c("2016-12-31 00:00:00", "2017-01-07 00:00:00"), tz = "UTC")
months <- as.POSIXct(c("2016-11-01", "2016-12-01", "2017-01-01", "2017-02-01", "2017-03-01"), tz = "UTC")
years <- as.POSIXct(c("2015-01-01", "2016-01-01", "2017-01-01"), tz = "UTC")

test_that("unevenly spaced time points result in an error", {
  expect_error(detect_granularity(days))
})
lubridate::tz(days) <- "UTC" # daylight savings time throws off detection
test_that("second-by-second granularity is detected correctly", {
  expect_identical(detect_granularity(seconds), "second")
})
test_that("minute-by-minute granularity is detected correctly", {
  expect_identical(detect_granularity(minutes), "minute")
})
test_that("hourly granularity is detected correctly", {
  expect_identical(detect_granularity(hours), "hour")
})
test_that("daily granularity is detected correctly", {
  expect_identical(detect_granularity(days), "day")
})
test_that("weekly granularity is detected correctly", {
  expect_identical(detect_granularity(weeks), "week")
})
test_that("monthly granularity is detected correctly", {
  expect_identical(detect_granularity(months), "month")
})
test_that("yearly granularity is detected correctly", {
  expect_identical(detect_granularity(years), "year")
})
