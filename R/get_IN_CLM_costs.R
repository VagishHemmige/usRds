#' Load and filter a single Institutional file
#'
#' Internal helper function to load and filter a single IN file
#' optionally by USRDS_IDs. File format can be CSV, SAS, or Parquet.
#'
#' If `usrds_ids` is `NULL`, all codes are returned.
#'
#' @noRd
.load_individual_file_IN_CLM_costs <- function(file_path, file_root, file_suffix, Year,
                                           file_directory, variablelist,
                                           usrds_ids = NULL) {
  message("Reading file: ", file_path)

  if (file_suffix == "parquet") {
    arrow::read_parquet(file_path) |>
      dplyr::rename_with(toupper) |>
      dplyr::select(dplyr::all_of(variablelist)) |>
      (\(df) if (!is.null(usrds_ids)) dplyr::filter(df, USRDS_ID %in% usrds_ids) else df)() |>
      dplyr::mutate(CLM_FROM = lubridate::as_date(CLM_FROM)) |>
      dplyr::collect()

  } else if (file_suffix == "csv") {
    readr::read_csv(file_path, show_col_types = FALSE) |>
      dplyr::rename_with(toupper) |>
      (\(df) if (!is.null(usrds_ids)) dplyr::filter(df, USRDS_ID %in% usrds_ids) else df)() |>
      dplyr::select(dplyr::all_of(variablelist)) |>
      dplyr::mutate(CLM_FROM = suppressWarnings(lubridate::dmy(CLM_FROM)))

  } else if (file_suffix == "sas7bdat") {
    haven::read_sas(file_path, col_select = variablelist) |>
      dplyr::rename_with(toupper) |>
      (\(df) if (!is.null(usrds_ids)) dplyr::filter(df, USRDS_ID %in% usrds_ids) else df)()

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
#' @return A data frame with columns: `
#' @export
#'
#' @examples
#' \dontrun{
#' get_IN_CLM_costs(years = 2012:2016, usrds_ids=1:1000)
#' }

get_IN_CLM_costs <- function(years, usrds_ids = NULL) {
  variablelist <- c("USRDS_ID", "CLM_FROM", "CLM_THRU", "CLM_TOT", "CLM_AMT", "HCFASAF")

  .check_valid_years(
    years = years,
    file_keys = IN_CLM_COSTS$file_root,
    label = "Institutional HCPCS files"
  )

  .usrds_env$file_list |>
    dplyr::inner_join(IN_CLM_COSTS, by = c("file_root", "Year")) |>
    dplyr::filter(Year %in% years) |>
    dplyr::select(-file_name) |>
    purrr::pmap(.f = function(...) {
      .load_individual_file_IN_CLM_costs(...,
                                     variablelist = variablelist,
                                     usrds_ids = usrds_ids)
    }) |>
    dplyr::bind_rows()%>%
    dplyr::mutate(
      HCFASAF = factor(
        HCFASAF,
        levels = c("I", "M", "O", "D", "N", "H", "S", "Q"),
        labels = c(
          "Inpatient",
          "Inpatient (REBUS)",
          "Outpatient",
          "Dialysis",
          "Skilled Nursing Facility",
          "Home Health",
          "Hospice",
          "Non-claim / auxiliary"
        )
      )
    )
}
