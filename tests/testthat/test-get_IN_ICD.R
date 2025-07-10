# test-get_IN_ICD.R
# Tests for get_IN_ICD() function, including year validation, ICD filtering,
# optional USRDS_ID restriction, and structural expectations.

# ---- Setup ----
test_that("setup: environment is initialized", {
  skip_if_not(
    isTRUE(.usrds_env$initialized),
    "USRDS environment not initialized — skipping tests."
  )
})

# ---- Constants ----
icd_test <- c("B45", "B450", "B451", "B452", "B453", "B454", "B458", "B459", "1175")  # ICD-9 and ICD-10 for Cryptococcosis
valid_year <- 2006
invalid_years <- c(2005, 2017)
test_ids <- c(45269, 36590)  # unlikely matches, used to test ID filter logic

# ---- Test: Out-of-range years should error ----
test_that("get_IN_ICD fails for out-of-range years", {
  for (yr in invalid_years) {
    expect_error(
      get_IN_ICD(icd_codes = icd_test, years = yr),
      regexp = paste0("not available.*", yr)
    )
  }
})

# ---- Test: In-range year should run silently ----
test_that("get_IN_ICD succeeds silently for in-range year", {
  expect_silent(
    suppressMessages(get_IN_ICD(icd_codes = icd_test, years = valid_year))
  )
})

# ---- Test: Output structure is correct ----
test_that("get_IN_ICD returns expected columns", {
  result <- suppressMessages(get_IN_ICD(icd_codes = icd_test, years = valid_year))

  expect_s3_class(result, "data.frame")
  expect_true(
    all(c("USRDS_ID", "CODE", "CLM_FROM") %in% names(result)),
    info = "Returned data frame is missing one or more expected columns"
  )
})

# ---- Test: Optional USRDS_ID filter returns valid structure ----
test_that("get_IN_ICD supports filtering by USRDS_IDs", {
  result <- suppressMessages(
    get_IN_ICD(icd_codes = icd_test, years = valid_year, usrds_ids = test_ids)
  )

  expect_s3_class(result, "data.frame")
  expect_true(
    all(c("USRDS_ID", "CODE", "CLM_FROM") %in% names(result)),
    info = "Returned data frame with filtering is missing one or more expected columns"
  )
})

# ---- Test: get_IN_ICD with icd_codes = NULL returns all claims ----
test_that("get_IN_ICD returns all diagnoses when icd_codes = NULL", {
  result <- get_IN_ICD(icd_codes = NULL, years = 2006)
  if (nrow(result) <= 0) {
    fail("No rows returned when icd_codes = NULL")
  }
})

# ---- Test: get_IN_ICD supports USRDS_ID filtering when icd_codes = NULL ----
test_that("get_IN_ICD filters to specific USRDS_IDs when icd_codes is NULL", {
  result <- suppressMessages(get_IN_ICD(icd_codes = NULL, years = valid_year, usrds_ids = test_ids))

  expect_s3_class(result, "data.frame")
  expect_true(all(result$USRDS_ID %in% test_ids))
})

# ╔════════════════════════════════════════════════════════════════════╗
# ║            DRAFT TEST: ICD coverage check for IN files            ║
# ╚════════════════════════════════════════════════════════════════════╝

if (FALSE) {

  # Internal loader for unmatched IN ICD codes
  .load_individual_file_IN_notin_ICD <- function(file_path, file_root, file_suffix, Year,
                                                 file_directory, icd_codes, usrds_ids = NULL) {
    message("Reading file: ", file_path)

    if (file_suffix == "parquet") {
      temp <- arrow::read_parquet(file_path) %>%
        dplyr::rename_with(toupper) %>%
        dplyr::filter(!CODE %in% icd_codes) %>%
        {
          if (!is.null(usrds_ids)) dplyr::filter(., USRDS_ID %in% usrds_ids) else .
        } %>%
        dplyr::select(USRDS_ID, CODE, CLM_FROM) %>%
        dplyr::collect()

    } else if (file_suffix == "csv") {
      temp <- readr::read_csv(file_path, show_col_types = FALSE) %>%
        dplyr::rename_with(toupper) %>%
        dplyr::mutate(CLM_FROM = suppressWarnings(lubridate::dmy(CLM_FROM))) %>%
        dplyr::filter(!CODE %in% icd_codes) %>%
        {
          if (!is.null(usrds_ids)) dplyr::filter(., USRDS_ID %in% usrds_ids) else .
        } %>%
        dplyr::select(USRDS_ID, CODE, CLM_FROM)

    } else if (file_suffix == "sas7bdat") {
      temp <- haven::read_sas(file_path, col_select = c("USRDS_ID", "CLM_FROM", "CODE")) %>%
        dplyr::rename_with(toupper) %>%
        dplyr::filter(!CODE %in% icd_codes) %>%
        {
          if (!is.null(usrds_ids)) dplyr::filter(., USRDS_ID %in% usrds_ids) else .
        } %>%
        dplyr::select(USRDS_ID, CODE, CLM_FROM)

    } else {
      stop("Unsupported file type: ", file_suffix)
    }

    return(temp)
  }

  # Wrapper function for unmatched ICD codes in IN files
  get_IN_notin_ICD <- function(icd_codes, years, usrds_ids = NULL) {
    .check_valid_years(
      years = years,
      file_keys = IN_ICD$file_root,
      label = "Institutional ICD files"
    )

    .usrds_env$file_list %>%
      dplyr::inner_join(IN_ICD, by = c("file_root", "Year")) %>%
      dplyr::filter(Year %in% years) %>%
      dplyr::select(-file_name) %>%
      purrr::pmap(.f = function(...) {
        .load_individual_file_IN_notin_ICD(...,
                                           icd_codes = icd_codes,
                                           usrds_ids = usrds_ids)
      }) %>%
      dplyr::bind_rows()
  }

  # Test to validate coverage of ICD codes in institutional claims
  test_that("All IN ICD codes for selected years are found in ICD reference list", {
    skip_if_not(.usrds_env$initialized, "USRDS environment not initialized")

    expect_true(exists("icd_reference"), info = "icd_reference not found in test environment")
    expect_true("code" %in% names(icd_reference), info = "icd_reference must have a 'code' column")

    unmatched_codes <- get_IN_notin_ICD(
      icd_codes = icd_reference$code,
      years = valid_year
    ) %>%
      dplyr::pull(CODE) %>%
      unique()

    expect_length(unmatched_codes, 0,
                  info = paste("Found", length(unmatched_codes), "ICD codes not in icd_reference:\n",
                               paste(head(unmatched_codes, 10), collapse = ", "))
    )
  })

}
