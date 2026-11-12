test_that("prorate_costs_by_day() spreads a claim's cost evenly over its days", {
  claims <- data.frame(
    USRDS_ID = 1,
    CLM_FROM = as.Date("2010-01-01"),
    CLM_THRU = as.Date("2010-01-03"),
    PMTAMT = 30
  )

  result <- prorate_costs_by_day(claims)

  expect_equal(
    result$service_date,
    as.Date(c("2010-01-01", "2010-01-02", "2010-01-03"))
  )
  expect_equal(result$PMTAMT_PRORATED, c(10, 10, 10))
  expect_false("PMTAMT" %in% names(result))
})

test_that("prorate_costs_by_day() errors on a missing column instead of using a global object", {
  claims <- data.frame(
    USRDS_ID = 1,
    CLM_FROM = as.Date("2010-01-01"),
    PMTAMT = 30
  )
  assign("CLM_THRU", as.Date("2010-01-03"), envir = globalenv())
  withr::defer(rm("CLM_THRU", envir = globalenv()))

  expect_error(
    prorate_costs_by_day(claims),
    class = "rlang_error_data_pronoun_not_found"
  )
})
