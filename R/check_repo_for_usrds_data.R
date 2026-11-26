#' Check a project folder for files that look like USRDS data
#'
#' Scans a project folder, usually a git repository, for files that look
#' like patient-level USRDS data, so they can be removed or ignored before
#' they are committed or shared. USRDS data are covered by a data use
#' agreement: a private repository is still a disclosure.
#'
#' A file is reported when it is:
#' * a data file type: `.sas7bdat`, `.sas7bcat`, `.xpt`, `.parquet`,
#'   `.feather`, `.arrow`, `.dta` or `.sav`;
#' * named like a USRDS file (an Appendix B file name, with any year, or a
#'   claim file the package reads), with a `.csv`, `.tsv`, `.txt`, `.rds`,
#'   `.rda`, `.rdata`, `.xls` or `.xlsx` extension; or
#' * a `.csv`, `.tsv` or `.txt` file whose header line has a column in
#'   `id_columns` (case ignored).
#'
#' Inside a git repository, the files checked are those git would commit:
#' tracked files, and untracked files that `.gitignore` does not exclude. A
#' file git already tracks is checked even if `.gitignore` lists it.
#' Outside one, or when git is not installed, every file under `path` is
#' checked, apart from the `.git` folder. Files under
#' `tests/testthat/fixtures/` whose names start with `synthetic-` are
#' skipped, as made-up test data.
#'
#' The check is read-only. It reads file names, and the first line of
#' `.csv`, `.tsv` and `.txt` files to find column names. It does not read
#' any other content, and it reports paths only.
#'
#' A clean result does not make a folder safe: data can sit in files with
#' other names or formats. See the article "Data protection and security"
#' on the package website.
#'
#' @param path The project folder to check. Defaults to the working
#'   directory.
#' @param id_columns Column names that identify a patient. A text file whose
#'   header has any of them is reported. The default is `"USRDS_ID"`; add
#'   SRTR identifiers such as `"PX_ID"` or `"PERS_ID"` when the project also
#'   uses SRTR data.
#' @param quiet If `TRUE`, nothing is printed.
#'
#' @return A data frame with one row per file reported and columns `path`
#'   (relative to `path`) and `reason`, invisibly. Its `scan` attribute is
#'   `"git"` or `"folder"`, saying which list of files was checked.
#' @export
#'
#' @examples
#' project <- tempfile("project")
#' dir.create(project)
#' writeLines(c("USRDS_ID,age", "1,50"), file.path(project, "cohort.csv"))
#' writeLines("x <- 1", file.path(project, "analysis.R"))
#' check_repo_for_usrds_data(project)
#' unlink(project, recursive = TRUE)
check_repo_for_usrds_data <- function(
  path = ".",
  id_columns = "USRDS_ID",
  quiet = FALSE
) {
  if (!is.character(path) || length(path) != 1 || is.na(path)) {
    cli::cli_abort("{.arg path} must be a single folder path.")
  }
  if (!dir.exists(path)) {
    cli::cli_abort(c(
      "Folder {.path {path}} does not exist.",
      "i" = "Give the project folder to check."
    ))
  }
  if (!is.character(id_columns) || length(id_columns) == 0 || anyNA(id_columns)) {
    cli::cli_abort("{.arg id_columns} must be a character vector of column names.")
  }
  if (!is.logical(quiet) || length(quiet) != 1 || is.na(quiet)) {
    cli::cli_abort("{.arg quiet} must be TRUE or FALSE.")
  }

  listing <- .project_files(path)
  files <- listing$files
  files <- files[!grepl(
    "^tests/testthat/fixtures/(.*/)?synthetic-[^/]*$",
    files
  )]

  reasons <- vapply(
    files,
    function(file) .usrds_data_reason(file, path, id_columns),
    character(1),
    USE.NAMES = FALSE
  )
  found <- !is.na(reasons)
  result <- data.frame(
    path = files[found],
    reason = reasons[found],
    stringsAsFactors = FALSE
  )
  result <- result[order(result$path), , drop = FALSE]
  rownames(result) <- NULL
  attr(result, "scan") <- listing$scan

  if (!quiet) {
    scope <- if (listing$scan == "git") {
      "files git would commit"
    } else {
      "all files (not a git repository, or git not found)"
    }
    if (nrow(result) == 0) {
      cli::cli_inform(c(
        "v" = "No files that look like USRDS data in {.path {path}}.",
        "i" = "Checked {length(files)} file{?s}: {scope}."
      ))
    } else {
      # Braces in file names would be read as cli expressions; double them
      # so each name prints as it is.
      lines <- gsub("([{}])", "\\1\\1", paste0(result$path, ": ", result$reason))
      names(lines) <- rep("*", length(lines))
      cli::cli_warn(c(
        "{nrow(result)} file{?s} in {.path {path}} may be USRDS data:",
        lines,
        "i" = "Checked {scope}.",
        "i" = "Move these files outside the project, or list untracked ones in {.file .gitignore}.",
        "i" = "{.file .gitignore} does not stop git tracking a file it already tracks; remove such files from git with {.code git rm --cached <file>}. Data already pushed needs separate remediation."
      ))
    }
  }

  invisible(result)
}

