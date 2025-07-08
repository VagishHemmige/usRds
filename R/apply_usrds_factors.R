#' Apply USRDS factor labels to a data frame
#'
#' Given a loaded USRDS dataset and the corresponding file key (e.g., "PATIENTS", "RXHIST"),
#' this function uses internal metadata to convert numerically coded variables to factors
#' using value mappings from Appendix C of the USRDS Researcher's Guide.
#'
#' Variable formats are looked up from Appendix B. Only variables with formats beginning
#' with a dollar sign (e.g., $REMCD.) and present in the dataset will be converted.
#'
#' @param df A data frame loaded from a USRDS file.
#' @param file_key Character. The canonical file key (e.g., "PATIENTS").
#' @param verbose Logical. If TRUE, print each variable being labeled.
#'
#' @return A data frame with factor variables applied where applicable.
#' @export
#'
#' @importFrom labelled var_label var_label<-
#' @importFrom rlang enquo
#' @importFrom tidyselect eval_select
#' @importFrom tibble tibble
#'
#' @examples
#' \dontrun{
#' df <- load_usrds_file("PATIENTS", factor_labels = TRUE)
#' }
apply_usrds_factors <- function(df, file_key, verbose = FALSE) {
  if (!exists("metadata_b", envir = .GlobalEnv) ||
      !exists("metadata_c", envir = .GlobalEnv)) {
    stop("metadata_b and metadata_c must exist in the global environment or namespace.")
  }

  # Normalize column names
  df_names_upper <- toupper(names(df))

  # Find variables in Appendix B that are formatted as coded (e.g., $FORMAT.)
  vars_to_code <- metadata_b |>
    dplyr::filter(file == toupper(file_key), grepl("\\.$", format)) |>
    dplyr::mutate(
      format_clean = gsub("^\\$|\\.", "", format),
      variable_upper = toupper(variable)
    ) |>
    dplyr::filter(!format_clean %in% .known_nonfactor_formats()) |>
    dplyr::filter(variable_upper %in% df_names_upper)

  if (nrow(vars_to_code) == 0) {
    if (verbose) message("No variables to label for ", file_key)
    return(df)
  }

  # Loop through each match and apply factor conversion
  for (i in seq_len(nrow(vars_to_code))) {
    var_upper <- vars_to_code$variable_upper[i]
    fmt <- vars_to_code$format_clean[i]
    var_match <- names(df)[toupper(names(df)) == var_upper][1]

    if (fmt %in% names(metadata_c)) {
      code_map <- metadata_c[[fmt]]
      code_vec <- stats::setNames(code_map$description, code_map$value)

      df[[var_match]] <- factor(as.character(df[[var_match]]),
                                levels = names(code_vec),
                                labels = code_vec)

      if (verbose) {
        message("Labeled variable: ", var_match, " with format: ", fmt)
      }
    } else {
      if (verbose) {
        message("Unmapped format for variable: ", var_match, " (", fmt, ")")
      }
    }
  }

  return(df)
}

#' Internal helper: known non-factor formats (e.g., dates)
#' @noRd
.known_nonfactor_formats <- function() {
  c("MMDDYY10", "MMDDYY8", "DATE10", "YYMMDD8", "TIME", "DATETIME")
}
