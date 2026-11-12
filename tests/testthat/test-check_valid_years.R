local_file_list <- function(file_list, env = parent.frame()) {
  old <- .usrds_env$file_list
  .usrds_env$file_list <- file_list
  withr::defer(.usrds_env$file_list <- old, envir = env)
}

test_that(".check_valid_years() accepts years present for the requested files", {
  local_file_list(data.frame(
    file_root = c("IN_CLM", "IN_CLM"),
    Year = c(2010, 2011)
  ))

  expect_invisible(.check_valid_years(c(2010, 2011), "IN_CLM"))
})

test_that(".check_valid_years() names the missing years", {
  local_file_list(data.frame(
    file_root = c("IN_CLM", "PS_CLM"),
    Year = c(2010, 2012)
  ))

  expect_error(.check_valid_years(c(2010, 2012), "IN_CLM"), regexp = "2012")
})
