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
#'   * `"duplicates"`: every copy of a file that has more than one copy in
#'     the format being read, one row per copy. These stop
#'     [set_USRDS_wd()]; move the extra copies or skip their folders with
#'     `exclude`.
#'   * `"excluded"`: files skipped because they sit in a folder named in
#'     `exclude`.
#'
#' `"unrecognised"`, `"duplicates"` and `"excluded"` describe the latest
#' scan even when it stopped with an error, so you can see why. After a stop
#' on same-format copies, no files are mapped and the other lists are not
#' available. After a stop on an incomplete claim-file group
#' (`on_incomplete = "error"`), the files found are still mapped and can be
#' read, so check `usrds_files("incomplete")` before using them.
#'
#' @return A tibble. Paths in `relative_path` are relative to the USRDS
#'   folder.
#' @export
#'
#' @examples
#' \dontrun{
#' set_USRDS_wd("C:/Data/USRDS")
#' usrds_files()
#' usrds_files("unrecognised")
#' usrds_files("duplicates")
#' }
usrds_files <- function(
  which = c(
    "mapped",
    "other_formats",
    "unrecognised",
    "unread_duplicates",
    "incomplete",
    "duplicates",
    "excluded"
  )
) {
  which <- rlang::arg_match(which)
  scan_reports <- c("unrecognised", "duplicates", "excluded")
  if (which %in% scan_reports && isTRUE(.usrds_env$scanned)) {
    return(switch(
      which,
      unrecognised = .usrds_env$unrecognised,
      duplicates = .duplicate_copies(.usrds_env$duplicates),
      excluded = .usrds_env$excluded
    ))
  }
  if (is.null(.usrds_env$file_list)) {
    if (isTRUE(.usrds_env$scanned)) {
      cli::cli_abort(c(
        "No USRDS files are mapped: the last scan of the USRDS folder
        stopped with an error.",
        "i" = "See why with {.run usRds::usrds_files(\"duplicates\")},
        {.run usRds::usrds_files(\"excluded\")} or
        {.run usRds::usrds_files(\"unrecognised\")}, then call
        {.fn set_USRDS_wd} again with your USRDS folder and {.arg exclude}."
      ))
    }
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

# One row per copy, from the grouped copies the file map stores.
.duplicate_copies <- function(groups) {
  if (is.null(groups) || nrow(groups) == 0) {
    return(tibble::tibble(
      file_name = character(),
      Year = numeric(),
      file_suffix = character(),
      relative_path = character()
    ))
  }
  tibble::tibble(
    file_name = rep(groups$file_name, lengths(groups$paths)),
    Year = rep(groups$Year, lengths(groups$paths)),
    file_suffix = rep(groups$file_suffix, lengths(groups$paths)),
    relative_path = unlist(groups$paths, use.names = FALSE)
  )
}
