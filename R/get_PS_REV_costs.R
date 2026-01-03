#' Load and filter a single PS line-item (revenue) cost file
#'
#' Internal helper function to load and filter a single Physician/Supplier file with line-item costs
#' Optionally limit by USRDS_IDs.
#'
#' For Parquet files, filtering is pushed down before collection.
#' If `USRDS_IDs` is `NULL`, all costs for all patients are returned.
#'
#' @noRd
.load_individual_file_PS_REV_costs <- function(file_path, file_root, file_suffix, Year,
                                           file_directory, variablelist,
                                           usrds_ids = NULL) {
  message("Reading file: ", file_path)

  if (file_suffix == "parquet") {
    arrow::read_parquet(file_path) |>
      dplyr::rename_with(toupper) |>
      dplyr::select(dplyr::all_of(variablelist)) |>
      (\(df) if (!is.null(usrds_ids)) dplyr::filter(df, USRDS_ID %in% usrds_ids) else df)() |>
      dplyr::mutate(CLM_FROM = lubridate::as_date(CLM_FROM)) |>
      dplyr::mutate(CLM_THRU = lubridate::as_date(CLM_THRU)) |>
      dplyr::collect()

  } else if (file_suffix == "csv") {
    readr::read_csv(file_path, show_col_types = FALSE) |>
      dplyr::rename_with(toupper) |>
      (\(df) if (!is.null(usrds_ids)) dplyr::filter(df, USRDS_ID %in% usrds_ids) else df)() |>
      dplyr::select(dplyr::all_of(variablelist)) |>
      dplyr::mutate(CLM_FROM = suppressWarnings(lubridate::dmy(CLM_FROM))) |>
      dplyr::mutate(CLM_THRU = suppressWarnings(lubridate::dmy(CLM_THRU)))

  } else if (file_suffix == "sas7bdat") {
    haven::read_sas(file_path, col_select = variablelist) |>
      dplyr::rename_with(toupper) |>
      (\(df) if (!is.null(usrds_ids)) dplyr::filter(df, USRDS_ID %in% usrds_ids) else df)()

  } else {
    stop("Unsupported file type: ", file_suffix)
  }
}




#' Retrieve line item costs from Physician/Supplier claims
#'
#' Extracts all line-item costs from physician/supplier billing data for the selected years,
#' optionally filtering by USRDS_IDs.
#' Option to `remove_missing_values` defaults to TRUE
#'
#'
#' @param years Integer vector of calendar years to include.
#' @param usrds_ids Optional. Vector of USRDS_IDs to restrict results to.
#'
#' @return A data frame with columns: `USRDS_ID`, `HCFASAF`, `CLM_FROM`, `CLM_THRU`,`SBMTCH`, `ALOWCH`, `PMTAMT`
#' @export
#'
#' @examples
#' \dontrun{
#' get_PS_REV_costs(years = 2006:2008, usrds_ids=1:1000)
#' get_PS_REV_costs(years = 2006:2008, usrds_ids=2000:4100)
#' }
get_PS_REV_costs <- function(years,
                             usrds_ids = NULL,
                             remove_missing_values=TRUE) {
  variablelist <- c("USRDS_ID", "HCFASAF", "CLM_FROM", "CLM_THRU", "SBMTCH", "ALOWCH", "PMTAMT")

  .check_valid_years(
    years = years,
    file_keys = PS_REV_COSTS$file_root,
    label = "Physician/Supplier line-item cost files"
  )

  .usrds_env$file_list |>
    dplyr::inner_join(PS_REV_COSTS, by = c("file_root", "Year")) |>
    dplyr::filter(Year %in% years) |>
    dplyr::select(-file_name) |>
    purrr::pmap(.f = function(...) {
      .load_individual_file_PS_REV_costs(...,
                                     variablelist = variablelist,
                                     usrds_ids = usrds_ids)
    }) |>
    dplyr::bind_rows()%>%
    (\(df) if (remove_missing_values==TRUE) dplyr::filter(df, !is.na(PMTAMT)) else df)()%>%
    dplyr::mutate(
      HCFASAF = factor(
        HCFASAF,
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
    )%>%
    labelled::set_variable_labels(
      USRDS_ID = "USRDS patient ID number",
      HCFASAF = "HCFA SAF source of this bill",
      CLM_FROM = "From date of service",
      CLM_THRU = "Thru date of service",
      SBMTCH = "Submitted charges",
      ALOWCH = "Allowed charges",
      PMTAMT = "Claim payment amount"
    )
}
