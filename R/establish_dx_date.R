#' Establish date a diagnosis is made
#'
#' Given a data frame of claims created with a `get_*_ICD` command, this
#' function finds, for each patient, the claim that establishes the
#' diagnosis: the first inpatient claim, or the second claim of any other
#' type, using the `HCFASAF` variable to classify claims as inpatient or
#' not. Patients whose claims never meet that rule are dropped.
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
#'   diagnosis on its own, whatever the window.
#' @param inpatient_types Values of `HCFASAF` that count as inpatient claims.
#'   The default includes `"Inpatient (REBUS)"`, code `M` in older files,
#'   which Appendix C 2025 (`$HCFASAF.`) describes as an inpatient stay.
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
  inpatient_types = c("Inpatient", "Inpatient (REBUS)")
) {
  date_as <- rlang::arg_match(date_as)
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
      "i" = "The {.code get_*_ICD()} extractors return dates; convert with
      {.fn as.Date} if the claims came from elsewhere."
    ))
  }
  if (!is.character(inpatient_types)) {
    cli::cli_abort("{.arg inpatient_types} must be a character vector.")
  }

  df |>
    dplyr::arrange(.data$USRDS_ID, .data$CLM_FROM) |>
    dplyr::group_by(.data$USRDS_ID) |>
    dplyr::mutate(
      # A claim confirms the diagnosis if it is inpatient, or if the claim
      # before it is within window_days.
      confirms = as.character(.data$HCFASAF) %in% .env$inpatient_types |
        (!is.na(dplyr::lag(.data$CLM_FROM)) &
          as.numeric(.data$CLM_FROM - dplyr::lag(.data$CLM_FROM)) <=
            .env$window_days),
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
}
