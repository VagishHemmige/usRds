#' Prorate costs by day
#'
#' Given a data frame of claims with cost data from claims which potentially span multiple days,
#' this function will prorate the costs evenly over the duration of the claim.
#'
#' The original cost variables will be removed, and replaced by variables with the same name but with
#' "_PRORATED" added to the variable name.
#'
#' The amount columns processed are those returned by [get_PS_CLM_costs()],
#' [get_IN_CLM_costs()], [get_PS_REV_costs()] and [get_IN_REV_costs()]:
#' `CLM_PMT_AMT`, `CARR_CLM_PRMRY_PYR_PD_AMT`, `NCH_CLM_PRVDR_PMT_AMT`,
#' `NCH_CLM_BENE_PMT_AMT`, `NCH_CARR_SBMT_CHRG_AMT`, `NCH_CARR_ALOW_CHRG_AMT`,
#' `CARR_CLM_CASH_DDCTBL_APPLY_AMT`, `CLM_TOT`, `CLM_AMT`, `SBMTCH`, `ALOWCH`,
#' `PMTAMT`, `REV_CH` and `REVPMT`, and the same columns with `_ADJUSTED`
#' added by [adjust_costs_for_inflation()]. Other columns are kept unchanged
#' on every day of the claim.
#'
#' A claim whose `CLM_FROM` or `CLM_THRU` is missing, or whose `CLM_THRU` is
#' before its `CLM_FROM`, cannot be spread over days. It is left out of the
#' result, with a warning giving how many claims were left out for each
#' reason, so prorated totals can fall short of the input.
#'
#' @param cost_data_frame data frame of cost data created by a `get_*_*_*costs` function
#'
#' @return A data frame with costs prorated, with the original variable name changed.
#' @export
#'
#' @examples
#' claims <- data.frame(
#'   USRDS_ID = c(1, 2),
#'   CLM_FROM = as.Date(c("2010-01-01", "2010-02-01")),
#'   CLM_THRU = as.Date(c("2010-01-03", "2010-02-01")),
#'   PMTAMT = c(30, 20)
#' )
#' prorate_costs_by_day(claims)
#'

prorate_costs_by_day <- function(cost_data_frame) {
  #Amount columns from the cost extractors, plus inflation-adjusted copies
  cost_vars <- .usrds_cost_column_names("_ADJUSTED")

  cost_data_frame <- cost_data_frame |>
    dplyr::mutate(
      claim_duration = as.integer(
        as.Date(.data$CLM_THRU) - as.Date(.data$CLM_FROM)
      ) +
        1
    )

  .warn_dropped_claims(cost_data_frame)

  #Duplicate the data frame the appropriate number of times

  cost_data_frame |>
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

# Warn, with a count for each reason, about claims prorate_costs_by_day()
# cannot spread over days (#66).
.warn_dropped_claims <- function(cost_data_frame) {
  duration <- cost_data_frame$claim_duration
  n_missing <- sum(is.na(duration))
  n_reversed <- sum(!is.na(duration) & duration <= 0)
  if (n_missing + n_reversed == 0) {
    return(invisible(NULL))
  }
  reasons <- c(
    "*" = if (n_missing > 0) {
      "{n_missing} with a missing {.field CLM_FROM} or {.field CLM_THRU}"
    },
    "*" = if (n_reversed > 0) {
      "{n_reversed} with {.field CLM_THRU} before {.field CLM_FROM}"
    }
  )
  n_dropped <- n_missing + n_reversed
  cli::cli_warn(
    c(
      "{n_dropped} claim{?s} could not be spread over days and {?was/were}
      left out, with {?its/their} amounts:",
      reasons
    ),
    class = "usrds_dropped_claims"
  )
}
