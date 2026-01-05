
#' Initialize a cohort of USRDS patients
#'
#' Initializes a cohort of USRDS patients.  Data set must have a variable named USRDS_ID.
#'
#' @param df is a data frame used to initialize a USRDS data frame.  Typically, this is a data frame created
#' from the `PATIENTS` file, potentially merged with the `MEDEVID` file or other files with baseline
#' variables which are to be time-invariant
#'
#' @param start_date is a fixed data or a date variable in the `df` data frame specifying when each patient
#' is considered to enter the cohort.
#'
#' @param end_date is a fixed data or a date variable in the `df` data frame specifying when each patient
#' is considered to exit the cohort.
#'
#' @return A data frame with columns `cohort_start_date` and `cohort_end_date` added, which take values based
#' on the `start_date` and `end_date` passed to the function.
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

  start_vec <- .resolve_date(df, start_date, "start_date")
  end_vec   <- .resolve_date(df, end_date,   "end_date")

  return_df <- df %>%
    dplyr::mutate(
      cohort_start_date = start_vec,
      cohort_end_date   = end_vec
    )

  attr(return_df, "cohort_type") <- "USRDS_cohort"
  return_df
}
