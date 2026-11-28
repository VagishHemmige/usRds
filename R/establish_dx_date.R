#' Establish date a diagnosis is made
#'
#' Given a data frame of claims created with a `get_*_ICD` command, this
#' function finds, for each patient, the claim that establishes the
#' diagnosis: the first inpatient claim, or a claim of any other type on a
#' second, later day, using the `HCFASAF` variable to classify claims as
#' inpatient or not. Patients whose claims never meet that rule are dropped.
#'
#' By default, rows on the same day count once, so several rows from one
#' visit (diagnosis positions or line items) cannot meet the two-claim rule
#' on their own. This follows the rule of one inpatient claim or two
#' outpatient claims on separate dates (Naik et al. 2016,
#' \doi{10.1111/tri.12711}). `count_by = "rows"` counts every row, as
#' this function did before the option was added.
#'
#' With `date_as = "first"` and the default `window_days = Inf`, the date
#' returned can be a claim recorded years before the claim that confirms the
#' diagnosis. Set a finite `window_days` when dating the diagnosis at the
#' first claim.
#'
#' @param df data frame of claims created by a `get_*_ICD` function, with
#'   `USRDS_ID`, `CLM_FROM` (class `Date`) and `HCFASAF`
#' @param diagnosis_established A string stored in the `diagnosis` column of
#'   the result, naming the diagnosis being dated (for example `"cryptococcus"`).
#' @param date_as Which date to return. `"confirming"` (the default) is the
#'   date of the claim that establishes the diagnosis: the inpatient claim, or
#'   the second other claim. `"first"` is the date of the patient's earliest
#'   claim within `window_days` before that confirming claim, so with the
#'   default window it is the patient's first claim with the code.
#' @param window_days The largest number of days between a claim of another
#'   type and the claim before it for the pair to establish the diagnosis.
#'   `Inf` (the default) sets no limit. An inpatient claim establishes the
#'   diagnosis on its own, whatever the window. With `count_by = "days"`, two
#'   days are at least 1 day apart, so `window_days = 0` lets only inpatient
#'   claims establish the diagnosis.
#' @param inpatient_types Values of `HCFASAF` that count as inpatient claims.
#'   The default includes `"Inpatient (REBUS)"`, code `M` in older files,
#'   which Appendix C 2025 (`$HCFASAF.`) describes as an inpatient stay.
#' @param count_by How claims of other types are counted. `"days"` (the
#'   default) counts distinct `CLM_FROM` dates, so the second claim must be on
#'   a later day, and `window_days` is the gap between two consecutive days
#'   with a claim. `"rows"` counts every row, so two rows on the same day
#'   establish the diagnosis.
#' @param on_missing_date What to do with claims whose `CLM_FROM` is missing.
#'   They are always left out, because they cannot be placed in time.
#'   `"warn"` (the default) says how many were left out and how many patients
#'   with such a claim got no diagnosis date; `"error"` stops instead;
#'   `"ignore"` leaves them out silently.
#'
#' @return A data frame filtered to keep the claim which establishes that a diagnosis has been made
#' @export
#'
#' @examples
#' # Made-up claims: patient 1 has two outpatient claims, patient 2 one
#' # inpatient claim, and patient 3 a single outpatient claim, which is not
#' # enough to establish the diagnosis.
#' claims <- data.frame(
#'   USRDS_ID = c(1, 1, 2, 3),
#'   CLM_FROM = as.Date(c("2015-01-01", "2015-03-01", "2015-02-01", "2015-04-01")),
#'   HCFASAF = c("Outpatient", "Outpatient", "Inpatient", "Outpatient")
#' )
#' establish_dx_date(claims, diagnosis_established = "cryptococcus")
#'
#' \dontrun{
#' # Codes are matched exactly, so list every billable code (#3):
#' # ICD-9 117.5 and ICD-10-CM B45.0-B45.3, B45.7-B45.9, without periods
#' cryptococcus_icd <- c(
#'   "1175", "B450", "B451", "B452", "B453", "B457", "B458", "B459"
#' )
#'
#' # Retrieve claims for all patients in selected years
#' result <- get_IN_ICD(icd_codes = cryptococcus_icd, years = 2013:2018)
#'
#' establish_dx_date(result)
#' }

