# Names that neither pkg:: nor .data$/strings can express. Keep this list
# short: anything else should use pkg::fn(), .data$col or a string.
# dplyr's data-mask pronouns, used without importing them from rlang.
utils::globalVariables(c(".data", ".env"))

#' @noRd
.onLoad <- function(libname, pkgname) {
  try(.map_USRDS_files(), silent = TRUE)
  options(arrow.skip_nul = TRUE)
}
