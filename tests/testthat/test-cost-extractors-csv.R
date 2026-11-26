# Offline tests of the CSV branch of get_PS_CLM_costs(), get_PS_REV_costs()
# and get_IN_REV_costs(), using made-up rows in a temporary folder. Column
# names follow Appendix B 2025 (PS_CLM_2023, PS_LINE_2023, OP_DET_2023).
# get_IN_CLM_costs() is tested in test-extractors-csv.R.

local_cost_csv <- function(file_root, year, rows, env = parent.frame()) {
  dir <- withr::local_tempdir(.local_envir = env)
  path <- file.path(dir, paste0(file_root, ".csv"))
  utils::write.csv(rows, path, row.names = FALSE)
  old <- .usrds_env$file_list
  .usrds_env$file_list <- data.frame(
    file_path = path,
    file_name = paste0(file_root, ".csv"),
    file_root = file_root,
    file_suffix = "csv",
    Year = year,
    file_directory = "Claims"
  )
  withr::defer(.usrds_env$file_list <- old, envir = env)
  path
}

ps_clm_rows <- function() {
  data.frame(
    USRDS_ID = c(1, 2, 3),
    HCFASAF = "P",
    CLM_FROM = c("01JAN2013", "01FEB2013", "01MAR2013"),
    CLM_THRU = c("02JAN2013", "01FEB2013", "03MAR2013"),
    CLM_PMT_AMT = c(80, 40, 10),
    CARR_CLM_PRMRY_PYR_PD_AMT = c(0, 0, 5),
    NCH_CLM_PRVDR_PMT_AMT = c(80, 40, 10),
    NCH_CLM_BENE_PMT_AMT = c(0, 0, 0),
    NCH_CARR_SBMT_CHRG_AMT = c(200, 100, 30),
    NCH_CARR_ALOW_CHRG_AMT = c(100, 50, 15),
    CARR_CLM_CASH_DDCTBL_APPLY_AMT = c(0, 10, 0)
  )
}

test_that("get_PS_CLM_costs() reads CSV claims with dates and amounts", {
  local_cost_csv("ps_clm_2013", 2013, ps_clm_rows())

  result <- suppressMessages(get_PS_CLM_costs(years = 2013))

  expect_setequal(
    names(result),
    c("USRDS_ID", names(ps_clm_rows())[-1])
  )
  expect_equal(result$USRDS_ID, c(1, 2, 3), ignore_attr = "label")
  expect_s3_class(result$CLM_FROM, "Date")
  expect_s3_class(result$CLM_THRU, "Date")
  expect_equal(result$CLM_THRU, as.Date(c("2013-01-02", "2013-02-01", "2013-03-03")), ignore_attr = "label")
  expect_equal(result$CLM_PMT_AMT, c(80, 40, 10), ignore_attr = "label")
  expect_equal(result$NCH_CARR_ALOW_CHRG_AMT, c(100, 50, 15), ignore_attr = "label")
  expect_s3_class(result$HCFASAF, "factor")
  expect_equal(as.character(result$HCFASAF), rep("Physician/Supplier", 3))
})

test_that("get_PS_CLM_costs() keeps only the requested patients", {
  local_cost_csv("ps_clm_2013", 2013, ps_clm_rows())

  result <- suppressMessages(get_PS_CLM_costs(years = 2013, usrds_ids = c(1, 3)))

  expect_equal(result$USRDS_ID, c(1, 3), ignore_attr = "label")
  expect_equal(result$CLM_PMT_AMT, c(80, 10), ignore_attr = "label")
})

test_that("get_PS_CLM_costs() keeps claims with a missing payment (#54)", {
  rows <- ps_clm_rows()
  rows$CLM_PMT_AMT[2] <- NA
  local_cost_csv("ps_clm_2013", 2013, rows)

  result <- suppressMessages(get_PS_CLM_costs(years = 2013))

  expect_equal(nrow(result), 3)
})

test_that("get_PS_CLM_costs() output prorates and keeps its totals", {
  local_cost_csv("ps_clm_2013", 2013, ps_clm_rows())

  daily <- suppressMessages(get_PS_CLM_costs(years = 2013)) |>
    prorate_costs_by_day()

  expect_equal(nrow(daily), 2 + 1 + 3)
  expect_equal(sum(daily$CLM_PMT_AMT_PRORATED), 130)
  expect_equal(sum(daily$NCH_CARR_SBMT_CHRG_AMT_PRORATED), 330)
})

