# Made-up patients, index 2010-01-01 for all:
# 1 dies 2010-03-01; 2 loses coverage 2010-06-30; 3 reaches the claims end;
# 4 reaches the study end; 5 has no Medicare-primary spell at the index.
followup_patients <- function() {
  data.frame(
    USRDS_ID = 1:5,
    index = as.Date("2010-01-01"),
    DIED = as.Date(c("2010-03-01", NA, NA, NA, NA)),
    coverage_end = as.Date(c(
      "2012-12-31",
      "2010-06-30",
      "2012-12-31",
      "2012-12-31",
      NA
    ))
  )
}

test_that("claims_followup_end() ends at the earliest end and names it (#23)", {
  patients <- followup_patients()
  patients$study_end <- as.Date(c(rep("2012-12-31", 3), "2011-01-01", "2012-12-31"))

  result <- claims_followup_end(
    patients,
    index_date = "index",
    coverage_end = "coverage_end",
    death_date = "DIED",
    claims_end = as.Date("2011-06-30"),
    study_end = "study_end"
  )

  expect_equal(
    result$followup_end,
    as.Date(c("2010-03-01", "2010-06-30", "2011-06-30", "2011-01-01", NA))
  )
  expect_equal(
    result$followup_end_reason,
    c("death", "coverage_end", "claims_end", "study_end", "no_coverage")
  )
  expect_named(result, c(names(patients), "followup_end", "followup_end_reason"))
})

test_that("claims_followup_end() takes fixed dates and a maximum length (#23)", {
  result <- claims_followup_end(
    followup_patients()[2:4, ],
    index_date = "index",
    coverage_end = "coverage_end",
    claims_end = as.Date("2023-12-31"),
    study_end = as.Date("2022-01-01"),
    max_days = 364
  )

  expect_equal(
    result$followup_end,
    as.Date(c("2010-06-30", "2010-12-31", "2010-12-31"))
  )
  expect_equal(result$followup_end_reason, c("coverage_end", "max_days", "max_days"))
})

test_that("claims_followup_end() breaks ties in the order death, coverage, claims, study, maximum (#23)", {
  patient <- data.frame(
    USRDS_ID = 1,
    index = as.Date("2010-01-01"),
    DIED = as.Date("2010-12-31"),
    coverage_end = as.Date("2010-12-31")
  )

  result <- claims_followup_end(
    patient,
    index_date = "index",
    coverage_end = "coverage_end",
    death_date = "DIED",
    claims_end = as.Date("2010-12-31"),
    max_days = 364
  )

  expect_equal(result$followup_end_reason, "death")
})

test_that("claims_followup_end() warns when follow-up ends before the index (#23)", {
  patient <- data.frame(
    USRDS_ID = 1,
    index = as.Date("2010-01-01"),
    DIED = as.Date("2009-12-01"),
    coverage_end = as.Date("2012-12-31")
  )

  expect_snapshot(
    result <- claims_followup_end(
      patient,
      index_date = "index",
      coverage_end = "coverage_end",
      death_date = "DIED",
      claims_end = as.Date("2023-12-31")
    )
  )
  expect_equal(result$followup_end, as.Date("2009-12-01"))
})

test_that("claims_followup_end() checks its arguments (#23)", {
  patients <- followup_patients()

  expect_snapshot(
    error = TRUE,
    claims_followup_end(patients, "index", "coverage_end", claims_end = "2023-12-31")
  )
  expect_snapshot(
    error = TRUE,
    claims_followup_end(patients, "index", "not_a_column", claims_end = as.Date("2023-12-31"))
  )
  expect_snapshot(
    error = TRUE,
    claims_followup_end(patients, "index", "coverage_end")
  )
})

test_that("claims_followup_end() gives no end to rows without an index date (#23)", {
  patients <- followup_patients()[2:3, ]
  patients$index[1] <- as.Date(NA)

  result <- claims_followup_end(
    patients,
    index_date = "index",
    coverage_end = "coverage_end",
    claims_end = as.Date("2011-06-30")
  )

  expect_equal(result$followup_end, as.Date(c(NA, "2011-06-30")))
  expect_equal(result$followup_end_reason, c("no_index", "claims_end"))
})

test_that("claims_followup_end() takes only whole days for max_days (#23)", {
  patient <- followup_patients()[3, ]
  run <- function(days) {
    claims_followup_end(
      patient, "index", "coverage_end",
      claims_end = as.Date("2023-12-31"), max_days = days
    )$followup_end
  }

  expect_equal(run(0), as.Date("2010-01-01"))
  expect_equal(run(364), as.Date("2010-12-31"))
  expect_snapshot(error = TRUE, run(0.5))
})
