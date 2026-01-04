#' Prorate costs by day
#'
#' Given a data frame of claims with cost data from claims which potentially span multiple days,
#' this function will prorate the costs evenly over the duration of the claim
#'
#'
#' @param df data frame of cost data created by a `get_*_*_*costs` function
#'
#' @return A data frame with costs prorated
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
    "ALOWCH",
    "SBMTCH",
    "CLM_PMT_AMT",
    "NCH_CLM_BENE_PMT_AMT"
  )

  #Duplicate the data frame the appropriate number of times

  cost_data_frame %>%
    mutate(
      claim_duration = as.integer(CLM_THRU - CLM_FROM) + 1
    ) %>%
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
