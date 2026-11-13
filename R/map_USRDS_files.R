#' Internal: Map USRDS data files in the working directory
#'
#' Scans the directory set by the USRDS_WD environment variable and stores
#' one row per USRDS file in the package's internal environment.
#'
#' Files are recognised by name, wherever they sit under USRDS_WD: the file
#' names in Appendix B (with any year in the name standing for every year)
#' and the claim files in the package's internal tables. Names and
#' extensions are matched without regard to case. Files with other names are
#' counted and set aside. Folders ending in `_chunks` (left by an interrupted
#' Parquet conversion) are ignored. When a file exists in more than one format, the
#' first format in `format_preference` is kept. Two copies of a file in the
#' same format are an error. Claim-file groups that are only partly present
#' for a year are reported, or are an error when `on_incomplete = "error"`.
#'
#' @param format_preference Formats to use, most preferred first.
#' @param on_incomplete What to do when only part of a year's file group is
#'   present: `"warn"` or `"error"`.
#' @param quiet If `TRUE`, the summary message and the incomplete-group
#'   warning are not shown. Errors are still raised.
#'
#' @return The file list, invisibly.
#' @keywords internal
#' @noRd
.map_USRDS_files <- function(
  format_preference = .usrds_env$format_preference,
  on_incomplete = c("warn", "error"),
  quiet = FALSE
) {
  on_incomplete <- rlang::arg_match(on_incomplete)
  if (is.null(format_preference)) {
    format_preference <- .usrds_formats
  }
  format_preference <- .check_format_preference(format_preference)

  # Clear the previous map first, so a failed mapping never leaves another
  # folder's files in place.
  .usrds_env$file_list <- NULL
  .usrds_env$file_inventory <- NULL
  .usrds_env$incomplete <- NULL
  .usrds_env$unrecognised <- NULL

  USRDS_wd <- Sys.getenv("USRDS_WD")
  if (USRDS_wd == "") {
    cli::cli_abort(c(
      "{.envvar USRDS_WD} is not set.",
      "i" = "Run {.code set_USRDS_wd(\"<your USRDS folder>\")}."
    ))
  }

  relative_paths <- list.files(
    path = USRDS_wd,
    pattern = "\\.(csv|sas7bdat|parquet)$",
    recursive = TRUE,
    ignore.case = TRUE
  )
  relative_paths <- relative_paths[
    !grepl("_chunks(/|$)", dirname(relative_paths), ignore.case = TRUE)
  ]

  inventory <- tibble::tibble(
    file_path = file.path(USRDS_wd, relative_paths),
    file_name = basename(relative_paths),
    file_root = tolower(tools::file_path_sans_ext(basename(relative_paths))),
    file_suffix = tolower(tools::file_ext(relative_paths)),
    Year = as.numeric(stringr::str_extract(
      tools::file_path_sans_ext(basename(relative_paths)),
      "20[0-9]{2}"
    )),
    file_directory = .usrds_folder(dirname(relative_paths))
  )
  recognised <- .is_usrds_file(inventory$file_root)
  unrecognised <- inventory[!recognised, ]
  inventory <- inventory[recognised, ]
  .usrds_env$unrecognised <- unrecognised

  if (nrow(inventory) == 0) {
    bullets <- c(
      "No USRDS files found in {.file {USRDS_wd}}.",
      "i" = "Files must be {.file .csv}, {.file .sas7bdat} or {.file .parquet},
             named as in the USRDS delivery (for example
             {.file patients.sas7bdat} or {.file ps2010a.csv})."
    )
    if (nrow(unrecognised) > 0) {
      shown <- utils::head(unrecognised$file_name, 5)
      bullets <- c(
        bullets,
        "i" = "{nrow(unrecognised)} file{?s} with {?a name/names} usRds does
               not recognise {?was/were} set aside, for example
               {.file {shown}}."
      )
    }
    cli::cli_abort(bullets)
  }

  .check_same_format_copies(inventory)

  ranked <- inventory |>
    dplyr::mutate(
      .rank = match(.data$file_suffix, .env$format_preference)
    )
  file_list <- ranked |>
    dplyr::filter(!is.na(.data$.rank)) |>
    dplyr::arrange(.data$.rank) |>
    dplyr::distinct(
      .data$file_root,
      .data$Year,
      .keep_all = TRUE
    ) |>
    dplyr::select(
      "file_path",
      "file_name",
      "file_root",
      "file_suffix",
      "Year",
      "file_directory"
    ) |>
    dplyr::arrange(.data$file_root, .data$Year)

  incomplete <- .find_incomplete_groups(file_list)

  .usrds_env$file_list <- file_list
  .usrds_env$file_inventory <- inventory
  .usrds_env$incomplete <- incomplete

  if (!quiet) {
    .report_file_map(inventory, file_list, unrecognised, format_preference)
  }
  if (nrow(incomplete) > 0) {
    .report_incomplete_groups(incomplete, on_incomplete, quiet)
  }

  invisible(file_list)
}

