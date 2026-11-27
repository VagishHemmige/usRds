#' Set the USRDS working directory
#'
#' Sets the USRDS working directory for the current session, or optionally saves it permanently
#' in the user's `.Renviron` file as the environment variable `USRDS_WD`, then
#' maps the USRDS files found there.
#'
#' The map keeps one file per USRDS file and year. Files are recognised by
#' name (the file names in Appendix B and the package's claim-file tables),
#' wherever they sit under `path`, without regard to case. Files with other
#' names are counted and set aside ([usrds_files()] lists them). Folders
#' named in `exclude` are skipped.
#'
#' **Which copy is read.** For each file and year, the first format in
#' `format_preference` that is present is read by every function that reads
#' that file, and copies in other formats are only reported. So a CSV export
#' next to a Parquet file is harmless, but two copies in the format that
#' will be read (for example a second `ps2015a.parquet` in a backup folder)
#' are an error, because reading both would count their claims twice. The
#' error lists the copies; `usrds_files("duplicates")` lists all of them, even
#' after the error. Move the extra copies out of `path`, or skip their
#' folders with `exclude`. usRds never chooses between same-format copies
#' itself.
#'
#' If only part of a year's group of claim files is present (for
#' example some, but not all, of the 2007 institutional files), the years and
#' missing files are reported.
#'
#' @param path Path to the USRDS data folder
#' @param permanent Logical; if TRUE, appends the setting to `.Renviron` for persistence
#' @param format_preference Character vector of formats to use, most preferred
#'   first: any of `"parquet"`, `"sas7bdat"` and `"csv"`. Formats left out are
#'   ignored. Applies for the rest of the session.
#' @param on_incomplete What to do when only part of a year's claim-file group
#'   is present: `"warn"` (the default) or `"error"`.
#' @param exclude Names of folders to skip, anywhere under `path`, compared
#'   without regard to case with each folder in a file's path: `"backup"`
#'   skips `old/Backup/ps2015a.parquet` but not `backups/ps2015a.parquet`.
#'   Files directly in `path` are never skipped. The default,
#'   `getOption("usRds.exclude")`, lets you set it once in a project's
#'   `.Rprofile`, for example `options(usRds.exclude = c("backup", "old"))`,
#'   so it also applies when usRds maps the folder on loading. An explicit
#'   value replaces the option; `character()` skips nothing. Applies for the
#'   rest of the session.
#' @return The normalized path, invisibly
#' @export
#'
#' @examples
#' \dontrun{
#' set_USRDS_wd("C:/Data/USRDS")          # Session only
#' set_USRDS_wd("C:/Data/USRDS", TRUE)    # Persistent across sessions
#'
#' # Skip folders that hold stray copies
#' set_USRDS_wd("C:/Data/USRDS", exclude = c("backup", "old exports"))
#' usrds_files("excluded")
#'
#' # Use SAS files where both SAS and Parquet exist
#' set_USRDS_wd("C:/Data/USRDS", format_preference = c("sas7bdat", "parquet"))
#' }
set_USRDS_wd <- function(
  path,
  permanent = FALSE,
  format_preference = c("parquet", "sas7bdat", "csv"),
  on_incomplete = c("warn", "error"),
  exclude = getOption("usRds.exclude", character())
) {
  format_preference <- .check_format_preference(format_preference)
  exclude <- .check_exclude(exclude)
  on_incomplete <- rlang::arg_match(on_incomplete)
  if (!dir.exists(path)) {
    stop("Directory does not exist: ", path)
  }
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

  .usrds_env$format_preference <- format_preference
  .usrds_env$exclude <- exclude
  .map_USRDS_files(
    format_preference = format_preference,
    exclude = exclude,
    on_incomplete = on_incomplete
  )

  invisible(normalized)
}
