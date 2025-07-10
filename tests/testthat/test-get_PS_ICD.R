# ╔════════════════════════════════════════════════════════════════════╗
# ║      Test Suite: get_PS_ICD() — Physician/Supplier Diagnoses      ║
# ╚════════════════════════════════════════════════════════════════════╝
#
# This test suite verifies:
#   1. Correct output structure when filtering by ICD codes
#   2. Behavior when icd_codes = NULL (all diagnosis claims returned)
#   3. Filtering by USRDS_ID subset
#   4. Compatibility with .usrds_env and year checking

test_that("get_PS_ICD() returns expected structure with ICD codes", {
  skip_if_not(.usrds_env$initialized, "USRDS environment not initialized")

  result <- get_PS_ICD(icd_codes = c("1175", "B45"), years = 2006)

  expect_s3_class(result, "data.frame")
  expect_true(all(c("USRDS_ID", "DIAG", "CLM_FROM", "CLM_THRU") %in% names(result)))
  expect_type(result$USRDS_ID, "double")
  expect_type(result$DIAG, "character")
  expect_s3_class(result$CLM_FROM, "Date")
  expect_s3_class(result$CLM_THRU, "Date")
})

test_that("get_PS_ICD() returns all claims when icd_codes = NULL", {
  skip_if_not(.usrds_env$initialized, "USRDS environment not initialized")

  result_all <- get_PS_ICD(icd_codes = NULL, years = 2006)

  expect_s3_class(result_all, "data.frame")
  expect_true(all(c("USRDS_ID", "DIAG", "CLM_FROM", "CLM_THRU") %in% names(result_all)))
  expect_gt(nrow(result_all), 0)
})

test_that("get_PS_ICD() correctly filters to specific USRDS_IDs", {
  skip_if_not(.usrds_env$initialized, "USRDS environment not initialized")

  full_result <- get_PS_ICD(icd_codes = NULL, years = 2006)
  unique_ids <- unique(full_result$USRDS_ID)

  if (length(unique_ids) >= 2) {
    subset_ids <- unique_ids[1:2]
    filtered_result <- get_PS_ICD(icd_codes = NULL, years = 2006, usrds_ids = subset_ids)
    expect_true(all(filtered_result$USRDS_ID %in% subset_ids))
  } else {
    skip("Test data must contain at least two distinct USRDS_IDs.")
  }
})

# ╔════════════════════════════════════════════════════════════════════╗
# ║                     DRAFT TEST: ICD coverage check                ║
# ╚════════════════════════════════════════════════════════════════════╝
#
# The following test and its dependencies are wrapped in `if (FALSE)`
# so they are excluded from routine `testthat` runs.
# Uncomment or refactor into a standalone test file when needed.

if (FALSE) {

  # Internal loader for ICDs not in reference list
  .load_individual_file_PS_notin_ICD <- function(file_path, file_root, file_suffix, Year,
                                                 file_directory, icd_codes, usrds_ids = NULL) {
    message("Reading file: ", file_path)

    if (file_suffix == "parquet") {
      temp <- arrow::read_parquet(file_path) %>%
        dplyr::rename_with(toupper) %>%
        dplyr::filter(!DIAG %in% icd_codes) %>%
        {
          if (!is.null(usrds_ids)) dplyr::filter(., USRDS_ID %in% usrds_ids) else .
        } %>%
        dplyr::select(USRDS_ID, DIAG, CLM_FROM, CLM_THRU) %>%
        dplyr::collect()

    } else if (file_suffix == "csv") {
      temp <- readr::read_csv(file_path, show_col_types = FALSE) %>%
        dplyr::rename_with(toupper) %>%
        dplyr::mutate(
          CLM_FROM = suppressWarnings(lubridate::dmy(CLM_FROM)),
          CLM_THRU = suppressWarnings(lubridate::dmy(CLM_THRU))
        ) %>%
        dplyr::filter(!DIAG %in% icd_codes) %>%
        {
          if (!is.null(usrds_ids)) dplyr::filter(., USRDS_ID %in% usrds_ids) else .
        } %>%
        dplyr::select(USRDS_ID, DIAG, CLM_FROM, CLM_THRU)

    } else if (file_suffix == "sas7bdat") {
      temp <- haven::read_sas(file_path, col_select = c("USRDS_ID", "CLM_FROM", "DIAG", "CLM_THRU")) %>%
        dplyr::rename_with(toupper) %>%
        dplyr::filter(!DIAG %in% icd_codes) %>%
        {
          if (!is.null(usrds_ids)) dplyr::filter(., USRDS_ID %in% usrds_ids) else .
        } %>%
        dplyr::select(USRDS_ID, DIAG, CLM_FROM, CLM_THRU)

    } else {
      stop("Unsupported file type: ", file_suffix)
    }

    return(temp)
  }

  # Wrapper to pull unmatched ICDs
  get_PS_notin_ICD <- function(icd_codes, years, usrds_ids = NULL) {
    .check_valid_years(
      years = years,
      file_keys = PS_ICD$file_root,
      label = "Physician/Supplier ICD files"
    )

    .usrds_env$file_list %>%
      dplyr::inner_join(PS_ICD, by = c("file_root", "Year")) %>%
      dplyr::filter(Year %in% years) %>%
      dplyr::select(-file_name) %>%
      purrr::pmap(.f = function(...) {
        .load_individual_file_PS_notin_ICD(...,
                                           icd_codes = icd_codes,
                                           usrds_ids = usrds_ids)
      }) %>%
      dplyr::bind_rows()
  }

  test_that("All PS ICD codes for selected years are found in ICD reference list", {
    skip_if_not(.usrds_env$initialized, "USRDS environment not initialized")

    expect_true(exists("icd_reference"), info = "icd_reference not found in test environment")
    expect_true("code" %in% names(icd_reference), info = "icd_reference must have a 'code' column")

    unmatched_icds <- get_PS_notin_ICD(
      icd_codes = icd_reference$code,
      years = 2006
    ) %>%
      dplyr::pull(DIAG) %>%
      unique()

    expect_length(unmatched_icds, 0,
                  info = paste("Found", length(unmatched_icds), "ICD codes not in icd_reference:\n",
                               paste(head(unmatched_icds, 10), collapse = ", "))
    )
  })

}
