local_ps_csv <- function(env = parent.frame()) {
  dir <- withr::local_tempdir(.local_envir = env)
  path <- file.path(dir, "ps2010a.csv")
  utils::write.csv(
    data.frame(
      USRDS_ID = c(1, 2, 3),
      CLM_FROM = c("01JAN2010", "15FEB2010", "01MAR2010"),
      SPCLTY = c(33, 44, 33),
      HCPCS = c("A1111", "A2222", "A3333")
    ),
    path,
    row.names = FALSE
  )
  old <- .usrds_env$file_list
  .usrds_env$file_list <- data.frame(
    file_path = path,
    file_name = "ps2010a.csv",
    file_root = "ps2010a",
    file_suffix = "csv",
    Year = 2010,
    file_directory = "PS"
  )
  withr::defer(.usrds_env$file_list <- old, envir = env)
  path
}

test_that("get_PS_specialty() keeps claims with the requested specialty codes", {
  local_ps_csv()

  result <- get_PS_specialty(specialtycodelist = 33, yearlist = 2010, HCPCS = TRUE)

  expect_equal(result$USRDS_ID, c(1, 3))
  expect_equal(result$CLM_FROM, as.Date(c("2010-01-01", "2010-03-01")))
  expect_named(result, c("USRDS_ID", "CLM_FROM", "SPCLTY", "HCPCS"))
})

test_that("get_PS_specialty() does not print file details", {
  local_ps_csv()

  expect_no_match(
    paste(capture.output(get_PS_specialty(33, 2010), type = "output"), collapse = "\n"),
    "ps2010a"
  )
})
