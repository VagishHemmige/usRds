# Needs real USRDS files; skips the whole file otherwise.
skip_if_not_live()

# ---- Constants ----
hcpcs_test <- c("90935", "90937") # Hemodialysis codes
valid_year <- 2006
invalid_years <- c(2005, 2017)
test_ids <- c(1, 2) # obviously fake; tests the filter, not matches

# ---- Test: Out-of-range years should error ----
test_that("get_IN_HCPCS fails for out-of-range years", {
  for (yr in invalid_years) {
    expect_error(
      get_IN_HCPCS(hcpcs_codes = hcpcs_test, years = yr),
      regexp = paste0("not available.*", yr)
    )
  }
})

# ---- Test: In-range year should run silently ----
test_that("get_IN_HCPCS succeeds silently for in-range year", {
  expect_silent(
    suppressMessages(get_IN_HCPCS(hcpcs_codes = hcpcs_test, years = valid_year))
  )
})

# ---- Test: Output structure is correct ----
test_that("get_IN_HCPCS returns expected columns", {
  result <- suppressMessages(get_IN_HCPCS(
    hcpcs_codes = hcpcs_test,
    years = valid_year
  ))

  expect_s3_class(result, "data.frame")
  expect_true(all(
    c("USRDS_ID", "CLM_FROM", "HCPCS", "REV_CH") %in% names(result)
  ))
})

# ---- Test: Optional USRDS_ID filter returns valid structure ----
test_that("get_IN_HCPCS supports filtering by USRDS_IDs", {
  result <- suppressMessages(
    get_IN_HCPCS(
      hcpcs_codes = hcpcs_test,
      years = valid_year,
      usrds_ids = test_ids
    )
  )

  expect_s3_class(result, "data.frame")
  expect_true(all(
    c("USRDS_ID", "CLM_FROM", "HCPCS", "REV_CH") %in% names(result)
  ))
})

test_that("get_IN_HCPCS works when hcpcs_codes = NULL", {
  result <- suppressMessages(get_IN_HCPCS(
    hcpcs_codes = NULL,
    years = valid_year
  ))

  expect_s3_class(result, "data.frame")
  expect_true(all(
    c("USRDS_ID", "CLM_FROM", "HCPCS", "REV_CH") %in% names(result)
  ))
  expect_true(nrow(result) > 0)
})

test_that("get_IN_HCPCS returns empty result when no matches", {
  result <- suppressMessages(get_IN_HCPCS(
    hcpcs_codes = "ZZZZZ",
    years = valid_year
  ))

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})
