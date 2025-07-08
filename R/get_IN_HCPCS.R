#' Load and filter a single Institutional HCPCS file
#'
#' Internal helper function to load and filter a single IN file by HCPCS codes
#' and optionally by USRDS_IDs. File format can be CSV, SAS, or Parquet.
#'
#' @noRd
.load_individual_file_IN_HCPCS <- function(file_path, file_root, file_suffix, Year,
                                           file_directory, hcpcs_codes, usrds_ids = NULL) {
  message("Reading file: ", file_path)

  if (file_suffix == "parquet") {
    arrow::read_parquet(file_path) |>
      dplyr::rename_with(toupper) |>
      dplyr::filter(HCPCS %in% hcpcs_codes) |>
      {\(df) if (!is.null(usrds_ids)) dplyr::filter(df, USRDS_ID %in% usrds_ids) else df}() |>
      dplyr::select(USRDS_ID, CLM_FROM, HCPCS, REV_CH) |>
      dplyr::collect()

  } else if (file_suffix == "csv") {
    readr::read_csv(file_path, show_col_types = FALSE) |>
      dplyr::rename_with(toupper) |>
      dplyr::filter(HCPCS %in% hcpcs_codes) |>
      {\(df) if (!is.null(usrds_ids)) dplyr::filter(df, USRDS_ID %in% usrds_ids) else df}() |>
      dplyr::mutate(CLM_FROM = suppressWarnings(lubridate::dmy(CLM_FROM))) |>
      dplyr::select(USRDS_ID, CLM_FROM, HCPCS, REV_CH)

  } else if (file_suffix == "sas7bdat") {
    haven::read_sas(file_path, col_select = c("USRDS_ID", "CLM_FROM", "HCPCS", "REV_CH")) |>
      dplyr::rename_with(toupper) |>
      dplyr::filter(HCPCS %in% hcpcs_codes) |>
      {\(df) if (!is.null(usrds_ids)) dplyr::filter(df, USRDS_ID %in% usrds_ids) else df}()

  } else {
    stop("Unsupported file type: ", file_suffix)
  }
}


#' Retrieve Institutional HCPCS Claims
#'
#' Searches institutional claim files for specified HCPCS codes in specified years.
#' Supports filtering by HCPCS and optionally USRDS_IDs. Handles CSV, SAS, and Parquet formats.
#'
#' @param hcpcs_codes Character vector of HCPCS codes to search for.
#' @param years Integer vector of years to include.
#' @param usrds_ids Optional vector of USRDS_IDs to filter to specific patients.
#'
#' @return A data frame with claims containing the specified HCPCS codes.
#' @export
#'
#' @examples
#' \dontrun{
#' hcpcs_list <- c("J1234", "A4567")
#' get_IN_HCPCS(hcpcs_codes = hcpcs_list, years = 2012:2016)
#' }
get_IN_HCPCS <- function(hcpcs_codes, years, usrds_ids = NULL) {
  .check_valid_years(
    years = years,
    file_keys = IN_HCPCS$file_root,
    label = "Institutional HCPCS files"
  )

  .usrds_env$file_list |>
    dplyr::inner_join(IN_HCPCS, by = c("file_root", "Year")) |>
    dplyr::filter(Year %in% years) |>
    dplyr::select(-file_name) |>
    purrr::pmap(.f = function(...) {
      .load_individual_file_IN_HCPCS(...,
                                     hcpcs_codes = hcpcs_codes,
                                     usrds_ids = usrds_ids)
    }) |>
    dplyr::bind_rows()
}
