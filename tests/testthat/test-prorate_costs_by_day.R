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

test_that("prorate_costs_by_day() conserves every amount column from the cost extractors", {
  claims <- data.frame(
    USRDS_ID = 1,
    CLM_FROM = as.Date("2010-01-01"),
    CLM_THRU = as.Date("2010-01-03")
  )
  for (i in seq_along(extractor_amount_columns)) {
    claims[[extractor_amount_columns[i]]] <- 30 * i
  }

  result <- prorate_costs_by_day(claims)

  expect_equal(nrow(result), 3)
  for (i in seq_along(extractor_amount_columns)) {
    prorated <- paste0(extractor_amount_columns[i], "_PRORATED")
    expect_equal(result[[prorated]], rep(10 * i, 3), label = prorated)
  }
  expect_equal(intersect(extractor_amount_columns, names(result)), character())
})

test_that("prorate_costs_by_day() reproduces the #31 example", {
  claims <- data.frame(
    USRDS_ID = 1,
    CLM_FROM = as.Date("2010-01-01"),
    CLM_THRU = as.Date("2010-01-03"),
    CLM_PMT_AMT = 300,
    NCH_CLM_BENE_PMT_AMT = 30
  )

  result <- prorate_costs_by_day(claims)

  expect_equal(sum(result$CLM_PMT_AMT_PRORATED), 300)
  expect_equal(sum(result$NCH_CLM_BENE_PMT_AMT_PRORATED), 30)
})

test_that("prorate_costs_by_day() prorates inflation-adjusted amounts", {
  claims <- data.frame(
    USRDS_ID = 1,
    CLM_FROM = as.Date("2010-01-01"),
    CLM_THRU = as.Date("2010-01-02"),
    CLM_PMT_AMT = 300,
    CLM_PMT_AMT_ADJUSTED = 330,
    REV_CH_ADJUSTED = 50
  )

  result <- prorate_costs_by_day(claims)

  expect_equal(result$CLM_PMT_AMT_PRORATED, c(150, 150))
  expect_equal(result$CLM_PMT_AMT_ADJUSTED_PRORATED, c(165, 165))
  expect_equal(result$REV_CH_ADJUSTED_PRORATED, c(25, 25))
})

test_that("prorating and adjusting for inflation give the same result in either order", {
  claims <- data.frame(
    USRDS_ID = c(1, 2),
    CLM_FROM = as.Date(c("2010-06-29", "2012-03-01")),
    CLM_THRU = as.Date(c("2010-07-02", "2012-03-02")),
    CLM_PMT_AMT = c(400, -60),
    REV_CH = c(NA, 80)
  )

  prorated_first <- claims |>
    prorate_costs_by_day() |>
    adjust_costs_for_inflation("December", 2015)
  adjusted_first <- claims |>
    adjust_costs_for_inflation("December", 2015) |>
    prorate_costs_by_day()

  expect_equal(
    prorated_first$CLM_PMT_AMT_PRORATED_ADJUSTED,
    adjusted_first$CLM_PMT_AMT_ADJUSTED_PRORATED
  )
  expect_equal(
    prorated_first$REV_CH_PRORATED_ADJUSTED,
    adjusted_first$REV_CH_ADJUSTED_PRORATED
  )

  # Both orders use the CPI of the claim's start month, even for the days of
  # claim 1 that fall in July.
  ratio <- function(year, month) {
    medical_cpi$value[medical_cpi$year == 2015 & medical_cpi$periodName == "December"] /
      medical_cpi$value[medical_cpi$year == year & medical_cpi$periodName == month]
  }
  expected <- c(rep(400 * ratio(2010, "June") / 4, 4), rep(-60 * ratio(2012, "March") / 2, 2))
  expect_equal(adjusted_first$CLM_PMT_AMT_ADJUSTED_PRORATED, expected)
  expect_equal(sum(adjusted_first$CLM_PMT_AMT_ADJUSTED_PRORATED), sum(expected))
  expect_equal(adjusted_first$REV_CH_ADJUSTED_PRORATED[1:4], rep(NA_real_, 4))
})
