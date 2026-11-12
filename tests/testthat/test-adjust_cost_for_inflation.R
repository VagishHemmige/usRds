cpi_value <- function(year, month) {
  medical_cpi$value[medical_cpi$year == year & medical_cpi$periodName == month]
}

test_that("adjust_costs_for_inflation() scales costs by the CPI ratio", {
  claims <- data.frame(
    USRDS_ID = c(1, 2),
    CLM_FROM = as.Date(c("2010-06-15", "2015-12-01")),
    PMTAMT = c(100, 100)
  )

  result <- adjust_costs_for_inflation(claims, "December", 2015)

  expect_equal(
    result$PMTAMT_ADJUSTED,
    c(100 * cpi_value(2015, "December") / cpi_value(2010, "June"), 100)
  )
  expect_equal(result$PMTAMT, c(100, 100))
  expect_false(any(c(".cpi", ".cpi_year", ".cpi_month") %in% names(result)))
})

test_that("adjust_costs_for_inflation() ignores a data column named like an internal variable", {
  claims <- data.frame(
    USRDS_ID = 1,
    CLM_FROM = as.Date("2015-12-01"),
    PMTAMT = 100,
    baseline_index = 1
  )

  result <- adjust_costs_for_inflation(claims, "December", 2015)

  expect_equal(result$PMTAMT_ADJUSTED, 100)
})