# Formats the package can read, in the default order of preference.
.usrds_formats <- c("parquet", "sas7bdat", "csv")

# Folder names in the USRDS delivery. They are not needed to find a file;
# when one appears in a file's path (any case), its short name is stored in
# `file_directory` for reference.
.usrds_folders <- c(
  "ESRD Core" = "Core",
  "ESRD transplant" = "Transplant",
  "ESRD hospital" = "Hospital",
  "ESRD PartD" = "Part D",
  "ESRD Institution" = "Institution",
  "Physician supplier" = "PS"
)

# Claim-file lookups (internal tables listing which files make up each
# year's group) and the functions that read them, for messages.
.usrds_file_groups <- c(
  IN_ICD = "get_IN_ICD()",
  IN_HCPCS = "get_IN_HCPCS()",
  IN_CLM_COSTS = "get_IN_CLM_costs()",
  IN_REV_COSTS = "get_IN_REV_costs()",
  PS_ICD = "get_PS_ICD()",
  PS_HCPCS = "get_PS_HCPCS() and get_PS_specialty()",
  PS_CLM_COSTS = "get_PS_CLM_costs()",
  PS_REV_COSTS = "get_PS_REV_costs()",
  PDE = "Part D files"
)

.check_format_preference <- function(
  format_preference,
  arg = "format_preference",
  call = rlang::caller_env()
) {
  if (
    !is.character(format_preference) ||
      length(format_preference) == 0 ||
      anyNA(format_preference)
  ) {
    cli::cli_abort(
      "{.arg {arg}} must be a character vector of file formats.",
      call = call
    )
  }
  format_preference <- tolower(format_preference)
  unknown <- setdiff(format_preference, .usrds_formats)
  if (length(unknown) > 0) {
    cli::cli_abort(
      c(
        "{.arg {arg}} has unknown format{?s} {.val {unknown}}.",
        "i" = "Use any of {.val {(.usrds_formats)}}."
      ),
      call = call
    )
  }
  if (anyDuplicated(format_preference)) {
    cli::cli_abort(
      "{.arg {arg}} lists {.val {format_preference[duplicated(format_preference)]}} more than once.",
      call = call
    )
  }
  format_preference
}

# TRUE for file roots (lower case) that name a USRDS file: an Appendix B
# file name, an Appendix B name with its year replaced by any year (so
# ps_clm_2022 also recognises ps_clm_2019), or a file in a claim-file table.
.is_usrds_file <- function(file_roots) {
  appendix_b <- unique(tolower(metadata_b$file))
  claim_files <- unlist(lapply(
    names(.usrds_file_groups),
    function(lookup) get(lookup)$file_root
  ))
  exact <- unique(c(appendix_b, tolower(claim_files)))
  yearly <- appendix_b[grepl("20[0-9]{2}", appendix_b)]
  yearly <- unique(gsub("20[0-9]{2}", "20[0-9]{2}", yearly, fixed = FALSE))
  pattern <- paste0("^(", paste(yearly, collapse = "|"), ")$")
  file_roots %in% exact | grepl(pattern, file_roots)
}

.usrds_folder <- function(paths) {
  out <- rep(NA_character_, length(paths))
  for (folder in names(.usrds_folders)) {
    hit <- is.na(out) & grepl(folder, paths, ignore.case = TRUE, fixed = FALSE)
    out[hit] <- .usrds_folders[[folder]]
  }
  out
}

