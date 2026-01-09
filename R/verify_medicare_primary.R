#' Verify that a patient has Medicare primary coverage
#'
#' This function accepts a data frame `df`, an index date option `index_date` which is either a fixed date or
#' the name of a date variable in quotes, and a variable `lookback_days` that encodes how many days of Medicare
#' coverage are necessary.
#'
#' It returns the same dataframe with a new variable `medicare_primary_TF` that takes the values `TRUE`
#' or `FALSE`.
#'
#' @param df is a data frame, presumably one with a single row per patient.  Data frame *must* contain
#' a column named `USRDS_ID`.
#'
#' @param index_date either a fixed date or the name of a date variable in quotes
#'
#' @param lookback_days is the number of days of Medicare as primary necessary.  Default value is 365.
#'
#' @return The original `df` data fame with the variable `medicare_primary_TF` added
#'
#' @export
#'
#' @examples
#' \dontrun{
#' }

verify_medicare_primary<-function(df, index_date, lookback_days=365)
{

  #Verify that lookback_days is an integer greater than zero.




eligible_payers <- c(
  "MEDICARE FFS PRIMARY PAY, FOR BOTH PART A AND PART B",
  "MEDICARE FFS PRIMARY PAY, FOR OTHER"
)

#Open Medicare history file, keep rows where the payer is Medicare primary, and sort by USRDS and date
medicare_history<-load_usrds_file("payhist",
                                  usrds_ids = df$USRDS_ID)%>%
  filter(PAYER %in% eligible_payers) %>%
  select(USRDS_ID, BEGDATE, ENDDATE)%>%
  arrange(USRDS_ID, BEGDATE)%>%

  #Combine lines where there is no gap between the lines and they are the same patient
  group_by(USRDS_ID) %>%
  arrange(BEGDATE, .by_group = TRUE) %>%
  mutate(
    prev_end = lag(ENDDATE),
    # start a new group if there is a gap
    new_group = if_else(
      is.na(prev_end) | BEGDATE > prev_end + days(1),
      1L,
      0L
    ),
    group_id = cumsum(new_group)
  ) %>%
  group_by(USRDS_ID, group_id) %>%
  summarise(
    BEGDATE = min(BEGDATE),
    ENDDATE = max(ENDDATE),
    .groups = "drop"
  )%>%
  select(-group_id)

#Join patient cohort to medicare history data
patients_clean<-left_join(df,
                          medicare_history,
                          join_by(USRDS_ID, between(index_date, BEGDATE, ENDDATE))
)

#Filter by FFS coverage on day of claim through 365 days prior
patients_clean<-patients_clean%>%
  mutate(medicare_primary_TF=ifelse(!is.na(BEGDATE) & index_date-BEGDATE>=lookback_days),TRUE,FALSE)

return(patients_clean)

}
