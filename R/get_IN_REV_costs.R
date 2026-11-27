#' Load and filter a single Institutional line item revenue file
#'
#' Internal helper function to load and filter a single IN file for costs
#' by USRDS_IDs. File format can be CSV, SAS, or Parquet.
#'
#' If `usrds_ids` is `NULL`, all codes are returned.
#'
#' @noRd
.load_individual_file_IN_REV_costs <- function(
  file_path,
  file_root,
  file_suffix,
  Year,
  file_directory,
  variablelist,
  usrds_ids = NULL
) {
  message("Reading file: ", file_path)

  if (file_suffix == "parquet") {
    file_data <- arrow::read_parquet(file_path) |>
      dplyr::rename_with(toupper) |>
      dplyr::select(dplyr::any_of(variablelist)) |>
      .filter_in("USRDS_ID", usrds_ids) |>
      dplyr::collect() |>
      .parse_claim_dates(
        c("CLM_FROM", "CLM_THRU", "REV_DT"),
        file_path,
        numeric_as_unix_days = TRUE
      )
  } else if (file_suffix == "csv") {
    # CODE is read as text so revenue center codes keep their leading zeros.
    header <- names(readr::read_csv(file_path, n_max = 0, show_col_types = FALSE))
    code_col <- header[toupper(header) == "CODE"]
    col_types <- readr::cols(.default = readr::col_guess())
    col_types$cols[code_col] <- list(readr::col_character())
    file_data <- readr::read_csv(
      file_path,
      col_types = col_types,
      show_col_types = FALSE
    ) |>
      dplyr::rename_with(toupper) |>
      .filter_in("USRDS_ID", usrds_ids) |>
      dplyr::select(dplyr::any_of(variablelist)) |>
      .parse_claim_dates(c("CLM_FROM", "CLM_THRU", "REV_DT"), file_path)
  } else if (file_suffix == "sas7bdat") {
    file_data <- haven::read_sas(file_path) |>
      dplyr::rename_with(toupper) |>
      dplyr::select(dplyr::any_of(variablelist)) |>
      .filter_in("USRDS_ID", usrds_ids)
  } else {
    stop("Unsupported file type: ", file_suffix)
  }

  .standardise_revenue_lines(file_data, file_path)
}

# Gives every file the same columns and types, so files that lack a column
# (older layouts) bind with the others. Dates become Date in every format: a
# SAS datetime becomes its date, and a number with no date format is
# reported, not guessed. Missing dates and codes become typed NA.
#
# Before 2008 the det files mix revenue center lines (CDTYPE "R") with
# diagnosis and procedure lines, whose CODE is an ICD code (Researcher's
# Guide 2025, Section 5, "CDTYPE and CODE Variables"). Only revenue center
# lines (CDTYPE "R"), or all lines of files without CDTYPE, are padded and
# can be dropped as 0001 totals; `.usrds_revenue_line` marks them until the lines are bound.
.standardise_revenue_lines <- function(file_data, file_path) {
  file_data <- .parse_claim_dates(
    file_data,
    c("CLM_FROM", "CLM_THRU", "REV_DT"),
    file_path
  )
  for (col in c("CLM_FROM", "CLM_THRU", "REV_DT")) {
    if (!col %in% names(file_data)) {
      file_data[[col]] <- as.Date(NA)
    }
  }
  if (!"CODE" %in% names(file_data)) {
    file_data$CODE <- NA_character_
  }
  # In a file with CDTYPE, a line whose type is missing or blank is left
  # alone, since its CODE may not be a revenue center code.
  revenue_line <- if ("CDTYPE" %in% names(file_data)) {
    trimws(as.character(file_data$CDTYPE)) %in% "R"
  } else {
    rep(TRUE, nrow(file_data))
  }
  file_data$CODE <- as.character(file_data$CODE)
  file_data$CODE[revenue_line] <- .pad_revenue_code(file_data$CODE[revenue_line])
  file_data$.usrds_revenue_line <- revenue_line
  file_data$CDTYPE <- NULL
  file_data
}

# Revenue center codes are four digits (Appendix C `$REVCEN.`). A code stored
# as a number (Parquet files converted from CSV, #44) has lost its leading
# zeros; numbers and digit strings shorter than four are padded back.
.pad_revenue_code <- function(code) {
  code <- trimws(as.character(code))
  code[code %in% c("", ".")] <- NA_character_
  short <- !is.na(code) & grepl("^[0-9]{1,3}$", code)
  code[short] <- formatC(as.integer(code[short]), width = 4, flag = "0")
  code
}


