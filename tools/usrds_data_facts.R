# usrds_data_facts.R: describe the USRDS files on this machine without
# showing any patient-level values.
#
# For the maintainer to run on his own USRDS folder. It prints and saves a
# report that can be pasted into a chat or an issue. The report contains:
#   - what set_USRDS_wd() found (summary, files set aside, incomplete groups);
#   - for each file family and format, the column names and types: from the
#     Parquet schema, from haven (first rows only), or, for CSV, the *form*
#     of the values (DATE9., MMDDYY10., ISO, digits with a leading zero, ...)
#     counted over the first rows;
#   - whether each SAS file opens with haven, and with encoding = "latin1";
#   - for a few code columns (HCFASAF, SPCLTY, PAYER), which of their
#     Appendix C codes (or code labels) occur in the first rows;
#   - Appendix B's type and format for each column, where the file name
#     matches an Appendix B sheet.
# The report holds no counts of values or codes (only which forms and codes
# occur), so no small cell can be shown or worked out from other numbers.
# It never prints a USRDS_ID, a date, an amount or any other value except
# Appendix C codes and labels in the few code columns named above; any
# other value in those columns goes only to the diagnostics file. The only file names it
# prints are names usRds recognises as USRDS files; unrecognised names,
# folder paths and the text of errors go to a separate diagnostics file for
# your eyes only, which the report names but does not include.
#
# Use:
#   source("tools/usrds_data_facts.R")
#   usrds_data_facts("<your USRDS folder>")
# Both files are written to tempdir() unless you give `out_file` and
# `diagnostics_file`.
#
# Needs usRds (this branch or later), arrow, haven and readr.

