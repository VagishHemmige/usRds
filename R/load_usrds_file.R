#' Load a USRDS file and optionally apply labels
#'
#' This function loads a USRDS data file using the internal registry and optionally applies:
#' - Factor labels using format definitions from
#'   [Appendix C](https://www.niddk.nih.gov/about-niddk/strategic-plans-reports/usrds/for-researchers/researchers-guide)
#' - Variable labels using descriptions from
#'   [Appendix B](https://www.niddk.nih.gov/about-niddk/strategic-plans-reports/usrds/for-researchers/researchers-guide)
#'
#' All variable names are standardized to uppercase after loading.
#'
#' `col_select` supports tidyselect syntax for CSV and SAS files, and is also available for
#' Parquet files (resolved automatically to column names).
#'
#' @param file_key Character. File key (e.g., "PATIENTS", "RXHIST"). Case-insensitive match to registered file names.
#' @param factor_labels Logical. Whether to apply factor labels (from Appendix C). Default = TRUE.
#' @param var_labels Logical. Whether to apply variable labels (from Appendix B). Default = FALSE.
#' @param usrds_ids Optional. A vector of USRDS_IDs to retain in the file. Only applied if the file contains a `USRDS_ID` column.
#' @param col_select Optional. A character vector or tidyselect expression for selecting columns to load.
#' @param ... Additional arguments passed to the file reader (e.g., `as_factor` for `read_sas`)
#'
#' @return A tibble with the contents of the selected file, optionally labeled with factors and variable descriptions.
#' @export
#'
#' @examples
#' \dontrun{
#' # Load the PATIENTS file and apply factor labels (Appendix C)
#' df <- load_usrds_file("PATIENTS", factor_labels = TRUE)
#'
#' # Load the RXHIST file with both factor and variable labels
#' df <- load_usrds_file("RXHIST", factor_labels = TRUE, var_labels = TRUE)
#'
#' # Select only columns starting with "CD" (works for all file types)
#' df <- load_usrds_file("PATIENTS", col_select = dplyr::starts_with("CD"))
#'
#' # Load only specific columns by name
#' df <- load_usrds_file("PATIENTS", col_select = c("USRDS_ID", "CDEATH"))
#'
#' # Filter to a subset of USRDS_IDs
#' df <- load_usrds_file("RXHIST", usrds_ids = c("100000123", "100000456"))
#' }
load_usrds_file <- function(file_key,
                            factor_labels = TRUE,
                            var_labels = FALSE,
                            usrds_ids = NULL,
                            col_select = NULL,
                            ...) {
  # ---- Ensure file registry is initialized ----
  if (is.null(.usrds_env$file_list)) {
    stop("File list not initialized.")
  }

  # Standardize file key for lookup
  file_key_input <- toupper(file_key)

  # Lookup file metadata
  match <- .usrds_env$file_list |>
    dplyr::filter(toupper(.data$file_root) == file_key_input) |>
    dplyr::slice(1)

  if (nrow(match) == 0) {
    stop("File key '", file_key, "' not found.")
  }

  full_path <- match$file_path
  suffix <- tolower(match$file_suffix)

  if (!file.exists(full_path)) {
    stop("File not found: ", full_path)
  }

  # ---- Read the file ----
  df <- switch(
    suffix,
    "csv" = {
      readr::read_csv(full_path, col_select = col_select, ...)
    },
    "sas7bdat" = {
      haven::read_sas(full_path, col_select = col_select, ...)
    },
    "parquet" = {
      if (is.null(col_select)) {
        arrow::read_parquet(full_path, ...)
      } else {
        dummy <- arrow::open_dataset(full_path)$head(1) |> as.data.frame()
        selected_names <- tidyselect::eval_select(rlang::enquo(col_select), dummy) |> names()
        arrow::read_parquet(full_path, columns = selected_names, ...)
      }
    },
    stop("Unsupported file type: ", suffix)
  )

  # ---- Standardize column names to uppercase ----
  names(df) <- toupper(names(df))

  # ---- Filter by USRDS_ID if requested ----
  if (!is.null(usrds_ids)) {
    if (!"USRDS_ID" %in% names(df)) {
      warning("USRDS_ID not found in this file; skipping filter.")
    } else {
      df <- dplyr::filter(df, .data$USRDS_ID %in% usrds_ids)
    }
  }

  # ---- Apply factor labels from Appendix C ----
  if (factor_labels) {
    df <- apply_usrds_factors(df, file_key = match$file_root)
  }

  # ---- Apply variable labels from Appendix B ----
  if (var_labels) {
    df <- apply_usrds_varlabels(df, file_key = match$file_root)
  }

  return(df)
}
