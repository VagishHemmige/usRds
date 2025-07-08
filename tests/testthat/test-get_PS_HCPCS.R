# ---- Setup ----
test_that("setup: environment is initialized", {
  skip_if_not(
    isTRUE(.usrds_env$initialized),
    "USRDS environment not initialized — skipping tests."
  )
})

# ---- Constants ----
hcpcs_test <- "81003"  # Example HCPCS code: Urinalysis, automated
valid_year <- 2006
invalid_years <- c(2005, 2017)
test_ids <- c(1726, 2516705)  # unlikely to match but valid format

# ---- Test: Out-of-range years should error ----
test_that("get_PS_HCPCS fails for out-of-range years", {
  for (yr in invalid_years) {
    expect_error(
      get_PS_HCPCS(hcpcs_codes = hcpcs_test, years = yr),
      regexp = paste0("not available.*", yr)
    )
  }
})

# ---- Test: In-range year should run silently ----
test_that("get_PS_HCPCS succeeds silently for in-range year", {
  expect_silent(
    suppressMessages(get_PS_HCPCS(hcpcs_codes = hcpcs_test, years = valid_year))
  )
})

# ---- Test: Output structure is correct ----
test_that("get_PS_HCPCS returns expected columns", {
  result <- suppressMessages(get_PS_HCPCS(hcpcs_codes = hcpcs_test, years = valid_year))

  expect_s3_class(result, "data.frame")
  expect_true(all(c("USRDS_ID", "CLM_FROM", "HCPCS") %in% names(result)))
})

# ---- Test: Optional USRDS_ID filter returns valid structure ----
test_that("get_PS_HCPCS supports filtering by USRDS_IDs", {
  result <- suppressMessages(
    get_PS_HCPCS(hcpcs_codes = hcpcs_test, years = valid_year, usrds_ids = test_ids)
  )

  expect_s3_class(result, "data.frame")
  expect_true(all(c("USRDS_ID", "CLM_FROM", "HCPCS") %in% names(result)))
})