usrds_data_facts <- function(
  usrds_dir,
  out_file = file.path(tempdir(), "usrds-data-facts.txt"),
  diagnostics_file = file.path(tempdir(), "usrds-data-facts-diagnostics.txt"),
  n_rows = 10000,
  one_per_family = TRUE,
  code_columns = c("HCFASAF", "SPCLTY", "PAYER")
) {
  stopifnot(dir.exists(usrds_dir))
  usrds_dir <- normalizePath(usrds_dir, winslash = "/")
  report <- character()
  add <- function(...) report <<- c(report, paste0(...))
  # Free text (messages, error text, unrecognised names, paths) goes only to
  # the local diagnostics file.
  diagnostics <- character()
  note <- function(...) diagnostics <<- c(diagnostics, paste0(...))
  n_notes <- 0L
  local_only <- function(heading, text) {
    n_notes <<- n_notes + 1L
    note("", "[D", n_notes, "] ", heading)
    note(text)
    paste0("[D", n_notes, "] in the diagnostics file")
  }

  add("# usRds data facts")
  add("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M %Z"))
  add(
    "R ", getRversion(), "; usRds ", .pkg_version("usRds"),
    "; haven ", .pkg_version("haven"), "; arrow ", .pkg_version("arrow"),
    "; readr ", .pkg_version("readr")
  )
  add("Rows sampled per file: ", n_rows, ". Forms and codes are listed by")
  add("presence only, most common first; no counts.")

  # ---- 1. What set_USRDS_wd() reports ----
  add("", "## 1. set_USRDS_wd()")
  conditions <- character()
  tryCatch(
    withCallingHandlers(
      usRds::set_USRDS_wd(usrds_dir),
      message = function(m) {
        conditions <<- c(conditions, paste("message:", conditionMessage(m)))
        invokeRestart("muffleMessage")
      },
      warning = function(w) {
        conditions <<- c(conditions, paste("warning:", conditionMessage(w)))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(e) {
      conditions <<- c(conditions, paste("ERROR:", conditionMessage(e)))
    }
  )
  env <- utils::getFromNamespace(".usrds_env", "usRds")
  if (any(startsWith(conditions, "ERROR:"))) {
    add("set_USRDS_wd() stopped with an error: ",
        local_only("set_USRDS_wd() messages", conditions))
  } else if (length(conditions) > 0) {
    add("Messages from set_USRDS_wd(): ",
        local_only("set_USRDS_wd() messages", conditions))
  }
  mapped <- env$file_list
  if (!is.null(mapped)) {
    by_format <- table(mapped$file_suffix)
    add("Files mapped: ", paste(names(by_format), by_format, collapse = ", "))
  }
  unrecognised <- env$unrecognised
  if (!is.null(unrecognised) && nrow(unrecognised) > 0) {
    add("Files set aside as not recognised: ", nrow(unrecognised), " (names: ",
        local_only("Unrecognised files", sort(unique(unrecognised$file_name))),
        ")")
  }
  incomplete <- env$incomplete
  if (!is.null(incomplete) && nrow(incomplete) > 0) {
    add("", "Incomplete claim-file groups (year, group: missing files):")
    for (i in seq_len(nrow(incomplete))) {
      add(
        "  ", incomplete$Year[i], ", ", incomplete$lookup[i], ": ",
        paste(incomplete$missing[[i]], collapse = ", ")
      )
    }
  }

  # ---- 2. Every recognised file, in every format ----
  is_usrds_file <- utils::getFromNamespace(".is_usrds_file", "usRds")
  relative <- list.files(
    usrds_dir,
    pattern = "\\.(csv|sas7bdat|parquet)$",
    recursive = TRUE,
    ignore.case = TRUE
  )
  relative <- relative[!grepl("_chunks(/|$)", dirname(relative), ignore.case = TRUE)]
  files <- data.frame(
    path = file.path(usrds_dir, relative),
    name = basename(relative),
    root = tolower(tools::file_path_sans_ext(basename(relative))),
    suffix = tolower(tools::file_ext(relative)),
    stringsAsFactors = FALSE
  )
  files <- files[is_usrds_file(files$root), , drop = FALSE]
  files$family <- gsub("[0-9]+", "#", files$root)
  has_year <- grepl("(19|20)[0-9]{2}", files$root)
  files$year <- ifelse(
    has_year,
    sub("^.*?((19|20)[0-9]{2}).*$", "\\1", files$root, perl = TRUE),
    NA_character_
  )
  files$size_mb <- round(file.size(files$path) / 1e6)

  add("", "## 2. Files by family and format")
  add("Family (digits shown as #) | format | files | total MB")
  tally <- stats::aggregate(
    size_mb ~ family + suffix,
    data = files,
    FUN = function(x) c(n = length(x), mb = sum(x))
  )
  for (i in seq_len(nrow(tally))) {
    add(
      tally$family[i], " | ", tally$suffix[i], " | ",
      tally$size_mb[i, "n"], " | ", tally$size_mb[i, "mb"]
    )
  }

  # ---- 3. Does each SAS file open? (every SAS file, first row only) ----
  sas <- files[files$suffix == "sas7bdat", , drop = FALSE]
  add("", "## 3. SAS files: does haven open them? (", nrow(sas), " files)")
  for (i in seq_len(nrow(sas))) {
    status <- .sas_opens(sas$path[i])
    shown <- status$status
    if (!is.null(status$errors)) {
      shown <- paste0(shown, " (error text: ",
                      local_only(paste("haven,", sas$name[i]), status$errors), ")")
    }
    add(sas$name[i], ": ", shown)
  }

  if (one_per_family) {
    # One file per family and format (the latest name in sort order, which
    # for yearly files is usually the latest year), except CSV, where date
    # forms vary by year, so one file per family and year.
    files$keep_key <- ifelse(
      files$suffix == "csv",
      paste(files$family, files$suffix, files$year),
      paste(files$family, files$suffix)
    )
    files <- files[order(files$family, files$suffix, files$name, decreasing = TRUE), ]
    files <- files[!duplicated(files$keep_key), ]
  }
  files <- files[order(files$family, files$suffix, files$name), ]

  # ---- 3. Columns of each file ----
  add("", "## 4. Columns (", nrow(files), " files)")
  metadata_b <- utils::getFromNamespace("metadata_b", "usRds")
  for (i in seq_len(nrow(files))) {
    f <- files[i, ]
    add("", "### ", f$name, " (", f$suffix, ", ", f$size_mb, " MB)")
    result <- tryCatch(
      .describe_file(f$path, f$suffix, n_rows, code_columns),
      error = function(e) list(error = conditionMessage(e))
    )
    if (!is.null(result$error)) {
      add("Could not describe: ",
          local_only(paste("Reading", f$name), result$error))
      next
    }
    if (!is.null(result$note)) {
      add(result$note)
    }
    appendix_b <- metadata_b[toupper(metadata_b$file) == toupper(f$root), ]
    add("Appendix B sheet matched: ", if (nrow(appendix_b) > 0) "yes" else "no")
    add("column | found | Appendix B type, format")
    for (j in seq_len(nrow(result$columns))) {
      column <- result$columns$column[j]
      b_row <- appendix_b[toupper(appendix_b$variable) == toupper(column), ]
      expected <- if (nrow(b_row) > 0) {
        paste(b_row$type[1], b_row$format[1], sep = ", ")
      } else {
        "-"
      }
      add(column, " | ", result$columns$found[j], " | ", expected)
    }
    for (code in names(result$codes)) {
      summary <- result$codes[[code]]
      line <- paste0("Codes in ", code, " (first rows): ", summary$shown)
      if (length(summary$other) > 0) {
        line <- paste0(
          line, "; also values not in Appendix C (",
          local_only(paste0("Other values in ", code, ", ", f$name), summary$other),
          ")"
        )
      }
      add(line)
    }
  }

  if (n_notes > 0) {
    add("", n_notes, " item(s) are in the local diagnostics file, which is not")
    add("part of this report. Read it before sharing anything from it.")
  }
  writeLines(report, out_file)
  writeLines(c("# usRds data facts: local diagnostics (do not share as is)",
               diagnostics), diagnostics_file)
  message("Report written to ", out_file)
  message("Local diagnostics written to ", diagnostics_file)
  cat(report, sep = "\n")
  invisible(c(report = out_file, diagnostics = diagnostics_file))
}

.sas_opens <- function(path) {
  first <- tryCatch({
    haven::read_sas(path, n_max = 1)
    NULL
  }, error = function(e) conditionMessage(e))
  if (is.null(first)) {
    return(list(status = "opens"))
  }
  second <- tryCatch({
    haven::read_sas(path, n_max = 1, encoding = "latin1")
    NULL
  }, error = function(e) conditionMessage(e))
  if (is.null(second)) {
    return(list(
      status = "opens only with encoding = 'latin1'",
      errors = paste("default:", first)
    ))
  }
  list(
    status = "FAILS with the default encoding and with 'latin1'",
    errors = c(paste("default:", first), paste("latin1:", second))
  )
}

.pkg_version <- function(package) {
  tryCatch(as.character(utils::packageVersion(package)), error = function(e) "not installed")
}

# Forms a text value can take. Order matters: the first match wins.
.value_forms <- c(
  "DATETIME" = "^\\d{2}[A-Za-z]{3}\\d{4}:\\d{2}:\\d{2}:\\d{2}",
  "DATE9 (01JAN2010)" = "^\\d{2}[A-Za-z]{3}\\d{4}$",
  "DATE7 (01JAN10)" = "^\\d{2}[A-Za-z]{3}\\d{2}$",
  "slash date, first part over 12 (day first)" = "^(1[3-9]|2\\d|3[01])/\\d{1,2}/\\d{4}$",
  "slash date, second part over 12 (month first)" = "^\\d{1,2}/(1[3-9]|2\\d|3[01])/\\d{4}$",
  "slash date, order not shown by value" = "^\\d{1,2}/\\d{1,2}/\\d{4}$",
  "ISO (2010-01-31)" = "^\\d{4}-\\d{2}-\\d{2}$",
  "8 digits (YYYYMMDD?)" = "^\\d{8}$",
  "digits, leading zero" = "^0\\d+$",
  "digits" = "^-?\\d+$",
  "decimal" = "^-?\\d*\\.\\d+$",
  "letters and digits" = "^[A-Za-z0-9]+$",
  "other text" = "."
)

.value_form <- function(text) {
  form <- rep(NA_character_, length(text))
  form[is.na(text) | trimws(text) == ""] <- "missing"
  form[!is.na(text) & trimws(text) == "."] <- "'.' (SAS missing)"
  for (name in names(.value_forms)) {
    todo <- is.na(form)
    form[todo][grepl(.value_forms[[name]], trimws(text[todo]))] <- name
  }
  form
}

# Which forms occur, most common first, with no counts.
.form_summary <- function(text) {
  counts <- sort(table(.value_form(text)), decreasing = TRUE)
  paste(names(counts), collapse = "; ")
}

# Which codes occur, most common first, with no counts. Only short values
# are listed, so a free-text column named like a code column shows nothing.
# Which codes occur, most common first, with no counts. Only values that
# are codes or code labels in the column's Appendix C format are shown;
# anything else is returned separately, for the local diagnostics file
# only, since a code column can hold free text (#97).
.code_summary <- function(values, allowed) {
  values <- as.character(values)
  values[is.na(values)] <- "<NA>"
  found <- names(sort(table(values), decreasing = TRUE))
  is_allowed <- found %in% c(allowed, "<NA>")
  shown <- found[is_allowed]
  list(
    shown = if (length(allowed) == 0) {
      "no Appendix C code list found for this column; values not listed"
    } else if (length(shown) == 0) {
      "none of its Appendix C codes"
    } else {
      paste(paste0("'", shown, "'"), collapse = ", ")
    },
    other = utils::head(found[!is_allowed], 30)
  )
}

# The codes and code labels Appendix C gives for a column, found through
# the column's format in Appendix B (any sheet).
.appendix_c_codes <- function(column) {
  metadata_b <- utils::getFromNamespace("metadata_b", "usRds")
  metadata_c <- utils::getFromNamespace("metadata_c", "usRds")
  formats <- metadata_b$format[toupper(metadata_b$variable) == toupper(column)]
  formats <- unique(gsub("^\\$|\\.$", "", stats::na.omit(formats)))
  formats <- intersect(formats, names(metadata_c))
  unique(unlist(lapply(formats, function(f) {
    c(as.character(metadata_c[[f]]$value), as.character(metadata_c[[f]]$description))
  })))
}

.describe_file <- function(path, suffix, n_rows, code_columns) {
  note <- NULL
  if (suffix == "parquet") {
    schema <- arrow::open_dataset(path)$schema
    columns <- data.frame(
      column = schema$names,
      found = vapply(schema$fields, function(x) x$type$ToString(), character(1))
    )
    present <- intersect(code_columns, toupper(schema$names))
    sample <- if (length(present) > 0) {
      wanted <- schema$names[toupper(schema$names) %in% present]
      as.data.frame(head(dplyr::select(arrow::open_dataset(path), dplyr::all_of(wanted)), n_rows))
    }
  } else if (suffix == "sas7bdat") {
    sample <- tryCatch(
      haven::read_sas(path, n_max = n_rows),
      error = function(e) e
    )
    if (inherits(sample, "error")) {
      first_error <- conditionMessage(sample)
      sample <- tryCatch(
        haven::read_sas(path, n_max = n_rows, encoding = "latin1"),
        error = function(e) e
      )
      if (inherits(sample, "error")) {
        stop(
          "haven could not open it. Default: ", first_error,
          " | encoding = 'latin1': ", conditionMessage(sample)
        )
      }
      note <- "haven opened it only with encoding = 'latin1'."
    } else {
      note <- "haven opened it."
    }
    columns <- data.frame(
      column = names(sample),
      found = vapply(sample, function(x) {
        sas_format <- attr(x, "format.sas")
        paste0(
          class(x)[1],
          if (!is.null(sas_format)) paste0(" (SAS format ", sas_format, ")") else ""
        )
      }, character(1))
    )
  } else {
    sample <- readr::read_csv(
      path,
      n_max = n_rows,
      col_types = readr::cols(.default = readr::col_character()),
      na = character(),
      progress = FALSE
    )
    columns <- data.frame(
      column = names(sample),
      found = vapply(sample, .form_summary, character(1))
    )
  }
  codes <- list()
  if (!is.null(sample)) {
    for (column in names(sample)[toupper(names(sample)) %in% code_columns]) {
      codes[[column]] <- .code_summary(sample[[column]], .appendix_c_codes(column))
    }
  }
  list(columns = columns, codes = codes, note = note)
}
