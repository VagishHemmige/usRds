#' Finalize a USRDS cohort
#'
#' This function accepts a data frame that is a USRDS longitudinal cohort, and returns the same object with the
#' `tstart` and `tstop` variables shifted so that each patient's first observation has `tstart`=0.
#'
#' @param USRDS_cohort is a USRDS cohort created using the `create_usrds_cohort()` function
#'#'
#' @return A data frame that is a USRDS cohort object
#'
#' @export
#'
#' @examples
#' \dontrun{
#' }



  finalize_usrds_cohort <- function(USRDS_cohort) {

    ## ---- Guards -------------------------------------------------------------

    if (!identical(attr(USRDS_cohort, "cohort_type", exact = TRUE), "USRDS_cohort")) {
      stop("USRDS_cohort must be a USRDS cohort object", call. = FALSE)
    }

    if (!all(c("USRDS_ID", "tstart", "tstop") %in% names(USRDS_cohort))) {
      stop("USRDS_cohort must contain USRDS_ID, tstart, and tstop", call. = FALSE)
    }

    ## ---- Shift time to patient-specific t0 ----------------------------------

    result <- USRDS_cohort |>
      dplyr::group_by(USRDS_ID) |>
      dplyr::mutate(
        .t0 = min(tstart),
        tstart = tstart - .t0,
        tstop  = tstop  - .t0
      ) |>
      dplyr::ungroup() |>
      dplyr::select(-.t0)

    ## ---- Sanity check -------------------------------------------------------

    if (any(result$tstart < 0)) {
      stop("Negative tstart produced during finalization", call. = FALSE)
    }

    ## ---- Restore attributes -------------------------------------------------

    attr(result, "cohort_type") <- "USRDS_cohort"
    attr(result, "finalized") <- TRUE

    return(result)
  }


