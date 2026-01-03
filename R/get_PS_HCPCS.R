#' Load and filter a single PS HCPCS file
#'
#' Internal helper function to load and filter a single Physician/Supplier file
#' by HCPCS codes and optionally by USRDS_IDs.
#'
#' For Parquet files, filtering is pushed down before collection.
#' If `hcpcs_codes` is `NULL`, all codes are returned.
#'
#' @noRd
.load_individual_file_PS_HCPCS <- function(file_path, file_root, file_suffix, Year,
                                           file_directory, hcpcs_codes, variablelist,
                                           usrds_ids = NULL) {
  message("Reading file: ", file_path)

  if (file_suffix == "parquet") {
    arrow::read_parquet(file_path) |>
      dplyr::rename_with(toupper) |>
      dplyr::select(dplyr::all_of(variablelist)) |>
      (\(df) if (!is.null(hcpcs_codes)) dplyr::filter(df, HCPCS %in% hcpcs_codes) else df)() |>
      (\(df) if (!is.null(usrds_ids)) dplyr::filter(df, USRDS_ID %in% usrds_ids) else df)() |>
      dplyr::mutate(CLM_FROM = lubridate::as_date(CLM_FROM)) |>
      dplyr::collect()

  } else if (file_suffix == "csv") {
    readr::read_csv(file_path, show_col_types = FALSE) |>
      dplyr::rename_with(toupper) |>
      (\(df) if (!is.null(hcpcs_codes)) dplyr::filter(df, HCPCS %in% hcpcs_codes) else df)() |>
      (\(df) if (!is.null(usrds_ids)) dplyr::filter(df, USRDS_ID %in% usrds_ids) else df)() |>
      dplyr::select(dplyr::all_of(variablelist)) |>
      dplyr::mutate(CLM_FROM = suppressWarnings(lubridate::dmy(CLM_FROM)))

  } else if (file_suffix == "sas7bdat") {
    haven::read_sas(file_path, col_select = variablelist) |>
      dplyr::rename_with(toupper) |>
      (\(df) if (!is.null(hcpcs_codes)) dplyr::filter(df, HCPCS %in% hcpcs_codes) else df)() |>
      (\(df) if (!is.null(usrds_ids)) dplyr::filter(df, USRDS_ID %in% usrds_ids) else df)()

  } else {
    stop("Unsupported file type: ", file_suffix)
  }
}




#' Retrieve HCPCS codes from Physician/Supplier claims
#'
#' Extracts all claims from physician/supplier billing data for the selected years,
#' optionally filtering by HCPCS codes and/or USRDS_IDs.
#'
#' If `hcpcs_codes` is `NULL`, all HCPCS-coded claims are returned.
#'
#' @param hcpcs_codes Optional. Character vector of HCPCS codes to filter by. If `NULL`, returns all codes.
#' @param years Integer vector of calendar years to include.
#' @param usrds_ids Optional. Vector of USRDS_IDs to restrict results to.
#'
#' @return A data frame with columns: `USRDS_ID`, `HCPCS`, `CLM_FROM`
#' @export
#'
#' @examples
#' \dontrun{
#' get_PS_HCPCS(c("81003", "87086"), years = 2006:2008)
#' get_PS_HCPCS(NULL, years = 2006:2008)  # All HCPCS codes
#' }
get_PS_HCPCS <- function(hcpcs_codes = NULL, years, usrds_ids = NULL) {
  variablelist <- c("USRDS_ID", "CLM_FROM", "SBMTCH")

  .check_valid_years(
    years = years,
    file_keys = PS_HCPCS$file_root,
    label = "Physician/Supplier HCPCS files"
  )

  .usrds_env$file_list |>
    dplyr::inner_join(PS_HCPCS, by = c("file_root", "Year")) |>
    dplyr::filter(Year %in% years) |>
    dplyr::select(-file_name) |>
    purrr::pmap(.f = function(...) {
      .load_individual_file_PS_HCPCS(...,
                                     hcpcs_codes = hcpcs_codes,
                                     variablelist = variablelist,
                                     usrds_ids = usrds_ids)
    }) |>
    dplyr::bind_rows()
}
