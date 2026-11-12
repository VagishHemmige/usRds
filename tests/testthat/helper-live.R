# Tests that need real USRDS files run only when both variables are set:
#   Sys.setenv(USRDS_LIVE_TESTS = "true", USRDS_WD = "<your USRDS folder>")
skip_if_not_live <- function() {
  live <- identical(Sys.getenv("USRDS_LIVE_TESTS"), "true") &&
    nzchar(Sys.getenv("USRDS_WD"))
  testthat::skip_if_not(
    live,
    "Needs real USRDS files: set USRDS_LIVE_TESTS=true and USRDS_WD."
  )
}
