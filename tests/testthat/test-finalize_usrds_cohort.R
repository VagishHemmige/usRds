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

test_that("finalize_usrds_cohort() refuses an already finalized cohort", {
  df <- data.frame(
    USRDS_ID = 1,
    start = as.Date("2020-01-01"),
    end = as.Date("2020-01-11")
  )
  cohort <- create_usrds_cohort(df, start_date = "start", end_date = "end")
  finalized <- finalize_usrds_cohort(cohort, baseline_date_variable = "start")

  expect_snapshot(
    finalize_usrds_cohort(finalized, baseline_date_variable = "start"),
    error = TRUE
  )
  expect_snapshot(finalize_usrds_cohort(finalized), error = TRUE)
})

test_that("finalize_usrds_cohort() still allows row-varying baselines", {
  df <- data.frame(
    USRDS_ID = c(1, 1),
    start = as.Date(c("2020-01-01", "2020-01-01")),
    end = as.Date(c("2020-01-11", "2020-01-11"))
  )
  cohort <- create_usrds_cohort(
    df[1, ],
    start_date = "start",
    end_date = "end"
  )
  cohort <- rbind(cohort, cohort)
  cohort$tstart <- c(18262, 18267)
  cohort$tstop <- c(18267, 18272)
  cohort$baseline <- as.Date(c("2020-01-01", "2020-01-06"))
  attr(cohort, "cohort_type") <- "USRDS_cohort"

  result <- finalize_usrds_cohort(cohort, baseline_date_variable = "baseline")

  expect_equal(result$tstart, c(0, 0))
  expect_equal(result$tstop, c(5, 5))
  expect_identical(attr(result, "finalized"), TRUE)
})
