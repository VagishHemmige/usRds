# Suppress NOTE about unbound global vars (e.g., tidyverse pipelines)
utils::globalVariables(c(
  "%>%", "filter", "mutate", "select", "rename_with", "read_csv",
  "tibble", "inner_join", "case_when", "pmap", "bind_rows", "separate",
  "str_detect", "str_extract", "dmy", "all_of",
  "CLM_FROM", "CLM_THRU", "DIAG", "CODE", "HCPCS", "SPCLTY", "USRDS_ID", "Year",
  ".USRDS_wd", ".File_List_clean", ".File_List_csv_clean", ".File_List_csv_raw",
  ".File_List_sas_clean", ".File_List_sas_raw", "file_path", "file_name", "file_root"
))

#' @noRd
.onLoad <- function(libname, pkgname) {
  try(.map_USRDS_files(), silent = TRUE)
  options(arrow.skip_nul = TRUE)
}
