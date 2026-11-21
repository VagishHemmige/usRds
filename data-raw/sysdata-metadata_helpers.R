#' Load USRDS Appendix B variable metadata
#'
#' Reads all non-TOC sheets in Appendix B and compiles variable metadata
#' for each file.
#'
#' @param path Path to Appendix B Excel file
#' @return A tibble with columns: file, variable, type, length, format, description
#' @noRd
.load_usrds_metadata_b <- function(path = "data-raw/USRDS_Res_Guide_Appendix_B_2024.xlsx") {
  sheets <- readxl::excel_sheets(path)
  sheets <- sheets[sheets != "TOC"]

  b_metadata <- purrr::map_dfr(sheets, function(sheet) {
    message("📄 Processing sheet: ", sheet)

    df <- tryCatch(
      readxl::read_excel(path, sheet = sheet, skip = 1, col_names = FALSE),
      error = function(e) {
        warning("❌ Failed to read sheet: ", sheet, " — ", e$message)
        return(NULL)
      }
    )

    if (is.null(df) || ncol(df) < 3) {
      warning("⚠️ Skipping malformed sheet: ", sheet)
      return(NULL)
    }

    # Pad with NA columns if fewer than 5
    while (ncol(df) < 5) {
      df[[ncol(df) + 1]] <- NA
    }

    colnames(df)[1:5] <- c("variable", "type", "length", "format", "description")

    df <- df |>
      dplyr::mutate(file = sheet) |>
      dplyr::filter(!is.na(variable)) |>
      dplyr::filter(toupper(variable) != "VARIABLE") |>
      dplyr::select(file, variable, type, length, format, description)

    # Cells that wrap in the workbook hold line breaks inside names and
    # formats (603 names and 79 formats in the 2024 workbook), so those
    # variables never matched a data column or an Appendix C format (#18).
    fixed_names <- .remove_line_breaks(df$variable)
    new_duplicate <- duplicated(toupper(fixed_names)) &
      !duplicated(toupper(df$variable))
    if (any(new_duplicate)) {
      stop(
        "Removing line breaks gives duplicate variable names in sheet ",
        sheet, ": ", paste(unique(fixed_names[new_duplicate]), collapse = ", ")
      )
    }
    df$variable <- fixed_names
    df$format <- .remove_line_breaks(df$format)

    return(df)
  })

  return(b_metadata)
}


#' Remove line breaks left inside cell text by wrapping in Excel
#'
#' @param x A vector; anything other than character is returned unchanged.
#' @return `x` with every carriage return and line feed removed.
#' @noRd
.remove_line_breaks <- function(x) {
  if (!is.character(x)) {
    return(x)
  }
  gsub("[\r\n]", "", x)
}


#' Load USRDS Appendix C coding dictionaries
#'
#' Reads all sheets in Appendix C and combines them into a named list of
#' lookup tables (one per coded format).
#'
#' @param path Path to Appendix C Excel file
#' @return A named list of tibbles, one per format (e.g., "REMCD")
#' @noRd
.load_usrds_metadata_c <- function(path = "data-raw/USRDS_Res_Guide_Appendix_C_2024.xlsx") {
  sheets <- readxl::excel_sheets(path)

  all_dfs <- purrr::map(sheets, function(sheet) {
    message("📄 Reading sheet: ", sheet)

    df <- tryCatch(
      readxl::read_excel(path, sheet = sheet),
      error = function(e) {
        warning("❌ Failed to read sheet: ", sheet, " — ", e$message)
        return(NULL)
      }
    )

    if (is.null(df)) return(NULL)

    # Normalize column names (handle multi-line "Format\nName" cases)
    colnames(df) <- colnames(df) |>
      tolower() |>
      stringr::str_replace_all("[\\s\\n]+", " ") |>
      trimws()

    required_cols <- c("format name", "value", "description")
    if (!all(required_cols %in% colnames(df))) {
      warning("⚠️ Skipping sheet: ", sheet, " — missing required columns")
      return(NULL)
    }

    df <- df |>
      tidyr::fill(`format name`) |>
      dplyr::transmute(
        format_name = gsub("^\\$|\\.", "", trimws(as.character(`format name`))),
        value = trimws(as.character(value)),
        description = trimws(as.character(description))
      ) |>
      dplyr::filter(!is.na(value), !is.na(description))

    return(df)
  })

  format_map <- all_dfs |>
    purrr::compact() |>
    dplyr::bind_rows() |>
    dplyr::distinct() |>
    dplyr::group_split(format_name)

  names(format_map) <- purrr::map_chr(format_map, ~ unique(.x$format_name))

  return(format_map)
}


#' Get known non-factor formats (e.g., SAS display formats)
#'
#' These are formats like MMDDYY10., DATE9., BEST12. that do not represent categories
#' and should not be converted to factors.
#'
#' @return A character vector of known non-factor formats
#' @noRd
.known_nonfactor_formats <- function() {
  c(
    "MMDDYY10", "MMDDYY8", "DATE9", "BEST12", "CHAR10",
    "Z8", "Z9", "Z10", "TIME5", "COMMA8", "F8"
  )
}
