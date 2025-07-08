#' Check that requested years are available for a given set of file roots
#'
#' Internal utility function to validate that all requested years are present
#' in `.usrds_env$file_list` for a specified subset of file roots (typically
#' coming from lookup tables like PS_ICD or IN_HCPCS).
#'
#' This ensures the user is not requesting data from years that are not
#' physically present on disk or in the working environment.
#'
#' @param years A numeric vector of requested calendar years.
#' @param file_keys A character vector of file_root values (not file_key) to restrict the check to.
#' @param label Optional. A string label used in the error message to indicate which function failed.
#'
#' @return NULL if all years are valid. Otherwise, an error is thrown.
#' @noRd
.check_valid_years <- function(years, file_keys, label = "requested files") {
  # Ensure file_keys is not missing or empty
  if (missing(file_keys) || length(file_keys) == 0) {
    stop("file_keys must be a non-empty character vector of file_root values.")
  }

  # Extract the list of available years from file_list for the specified file_roots
  available_years <- .usrds_env$file_list %>%
    dplyr::filter(file_root %in% file_keys) %>%
    dplyr::pull(Year) %>%
    unique()

  # Identify which requested years are not available
  invalid_years <- setdiff(years, available_years)

  # If any are invalid, stop with a message
  if (length(invalid_years) > 0) {
    stop("The following years are not available for ", label, ": ",
         paste(invalid_years, collapse = ", "))
  }

  invisible(NULL)
}
