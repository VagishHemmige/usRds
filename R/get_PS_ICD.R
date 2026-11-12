#' Load and filter a single PS ICD file
#'
#' Internal helper function to load and filter a single Physician/Supplier file
#' by ICD diagnosis codes and optionally by USRDS_IDs.
#'
#' For Parquet files, filtering is pushed down before collection for performance.
#' For CSV and SAS files, filtering occurs after reading into memory.
#'
#' @noRd
.load_individual_file_PS_ICD <- function(
  file_path,
  file_root,
  file_suffix,
  Year,
  file_directory,
  icd_codes = NULL,
  usrds_ids = NULL
) {
  message("Reading file: ", file_path)

  if (file_suffix == "parquet") {
    temp <- arrow::read_parquet(file_path) |>
      dplyr::rename_with(toupper) |>
      .filter_in("DIAG", icd_codes) |>
      .filter_in("USRDS_ID", usrds_ids) |>
      dplyr::select("USRDS_ID", "DIAG", "CLM_FROM", "CLM_THRU", "HCFASAF") |>
      dplyr::collect() |>
      dplyr::mutate(
        CLM_FROM = as.Date(.data$CLM_FROM),
        CLM_THRU = as.Date(.data$CLM_THRU)
      )
  } else if (file_suffix == "csv") {
    temp <- readr::read_csv(file_path, show_col_types = FALSE) |>
      dplyr::rename_with(toupper) |>
      dplyr::mutate(
        CLM_FROM = suppressWarnings(lubridate::dmy(.data$CLM_FROM)),
        CLM_THRU = suppressWarnings(lubridate::dmy(.data$CLM_THRU))
      ) |>
      .filter_in("DIAG", icd_codes) |>
      .filter_in("USRDS_ID", usrds_ids) |>
      dplyr::select("USRDS_ID", "DIAG", "CLM_FROM", "CLM_THRU", "HCFASAF")
  } else if (file_suffix == "sas7bdat") {
    temp <- haven::read_sas(
      file_path,
      col_select = c("USRDS_ID", "CLM_FROM", "DIAG", "CLM_THRU", "HCFASAF")
    ) |>
      dplyr::rename_with(toupper) |>
      .filter_in("DIAG", icd_codes) |>
      .filter_in("USRDS_ID", usrds_ids) |>
      dplyr::select("USRDS_ID", "DIAG", "CLM_FROM", "CLM_THRU")
  } else {
    stop("Unsupported file type: ", file_suffix)
  }

  return(temp)
}


#' Retrieve diagnosis claims from Physician/Supplier files by ICD code
#'
#' Extracts diagnosis-level claims from the USRDS Physician/Supplier (PS) billing files
#' for selected years and filters them by specified ICD-9 or ICD-10 codes and/or USRDS_IDs.
#' This function supports input files in Parquet, CSV, or SAS format and automatically
#' identifies and loads the correct files for each year using the internal USRDS file list.
#'
#' When Parquet files are used, filtering by ICD code and USRDS_ID is applied
#' before collection for improved performance. For CSV and SAS files, filtering
#' occurs after reading the file into memory.
#'
#' If `icd_codes` is `NULL`, all diagnosis claims for the specified years (and optionally,
#' specific USRDS_IDs) are returned.
#'
#' @param icd_codes Optional. Character vector of ICD-9/10 diagnosis codes (without periods).
#'   If `NULL`, returns all diagnosis claims for the selected years (filtered by `usrds_ids`, if specified).
#' @param years Integer vector of calendar years to include. Must match available years in the PS ICD file index.
#' @param usrds_ids Optional. Vector of USRDS_IDs to filter the data to specific patients.
#'
#' @return A data frame with one row per diagnosis claim, containing:
#'   \describe{
#'     \item{USRDS_ID}{Patient ID}
#'     \item{DIAG}{ICD diagnosis code (character)}
#'     \item{CLM_FROM}{Claim start date (Date)}
#'     \item{CLM_THRU}{Claim end date (Date)}
#'     \item{HCFASAF}{Source file}
#'   }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Codes are matched exactly, so list every billable code (#3):
#' # ICD-9 117.5 and ICD-10-CM B45.0-B45.3, B45.7-B45.9, without periods
#' cryptococcus_icd <- c(
#'   "1175", "B450", "B451", "B452", "B453", "B457", "B458", "B459"
#' )
#' result <- get_PS_ICD(icd_codes = cryptococcus_icd, years = 2013:2018)
#'
#' # Return all diagnosis claims for selected patients in 2016-2017
#' result_all <- get_PS_ICD(
#'   icd_codes = NULL,
#'   years = c(2016, 2017),
#'   usrds_ids = c(1, 2)
#' )
#' }

get_PS_ICD <- function(icd_codes = NULL, years, usrds_ids = NULL) {
  .check_valid_years(
    years = years,
    file_keys = PS_ICD$file_root,
    label = "Physician/Supplier ICD files"
  )

  if (is.null(icd_codes)) {
    message("No ICD codes specified; returning all diagnosis claims.")
  }

  .usrds_env$file_list |>
    dplyr::inner_join(PS_ICD, by = c("file_root", "Year")) |>
    dplyr::filter(.data$Year %in% .env$years) |>
    dplyr::select(-"file_name") |>
    purrr::pmap(.f = function(...) {
      .load_individual_file_PS_ICD(
        ...,
        icd_codes = icd_codes,
        usrds_ids = usrds_ids
      )
    }) |>
    dplyr::bind_rows() |>
    dplyr::mutate(
      HCFASAF = factor(
        .data$HCFASAF,
        levels = c("I", "M", "O", "D", "N", "H", "S", "Q", "P"),
        labels = c(
          "Inpatient",
          "Inpatient (REBUS)",
          "Outpatient",
          "Dialysis",
          "Skilled Nursing Facility",
          "Home Health",
          "Hospice",
          "Non-claim / auxiliary",
          "Physician/Supplier"
        )
      )
    ) |>
    labelled::set_variable_labels(
      USRDS_ID = "USRDS patient ID number",
      HCFASAF = "HCFA SAF source of this bill",
      CLM_FROM = "From date of service",
      CLM_THRU = "Thru date of service",
      DIAG = "ICD code"
    )
}
