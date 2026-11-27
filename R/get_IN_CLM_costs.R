#' Load and filter a single Institutional file
#'
#' Internal helper function to load and filter a single IN file
#' optionally by USRDS_IDs. File format can be CSV, SAS, or Parquet.
#'
#' If `usrds_ids` is `NULL`, all codes are returned.
#'
#' @noRd
.load_individual_file_IN_CLM_costs <- function(
  file_path,
  file_root,
  file_suffix,
  Year,
  file_directory,
  variablelist,
  usrds_ids = NULL
) {
  message("Reading file: ", file_path)

  if (file_suffix == "parquet") {
    arrow::read_parquet(file_path) |>
      dplyr::rename_with(toupper) |>
      dplyr::select(dplyr::all_of(variablelist)) |>
      .filter_in("USRDS_ID", usrds_ids) |>
      dplyr::collect() |>
      .parse_claim_dates(
        c("CLM_FROM", "CLM_THRU"),
        file_path,
        numeric_as_unix_days = TRUE
      )
  } else if (file_suffix == "csv") {
    readr::read_csv(file_path, show_col_types = FALSE) |>
      dplyr::rename_with(toupper) |>
      .filter_in("USRDS_ID", usrds_ids) |>
      dplyr::select(dplyr::all_of(variablelist)) |>
      .parse_claim_dates(c("CLM_FROM", "CLM_THRU"), file_path)
  } else if (file_suffix == "sas7bdat") {
    haven::read_sas(file_path, col_select = variablelist) |>
      dplyr::rename_with(toupper) |>
      .filter_in("USRDS_ID", usrds_ids)
  } else {
    stop("Unsupported file type: ", file_suffix)
  }
}


#' Retrieve Institutional Claims
#'
#' Searches institutional claim files for specified USRDS_IDs in specified years.
#' Supports filtering by USRDS_IDs. Handles CSV, SAS, and Parquet formats.
#'
#' If `usrds_ids` is `NULL`, all claims are returned.
#'
#' @param years Integer vector of years to include.
#' @param usrds_ids Optional vector of USRDS_IDs to filter to specific patients.
#'
#' @return A data frame with one row per claim and columns `USRDS_ID`,
#'   `CLM_FROM` and `CLM_THRU` (both `Date`), `CLM_TOT` (total charges),
#'   `CLM_AMT` (Medicare payments) and `HCFASAF` (claim type, as a factor).
#'   Descriptions are from Appendix B of the 2025 Researcher's Guide (for
#'   example table `IP_CLM_2023`). These are claim totals: do not add them to
#'   revenue-line amounts from [get_IN_REV_costs()] for the same claims. Dates stored as text that cannot
#'   be read become `NA`, with a warning naming the file and column.
#' @export
#'
#' @examples
#' \dontrun{
#' get_IN_CLM_costs(years = 2012:2016, usrds_ids=1:1000)
#' }

get_IN_CLM_costs <- function(years, usrds_ids = NULL) {
  .local_arrow_options()
  variablelist <- c(
    "USRDS_ID",
    "CLM_FROM",
    "CLM_THRU",
    "CLM_TOT",
    "CLM_AMT",
    "HCFASAF"
  )

  .check_valid_years(
    years = years,
    file_keys = IN_CLM_COSTS$file_root,
    label = "Institutional claim cost files"
  )

  .usrds_env$file_list |>
    dplyr::inner_join(IN_CLM_COSTS, by = c("file_root", "Year")) |>
    dplyr::filter(.data$Year %in% .env$years) |>
    dplyr::select(-"file_name") |>
    purrr::pmap(.f = function(...) {
      .load_individual_file_IN_CLM_costs(
        ...,
        variablelist = variablelist,
        usrds_ids = usrds_ids
      )
    }) |>
    dplyr::bind_rows() |>
    dplyr::mutate(
      HCFASAF = .hcfasaf_factor(.data$HCFASAF)
    )
}
