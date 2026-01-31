
#' Initialize a cohort of USRDS patients
#'
#' Initializes a cohort of USRDS patients.  Data set must have a variable named USRDS_ID.
#'
#' @param df is a data frame used to initialize a USRDS data frame.  Typically, this is a data frame created
#' from the `PATIENTS` file, potentially merged with the `MEDEVID` file or other files with baseline
#' variables which are to be time-invariant.  `USRDS_ID` must be unique or the function will error.
#'
#' @param start_date is a fixed data or a date variable in the `df` data frame specifying when each patient
#' is considered to enter the cohort.
#'
#' @param end_date is a fixed data or a date variable in the `df` data frame specifying when each patient
#' is considered to exit the cohort.
#'
#' @return A data frame and tmerge class object with columns `cohort_start_date` and `cohort_stop_date` added, which take values based
#' on the `start_date` and `end_date` passed to the function, as well as `tstart` and `tstop` helper numbers
#'
#' @export
#'
#' @examples
#' \dontrun{
#' }

create_usrds_cohort <- function(df, start_date, end_date) {

  #Error check
  if (!"USRDS_ID" %in% names(df)) {
    stop("Data set must have a variable named 'USRDS_ID'", call. = FALSE)
  }

  if (anyDuplicated(df$USRDS_ID) > 0) {
    stop("USRDS_ID must be unique in df for cohort initialization", call. = FALSE)
  }

  start_vec <- .resolve_date(df, start_date, "start_date")
  end_vec   <- .resolve_date(df, end_date,   "end_date")

  USRDS_temp_cohort <- df %>%
    dplyr::mutate(
      cohort_start_date = start_vec,
      cohort_stop_date   = end_vec
    )

  origin_date <- as.Date("1970-01-01")

  USRDS_temp_cohort <- USRDS_temp_cohort %>%
    dplyr::mutate(
      tstart = as.numeric(cohort_start_date - origin_date),
      tstop  = as.numeric(cohort_stop_date  - origin_date)
    )

  return_df <- survival::tmerge(
    data1 = USRDS_temp_cohort,
    data2 = USRDS_temp_cohort,
    id = USRDS_ID,
    tstart = tstart,
    tstop  = tstop
  )

  attr(return_df, "cohort_type") <- "USRDS_cohort"
  return_df
}
