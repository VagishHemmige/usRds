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
