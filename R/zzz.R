# Names that neither pkg:: nor .data$/strings can express. Keep this list
# short: anything else should use pkg::fn(), .data$col or a string.
# dplyr's data-mask pronouns, used without importing them from rlang.
utils::globalVariables(c(".data", ".env"))

#' @noRd
.onLoad <- function(libname, pkgname) {
  if (nzchar(Sys.getenv("USRDS_WD"))) {
    try(.map_USRDS_files(quiet = TRUE), silent = TRUE)
  }
}

# Sets arrow.skip_nul = TRUE until the calling function exits, so strings
# with embedded nul characters do not stop a read. Scoped so loading usRds
# does not change Arrow's behaviour elsewhere in the session.
.local_arrow_options <- function(.local_envir = parent.frame()) {
  old <- options(arrow.skip_nul = TRUE)
  do.call(
    base::on.exit,
    list(bquote(options(.(old))), add = TRUE),
    envir = .local_envir
  )
  invisible(old)
}
