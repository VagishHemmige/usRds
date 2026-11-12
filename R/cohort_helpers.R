#' Resolve date inputs for cohort functions
#'
#' @param df Data frame
#' @param x Fixed Date or date column
#' @param arg_name Name of argument (for error messages)
#'
#' @keywords internal
#' @noRd

.resolve_date <- function(df, x, arg_name) {

  # Fixed Date
  if (inherits(x, c("Date", "POSIXct", "POSIXt"))) {
    return(as.Date(x))
  }

  # Column name, given as a string
  if (!is.character(x) || length(x) != 1 || is.na(x)) {
    stop(
      sprintf(
        "`%s` must be a Date or the name of a date column in `df`",
        arg_name
      ),
      call. = FALSE
    )
  }

  if (!x %in% names(df)) {
    stop(
      sprintf(
        "Column '%s' named in `%s` is not in `df`",
        x,
        arg_name
      ),
      call. = FALSE
    )
  }

  col <- df[[x]]

  if (!inherits(col, c("Date", "POSIXct", "POSIXt"))) {
    stop(
      sprintf(
        "Column used for `%s` must be a Date or POSIXct variable",
        arg_name
      ),
      call. = FALSE
    )
  }

  as.Date(col)
}
