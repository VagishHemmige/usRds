#' Add an event variable to a USRDS cohort
#'
#' This function accepts two data frames.  One is a USRDS longitudinal cohort.  The second is a data frame with
#' dates representing an event.  The resulting output is a USRDS longitudinal cohort with the events added to
#' the data frame
#'
#' @param USRDS_cohort is a USRDS cohort created using the `create_usrds_cohort()` function
#'
#' @param event_data_frame is a data frame with a date variable (delineated via the `event_date` option).
#'
#' @param event_date is a fixed data or a date variable in the `df` data frame specifying when each patient
#' is considered to have the event
#'
#' @return A data frame with columns `cohort_start_date` and `cohort_end_date` added, which take values based
#' on the `start_date` and `end_date` passed to the function.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' }

add_cohort_event <- function(USRDS_cohort, event_data_frame, event_date, event_variable_name) {

  #Confirm that the first object is in fact a USRDS cohort
  if (!identical(attr(USRDS_cohort, "cohort_type", exact = TRUE), "USRDS_cohort")) {
    stop("USRDS_cohort must be a USRDS cohort object", call. = FALSE)
  }

  #Use tmerge to add the event variable `event_variable_name` to the dataset
  #Tmerge can only merge on numerical data, not date range data, so we need to convert
  #cohort_date_start and cohort_date_stop
  tmerge()



}
