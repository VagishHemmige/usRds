#' Load and filter a single PS line-item (revenue) cost file
#'
#' Internal helper function to load and filter a single Physician/Supplier file with claims costs
#' Optionally limit by USRDS_IDs.
#'
#' For Parquet files, filtering is pushed down before collection.
#' If `USRDS_IDs` is `NULL`, all costs for all patients are returned.
#'
#' @noRd
.load_individual_file_PS_CLM_costs <- function(
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
      dplyr::mutate(CLM_FROM = lubridate::as_date(.data$CLM_FROM)) |>
      dplyr::mutate(CLM_THRU = lubridate::as_date(.data$CLM_THRU)) |>
      dplyr::collect()
  } else if (file_suffix == "csv") {
    # Amounts are read as numbers, with "." (SAS missing) as NA, so a
    # missing payment is NA and an unreadable one is reported by readr.
    header <- names(readr::read_csv(file_path, n_max = 0, show_col_types = FALSE))
    amount_cols <- header[
      toupper(header) %in%
        setdiff(variablelist, c("USRDS_ID", "HCFASAF", "CLM_FROM", "CLM_THRU"))
    ]
    col_types <- readr::cols(.default = readr::col_guess())
    col_types$cols[amount_cols] <- rep(list(readr::col_double()), length(amount_cols))
    readr::read_csv(
      file_path,
      col_types = col_types,
      na = c("", "NA", "."),
      show_col_types = FALSE
    ) |>
      dplyr::rename_with(toupper) |>
      .filter_in("USRDS_ID", usrds_ids) |>
      dplyr::select(dplyr::all_of(variablelist)) |>
      dplyr::mutate(
        CLM_FROM = suppressWarnings(lubridate::dmy(.data$CLM_FROM))
      ) |>
      dplyr::mutate(CLM_THRU = suppressWarnings(lubridate::dmy(.data$CLM_THRU)))
  } else if (file_suffix == "sas7bdat") {
    haven::read_sas(file_path, col_select = variablelist) |>
      dplyr::rename_with(toupper) |>
      .filter_in("USRDS_ID", usrds_ids)
  } else {
    stop("Unsupported file type: ", file_suffix)
  }
}


#' Retrieve claims costs from Physician/Supplier claims
#'
#' Extracts all claims costs from physician/supplier billing data for the selected years,
#' optionally filtering by USRDS_IDs.
#'
#' @param years Integer vector of calendar years to include.  Range is 2013-2021.
#' @param usrds_ids Optional. Vector of USRDS_IDs to restrict results to.
#' @param remove_missing_values If `TRUE` (the default), drop claims whose
#'   `CLM_PMT_AMT` is missing: a missing payment is an unknown amount, not a
#'   payment of zero (#54). This matches `get_PS_REV_costs()`, which drops
#'   lines with a missing `PMTAMT`.
#'
#' @return A data frame with one row per Physician/Supplier claim. Column
#'   descriptions are from Appendix B of the 2025 Researcher's Guide
#'   (table `PS_CLM_2023`):
#'   \describe{
#'     \item{USRDS_ID}{Patient ID}
#'     \item{HCFASAF}{Claim type (labelled factor)}
#'     \item{CLM_FROM, CLM_THRU}{From and through dates of service (Date)}
#'     \item{CLM_PMT_AMT}{Amount paid by Medicare}
#'     \item{CARR_CLM_PRMRY_PYR_PD_AMT}{Amount paid by primary payer (not
#'       Medicare)}
#'     \item{NCH_CLM_PRVDR_PMT_AMT}{Total payments to the provider}
#'     \item{NCH_CLM_BENE_PMT_AMT}{Total payment to beneficiary}
#'     \item{NCH_CARR_SBMT_CHRG_AMT}{Submitted charge amount}
#'     \item{NCH_CARR_ALOW_CHRG_AMT}{Allowed charge amount}
#'     \item{CARR_CLM_CASH_DDCTBL_APPLY_AMT}{Cash deductible amount}
#'   }
#'   These are claim totals: do not add them to line-item amounts from
#'   [get_PS_REV_costs()] for the same claims.
#' @export
#'
#' @examples
#' \dontrun{
#' get_PS_CLM_costs(years = 2016:2018, usrds_ids=1:1000)
#' get_PS_CLM_costs(years = 2014:2017, usrds_ids=2000:4100)
#' }

get_PS_CLM_costs <- function(
  years,
  usrds_ids = NULL,
  remove_missing_values = TRUE
) {
  .local_arrow_options()
  variablelist <- c(
    "USRDS_ID",
    "HCFASAF",
    "CLM_FROM",
    "CLM_THRU",
    "CLM_PMT_AMT",
    "CARR_CLM_PRMRY_PYR_PD_AMT",
    "NCH_CLM_PRVDR_PMT_AMT",
    "NCH_CLM_BENE_PMT_AMT",
    "NCH_CARR_SBMT_CHRG_AMT",
    "NCH_CARR_ALOW_CHRG_AMT",
    "CARR_CLM_CASH_DDCTBL_APPLY_AMT"
  )

  .check_valid_years(
    years = years,
    file_keys = PS_CLM_COSTS$file_root,
    label = "Physician/Supplier claims cost files"
  )

  .usrds_env$file_list |>
    dplyr::inner_join(PS_CLM_COSTS, by = c("file_root", "Year")) |>
    dplyr::filter(.data$Year %in% .env$years) |>
    dplyr::select(-"file_name") |>
    purrr::pmap(.f = function(...) {
      .load_individual_file_PS_CLM_costs(
        ...,
        variablelist = variablelist,
        usrds_ids = usrds_ids
      )
    }) |>
    dplyr::bind_rows() |>
    (\(df) {
      if (remove_missing_values == TRUE) {
        dplyr::filter(df, !is.na(.data$CLM_PMT_AMT))
      } else {
        df
      }
    })() |>
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
      CLM_PMT_AMT = "Amount paid by Medicare",
      CARR_CLM_PRMRY_PYR_PD_AMT = "Amount paid by primary payer (not Medicare)",
      NCH_CLM_PRVDR_PMT_AMT = "Total payments to the provider",
      NCH_CLM_BENE_PMT_AMT = "Total payment to beneficiary",
      NCH_CARR_SBMT_CHRG_AMT = "Submitted charge amount",
      NCH_CARR_ALOW_CHRG_AMT = "Allowed charge amount",
      CARR_CLM_CASH_DDCTBL_APPLY_AMT = "Cash deductible amount"
    )
}
