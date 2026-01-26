#' Adjust costs for inflation
#'
#' Given a data frame of claims with cost data and a month and year, adjust all costs to that month and year using CPI-M.
#'
#' The original cost variables will be retained, and new variables created that contain "_ADJUSTED" appended to them.
#'
#' @param cost_data_frame data frame of cost data created by a `get_*_*_*costs` function
#'
#' @param baseline_year is a year in the 2006-2025 range.
#'
#' @param baseline_month is the full name of the month.
#'
#' @return A data frame with costs adjusted for inflation, with the original variable name changed.
#' @export
#'
#' @examples
#' \dontrun{
#' adjust_costs_for_inflation()
#' }
#'

adjust_costs_for_inflation <-function(cost_data_frame, baseline_month, baseline_year) {

  #List potential variables which could be in a data frame
  cost_vars <- c(
    "PMTAMT",
    "ALOWCH",
    "SBMTCH",
    "CLM_TOT",
    "CLM_AMT",
    "NCH_CLM_BENE_PMT_AMT",
    "PMTAMT_PRORATED",
    "ALOWCH_PRORATED",
    "SBMTCH_PRORATED",
    "CLM_TOT_PRORATED",
    "CLM_AMT_PRORATED",
    "NCH_CLM_BENE_PMT_AMT_PRORATED"
  )


  #Error checking
  baseline_year<-as.integer(baseline_year)
  if (!baseline_year %in% medical_cpi$year)
  {
    rlang::abort("`baseline_year` provided must be 2006-2025")
  }

  if (!baseline_month %in% medical_cpi$periodName)
  {
    rlang::abort("`baseline_month` provided must be full name of month.")
  }

  baseline_index <- medical_cpi$value[medical_cpi$year == baseline_year & medical_cpi$periodName == baseline_month]
  stopifnot(length(baseline_index) == 1)



  df <- cost_data_frame %>%
    dplyr::mutate(
      .cpi_year  = lubridate::year(.data$CLM_FROM),
      .cpi_month = as.character(lubridate::month(.data$CLM_FROM,
                                                 label = TRUE,
                                                 abbr = FALSE))
    )

  # attach CPI per row
  df <- df %>%
    left_join(
      medical_cpi %>%
        select(year, periodName, value) %>%
        rename(.cpi = value),
      by = c(".cpi_year" = "year", ".cpi_month" = "periodName")
    )

  if (any(is.na(df$.cpi))) {
    rlang::abort("Missing CPI values for some rows.")
  }

  # inflate
  df %>%
    mutate(
      across(
        any_of(cost_vars),
        ~ .x * (baseline_index / .data$.cpi),
        .names = "{.col}_ADJUSTED"
      )
    ) %>%
    select(-.cpi, -.cpi_year, -.cpi_month)%>%
    return()
}
