#' Apply USRDS variable labels to a data frame
#'
#' Adds descriptive variable labels using Appendix B of the USRDS Researcher's Guide.
#' Variable labels are applied using the `labelled` package.
#'
#' @param df A data frame loaded from a USRDS file.
#' @param file_key Character. The canonical file key (e.g., "PATIENTS").
#' @param verbose Logical. If TRUE, prints each variable being labeled.
#'
#' @return A data frame with variable labels added (invisible via print, viewable via `labelled::var_label()`).
#' @export
#'
#' @importFrom labelled var_label var_label<-
#'
#' @examples
#' \dontrun{
#' df <- load_usrds_file("PATIENTS", var_labels = TRUE)
#' labelled::var_label(df$CDEATH)
#' }
apply_usrds_varlabels <- function(df, file_key, verbose = FALSE) {
  if (!exists("metadata_b", envir = .GlobalEnv)) {
    stop("metadata_b must exist in the global environment or namespace.")
  }

  df_names_upper <- toupper(names(df))

  vars_to_label <- metadata_b |>
    dplyr::filter(file == toupper(file_key)) |>
    dplyr::mutate(
      variable_upper = toupper(variable)
    ) |>
    dplyr::filter(variable_upper %in% df_names_upper)

  if (nrow(vars_to_label) == 0) {
    if (verbose) message("No variable labels applied for ", file_key)
    return(df)
  }

  for (i in seq_len(nrow(vars_to_label))) {
    var_upper <- vars_to_label$variable_upper[i]
    label_text <- vars_to_label$description[i]
    var_match <- names(df)[toupper(names(df)) == var_upper][1]

    labelled::var_label(df[[var_match]]) <- label_text

    if (verbose) {
      message("Labeled variable: ", var_match, " - ", label_text)
    }
  }

  return(df)
}
