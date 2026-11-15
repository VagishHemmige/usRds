#' Prorate costs by day
#'
#' Given a data frame of claims with cost data from claims which potentially span multiple days,
#' this function will prorate the costs evenly over the duration of the claim.
#'
#' The original cost variables will be removed, and replaced by variables with the same name but with
#' "_PRORATED" added to the variable na,e.
#'
#' @param cost_data_frame data frame of cost data created by a `get_*_*_*costs` function
#'
#' @return A data frame with costs prorated, with the original variable name changed.
#' @export
#'
#' @examples
#' \dontrun{
#' prorate_costs_by_day()
#' }
#'

prorate_costs_by_day <- function(cost_data_frame) {
  #Amount columns from the cost extractors, plus inflation-adjusted copies
  cost_vars <- .usrds_cost_column_names("_ADJUSTED")

  #Duplicate the data frame the appropriate number of times

  cost_data_frame |>
    dplyr::mutate(
      claim_duration = as.integer(
        as.Date(.data$CLM_THRU) - as.Date(.data$CLM_FROM)
      ) +
        1
    ) |>
    dplyr::filter(!is.na(.data$claim_duration), .data$claim_duration > 0) |>
    tidyr::uncount(.data$claim_duration, .id = "day_index", .remove = FALSE) |>

    #Create a service date variable
    dplyr::mutate(
      service_date = .data$CLM_FROM + .data$day_index - 1
    ) |>

    #Prorate costs
    dplyr::mutate(
      dplyr::across(
        dplyr::any_of(cost_vars),
        ~ .x / .data$claim_duration,
        .names = "{.col}_PRORATED"
      )
    ) |>

    #Remove unnecessary variables
    dplyr::select(-"day_index", -"claim_duration", -dplyr::any_of(cost_vars))
}
