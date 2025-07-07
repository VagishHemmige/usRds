#' Set the USRDS working directory
#'
#' Sets the USRDS working directory for the current session, or optionally saves it permanently
#' in the user's `.Renviron` file as the environment variable `USRDS_WD`.
#'
#' @param path Path to the USRDS data folder
#' @param permanent Logical; if TRUE, appends the setting to `.Renviron` for persistence
#' @return The normalized path, invisibly
#' @export
#'
#' @examples
#' \dontrun{
#' set_USRDS_wd("C:/Data/USRDS")          # Session only
#' set_USRDS_wd("C:/Data/USRDS", TRUE)    # Persistent across sessions
#' }
set_USRDS_wd <- function(path, permanent = FALSE) {
  if (!dir.exists(path)) stop("Directory does not exist: ", path)
  normalized <- normalizePath(path, winslash = "/", mustWork = TRUE)

  # Set for current session
  Sys.setenv(USRDS_WD = normalized)

  if (permanent) {
    renv_path <- path.expand("~/.Renviron")
    line <- sprintf('USRDS_WD="%s"', normalized)

    if (!file.exists(renv_path)) {
      writeLines(line, renv_path)
      message("Created ~/.Renviron and added:\n", line)
    } else {
      renv <- readLines(renv_path)

      # Check if USRDS_WD already exists
      if (any(grepl("^USRDS_WD=", renv))) {
        # Replace existing line
        renv <- sub("^USRDS_WD=.*", line, renv)
        message("Updated USRDS_WD in ~/.Renviron:\n", line)
      } else {
        renv <- c(renv, line)
        message("Appended USRDS_WD to ~/.Renviron:\n", line)
      }

      writeLines(renv, renv_path)
    }

    message("Restart R or call `Sys.getenv(\"USRDS_WD\")` to confirm.")
  }

  # Call the mapper immediately after setting
  .map_USRDS_files()

  invisible(normalized)
}
