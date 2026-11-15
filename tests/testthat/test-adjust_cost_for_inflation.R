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

# Every amount column returned by get_PS_CLM_costs(), get_IN_CLM_costs(),
# get_PS_REV_costs() and get_IN_REV_costs() (#31).
extractor_amount_columns <- c(
  "CLM_PMT_AMT", "CARR_CLM_PRMRY_PYR_PD_AMT", "NCH_CLM_PRVDR_PMT_AMT",
  "NCH_CLM_BENE_PMT_AMT", "NCH_CARR_SBMT_CHRG_AMT", "NCH_CARR_ALOW_CHRG_AMT",
  "CARR_CLM_CASH_DDCTBL_APPLY_AMT",
  "CLM_TOT", "CLM_AMT",
  "SBMTCH", "ALOWCH", "PMTAMT",
  "REV_CH", "REVPMT"
)

test_that("adjust_costs_for_inflation() adjusts every amount column from the cost extractors", {
  claims <- data.frame(USRDS_ID = 1, CLM_FROM = as.Date("2010-06-15"))
  for (i in seq_along(extractor_amount_columns)) {
    claims[[extractor_amount_columns[i]]] <- 100 * i
  }
  ratio <- cpi_value(2015, "December") / cpi_value(2010, "June")

  result <- adjust_costs_for_inflation(claims, "December", 2015)

  for (i in seq_along(extractor_amount_columns)) {
    column <- extractor_amount_columns[i]
    adjusted <- paste0(column, "_ADJUSTED")
    expect_equal(result[[adjusted]], 100 * i * ratio, label = adjusted)
    expect_equal(result[[column]], 100 * i, label = column)
  }
})

test_that("adjust_costs_for_inflation() adjusts prorated amounts", {
  claims <- data.frame(
    USRDS_ID = 1,
    CLM_FROM = as.Date("2010-06-15"),
    CLM_PMT_AMT_PRORATED = 100,
    REV_CH_PRORATED = 50
  )
  ratio <- cpi_value(2015, "December") / cpi_value(2010, "June")

  result <- adjust_costs_for_inflation(claims, "December", 2015)

  expect_equal(result$CLM_PMT_AMT_PRORATED_ADJUSTED, 100 * ratio)
  expect_equal(result$REV_CH_PRORATED_ADJUSTED, 50 * ratio)
})