#' Retrieve Institutional costs Claims
#'
#' Searches institutional claim files for costs for specified USRDS_IDs in specified years.
#' Handles CSV, SAS, and Parquet formats.
#'
#' If `usrds_ids` is `NULL`, all claims are returned.
#'
#' @param years Integer vector of years to include.
#' @param usrds_ids Optional vector of USRDS_IDs to filter to specific patients.
#' @param drop_total_lines If `TRUE` (the default), drop lines with revenue
#'   center code `0001`. The 2025 Researcher's Guide (Section 5,
#'   "Institutional Claims Details and Revenue Center Details") reports that
#'   the `0001` line's `REV_CH` is the sum of the claim's other lines'
#'   `REV_CH`, so keeping it counts the charges twice. The Guide does not
#'   describe `REVPMT` on that line; dropping the line removes its `REVPMT`
#'   too. Lines whose code is missing are kept. In files that have `CDTYPE`
#'   (det files before 2008, which also hold diagnosis and procedure lines),
#'   only revenue center lines (`CDTYPE` `"R"`) are dropped or have their
#'   codes padded; the other lines, including those with a missing or blank
#'   `CDTYPE`, are returned unchanged for now.
#'
#' @return A data frame with one row per revenue center line and columns
#'   `USRDS_ID`, `CLM_FROM` and `CLM_THRU` (claim from and through dates),
#'   `REV_DT` (revenue center date), `CODE` (revenue center code, as text with
#'   its leading zeros), `REV_CH` (revenue center total charge), `REVPMT`
#'   (revenue center payment amount) and `HCFASAF` (claim type, as a factor).
#'   Dates are of class `Date`. Descriptions are from Appendix B of the 2025
#'   Researcher's Guide (for example table `OP_DET_2023`). A column a file
#'   does not have is `NA` for that file's lines. Dates stored as text that
#'   cannot be read become `NA`, with a warning naming the file and column.
#'
#'   With `CLM_FROM` and `CLM_THRU`, the result can go straight into
#'   [prorate_costs_by_day()]. Do not add these amounts to claim totals from
#'   [get_IN_CLM_costs()] for the same claims.
#' @export
#'
#' @examples
#' \dontrun{
#' get_IN_REV_costs(years = 2012:2016, usrds_ids=1:1000)
#' }
get_IN_REV_costs <- function(years, usrds_ids = NULL, drop_total_lines = TRUE) {
  .local_arrow_options()
  if (!is.logical(drop_total_lines) || length(drop_total_lines) != 1 || is.na(drop_total_lines)) {
    cli::cli_abort("{.arg drop_total_lines} must be {.code TRUE} or {.code FALSE}.")
  }
  variablelist <- c(
    "USRDS_ID",
    "CLM_FROM",
    "CLM_THRU",
    "REV_DT",
    "CODE",
    "CDTYPE",
    "REV_CH",
    "REVPMT",
    "HCFASAF"
  )

  .check_valid_years(
    years = years,
    file_keys = IN_REV_COSTS$file_root,
    label = "Institutional revenue center cost files"
  )

  .usrds_env$file_list |>
    dplyr::inner_join(IN_REV_COSTS, by = c("file_root", "Year")) |>
    dplyr::filter(.data$Year %in% .env$years) |>
    dplyr::select(-"file_name") |>
    purrr::pmap(.f = function(...) {
      .load_individual_file_IN_REV_costs(
        ...,
        variablelist = variablelist,
        usrds_ids = usrds_ids
      )
    }) |>
    dplyr::bind_rows() |>
    (\(lines) {
      if (drop_total_lines) {
        lines <- dplyr::filter(
          lines,
          !(.data$.usrds_revenue_line & .data$CODE %in% "0001")
        )
      }
      dplyr::select(lines, -".usrds_revenue_line")
    })() |>
    dplyr::mutate(
      HCFASAF = factor(
        .data$HCFASAF,
        levels = c("I", "M", "O", "D", "N", "H", "S", "Q", "P"),
        labels = c(
          "Inpatient",
          "Inpatient (REBUS)",
          "Outpatient",
          "Dialysis",
          "Skilled Nursing Facility",
          "Home Health",
          "Hospice",
          "Non-claim / auxiliary",
          "Physician/Supplier"
        )
      )
    )
}
