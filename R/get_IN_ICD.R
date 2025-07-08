#' Load and filter a single IN ICD file
#'
#' Internal helper function to load and filter a single Institutional file
#' by ICD diagnosis codes and optionally by USRDS_IDs.
#'
#' For Parquet files, filtering is pushed down before collection for performance.
#' For CSV and SAS files, filtering occurs after reading into memory.
#'
#' @noRd
.load_individual_file_IN_ICD <- function(file_path, file_root, file_suffix, Year,
                                         file_directory, icd_codes, usrds_ids = NULL) {
  message("Reading file: ", file_path)

  if (file_suffix == "parquet") {
    temp <- arrow::read_parquet(file_path) %>%
      dplyr::rename_with(toupper) %>%
      dplyr::filter(CODE %in% icd_codes) %>%
      {
        if (!is.null(usrds_ids)) dplyr::filter(., USRDS_ID %in% usrds_ids) else .
      } %>%
      dplyr::select(USRDS_ID, CODE, CLM_FROM) %>%
      dplyr::collect()
    # Note: CLM_FROM should already be a date if correctly parquetized

  } else if (file_suffix == "csv") {
    temp <- readr::read_csv(file_path, show_col_types = FALSE) %>%
      dplyr::rename_with(toupper) %>%
      dplyr::mutate(
        CLM_FROM = suppressWarnings(lubridate::dmy(CLM_FROM))
      ) %>%
      dplyr::filter(CODE %in% icd_codes) %>%
      {
        if (!is.null(usrds_ids)) dplyr::filter(., USRDS_ID %in% usrds_ids) else .
      } %>%
      dplyr::select(USRDS_ID, CODE, CLM_FROM)

  } else if (file_suffix == "sas7bdat") {
    temp <- haven::read_sas(file_path, col_select = c("USRDS_ID", "CLM_FROM", "CODE")) %>%
      dplyr::rename_with(toupper) %>%
      dplyr::filter(CODE %in% icd_codes) %>%
      {
        if (!is.null(usrds_ids)) dplyr::filter(., USRDS_ID %in% usrds_ids) else .
      } %>%
      dplyr::select(USRDS_ID, CODE, CLM_FROM)

  } else {
    stop("Unsupported file type: ", file_suffix)
  }

  return(temp)
}

#' Retrieve diagnosis codes from Institutional claims
#'
#' Extracts all claims containing specified ICD-9 or ICD-10 diagnosis codes from
#' institutional billing data for the selected years. The data may be stored
#' in CSV, SAS, or Parquet format. The function automatically loads and combines
#' matching files and can optionally filter to a subset of USRDS_IDs.
#'
#' @param icd_codes Character vector of ICD diagnosis codes (without periods).
#' @param years Integer vector of calendar years to include.
#' @param usrds_ids Optional. Vector of USRDS_IDs to restrict the output to specific patients.
#'
#' @return A data frame with columns: `USRDS_ID`, `CODE`, and `CLM_FROM`.
#' @export
#'
#' @examples
#' \dontrun{
#' # ICD-9 and ICD-10 codes for Cryptococcosis (no periods)
#' cryptococcus_icd <- c("1175", "B45")
#'
#' # Retrieve claims for all patients in selected years
#' result <- get_IN_ICD(icd_codes = cryptococcus_icd, years = 2013:2018)
#'
#' # Retrieve claims for specific patients
#' result_subset <- get_IN_ICD(
#'   icd_codes = cryptococcus_icd,
#'   years = c(2016, 2017),
#'   usrds_ids = c(100012345, 100078901)
#' )
#' }
get_IN_ICD <- function(icd_codes, years, usrds_ids = NULL) {
  # Validate that the requested years are available for the file roots defined in IN_ICD
  .check_valid_years(
    years = years,
    file_keys = IN_ICD$file_root,
    label = "Institutional ICD files"
  )

  # Load and filter relevant files
  .usrds_env$file_list %>%
    dplyr::inner_join(IN_ICD, by = c("file_root", "Year")) %>%
    dplyr::filter(Year %in% years) %>%
    dplyr::select(-file_name) %>%
    purrr::pmap(.f = function(...) {
      .load_individual_file_IN_ICD(...,
                                   icd_codes = icd_codes,
                                   usrds_ids = usrds_ids)
    }) %>%
    dplyr::bind_rows()
}
