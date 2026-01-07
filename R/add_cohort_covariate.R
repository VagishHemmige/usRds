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
add_cohort_covariate <- function(USRDS_cohort,
                             covariate_data_frame,
                             covariate_date,
                             covariate_value=NULL,
                             covariate_variable_name) {

  ## ---- Guards -------------------------------------------------------------

  # Confirm USRDS cohort
  if (!identical(attr(USRDS_cohort, "cohort_type", exact = TRUE), "USRDS_cohort")) {
    stop("USRDS_cohort must be a USRDS cohort object", call. = FALSE)
  }

  # Check ID exists in both data frames
  if (!"USRDS_ID" %in% names(USRDS_cohort) ||
      !"USRDS_ID" %in% names(covariate_data_frame)) {
    stop("Both data frames must contain 'USRDS_ID'", call. = FALSE)
  }

  # Validate event_variable_name
  if (!is.character(covariate_variable_name) || length(covariate_variable_name) != 1) {
    stop("covariate_variable_name must be a single character string", call. = FALSE)
  }

  if (covariate_variable_name %in% names(USRDS_cohort)) {
    stop(
      sprintf("Variable '%s' already exists in USRDS_cohort", covariate_variable_name),
      call. = FALSE
    )
  }

  # Validate covariate_date (must be a column name)
  if (!is.character(covariate_date) || length(covariate_date) != 1) {
    stop("covariate_date must be a single column name (character string)", call. = FALSE)
  }

  if (!covariate_date %in% names(covariate_data_frame)) {
    stop(
      sprintf(
        "Covariate date variable '%s' not found in covariate_data_frame",
        covariate_date
      ),
      call. = FALSE
    )
  }

  if (!is.null(covariate_value)) {

    # Must be a single character string
    if (!is.character(covariate_value) || length(covariate_value) != 1) {
      stop(
        "covariate_value must be a single character string naming a column in covariate_data_frame",
        call. = FALSE
      )
    }

    # Must exist in covariate_data_frame
    if (!covariate_value %in% names(covariate_data_frame)) {
      stop(
        sprintf(
          "covariate_value '%s' not found in covariate_data_frame",
          covariate_value
        ),
        call. = FALSE
      )
    }
  }



  ## ---- Time setup ----------------------------------------------------------

  origin_date <- as.Date("2000-01-01")


  ## ---- Event time conversion ----------------------------------------------

  covariate_temp_data_frame <- covariate_data_frame %>%
    dplyr::mutate(
      tcovariate = as.numeric(.data[[covariate_date]] - origin_date)
    )

  ## ---- tmerge --------------------------------------------------------------


  if (is.null(covariate_value)) {

    event_call <- setNames(
      list(quote(tdc(tcovariate))),
      covariate_variable_name
    )

  } else {

    event_call <- setNames(
      list(
        as.call(list(
          quote(tdc),
          quote(tcovariate),
          as.name(covariate_value)
        ))
      ),
      covariate_variable_name
    )
  }




  result <- do.call(
    survival::tmerge,
    c(
      list(
        USRDS_cohort,
        covariate_temp_data_frame,
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
  attr(result, "covariate_variables") <- c(covariate_variable_name, attr(result, "covariate_variables"))


  return(result)
}

