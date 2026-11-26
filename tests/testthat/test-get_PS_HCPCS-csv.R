# Offline tests of get_PS_HCPCS() on a made-up CSV claim-line file.
# test-get_PS_HCPCS.R holds the live tests on real files.

local_ps_csv <- function(rows, env = parent.frame()) {
  dir <- withr::local_tempdir(.local_envir = env)
  path <- file.path(dir, "ps2010a.csv")
  utils::write.csv(rows, path, row.names = FALSE)
  old <- .usrds_env$file_list
  .usrds_env$file_list <- data.frame(
    file_path = path,
    file_name = "ps2010a.csv",
    file_root = "ps2010a",
    file_suffix = "csv",
    Year = 2010,
    file_directory = "Claims"
  )
  withr::defer(.usrds_env$file_list <- old, envir = env)
  path
}

ps_lines <- function() {
  data.frame(
    USRDS_ID = c(1, 1, 2, 3),
    HCFASAF = "P",
    CLM_FROM = c("01JAN2010", "02JAN2010", "01FEB2010", "01MAR2010"),
    HCPCS = c("81003", "G0008", "81003", "99213")
  )
}

test_that("get_PS_HCPCS() filters CSV lines by code and ID", {
  local_ps_csv(ps_lines())

  result <- suppressMessages(
    get_PS_HCPCS(hcpcs_codes = "81003", years = 2010, usrds_ids = c(1, 3))
  )

  expect_named(result, c("USRDS_ID", "CLM_FROM", "HCPCS", "HCFASAF"), ignore.order = TRUE)
  expect_equal(result$USRDS_ID, 1, ignore_attr = "label")
  expect_equal(result$HCPCS, "81003", ignore_attr = "label")
  expect_equal(result$CLM_FROM, as.Date("2010-01-01"), ignore_attr = "label")
  expect_equal(as.character(result$HCFASAF), "Physician/Supplier")
})

test_that("get_PS_HCPCS() keeps every line when hcpcs_codes is NULL", {
  local_ps_csv(ps_lines())

  result <- suppressMessages(get_PS_HCPCS(years = 2010))

  expect_equal(nrow(result), 4)
  expect_setequal(result$HCPCS, c("81003", "G0008", "99213"))
})

test_that("get_PS_HCPCS() returns no rows when nothing matches", {
  local_ps_csv(ps_lines())

  result <- suppressMessages(get_PS_HCPCS(hcpcs_codes = "J9999", years = 2010))

  expect_equal(nrow(result), 0)
})