ps_line_rows <- function() {
  data.frame(
    USRDS_ID = c(1, 1, 2),
    HCFASAF = "P",
    CLM_FROM = c("01JAN2010", "01JAN2010", "01FEB2010"),
    CLM_THRU = c("01JAN2010", "01JAN2010", "02FEB2010"),
    SBMTCH = c(100, 60, 40),
    ALOWCH = c(50, 30, 20),
    PMTAMT = c(40, 24, NA)
  )
}

test_that("get_PS_REV_costs() reads CSV lines with dates and amounts", {
  local_cost_csv("ps2010a", 2010, ps_line_rows())

  result <- suppressMessages(
    get_PS_REV_costs(years = 2010, remove_missing_values = FALSE)
  )

  expect_setequal(names(result), names(ps_line_rows()))
  expect_equal(result$USRDS_ID, c(1, 1, 2), ignore_attr = "label")
  expect_s3_class(result$CLM_FROM, "Date")
  expect_equal(result$CLM_THRU, as.Date(c("2010-01-01", "2010-01-01", "2010-02-02")), ignore_attr = "label")
  expect_equal(result$SBMTCH, c(100, 60, 40), ignore_attr = "label")
  expect_equal(result$ALOWCH, c(50, 30, 20), ignore_attr = "label")
  expect_equal(as.character(result$HCFASAF), rep("Physician/Supplier", 3))
})

test_that("get_PS_REV_costs() drops lines with a missing PMTAMT by default", {
  local_cost_csv("ps2010a", 2010, ps_line_rows())

  dropped <- suppressMessages(get_PS_REV_costs(years = 2010))
  kept <- suppressMessages(
    get_PS_REV_costs(years = 2010, remove_missing_values = FALSE)
  )

  expect_equal(dropped$PMTAMT, c(40, 24), ignore_attr = "label")
  expect_equal(nrow(kept), 3)
})

test_that("get_PS_REV_costs() keeps only the requested patients", {
  local_cost_csv("ps2010a", 2010, ps_line_rows())

  result <- suppressMessages(
    get_PS_REV_costs(years = 2010, usrds_ids = 2, remove_missing_values = FALSE)
  )

  expect_equal(result$USRDS_ID, 2, ignore_attr = "label")
  expect_equal(result$SBMTCH, 40, ignore_attr = "label")
})

rev_rows <- function() {
  data.frame(
    USRDS_ID = c(1, 1, 2),
    HCFASAF = "O",
    CLM_FROM = c("01JAN2010", "01JAN2010", "01FEB2010"),
    CODE = c("0300", "0636", "0300"),
    REV_CH = c(120, 80, 50),
    REVPMT = c(60, 40, 25)
  )
}

test_that("get_IN_REV_costs() reads CSV revenue lines with dates and amounts", {
  local_cost_csv("rev2010a", 2010, rev_rows())

  result <- suppressMessages(get_IN_REV_costs(years = 2010))

  expect_contains(names(result), c("USRDS_ID", "CLM_FROM", "REV_CH", "REVPMT", "HCFASAF"))
  expect_equal(result$USRDS_ID, c(1, 1, 2), ignore_attr = "label")
  expect_s3_class(result$CLM_FROM, "Date")
  expect_equal(result$CLM_FROM, as.Date(c("2010-01-01", "2010-01-01", "2010-02-01")), ignore_attr = "label")
  expect_equal(result$REV_CH, c(120, 80, 50), ignore_attr = "label")
  expect_equal(result$REVPMT, c(60, 40, 25), ignore_attr = "label")
  expect_equal(as.character(result$HCFASAF), rep("Outpatient", 3))
})

test_that("get_IN_REV_costs() keeps only the requested patients", {
  local_cost_csv("rev2010a", 2010, rev_rows())

  result <- suppressMessages(get_IN_REV_costs(years = 2010, usrds_ids = 2))

  expect_equal(result$USRDS_ID, 2, ignore_attr = "label")
  expect_equal(result$REVPMT, 25, ignore_attr = "label")
})
