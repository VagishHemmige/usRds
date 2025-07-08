# ---- Setup ----
test_that("setup: environment is initialized", {
  skip_if_not(
    isTRUE(.usrds_env$initialized),
    "USRDS environment not initialized — skipping tests."
  )
})

# ---- Constants ----
icd_test <- c("B45", "B450", "B451", "B452", "B453", "B454", "B458", "B459", "1175")  # ICD-9/10 codes for Cryptococcosis
valid_year <- 2006
invalid_years <- c(2005, 2017)
test_ids <- c(36590, 45269)  # unlikely to match but valid format

# ---- Test: Out-of-range years should error ----
test_that("get_PS_ICD fails for out-of-range years", {
  for (yr in invalid_years) {
    expect_error(
      get_PS_ICD(icd_codes = icd_test, years = yr),
      regexp = paste0("not available.*", yr)
    )
  }
})

# ---- Test: In-range year should run silently ----
test_that("get_PS_ICD succeeds silently for in-range year", {
  expect_silent(
    suppressMessages(get_PS_ICD(icd_codes = icd_test, years = valid_year))
  )
})

# ---- Test: Output structure is correct ----
test_that("get_PS_ICD returns expected columns", {
  result <- suppressMessages(get_PS_ICD(icd_codes = icd_test, years = valid_year))

  expect_s3_class(result, "data.frame")
  expect_true(all(c("USRDS_ID", "DIAG", "CLM_FROM", "CLM_THRU") %in% names(result)))
})

# ---- Test: Optional USRDS_ID filter returns valid structure ----
test_that("get_PS_ICD supports filtering by USRDS_IDs", {
  result <- suppressMessages(
    get_PS_ICD(icd_codes = icd_test, years = valid_year, usrds_ids = test_ids)
  )

  expect_s3_class(result, "data.frame")
  expect_true(all(c("USRDS_ID", "DIAG", "CLM_FROM", "CLM_THRU") %in% names(result)))
})
