medicare_ab <- "MEDICARE FFS PRIMARY PAY, FOR BOTH PART A AND PART B"

payhist <- function() {
  data.frame(
    USRDS_ID = c(1, 1, 2, 3),
    PAYER = c(
      medicare_ab,
      medicare_ab,
      medicare_ab,
      "EMPLOYER GROUP HEALTH PLAN"
    ),
    BEGDATE = as.Date(c(
      "2009-01-01",
      "2009-07-01",
      "2010-03-01",
      "2009-01-01"
    )),
    ENDDATE = as.Date(c("2009-06-30", "2010-12-31", "2010-12-31", "2010-12-31"))
  )
}

patients <- function() {
  data.frame(
    USRDS_ID = c(1, 2, 3),
    index = as.Date(c("2010-06-01", "2010-06-01", "2010-06-01"))
  )
}

test_that("verify_medicare_primary() needs Medicare primary for the whole lookback", {
  result <- verify_medicare_primary(
    patients(),
    index_date = "index",
    medicare_coverage_df = payhist(),
    coverage_start_variable = "coverage_start",
    coverage_end_variable = "coverage_end"
  )

  expect_equal(result$medicare_primary_TF, c(TRUE, FALSE, FALSE))
  expect_equal(
    result$coverage_start,
    as.Date(c("2009-01-01", "2010-03-01", NA))
  )
  expect_equal(result$coverage_end, as.Date(c("2010-12-31", "2010-12-31", NA)))
  expect_named(
    result,
    c(
      "USRDS_ID",
      "index",
      "medicare_primary_TF",
      "coverage_start",
      "coverage_end"
    )
  )
})

test_that("verify_medicare_primary() accepts a fixed index date", {
  result <- verify_medicare_primary(
    patients(),
    index_date = as.Date("2010-02-01"),
    medicare_coverage_df = payhist()
  )

  expect_equal(result$medicare_primary_TF, c(TRUE, FALSE, FALSE))
  expect_named(result, c("USRDS_ID", "index", "medicare_primary_TF"))
})

test_that("verify_medicare_primary() uses its argument, not a data column named lookback_days", {
  df <- patients()
  df$lookback_days <- 0

  result <- verify_medicare_primary(
    df,
    index_date = "index",
    medicare_coverage_df = payhist()
  )

  expect_equal(result$medicare_primary_TF, c(TRUE, FALSE, FALSE))
})
