#' Apply SRTR variable labels to a data frame
#'
#' Adds descriptive variable labels to a dataset using the SRTR SAF data dictionary.
#'
#' @param df A data frame from a SAF file (e.g., CAND_KIPA, TX_KI).
#' @param dataset_key Character. The dataset name used in the SRTR dictionary (e.g., "CAND_KIPA").
#' @param verbose Logical. If TRUE, prints each variable being labeled.
#'
#' @return A data frame with variable labels added (invisible via print, viewable via `labelled::var_label()`).
#' @export
#'
#' @importFrom labelled var_label var_label<-
#'
#' @examples
#' \dontrun{
#' df <- read.csv("CAND_KIPA.parquet")
#' df <- apply_srtr_varlabels(df, dataset_key = "CAND_KIPA", verbose = TRUE)
#' labelled::var_label(df$ABO)
#' }
apply_srtr_varlabels <- function(df, dataset_key, verbose = FALSE) {
  dictionary <- srtrDataDict::dictionary

  df_names_upper <- toupper(names(df))

  vars_to_label <- dictionary |>
    dplyr::filter(Dataset == dataset_key) |>
    dplyr::mutate(
      variable_upper = toupper(Variable)
    ) |>
    dplyr::filter(variable_upper %in% df_names_upper)

  if (nrow(vars_to_label) == 0) {
    if (verbose) message("No variable labels applied for ", dataset_key)
    return(df)
  }

  for (i in seq_len(nrow(vars_to_label))) {
    var_upper <- vars_to_label$variable_upper[i]
    label_text <- vars_to_label$Label[i]
    var_match <- names(df)[toupper(names(df)) == var_upper][1]

    labelled::var_label(df[[var_match]]) <- label_text

    if (verbose) {
      message("Labeled variable: ", var_match, " - ", label_text)
    }
  }

  return(df)
}
