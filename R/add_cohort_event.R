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
#' @param event_date is a character string naming a date variable in
#'   `event_data_frame` that specifies when each patient experiences the event
#'
#' @param event_variable_name is a string with the variable name for the new event variable created
#'
#' @return A data frame with columns `cohort_start_date` and `cohort_end_date` for each row
#'
#' @export
#'
#' @examples
#' \dontrun{
#' }

add_cohort_event <- function(USRDS_cohort,
                             event_data_frame,
                             event_date,
                             event_variable_name) {

  ## ---- Guards -------------------------------------------------------------

  # Confirm USRDS cohort
  if (!identical(attr(USRDS_cohort, "cohort_type", exact = TRUE), "USRDS_cohort")) {
    stop("USRDS_cohort must be a USRDS cohort object", call. = FALSE)
  }

  # Check ID exists in both data frames
  if (!"USRDS_ID" %in% names(USRDS_cohort) ||
      !"USRDS_ID" %in% names(event_data_frame)) {
    stop("Both data frames must contain 'USRDS_ID'", call. = FALSE)
  }

  # Validate event_variable_name
  if (!is.character(event_variable_name) || length(event_variable_name) != 1) {
    stop("event_variable_name must be a single character string", call. = FALSE)
  }

  if (event_variable_name %in% names(USRDS_cohort)) {
    stop(
      sprintf("Variable '%s' already exists in USRDS_cohort", event_variable_name),
      call. = FALSE
    )
  }

  # Validate event_date (must be a column name)
  if (!is.character(event_date) || length(event_date) != 1) {
    stop("event_date must be a single column name (character string)", call. = FALSE)
  }

  if (!event_date %in% names(event_data_frame)) {
    stop(
      sprintf(
        "Event date variable '%s' not found in event_data_frame",
        event_date
      ),
      call. = FALSE
    )
  }

  ## ---- Time setup ----------------------------------------------------------

  origin_date <- as.Date("2000-01-01")

  USRDS_temp_cohort <- USRDS_cohort %>%
    dplyr::mutate(
      tstart = as.numeric(cohort_start_date - origin_date),
      tstop  = as.numeric(cohort_stop_date  - origin_date)
    )

  ## ---- Event time conversion ----------------------------------------------

  event_temp_data_frame <- event_data_frame %>%
    dplyr::mutate(
      tevent = as.numeric(.data[[event_date]] - origin_date)
    )

  ## ---- tmerge --------------------------------------------------------------

  result <- tmerge(
    USRDS_temp_cohort,
    event_temp_data_frame,
    id = USRDS_ID,
    !!event_variable_name := cumevent(tevent)
  )

  #Convert back to dates and remove tmerge variables
  result <- result %>%
    dplyr::mutate(
      cohort_start_date = origin_date + tstart,
      cohort_stop_date  = origin_date + tstop
    ) %>%
    dplyr::select(-tstart, -tstop)

  #Restore cohort attribute
  attr(result, "cohort_type") <- "USRDS_cohort"

  return(result)
}
