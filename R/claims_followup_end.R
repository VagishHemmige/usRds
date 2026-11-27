#' End of claims-based follow-up
#'
#' For each row, finds the last day of follow-up for a claims-based outcome:
#' the earliest of death, the end of the Medicare-primary coverage spell
#' containing the index date, the date the claims are complete to, a study
#' end date, and a maximum length of follow-up. Every end date is the last
#' day observed, so a patient is followed from `index_date` through
#' `followup_end`, both included.
#'
#' Claims end before the payer history and the death records do: in the 2025
#' standard analysis files, claims are complete through 2023-12-31 while
#' the core files run through 2024-12-31 (Researcher's Guide 2025, Section 5,
#' "Introduction"). An open payer spell is given the end of the data period
#' as its `ENDDATE` (Section 4, "ESRD Payer Sequence File"), so the coverage
#' end alone does not stop follow-up when the claims stop. The 2017 Annual Data Report (Volume 2, ESRD Analytical
#' Methods, hospitalization) censors at death, at the end of Medicare Parts
#' A and B or Medicare primary, and at December 31.
#'
#' @param df A data frame with a column `USRDS_ID` and the columns named
#'   below.
#' @param index_date The name of a `Date` column in `df`: the first day of
#'   follow-up. A missing value means follow-up never starts:
#'   `followup_end` is then `NA`, with reason `"no_index"`.
#' @param coverage_end The name of a `Date` column in `df` holding the end of
#'   the Medicare-primary spell that contains the index date, as returned by
#'   [verify_medicare_primary()] through `coverage_end_variable`. A missing
#'   value means the patient has no Medicare-primary spell at the index date:
#'   `followup_end` is then `NA`, with reason `"no_coverage"`.
#' @param death_date Optional name of a `Date` column in `df` holding the date
#'   of death (for example `DIED` from the `patients` file). A missing value
#'   means the patient is not known to have died.
#' @param claims_end Required. The last date the claims are complete to, for
#'   the release in use (`as.Date("2023-12-31")` for the 2025 standard
#'   analysis files). It has no default because it changes with every
#'   release.
#' @param study_end Optional last day of the study: a `Date`, or the name of
#'   a `Date` column in `df`.
#' @param max_days Optional largest number of whole days after the index
#'   date; the last day is `index_date + max_days`.
#'
#' @return `df` with two added columns: `followup_end` (`Date`) and
#'   `followup_end_reason`, one of `"death"`, `"coverage_end"`,
#'   `"claims_end"`, `"study_end"`, `"max_days"`, `"no_coverage"` or
#'   `"no_index"`. When two ends fall on the same day, the reason is the first
#'   in that order. A missing index date takes precedence over missing
#'   coverage.
#' @export
#'
#' @examples
#' patients <- data.frame(
#'   USRDS_ID = c(1, 2),
#'   index = as.Date(c("2015-01-01", "2015-01-01")),
#'   DIED = as.Date(c("2015-03-01", NA)),
#'   coverage_end = as.Date(c("2016-12-31", "2015-06-30"))
#' )
#' claims_followup_end(
#'   patients,
#'   index_date = "index",
#'   coverage_end = "coverage_end",
#'   death_date = "DIED",
#'   claims_end = as.Date("2023-12-31"),
#'   max_days = 364
#' )
claims_followup_end <- function(
  df,
  index_date,
  coverage_end,
  death_date = NULL,
  claims_end,
  study_end = NULL,
  max_days = NULL
) {
  if (!inherits(df, "data.frame")) {
    cli::cli_abort("{.arg df} must be a data frame.")
  }
  if (missing(claims_end)) {
    cli::cli_abort(c(
      "{.arg claims_end} is required.",
      "i" = "Give the date the claims in your release are complete to, for
      example {.code as.Date(\"2023-12-31\")} for the 2025 standard analysis
      files."
    ))
  }
  .check_date_column(df, index_date, "index_date")
  .check_date_column(df, coverage_end, "coverage_end")
  if (!is.null(death_date)) {
    .check_date_column(df, death_date, "death_date")
  }
  if (!inherits(claims_end, "Date") || length(claims_end) != 1 || is.na(claims_end)) {
    cli::cli_abort("{.arg claims_end} must be a single {.cls Date}.")
  }
  if (is.character(study_end)) {
    .check_date_column(df, study_end, "study_end")
  } else if (
    !is.null(study_end) &&
      (!inherits(study_end, "Date") || length(study_end) != 1 || is.na(study_end))
  ) {
    cli::cli_abort(
      "{.arg study_end} must be a single {.cls Date} or the name of a date column."
    )
  }
  if (
    !is.null(max_days) &&
      (!is.numeric(max_days) || length(max_days) != 1 || !is.finite(max_days) ||
        max_days < 0 || max_days != round(max_days))
  ) {
    cli::cli_abort("{.arg max_days} must be a single whole number of days, 0 or more.")
  }
  added <- intersect(c("followup_end", "followup_end_reason"), names(df))
  if (length(added) > 0) {
    cli::cli_abort("{.arg df} already has column{?s} {.field {added}}.")
  }

  n <- nrow(df)
  none <- rep(as.Date(NA), n)
  index <- df[[index_date]]
  # Candidate ends, in the order used to break ties.
  ends <- list(
    death = if (is.null(death_date)) none else df[[death_date]],
    coverage_end = df[[coverage_end]],
    claims_end = rep(claims_end, n),
    study_end = if (is.null(study_end)) {
      none
    } else if (is.character(study_end)) {
      df[[study_end]]
    } else {
      rep(study_end, n)
    },
    max_days = if (is.null(max_days)) none else index + max_days
  )

  end_days <- do.call(cbind, lapply(ends, as.numeric))
  end_days[is.na(end_days)] <- Inf
  earliest <- apply(end_days, 1, min)
  reason <- names(ends)[max.col(-end_days, ties.method = "first")]

  followup_end <- as.Date(earliest, origin = "1970-01-01")
  no_coverage <- is.na(df[[coverage_end]])
  followup_end[no_coverage] <- as.Date(NA)
  reason[no_coverage] <- "no_coverage"
  no_index <- is.na(index)
  followup_end[no_index] <- as.Date(NA)
  reason[no_index] <- "no_index"

  before_index <- !is.na(followup_end) & !is.na(index) & followup_end < index
  if (any(before_index)) {
    cli::cli_warn(
      "{sum(before_index)} row{?s} end{?s/} follow-up before {.arg index_date}."
    )
  }

  df$followup_end <- followup_end
  df$followup_end_reason <- reason
  df
}

.check_date_column <- function(df, column, arg, call = rlang::caller_env()) {
  if (!is.character(column) || length(column) != 1 || !column %in% names(df)) {
    cli::cli_abort(
      "{.arg {arg}} must name a column of {.arg df}.",
      call = call
    )
  }
  if (!inherits(df[[column]], "Date")) {
    cli::cli_abort(
      "{.field {column}} ({.arg {arg}}) must be of class {.cls Date}, not
      {.cls {class(df[[column]])[1]}}.",
      call = call
    )
  }
  invisible(column)
}
