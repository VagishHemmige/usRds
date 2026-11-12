.load_individual_file_PS_specialty <- function(
  file_path,
  file_root,
  file_suffix,
  Year,
  file_directory,
  specialtycodelist,
  variablelist
) {
  if (file_suffix == "csv") {
    temp <- readr::read_csv(file_path) |>
      dplyr::rename_with(toupper) |>
      dplyr::filter(.data$SPCLTY %in% .env$specialtycodelist) |>
      dplyr::select(dplyr::all_of(variablelist)) |>
      dplyr::mutate(CLM_FROM = lubridate::dmy(.data$CLM_FROM))
    return(temp)
  }

  if (file_suffix == "sas7bdat") {
    temp <- haven::read_sas(
      file_path,
      col_select = dplyr::all_of(variablelist)
    ) |>
      dplyr::rename_with(toupper) |>
      dplyr::filter(.data$SPCLTY %in% .env$specialtycodelist)
    return(temp)
  }

  if (file_suffix == "parquet") {
    temp <- arrow::read_parquet(file_path) |>
      dplyr::rename_with(toupper) |>
      dplyr::select(dplyr::all_of(variablelist)) |>
      dplyr::filter(.data$SPCLTY %in% .env$specialtycodelist) |>
      dplyr::mutate(CLM_FROM = lubridate::as_date(.data$CLM_FROM)) |>
      arrow::collect()
    return(temp)
  }
}


#' Extract PS specialty claims
#'
#' Returns claims filtered by specialty code from the PS HCPCS dataset.
#'
#' @param specialtycodelist A vector of specialty codes to keep.
#' @param yearlist A vector of years to include.
#' @param DIAG Logical, include DIAG column.
#' @param HCPCS Logical, include HCPCS column.
#' @param PLCSRV Logical, include PLCSRV column.
#'
#' @return A tibble with filtered and selected PS HCPCS data.
#' @export

get_PS_specialty <- function(
  specialtycodelist,
  yearlist,
  DIAG = FALSE,
  HCPCS = FALSE,
  PLCSRV = FALSE
) {
  variablelist <- c("USRDS_ID", "CLM_FROM", "SPCLTY")

  if (DIAG == TRUE) {
    variablelist <- c(variablelist, "DIAG")
  }

  if (HCPCS == TRUE) {
    variablelist <- c(variablelist, "HCPCS")
  }

  if (PLCSRV == TRUE) {
    variablelist <- c(variablelist, "PLCSRV")
  }

  .usrds_env$file_list |>
    dplyr::inner_join(PS_HCPCS, by = c("file_root", "Year")) |>
    dplyr::filter(.data$Year %in% .env$yearlist) |>
    dplyr::select(-"file_name") |>
    purrr::pmap(
      .load_individual_file_PS_specialty,
      specialtycodelist = specialtycodelist,
      variablelist = variablelist
    ) |>
    dplyr::bind_rows()
}