# Files to check, relative to `path`, and which listing produced them.
.project_files <- function(path) {
  git <- Sys.which("git")
  if (nzchar(git)) {
    inside <- suppressWarnings(system2(
      git,
      c("-C", shQuote(path), "rev-parse", "--is-inside-work-tree"),
      stdout = TRUE,
      stderr = FALSE
    ))
    if (identical(inside, "true")) {
      # -z gives each path exactly, separated by NUL bytes; without it, git
      # quotes paths with unusual characters. Paths are relative to `path`.
      listing <- tempfile("usrds-ls-files-")
      on.exit(unlink(listing), add = TRUE)
      status <- suppressWarnings(system2(
        git,
        c(
          "-C", shQuote(path), "ls-files", "-z", "--cached", "--others",
          "--exclude-standard", "--", "."
        ),
        stdout = listing,
        stderr = FALSE
      ))
      if (identical(as.integer(status), 0L)) {
        return(list(files = .split_nul(listing), scan = "git"))
      }
    }
  }
  files <- list.files(path, recursive = TRUE, all.files = TRUE, no.. = TRUE)
  files <- files[!grepl("(^|/)\\.git/", files)]
  list(files = files, scan = "folder")
}

# The NUL-separated UTF-8 paths in `file`.
.split_nul <- function(file) {
  bytes <- readBin(file, "raw", n = file.size(file))
  if (length(bytes) == 0) {
    return(character())
  }
  ends <- which(bytes == as.raw(0))
  starts <- c(1L, utils::head(ends, -1L) + 1L)
  paths <- mapply(
    function(from, to) rawToChar(bytes[seq.int(from, length.out = to - from)]),
    starts,
    ends,
    USE.NAMES = FALSE
  )
  Encoding(paths) <- "UTF-8"
  unique(paths)
}

.usrds_data_types <- c(
  "sas7bdat", "sas7bcat", "xpt", "parquet", "feather", "arrow", "dta", "sav"
)
.usrds_named_types <- c(
  "csv", "tsv", "txt", "rds", "rda", "rdata", "xls", "xlsx"
)
.usrds_header_types <- c("csv", "tsv", "txt")

# Why `file` looks like USRDS data, or NA.
.usrds_data_reason <- function(file, path, id_columns) {
  extension <- tolower(tools::file_ext(file))
  if (extension %in% .usrds_data_types) {
    return(paste0("data file type (.", extension, ")"))
  }
  if (extension %in% .usrds_named_types) {
    root <- tolower(tools::file_path_sans_ext(basename(file)))
    if (.is_usrds_file(root)) {
      return("USRDS file name")
    }
  }
  if (extension %in% .usrds_header_types) {
    header <- .header_columns(file.path(path, file))
    hit <- id_columns[toupper(id_columns) %in% toupper(header)]
    if (length(hit) > 0) {
      return(paste0("identifier column (", paste(hit, collapse = ", "), ")"))
    }
  }
  NA_character_
}

# Column names from the first line of a delimited text file.
.header_columns <- function(file) {
  # Unreadable files (deleted but still tracked, locked, no permission) have
  # no header to check.
  first <- tryCatch(
    suppressWarnings(readLines(file, n = 1, warn = FALSE, encoding = "UTF-8")),
    error = function(e) character()
  )
  if (length(first) == 0) {
    return(character())
  }
  first <- sub("^\ufeff", "", first)
  columns <- strsplit(first, "[,\t;|]")[[1]]
  trimws(gsub("[\"']", "", columns))
}
