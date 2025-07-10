#' Parse and combine ICD-9 and ICD-10 codebooks
#'
#' Hidden internal function to return a combined lookup table for ICD codes.
#'
#' @return A tibble with columns: code, description, version
#' @noRd
.parse_icd_reference <- function(icd9_path, icd10_path) {
  icd9 <- readLines(icd9_path) |>
    stringr::str_trim() |>
    stringr::str_match("^([0-9VEC]+)\\s+(.*)$") |>
    as.data.frame() |>
    dplyr::select(code = V2, description = V3) |>
    dplyr::filter(!is.na(code)) |>
    dplyr::mutate(
      code = stringr::str_trim(code),
      description = stringr::str_trim(description),
      version = "ICD9"
    )

  icd10 <- readLines(icd10_path) |>
    stringr::str_trim() |>
    stringr::str_match("^(\\S+)\\s+(.*)$") |>
    as.data.frame() |>
    dplyr::select(code = V2, description = V3) |>
    dplyr::filter(!is.na(code)) |>
    dplyr::mutate(
      code = stringr::str_trim(code),
      description = stringr::str_trim(description),
      version = "ICD10"
    )

  dplyr::bind_rows(icd9, icd10)
}