.check_same_format_copies <- function(inventory, call = rlang::caller_env()) {
  copies <- inventory |>
    dplyr::group_by(
      .data$file_root,
      .data$Year,
      .data$file_suffix
    ) |>
    dplyr::filter(dplyr::n() > 1) |>
    dplyr::ungroup()
  if (nrow(copies) == 0) {
    return(invisible())
  }
  n_files <- nrow(dplyr::distinct(copies, .data$file_root, .data$file_suffix))
  paths <- copies$file_path
  cli::cli_abort(
    c(
      "{n_files} file{?s} {?has/have} more than one copy in the same format.",
      "x" = "{.file {paths}}",
      "i" = "Keep one copy of each, or move the others outside
             {.envvar USRDS_WD}, then run {.code set_USRDS_wd()} again."
    ),
    call = call
  )
}

.find_incomplete_groups <- function(file_list) {
  present <- unique(file_list$file_root)
  groups <- lapply(names(.usrds_file_groups), function(lookup) {
    expected <- get(lookup)
    tibble::tibble(
      lookup = lookup,
      Year = expected$Year,
      file_root = expected$file_root,
      present = expected$file_root %in% present
    )
  })
  dplyr::bind_rows(groups) |>
    dplyr::summarise(
      n_expected = dplyr::n(),
      n_present = sum(.data$present),
      missing = list(.data$file_root[!.data$present]),
      .by = c("lookup", "Year")
    ) |>
    dplyr::filter(
      .data$n_present > 0,
      .data$n_present < .data$n_expected
    ) |>
    dplyr::arrange(.data$Year, .data$lookup)
}

.report_file_map <- function(
  inventory,
  file_list,
  unrecognised,
  format_preference
) {
  counts <- table(factor(file_list$file_suffix, levels = .usrds_formats))
  labels <- c(parquet = "Parquet", sas7bdat = "SAS", csv = "CSV")
  found <- paste(counts[counts > 0], labels[names(counts)[counts > 0]])
  n_other <- nrow(inventory) - nrow(file_list)
  bullets <- c(
    "v" = "Mapped {nrow(file_list)} USRDS file{?s}: {found}."
  )
  if (n_other > 0) {
    bullets <- c(
      bullets,
      "i" = "{n_other} other cop{?y/ies} in another format {?was/were} set
             aside. Format order: {.val {format_preference}}."
    )
  }
  if (nrow(unrecognised) > 0) {
    shown <- utils::head(unrecognised$file_name, 5)
    bullets <- c(
      bullets,
      "i" = "{nrow(unrecognised)} file{?s} with {?a name/names} usRds does
             not recognise {?was/were} set aside, for example
             {.file {shown}}."
    )
  }
  cli::cli_inform(bullets)
}

.report_incomplete_groups <- function(incomplete, on_incomplete, quiet) {
  by_year <- incomplete |>
    dplyr::summarise(
      missing = list(sort(unique(unlist(.data$missing)))),
      readers = list(unname(.usrds_file_groups[.data$lookup])),
      .by = "Year"
    )
  lines <- vapply(
    seq_len(nrow(by_year)),
    function(i) {
      missing <- by_year$missing[[i]]
      shown <- utils::head(missing, 6)
      more <- if (length(missing) > 6) {
        paste0(" and ", length(missing) - 6, " more")
      } else {
        ""
      }
      paste0(
        by_year$Year[i],
        ": missing ",
        paste(shown, collapse = ", "),
        more,
        " (read by ",
        paste(by_year$readers[[i]], collapse = ", "),
        ")"
      )
    },
    character(1)
  )
  bullets <- c(
    "Some years have only part of their USRDS file group.",
    rlang::set_names(lines, rep("!", length(lines))),
    "i" = "Claims, diagnoses and costs for these years would be incomplete.
           Add the missing files, then run {.code set_USRDS_wd()} again."
  )
  if (on_incomplete == "error") {
    cli::cli_abort(bullets, class = "usrds_incomplete_files", call = NULL)
  }
  if (!quiet) {
    cli::cli_warn(bullets, class = "usrds_incomplete_files")
  }
  invisible()
}
