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
#' Columns that are already `Date` are kept. Date-times become dates. Text is
#' read as ISO year-month-day when every value in the column has that form,
#' and otherwise as day-month-year (`01JAN2010`, the SAS DATE9. form in USRDS
#' CSV exports); `""` and `"."` are missing. Other date forms (MMDDYY10.,
#' SAS day counts) are left to the reader rebuild in #44. Any other value that cannot be read
#' becomes `NA` with a warning naming the file, the column and how many
#' values, so claims are not dropped downstream without notice. The values
#' themselves are never printed.
#'
#' @param df A data frame.
#' @param cols Names of the date columns; those not in `df` are skipped.
#' @param file_path The file the rows came from, for the warning.
#' @noRd
.parse_claim_dates <- function(df, cols, file_path) {
  for (col in intersect(cols, names(df))) {
    values <- df[[col]]
    if (inherits(values, "Date")) {
      next
    }
    if (inherits(values, "POSIXt")) {
      df[[col]] <- as.Date(values)
      next
    }
    text <- trimws(as.character(values))
    text[text %in% c("", ".")] <- NA_character_
    present <- text[!is.na(text)]
    all_iso <- length(present) > 0 &&
      all(grepl("^\\d{4}-\\d{2}-\\d{2}$", present))
    parse <- if (all_iso) lubridate::ymd else lubridate::dmy
    # Failures are counted and reported below, so lubridate's own warning
    # would only repeat it.
    parsed <- suppressWarnings(parse(text))
    n_failed <- sum(!is.na(text) & is.na(parsed))
    if (n_failed > 0) {
      cli::cli_warn(
        c(
          "{.field {col}} in {.file {basename(file_path)}}: {n_failed}
          value{?s} could not be read as {?a date/dates} and {?was/were} set
          to {.code NA}.",
          "i" = "Expected day-month-year dates such as {.val 01JAN2010}."
        ),
        class = "usrds_unparsed_dates"
      )
    }
    df[[col]] <- parsed
  }
  df
}
