#' Finalize a USRDS cohort
#'
#' This function accepts a data frame that is a USRDS longitudinal cohort, and returns the same object with the
#' `tstart` and `tstop` variables shifted to an appropriate baseline t=0 as specified by `baseline_date_variable`.
#'
#' Of note,`baseline_date_variable` does NOT have to be constant within each patient.  If the baseline is the time since most recent transplant,
#' for example, and a patient has multiple transplants within the `USRDS_cohort`, it may be appropriate for different observations periods for the
#' same patient to use different baseline dates.
#'
#' If `baseline_date_variable` is unspecified or specified as NULL, its default value, a default baseline value will be calculated for each patient such that
#' each patient's first observation has `tstart`=0.
#'
#' Finalize a cohort once, after all covariates and events have been added. The
#' returned cohort is marked as finalized, and passing it to
#' `finalize_usrds_cohort()` again is an error, because a second shift would
#' subtract the baseline twice.
#'
#' @param USRDS_cohort is a USRDS cohort created using the `create_usrds_cohort()` function
#'
#' @param baseline_date_variable, if not NULL, includes the name of the variable in `USRDS_cohort` that determines the t0 date for each row of
#' the cohort
#'
#' @return A data frame that is a USRDS cohort object
#'
#' @export
#'
#' @examples
#' # Made-up patients; real cohorts usually start from a USRDS file
#' patients <- data.frame(
#'   USRDS_ID = c(1, 2),
#'   start = as.Date(c("2020-01-01", "2020-03-01")),
#'   end = as.Date(c("2020-12-31", "2020-12-31"))
#' )
#' cohort <- create_usrds_cohort(patients, start_date = "start", end_date = "end")
#' diagnoses <- data.frame(USRDS_ID = 1, dx_date = as.Date("2020-04-01"))
#' cohort <- add_cohort_covariate(
#'   cohort,
#'   diagnoses,
#'   covariate_date = "dx_date",
#'   covariate_variable_name = "diabetes"
#' )
#' admissions <- data.frame(USRDS_ID = 2, admit_date = as.Date("2020-06-01"))
#' cohort <- add_cohort_event(
#'   cohort,
#'   admissions,
#'   event_date = "admit_date",
#'   event_variable_name = "hospitalized"
#' )
#' finalize_usrds_cohort(cohort)

finalize_usrds_cohort <- function(USRDS_cohort, baseline_date_variable = NULL) {
  ## ---- Guards -------------------------------------------------------------

  if (
    !identical(attr(USRDS_cohort, "cohort_type", exact = TRUE), "USRDS_cohort")
  ) {
    stop("USRDS_cohort must be a USRDS cohort object", call. = FALSE)
  }

  if (!all(c("USRDS_ID", "tstart", "tstop") %in% names(USRDS_cohort))) {
    stop("USRDS_cohort must contain USRDS_ID, tstart, and tstop", call. = FALSE)
  }

  # A second shift would subtract the baseline from times that are already
  # relative to it, so the time scale would be silently wrong (#34).
  if (isTRUE(attr(USRDS_cohort, "finalized", exact = TRUE))) {
    stop(
      paste0(
        "USRDS_cohort has already been finalized; its tstart and tstop are ",
        "already relative to the baseline. Call finalize_usrds_cohort() once, ",
        "on the cohort returned by create_usrds_cohort() and the ",
        "add_cohort_*() functions."
      ),
      call. = FALSE
    )
  }

  #Validate baseline_date_variable
  if (!is.null(baseline_date_variable)) {
    ## 1. Must be a single character string
    if (
      !is.character(baseline_date_variable) ||
        length(baseline_date_variable) != 1
    ) {
      stop(
        "`baseline_date_variable` must be a single character string naming a column."
      )
    }

    ## 2. Must exist in the cohort
    if (!baseline_date_variable %in% names(USRDS_cohort)) {
      stop(
        sprintf(
          "Baseline date variable '%s' not found in USRDS_cohort.",
          baseline_date_variable
        )
      )
    }

    ## 3. Must be a Date or date-time
    x <- USRDS_cohort[[baseline_date_variable]]

    if (!inherits(x, c("Date", "POSIXct", "POSIXt"))) {
      stop(
        sprintf(
          "Baseline date variable '%s' must be of class Date or POSIXct.",
          baseline_date_variable
        )
      )
    }

    ## Optional but highly recommended: no missing values
    if (anyNA(x)) {
      stop(
        sprintf(
          "Baseline date variable '%s' contains missing values.",
          baseline_date_variable
        )
      )
    }
  }

  ## ---- Shift time to patient-specific t0 ----------------------------------

  if (is.null(baseline_date_variable)) {
    result <- USRDS_cohort |>
      dplyr::group_by(.data$USRDS_ID) |>
      dplyr::mutate(
        .t0 = min(.data$tstart)
      ) |>
      dplyr::ungroup()
  } else {
    result <- USRDS_cohort |>
      dplyr::mutate(
        .t0 = as.numeric(as.Date(.data[[baseline_date_variable]]))
      )
  }

  result <- result |>
    dplyr::mutate(
      tstart = .data$tstart - .data$.t0,
      tstop = .data$tstop - .data$.t0
    ) |>
    dplyr::select(-".t0")

  ## ---- Sanity check -------------------------------------------------------

  neg_n <- sum(result$tstart < 0, na.rm = TRUE)

  if (neg_n > 0) {
    warning(
      sprintf(
        "Negative tstart produced during finalization (%d rows affected)",
        neg_n
      ),
      call. = FALSE
    )
  }

  ## ---- Restore attributes -------------------------------------------------

  attr(result, "cohort_type") <- "USRDS_cohort"
  attr(result, "finalized") <- TRUE

  return(result)
}
