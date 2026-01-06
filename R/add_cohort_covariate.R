#' Add a covariate variable to a USRDS cohort
#'
#' This function accepts two data frames.  One is a USRDS longitudinal cohort.  The second is a data frame with
#' dates representing covariates.  The resulting output is a USRDS longitudinal cohort with the covariates added to
#' the data frame as time-varying covariates.
#'
#' Both `USRDS_cohort` and `condition_data_frame` must contain `USRDS_ID`.
#'
#' Examples of characteristics
#'
#'   - That a patient has developed a specific medical condition
#'   - That a patient has, in the past, experienced an event of interest
#'   - Patient ZIP code
#'
#'
#' @param USRDS_cohort is a USRDS cohort created using the `create_usrds_cohort()` function
#'
#' @param covariate_data_frame is a data frame with a date variable (delineated via the `covariate_date` option).
#'
#' @param covariate_date is a character string naming a date variable in
#'   `covariate_data_frame` that specifies the date of onset of the covariate
#'
#' @param covariate_value is an optional variable which encodes the value taken
#'   by the time-dependent covariate on the date encoded in `covariate_date`.  If
#'   `covariate_value` is not specified,
#'
#' @param covariate_variable_name is a string with the variable name for the new covariate variable created
#'
#' @return A USRDS longitudinal cohort with additional rows created as needed
#'   and a new time-varying covariate column named `covariate_variable_name`.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' }
#'
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


  ## ---- Event time conversion ----------------------------------------------

  event_temp_data_frame <- event_data_frame %>%
    dplyr::mutate(
      tevent = as.numeric(.data[[event_date]] - origin_date)
    )

  ## ---- tmerge --------------------------------------------------------------

  event_call <- setNames(
    list(quote(cumevent(tevent))),
    event_variable_name
  )

  result <- do.call(
    survival::tmerge,
    c(
      list(
        USRDS_cohort,
        event_temp_data_frame,
        id = quote(USRDS_ID)
      ),
      event_call
    )
  )

  #Update cohort variables
  result$cohort_start_date<-as.Date("2000-01-01")+result$tstart
  result$cohort_stop_date<-as.Date("2000-01-01")+result$tstop


  #Restore cohort attribute
  attr(result, "cohort_type") <- "USRDS_cohort"
  attr(result, "event_variables") <- c(event_variable_name, attr(result, "event_variables"))


  #Potentially replace cumulative sum of events with a 1/0 marker of whether event happened?
  #cohort$event1<-ifelse(cohort$event1>0,1,0)

  return(result)
}

