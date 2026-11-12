#' Apply SRTR variable labels to a data frame
#'
#' Adds descriptive variable labels to a dataset using the SRTR SAF data
#' dictionary from the 'sRtr' package, which must be installed. 'sRtr' also
#' has its own `sRtr::apply_srtr_varlabels()`, which can infer the dataset
#' from a file loaded with `sRtr::load_srtr_file()`.
#'
#' @param df A data frame from a SAF file (e.g., CAND_KIPA, TX_KI).
#' @param dataset_key Character. The dataset name used in the SRTR dictionary (e.g., "CAND_KIPA").
#' @param verbose Logical. If TRUE, prints each variable being labeled.
#'
#' @return A data frame with variable labels added (invisible via print, viewable via `labelled::var_label()`).
#' @export
#'
#' @examplesIf rlang::is_installed("sRtr")
#' df <- data.frame(CAN_ABO = c("A", "O"))
#' df <- apply_srtr_varlabels(df, dataset_key = "CAND_KIPA")
#' labelled::var_label(df$CAN_ABO)
apply_srtr_varlabels <- function(df, dataset_key, verbose = FALSE) {
  dictionary <- .srtr_dictionary()

  df_names_upper <- toupper(names(df))

  vars_to_label <- dictionary |>
    dplyr::filter(.data$Dataset == .env$dataset_key) |>
    dplyr::mutate(
      variable_upper = toupper(.data$Variable)
    ) |>
    dplyr::filter(.data$variable_upper %in% .env$df_names_upper)

  if (nrow(vars_to_label) == 0) {
    if (verbose) {
      message("No variable labels applied for ", dataset_key)
    }
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

#' Is the sRtr package installed?
#' @noRd
.srtr_available <- function() {
  requireNamespace("sRtr", quietly = TRUE)
}

#' The SRTR data dictionary from sRtr, or an error saying how to install it
#' @noRd
.srtr_dictionary <- function() {
  if (!.srtr_available()) {
    rlang::abort(
      c(
        "Labelling SRTR data needs the sRtr package, which is not installed.",
        i = "Install it with `pak::pak(\"VagishHemmige/sRtr\")`."
      ),
      class = "usRds_error_missing_srtr"
    )
  }
  sRtr::dictionary
}
