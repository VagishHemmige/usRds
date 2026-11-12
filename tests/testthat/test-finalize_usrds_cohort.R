test_that("finalize_usrds_cohort() shifts time to each patient's first tstart", {
  df <- data.frame(
    USRDS_ID = c(1, 2),
    start = as.Date(c("2005-01-01", "2006-01-01")),
    end = as.Date(c("2005-01-11", "2006-01-21"))
  )
  cohort <- create_usrds_cohort(df, start_date = "start", end_date = "end")

  result <- finalize_usrds_cohort(cohort)

  expect_equal(result$tstart, c(0, 0))
  expect_equal(result$tstop, c(10, 20))
  expect_false(".t0" %in% names(result))
  expect_false(dplyr::is_grouped_df(result))
})

