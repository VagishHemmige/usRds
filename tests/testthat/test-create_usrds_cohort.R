test_that("create_usrds_cohort() takes start and end dates as column names", {
  df <- data.frame(
    USRDS_ID = c(1, 2),
    start = as.Date(c("2005-01-01", "2006-01-01")),
    end = as.Date(c("2010-01-01", "2011-01-01"))
  )

  cohort <- create_usrds_cohort(df, start_date = "start", end_date = "end")

  expect_equal(cohort$tstart, as.numeric(df$start))
  expect_equal(cohort$tstop, as.numeric(df$end))
})

test_that("create_usrds_cohort() ignores a data column that shares a name with an internal variable", {
  df <- data.frame(
    USRDS_ID = c(1, 2),
    start = as.Date(c("2005-01-01", "2006-01-01")),
    end = as.Date(c("2010-01-01", "2011-01-01")),
    origin_date = as.Date(c("2000-01-01", "2000-01-01"))
  )

  cohort <- create_usrds_cohort(df, start_date = "start", end_date = "end")

  expect_equal(cohort$tstart, as.numeric(df$start))
})

test_that("create_usrds_cohort() errors clearly when a named column is missing", {
  df <- data.frame(
    USRDS_ID = c(1, 2),
    start = as.Date(c("2005-01-01", "2006-01-01"))
  )

  expect_error(
    create_usrds_cohort(df, start_date = "start", end_date = "end"),
    regexp = "end_date"
  )
})
