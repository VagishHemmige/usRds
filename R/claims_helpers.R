#' Keep rows whose column value is in a set, unless the set is NULL
#'
#' @param df A data frame.
#' @param col Column name, as a string.
#' @param values Values to keep, or `NULL` to keep every row.
#' @noRd
.filter_in <- function(df, col, values) {
  if (is.null(values)) {
    return(df)
  }
  dplyr::filter(df, .data[[col]] %in% .env$values)
}

#' Convert claim date columns to Date, reporting values that cannot be read
#'
#' Columns that are already `Date` are kept, and date-times become dates.
#' Text is read value by value: ISO year-month-day (`2010-01-31`) and SAS
#' DATE9. (`31JAN2010`, the form in USRDS CSV exports) are read; `""` and
#' `"."` are missing. Any other text, including slash dates such as
#' `01/02/2010`, whose day and month order cannot be told from the value,
#' becomes `NA` with a warning naming the file, the column and how many
#' values, so claims are not dropped downstream without notice. The values
#' themselves are never printed. Other date forms are left to the reader
#' rebuild in #44.
#'
#' @param df A data frame.
#' @param cols Names of the date columns; those not in `df` are skipped.
#' @param file_path The file the rows came from, for the warning.
#' @param numeric_as_unix_days If `TRUE`, numbers are read as days since
#'   1970-01-01, as `lubridate::as_date()` does (the Parquet branch's earlier
#'   behaviour). If `FALSE`, numbers are text that cannot be read, since a
#'   number in a CSV may be a SAS day count, which starts in 1960.
#' @noRd
.parse_claim_dates <- function(
  df,
  cols,
  file_path,
  numeric_as_unix_days = FALSE
) {
  for (col in intersect(cols, names(df))) {
    values <- df[[col]]
    if (inherits(values, "Date")) {
      next
    }
    if (inherits(values, "POSIXt")) {
      df[[col]] <- as.Date(values)
      next
    }
    if (is.numeric(values) && numeric_as_unix_days) {
      df[[col]] <- lubridate::as_date(values)
      next
    }
    text <- trimws(as.character(values))
    text[text %in% c("", ".")] <- NA_character_
    is_iso <- !is.na(text) & grepl("^\\d{4}-\\d{2}-\\d{2}$", text)
    is_date9 <- !is.na(text) & grepl("^\\d{1,2}[A-Za-z]{3}\\d{4}$", text)
    parsed <- rep(as.Date(NA), length(text))
    # Impossible dates (31FEB2010) fail here; they are counted and reported
    # below, so lubridate's own warning would only repeat it.
    parsed[is_iso] <- suppressWarnings(lubridate::ymd(text[is_iso]))
    parsed[is_date9] <- suppressWarnings(lubridate::dmy(text[is_date9]))
    n_failed <- sum(!is.na(text) & is.na(parsed))
    if (n_failed > 0) {
      cli::cli_warn(
        c(
          "{.field {col}} in {.file {basename(file_path)}}: {n_failed}
          value{?s} could not be read as {?a date/dates} and {?was/were} set
          to {.code NA}.",
          "i" = "Dates are read in the forms {.val 31JAN2010} and
                 {.val 2010-01-31}."
        ),
        class = "usrds_unparsed_dates"
      )
    }
    df[[col]] <- parsed
  }
  df
}

#' Label claim types (`HCFASAF`) as a factor
#'
#' Codes and meanings follow the Appendix C 2025 `$HCFASAF.` format: D
#' dialysis, E durable medical equipment, H home health, I inpatient, M
#' PMMIS inpatient stay (labelled "Inpatient (REBUS)" as before), N skilled
#' nursing, O outpatient, P physician/supplier, Q PMMIS quarterly dialysis,
#' S hospice. Codes not in that list become `NA` with a warning, so claims
#' are not dropped downstream without notice (#27).
#'
#' The Researcher's Guide 2025 (Section 5, Table 10) also lists `P` as
#' "Quarterly Dialysis Records" for institutional files, while Appendix C
#' 2025 gives `P` as physician/supplier and `Q` as PMMIS quarterly dialysis.
#' The extractors read 2006 onward, including the combined `det2006`/
#' `det2007` files. A schema report on the maintainer's files (2026-11-22,
#' codes only) found `M` and `Q` in the older institutional files and `P`
#' only in physician/supplier files, so the map follows Appendix C and keeps
#' `P` as Physician/Supplier, as seven of the eight extractors did before
#' (`get_IN_CLM_costs()` had no `P` level). A different meaning of `P` in
#' some release would need a layout-specific map.
#'
#' @param code Claim type codes.
#' @noRd
.hcfasaf_factor <- function(code) {
  levels <- c("I", "M", "O", "D", "N", "H", "S", "Q", "P", "E")
  labels <- c(
    "Inpatient",
    "Inpatient (REBUS)",
    "Outpatient",
    "Dialysis",
    "Skilled Nursing Facility",
    "Home Health",
    "Hospice",
    "Quarterly dialysis (PMMIS)",
    "Physician/Supplier",
    "Durable Medical Equipment"
  )
  code <- as.character(code)
  unknown <- !is.na(code) & !code %in% levels
  if (any(unknown)) {
    cli::cli_warn(
      c(
        "{sum(unknown)} claim{?s} {?has/have} a claim type ({.field HCFASAF})
        not in Appendix C and {?was/were} set to {.code NA}.",
        "i" = "Unknown code{?s}: {.val {unique(code[unknown])}}."
      ),
      class = "usrds_unknown_claim_type"
    )
  }
  factor(code, levels = levels, labels = labels)
}
