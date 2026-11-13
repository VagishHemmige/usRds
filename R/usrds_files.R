#' List the USRDS files mapped by `set_USRDS_wd()`
#'
#' Returns what [set_USRDS_wd()] found when it last mapped the USRDS folder:
#' the files the package reads, and the files it set aside or flagged.
#'
#' @param which Which list to return:
#'   * `"mapped"`: the files the package reads, one per file and year.
#'   * `"other_formats"`: copies in another format that were set aside
#'     because of `format_preference`.
#'   * `"unrecognised"`: files whose names usRds does not recognise as
#'     USRDS files. Most are usually your own files; a USRDS file listed here
#'     would never be read.
#'   * `"unread_duplicates"`: files with more than one copy in a format that
#'     is not being read.
#'   * `"incomplete"`: years where only part of a claim-file group is present,
#'     with the missing files in the `missing` list column.
#'
#' @return A tibble.
#' @export
#'
#' @examples
#' \dontrun{
#' set_USRDS_wd("C:/Data/USRDS")
#' usrds_files()
#' usrds_files("unrecognised")
#' }
usrds_files <- function(
  which = c(
    "mapped",
    "other_formats",
    "unrecognised",
    "unread_duplicates",
    "incomplete"
  )
) {
  which <- rlang::arg_match(which)
  if (is.null(.usrds_env$file_list)) {
    cli::cli_abort(c(
      "No USRDS files are mapped yet.",
      "i" = "Run {.code set_USRDS_wd(\"<your USRDS folder>\")} first."
    ))
  }
  switch(
    which,
    mapped = .usrds_env$file_list,
    other_formats = dplyr::anti_join(
      .usrds_env$file_inventory,
      .usrds_env$file_list,
      by = "file_path"
    ),
    unrecognised = .usrds_env$unrecognised,
    unread_duplicates = .usrds_env$unread_duplicates,
    incomplete = .usrds_env$incomplete
  )
}
