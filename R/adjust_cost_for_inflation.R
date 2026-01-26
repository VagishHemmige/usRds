#' Adjust costs for inflation
#'
#' Given a data frame of claims with cost data and a month and year, adjust all costs to that month and year using CPI-M.
#'
#' The original cost variables will be retained, and new variables created that contain "_ADJUSTED" appended to them.
#'
#' @param cost_data_frame data frame of cost data created by a `get_*_*_*costs` function
#'
#' @return A data frame with costs adjusted for inflation, with the original variable name changed.
#' @export
#'
#' @examples
#' \dontrun{
#' adjust_costs_for_inflation()
#' }
#'

adjust_costs_for_inflation <-function(cost_data_frame, month, year) {

  #List potential variables which could be in a data frame
  cost_vars <- c(
    "PMTAMT",
    "ALOWCH",
    "SBMTCH",
    "CLM_TOT",
    "CLM_AMT",
    "NCH_CLM_BENE_PMT_AMT"
  )



}
