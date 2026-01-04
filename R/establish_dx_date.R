#' Establish date a diagnosis is made
#'
#' Given a data frame of claims created with a `get_*_ICD` command, this function
#' will keep the date of either the second outpatient or
#' first inpatient claim with that code, using the `HCFASAF` variable to classify claims as outpatient
#' or inpatient.
#'
#'
#' @param df data frame of claims created by a `get_*_ICD` function
#'
#' @return A data frame filtered to keep the claim which establishes that a diagnosis has been made
#' @export
#'
#' @examples
#' \dontrun{
#' cryptococcus_icd <- c("1175", "B45")
#'
#' # Retrieve claims for all patients in selected years
#' result <- get_IN_ICD(icd_codes = cryptococcus_icd, years = 2013:2018)
#'
#' establish_dx_date(result)
#' }

establish_dx_date <- function(df, diagnosis_established="diagnosis") {
  df%>%
    arrange(USRDS_ID, CLM_FROM)%>%
    mutate(claim_value=ifelse(HCFASAF=="Inpatient", 2,1))%>%
    group_by(USRDS_ID)%>%
    mutate(cum_sum_claims = cumsum(claim_value))%>%
    filter(cum_sum_claims>1)%>%
    slice(1)%>%
    ungroup()%>%
    select(-cum_sum_claims, -claim_value)%>%
    transmute(USRDS_ID=USRDS_ID,
              diagnosis=diagnosis_established,
              date_established=CLM_FROM)
}
