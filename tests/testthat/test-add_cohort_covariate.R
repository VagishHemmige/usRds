test_that("add_cohort_covariate() ignores a covariate data column named origin_date", {
  cohort <- create_usrds_cohort(
    data.frame(
      USRDS_ID = 1,
      start = as.Date("2010-01-01"),
      end = as.Date("2010-12-31")
    ),
    start_date = "start",
    end_date = "end"
  )
  covariates <- data.frame(
    USRDS_ID = 1,
    covariate_date = as.Date("2010-06-01"),
    origin_date = as.Date("2000-01-01")
  )

  result <- add_cohort_covariate(
    cohort,
    covariates,
    "covariate_date",
    covariate_variable_name = "diabetes"
  )

  expect_equal(
    result$tstart[result$diabetes == 1],
    as.numeric(as.Date("2010-06-01"))
  )
})

test_that("add_cohort_covariate() refuses a finalized cohort", {
  cohort <- create_usrds_cohort(
    data.frame(
      USRDS_ID = 1,
      start = as.Date("2010-01-01"),
      end = as.Date("2010-12-31")
    ),
    start_date = "start",
    end_date = "end"
  )
  finalized <- finalize_usrds_cohort(cohort, baseline_date_variable = "start")
  covariates <- data.frame(
    USRDS_ID = 1,
    covariate_date = as.Date("2010-06-01")
  )

  expect_snapshot(
    add_cohort_covariate(
      finalized,
      covariates,
      "covariate_date",
      covariate_variable_name = "diabetes"
    ),
    error = TRUE
  )
})
