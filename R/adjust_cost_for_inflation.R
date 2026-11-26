#' Adjust costs for inflation
#'
#' Given a data frame of claims with cost data and a month and year, adjust all costs to that month and year using CPI-M.
#'
#' The original cost variables will be retained, and new variables created that contain "_ADJUSTED" appended to them.
#'
#' Each claim is adjusted using the medical care consumer price index for
#' the month and year of its `CLM_FROM` date (BLS series CUUR0000SAM, US city
#' average, not seasonally adjusted, stored in the package). Claims whose
#' month is not in that table get `NA` adjusted amounts and a warning.
#'
#' The amount columns adjusted are those returned by [get_PS_CLM_costs()],
#' [get_IN_CLM_costs()], [get_PS_REV_costs()] and [get_IN_REV_costs()]:
#' `CLM_PMT_AMT`, `CARR_CLM_PRMRY_PYR_PD_AMT`, `NCH_CLM_PRVDR_PMT_AMT`,
#' `NCH_CLM_BENE_PMT_AMT`, `NCH_CARR_SBMT_CHRG_AMT`, `NCH_CARR_ALOW_CHRG_AMT`,
#' `CARR_CLM_CASH_DDCTBL_APPLY_AMT`, `CLM_TOT`, `CLM_AMT`, `SBMTCH`, `ALOWCH`,
#' `PMTAMT`, `REV_CH` and `REVPMT`, and the same columns with `_PRORATED`
#' added by [prorate_costs_by_day()]. Other columns are returned unchanged.
#'
#' @param cost_data_frame data frame of cost data created by a `get_*_*_*costs` function
#'
#' @param baseline_year is a year in the 2006-2025 range.
#'
#' @param baseline_month is the full name of the month.
#'
#' @return The input data frame with an `_ADJUSTED` copy of each amount
#'   column, in `baseline_month` `baseline_year` dollars. The original amount
#'   columns are kept unchanged.
#' @export
#'
#' @examples
#' claims <- data.frame(
#'   USRDS_ID = c(1, 2),
#'   CLM_FROM = as.Date(c("2010-06-01", "2015-12-01")),
#'   PMTAMT = c(100, 100)
#' )
#' adjust_costs_for_inflation(claims, baseline_month = "December",
#'                            baseline_year = 2015)
#'

adjust_costs_for_inflation <- function(
  cost_data_frame,
  baseline_month,
  baseline_year
) {
  #Amount columns from the cost extractors, plus prorated copies
  cost_vars <- .usrds_cost_column_names("_PRORATED")

  #Error checking
  baseline_year <- as.integer(baseline_year)
  if (!baseline_year %in% medical_cpi$year) {
    rlang::abort("`baseline_year` provided must be 2006-2025")
  }

  if (!baseline_month %in% medical_cpi$periodName) {
    rlang::abort("`baseline_month` provided must be full name of month.")
  }

  baseline_index <- medical_cpi$value[
    medical_cpi$year == baseline_year & medical_cpi$periodName == baseline_month
  ]
  stopifnot(length(baseline_index) == 1)

  df <- cost_data_frame |>
    dplyr::mutate(
      .cpi_year = lubridate::year(.data$CLM_FROM),
      # English month names, as in medical_cpi$periodName, whatever the
      # session's LC_TIME locale (#105)
      .cpi_month = month.name[lubridate::month(.data$CLM_FROM)]
    )

  # attach CPI per row
  df <- df |>
    dplyr::left_join(
      medical_cpi |>
        dplyr::select("year", "periodName", "value") |>
        dplyr::rename(.cpi = "value"),
      by = c(".cpi_year" = "year", ".cpi_month" = "periodName")
    )

  if (any(is.na(df$.cpi))) {
    rlang::warn("Missing CPI values for some rows.")
  }

  # inflate
  df |>
    dplyr::mutate(
      dplyr::across(
        dplyr::any_of(cost_vars),
        ~ .x * (.env$baseline_index / .data$.cpi),
        .names = "{.col}_ADJUSTED"
      )
    ) |>
    dplyr::select(-".cpi", -".cpi_year", -".cpi_month")
}
