#' Load and filter a single Institutional HCPCS file
#'
#' Internal helper function to load and filter a single IN file by HCPCS codes
#' and optionally by USRDS_IDs. File format can be CSV, SAS, or Parquet.
#'
#' If `hcpcs_codes` is `NULL`, all codes are returned.
#'
#' @noRd
.load_individual_file_IN_HCPCS <- function(file_path, file_root, file_suffix, Year,
                                           file_directory, hcpcs_codes, variablelist,
                                           usrds_ids = NULL) {
  message("Reading file: ", file_path)

  if (file_suffix == "parquet") {
    arrow::read_parquet(file_path) |>
      dplyr::rename_with(toupper) |>
      dplyr::select(dplyr::any_of(variablelist)) |>
      (\(df) if (!is.null(hcpcs_codes)) dplyr::filter(df, HCPCS %in% hcpcs_codes) else df)() |>
      (\(df) if (!is.null(usrds_ids)) dplyr::filter(df, USRDS_ID %in% usrds_ids) else df)() |>
      dplyr::mutate(CLM_FROM = lubridate::as_date(CLM_FROM)) |>
      dplyr::collect()

  } else if (file_suffix == "csv") {
    readr::read_csv(file_path, show_col_types = FALSE) |>
      dplyr::rename_with(toupper) |>
      (\(df) if (!is.null(hcpcs_codes)) dplyr::filter(df, HCPCS %in% hcpcs_codes) else df)() |>
      (\(df) if (!is.null(usrds_ids)) dplyr::filter(df, USRDS_ID %in% usrds_ids) else df)() |>
      dplyr::select(dplyr::any_of(variablelist)) |>
      dplyr::mutate(CLM_FROM = suppressWarnings(lubridate::dmy(CLM_FROM)))

  } else if (file_suffix == "sas7bdat") {
    haven::read_sas(file_path) |>
      dplyr::rename_with(toupper) |>
      dplyr::select(dplyr::any_of(variablelist)) |>   # <-- safe even if some variables are missing
      (\(df) if (!is.null(hcpcs_codes)) dplyr::filter(df, HCPCS %in% hcpcs_codes) else df)() |>
      (\(df) if (!is.null(usrds_ids)) dplyr::filter(df, USRDS_ID %in% usrds_ids) else df)()

  } else {
    stop("Unsupported file type: ", file_suffix)
  }
}



#' Retrieve Institutional HCPCS Claims
#'
#' Searches institutional claim files for specified HCPCS codes in specified years.
#' Supports filtering by HCPCS and optionally by USRDS_IDs. Handles CSV, SAS, and Parquet formats.
#'
#' If `hcpcs_codes` is `NULL`, all HCPCS-coded claims are returned.
#'
#' @param hcpcs_codes Optional character vector of HCPCS codes to search for. If `NULL`, all codes are returned.
#' @param years Integer vector of years to include.
#' @param usrds_ids Optional vector of USRDS_IDs to filter to specific patients.
#'
#' @return A data frame with columns: `USRDS_ID`, `CLM_FROM`, `HCPCS`, `REV_CH`, `REVPMT`, `HCFASAF`
#' @export
#'
#' @examples
#' \dontrun{
#' get_IN_HCPCS(c("J1234", "A4567"), years = 2012:2016)
#' get_IN_HCPCS(NULL, years = 2012:2016)  # All HCPCS claims
#' }
get_IN_HCPCS <- function(hcpcs_codes = NULL, years, usrds_ids = NULL) {
  variablelist <- c("USRDS_ID", "CLM_FROM", "HCPCS", "REV_CH", "REVPMT", "HCFASAF")

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
                                     variablelist = variablelist,
                                     usrds_ids = usrds_ids)
    }) |>
    dplyr::bind_rows()%>%
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
      HCPCS = "HCPCS code",
      REVPMT = "Revenue Center Payment Amount Amount",
      REV_CH = "Revenue center total charge"

    )
}
