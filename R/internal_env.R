#' Internal environment for package-level state
#'
#' This environment is used to store internal session-specific state,
#' such as the file list loaded from `map_USRDS_files()`. It is not
#' exported and should not be accessed directly by users.
#'
#' @keywords internal
.usrds_env <- new.env(parent = emptyenv())

