# Names that neither pkg:: nor .data$/strings can express. Keep this list
# short: anything else should use pkg::fn(), .data$col or a string.
utils::globalVariables(c(
  # dplyr data-mask pronouns, used without importing them from rlang
  ".data", ".env",
  # survival::tmerge() evaluates these itself (create_usrds_cohort())
  "USRDS_ID", "tstart", "tstop",
  # dplyr::join_by() takes bare column names (verify_medicare_primary())
  ".index_date", "usrds_package_medicare_begdate", "usrds_package_medicare_enddate"
))

#' @noRd
.onLoad <- function(libname, pkgname) {
  try(.map_USRDS_files(), silent = TRUE)
  options(arrow.skip_nul = TRUE)
}
