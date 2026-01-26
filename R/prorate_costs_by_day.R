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

prorate_costs_by_day <-function(cost_data_frame) {

  #List potential variables which could be in a data frame
  cost_vars <- c(
    "PMTAMT",
    "REVPMT",
    "ALOWCH",
    "SBMTCH",
    "CLM_TOT",
    "CLM_AMT",
    "NCH_CLM_BENE_PMT_AMT",
    "PMTAMT_ADJUSTED",
    "REVPMT_ADJUSTED",
    "ALOWCH_ADJUSTED",
    "SBMTCH_ADJUSTED",
    "CLM_TOT_ADJUSTED",
    "CLM_AMT_ADJUSTED",
    "NCH_CLM_BENE_PMT_AMT_ADJUSTED"
  )

  #Duplicate the data frame the appropriate number of times

  cost_data_frame %>%
    mutate(
      claim_duration = as.integer(as.Date(CLM_THRU) - as.Date(CLM_FROM)) + 1
    ) %>%
    filter(!is.na(claim_duration), claim_duration > 0) %>%
    uncount(claim_duration, .id = "day_index", .remove = FALSE) %>%

    #Create a service date variable
    mutate(
      service_date = CLM_FROM + day_index - 1
    ) %>%

    #Prorate costs
    mutate(
      across(
        any_of(cost_vars),
        ~ .x / claim_duration,
        .names = "{.col}_PRORATED"
      ))%>%

    #Remove unnecessary variables
    select(-day_index, -claim_duration, -any_of(cost_vars))

}
