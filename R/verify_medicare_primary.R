#' Verify that a patient has Medicare primary coverage
#'
#' This function accepts a data frame `df`, an index date option `index_date` which is either a fixed date or
#' the name of a date variable in quotes, and a variable `lookback_days` that encodes how many days of Medicare
#' coverage are necessary.
#'
#' An optional variable `medicare_coverage_df` allows for a df containing information from the `payhist` file to be passed to the function.  If left
#' NULL, then the function will load the data via the `load_usrds_file` function.
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
#' @param medicare_coverage_df is an optional parameter containing a df from the `payhist` file.
#'
#' @return The original `df` data fame with the variable `medicare_primary_TF` added
#'
#' @export
#'
#' @examples
#' \dontrun{
#'
#' test_df<-data.frame(
#' USRDS_ID=c(30, 111112),
#' initial_dates=as.Date(c("1994-01-01", "2019-01-01"))
#' )
#'
#'verify_medicare_primary(df=test_df, index_date = "initial_dates", lookback_days = 365)
#'
#' }

verify_medicare_primary<-function(df, index_date, lookback_days=365, medicare_coverage_df=NULL)
{

  #Error checking

  #Check that df is an appropriate data frame
  if (!inherits(df, "data.frame")) {
    rlang::abort("`df` must be a data frame.")
  }

  #Check that medicare_coverage_df is an appropriate data frame
  if (!inherits(medicare_coverage_df, "data.frame") && !is.null(medicare_coverage_df)) {
    rlang::abort("`medicare_coverage_df` must be a data frame or NULL.")
  }

  if (nrow(df) == 0) {
    rlang::abort("`df` must have at least one row.")
  }

  if (!"USRDS_ID" %in% names(df)) {
    rlang::abort("`df` must contain a column named `USRDS_ID`.")
  }

  if (!is.null(medicare_coverage_df) &&
      !"USRDS_ID" %in% names(medicare_coverage_df)) {
    rlang::abort("`medicare_coverage_df` must contain a column named `USRDS_ID`.")
  }

  if (all(is.na(df$USRDS_ID))) {
    rlang::abort("`df$USRDS_ID` cannot be all missing.")
  }

  #Confirm that index_date is of the right form
  if (inherits(index_date, "Date")) {
    # ok
  } else if (is.character(index_date) && length(index_date) == 1) {
    if (!index_date %in% names(df)) {
      rlang::abort("`index_date` must be a Date or the name of a date column in `df`.")
    }
    if (!inherits(df[[index_date]], "Date")) {
      rlang::abort(
        paste0("`df$", index_date, "` must be of class Date.")
      )
    }
  } else {
    rlang::abort(
      "`index_date` must be a Date or a single character string naming a Date column in `df`."
    )
  }


  #Verify that lookback_days is an integer greater than zero.
  if (!is.numeric(lookback_days) ||
      length(lookback_days) != 1 ||
      lookback_days <= 0 ||
      lookback_days %% 1 != 0) {
    rlang::abort(
      "`lookback_days` must be a single integer greater than 0."
    )
  }

  if (is.character(index_date)) {
    if (any(is.na(df[[index_date]]))) {
      rlang::warn(
        paste0("`df$", index_date, "` contains missing values; ",
               "these patients will be classified as FALSE.")
      )
    }
  }

  #Warning if df containus USRDS_IDs that are not in the medicare_coverage_df (assuming the latter is not NULL)
  if (!is.null(medicare_coverage_df)) {

    missing_ids <- setdiff(df$USRDS_ID, medicare_coverage_df$USRDS_ID)

    if (length(missing_ids) > 0) {
      rlang::warn(glue::glue(
        "{length(missing_ids)} USRDS_ID(s) in `df` are not present in `medicare_coverage_df`."
      ))
    }
  }

#--------------------------------------------------------------------------------------------

  # Now we begin the code which executes the purpose of the function

  #Convert index_date if necessary to something that can be used
  if (is.character(index_date) && length(index_date) == 1) {
    index_date_var <- rlang::sym(index_date)
    df <- df %>% mutate(.index_date = !!index_date_var)
  } else {
    df <- df %>% mutate(.index_date = as.Date(index_date))
  }


#Define eligible payers
eligible_payers <- c(
  "MEDICARE FFS PRIMARY PAY, FOR BOTH PART A AND PART B",
  "MEDICARE FFS PRIMARY PAY, FOR OTHER"
)

#Open Medicare history file, keep rows where the payer is Medicare primary, and sort by USRDS and date

if (is.null(medicare_coverage_df)) {
  medicare_history<-load_usrds_file("payhist",
                                    usrds_ids = df$USRDS_ID)
} else
{
  medicare_history<-medicare_coverage_df
}

medicare_history<-medicare_history%>%
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
                          join_by(USRDS_ID, between(.index_date, BEGDATE, ENDDATE))
)

#Create variable that marks FFS coverage on day of claim through 365 days prior
#Logic here depends strongly on nature of between join in dplyr
patients_clean<-patients_clean%>%
  mutate(medicare_primary_TF=ifelse(!is.na(BEGDATE) & .index_date-BEGDATE>=lookback_days,TRUE,FALSE))%>%
  select(-.index_date, -BEGDATE, -ENDDATE)

return(patients_clean)

}