establish_dx_date <- function(
  df,
  diagnosis_established = "diagnosis",
  date_as = c("confirming", "first"),
  window_days = Inf,
  inpatient_types = c("Inpatient", "Inpatient (REBUS)"),
  count_by = c("days", "rows"),
  on_missing_date = c("warn", "error", "ignore")
) {
  date_as <- rlang::arg_match(date_as)
  count_by <- rlang::arg_match(count_by)
  on_missing_date <- rlang::arg_match(on_missing_date)
  if (
    !is.numeric(window_days) ||
      length(window_days) != 1 ||
      is.na(window_days) ||
      window_days < 0
  ) {
    cli::cli_abort(
      "{.arg window_days} must be a single number of days, 0 or more, or {.code Inf}."
    )
  }
  if (!inherits(df$CLM_FROM, "Date")) {
    cli::cli_abort(c(
      "{.field CLM_FROM} must be of class {.cls Date}, not
      {.cls {class(df$CLM_FROM)[1]}}.",
      "i" = "Convert it with {.fn as.Date} before calling
      {.fn establish_dx_date}."
    ))
  }
  if (!is.character(inpatient_types)) {
    cli::cli_abort("{.arg inpatient_types} must be a character vector.")
  }

  undated <- is.na(df$CLM_FROM)
  n_undated <- sum(undated)
  if (n_undated > 0 && on_missing_date == "error") {
    cli::cli_abort(c(
      "{n_undated} claim{?s} {?has/have} a missing {.field CLM_FROM}.",
      "i" = "Remove or date them, or set {.arg on_missing_date} to
      {.val warn} or {.val ignore} to leave them out."
    ))
  }
  undated_ids <- unique(df$USRDS_ID[undated])
  df <- dplyr::filter(df, !is.na(.data$CLM_FROM))

  previous_date <- if (count_by == "days") .previous_day else dplyr::lag

  result <- df |>
    dplyr::arrange(.data$USRDS_ID, .data$CLM_FROM) |>
    dplyr::group_by(.data$USRDS_ID) |>
    dplyr::mutate(
      # A claim confirms the diagnosis if it is inpatient, or if the claim
      # (or, with count_by = "days", the day) before it is within window_days.
      previous = previous_date(.data$CLM_FROM),
      confirms = as.character(.data$HCFASAF) %in% .env$inpatient_types |
        (!is.na(.data$previous) &
          as.numeric(.data$CLM_FROM - .data$previous) <= .env$window_days),
      confirming_date = .data$CLM_FROM[which(.data$confirms)[1]]
    ) |>
    dplyr::filter(
      !is.na(.data$confirming_date),
      as.numeric(.data$confirming_date - .data$CLM_FROM) <= .env$window_days,
      .data$CLM_FROM <= .data$confirming_date
    ) |>
    dplyr::summarise(
      date_established = if (.env$date_as == "first") {
        min(.data$CLM_FROM)
      } else {
        .data$confirming_date[1]
      },
      .groups = "drop"
    ) |>
    dplyr::transmute(
      USRDS_ID = .data$USRDS_ID,
      diagnosis = .env$diagnosis_established,
      date_established = .data$date_established
    )

  if (n_undated > 0 && on_missing_date == "warn") {
    n_patients <- length(undated_ids)
    n_lost <- sum(!undated_ids %in% result$USRDS_ID)
    cli::cli_warn(c(
      "Left out {n_undated} claim{?s} with a missing {.field CLM_FROM}.",
      "i" = "{n_lost} of the {n_patients} patient{?s} with such a claim
      got no diagnosis date.",
      "i" = if (n_lost < n_patients) {
        "For the others, an undated claim may have given an earlier date."
      },
      "i" = "Set {.arg on_missing_date} to {.val ignore} to silence this, or
      {.val error} to stop."
    ))
  }
  result
}

# For each date in a sorted vector, the latest earlier date (NA for the first
# day), so rows on the same day share one previous day.
.previous_day <- function(dates) {
  days <- unique(dates)
  c(dates[NA_integer_], days)[match(dates, days)]
}
