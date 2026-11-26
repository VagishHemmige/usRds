# Offline tests of load_usrds_file()'s col_select in each format, on a
# made-up PATIENTS-like table (#22).

made_up_patients <- function() {
  data.frame(
    USRDS_ID = c(1, 2, 3),
    CDEATH = c("01", "02", "03"),
    CDTYPE = c("A", "B", "C"),
    OTHER = c(10, 20, 30)
  )
}

local_patients_file <- function(suffix, env = parent.frame()) {
  path <- withr::local_tempfile(
    fileext = paste0(".", suffix),
    .local_envir = env
  )
  old <- .usrds_env$file_list
  .usrds_env$file_list <- data.frame(
    file_path = path,
    file_name = basename(path),
    file_root = "patients",
    file_suffix = suffix,
    Year = NA,
    file_directory = "Core"
  )
  withr::defer(.usrds_env$file_list <- old, envir = env)
  path
}

# Deprecation warnings from tidyselect become errors, so a selection that
# is evaluated too early fails the test rather than only warning.
load_patients <- function(...) {
  withr::local_options(lifecycle_verbosity = "error")
  load_usrds_file("patients", factor_labels = FALSE, ...)
}

skip_if_no_arrow <- function() {
  has_writer <- requireNamespace("arrow", quietly = TRUE) &&
    exists("write_parquet", envir = asNamespace("arrow"), inherits = FALSE)
  skip_if_not(has_writer, "arrow is not installed with Parquet support")
}

test_that("col_select works on Parquet files (#22)", {
  skip_if_no_arrow()
  path <- local_patients_file("parquet")
  arrow::write_parquet(made_up_patients(), path)

  expect_named(
    load_patients(col_select = c("USRDS_ID", "CDEATH")),
    c("USRDS_ID", "CDEATH")
  )
  expect_named(
    load_patients(col_select = dplyr::all_of(c("USRDS_ID", "CDEATH"))),
    c("USRDS_ID", "CDEATH")
  )
  expect_named(
    load_patients(col_select = dplyr::starts_with("CD")),
    c("CDEATH", "CDTYPE")
  )
  expect_named(load_patients(), c("USRDS_ID", "CDEATH", "CDTYPE", "OTHER"))
})

test_that("col_select gives the same columns from CSV files (#22)", {
  path <- local_patients_file("csv")
  utils::write.csv(made_up_patients(), path, row.names = FALSE)

  expect_named(
    load_patients(col_select = c("USRDS_ID", "CDEATH"), show_col_types = FALSE),
    c("USRDS_ID", "CDEATH")
  )
  expect_named(
    load_patients(
      col_select = dplyr::all_of(c("USRDS_ID", "CDEATH")),
      show_col_types = FALSE
    ),
    c("USRDS_ID", "CDEATH")
  )
  expect_named(
    load_patients(
      col_select = dplyr::starts_with("CD"),
      show_col_types = FALSE
    ),
    c("CDEATH", "CDTYPE")
  )
})

test_that("col_select gives the same columns from SAS files (#22)", {
  local_patients_file("sas7bdat")
  rows <- made_up_patients()
  local_mocked_bindings(
    read_sas = function(data_file, col_select = NULL, ...) {
      selected <- tidyselect::eval_select(rlang::enquo(col_select), rows)
      if (length(selected) == 0) rows else rows[selected]
    },
    .package = "haven"
  )
  file.create(.usrds_env$file_list$file_path)

  expect_named(
    load_patients(col_select = c("USRDS_ID", "CDEATH")),
    c("USRDS_ID", "CDEATH")
  )
  expect_named(
    load_patients(col_select = dplyr::all_of(c("USRDS_ID", "CDEATH"))),
    c("USRDS_ID", "CDEATH")
  )
  expect_named(
    load_patients(col_select = dplyr::starts_with("CD")),
    c("CDEATH", "CDTYPE")
  )
})

# ---- Other behaviour, on made-up CSV files ----

local_csv_file <- function(file_root, rows, env = parent.frame()) {
  dir <- withr::local_tempdir(.local_envir = env)
  path <- file.path(dir, paste0(file_root, ".csv"))
  utils::write.csv(rows, path, row.names = FALSE)
  old <- .usrds_env$file_list
  .usrds_env$file_list <- data.frame(
    file_path = path,
    file_name = basename(path),
    file_root = file_root,
    file_suffix = "csv",
    Year = NA,
    file_directory = "Core"
  )
  withr::defer(.usrds_env$file_list <- old, envir = env)
  path
}

made_up_payhist <- function() {
  data.frame(
    usrds_id = c(1, 2, 3),
    payer = c("MPAB", "MPO", "MSP-EGHP")
  )
}

test_that("load_usrds_file() upper-cases names and filters by USRDS_ID", {
  local_csv_file("payhist", made_up_payhist())

  result <- load_usrds_file(
    "PAYHIST",
    factor_labels = FALSE,
    usrds_ids = c(1, 3),
    show_col_types = FALSE
  )

  expect_named(result, c("USRDS_ID", "PAYER"))
  expect_equal(result$USRDS_ID, c(1, 3))
  expect_equal(result$PAYER, c("MPAB", "MSP-EGHP"))
})

test_that("load_usrds_file() finds the file whatever the case of file_key", {
  local_csv_file("payhist", made_up_payhist())

  result <- load_usrds_file("payhist", factor_labels = FALSE, show_col_types = FALSE)

  expect_equal(nrow(result), 3)
})

test_that("load_usrds_file() applies Appendix C labels by default", {
  local_csv_file("payhist", made_up_payhist())

  labelled_payers <- load_usrds_file("PAYHIST", show_col_types = FALSE)

  expect_equal(
    as.character(labelled_payers$PAYER[1:2]),
    c(
      "MEDICARE FFS PRIMARY PAY, FOR BOTH PART A AND PART B",
      "MEDICARE FFS PRIMARY PAY, FOR OTHER"
    )
  )
})

test_that("load_usrds_file() adds Appendix B variable labels on request", {
  local_csv_file("payhist", made_up_payhist())

  result <- load_usrds_file(
    "PAYHIST",
    factor_labels = FALSE,
    var_labels = TRUE,
    show_col_types = FALSE
  )

  expect_equal(labelled::var_label(result$PAYER), "Payer Category")
})

test_that("load_usrds_file() stops when no files are mapped", {
  old <- .usrds_env$file_list
  withr::defer(.usrds_env$file_list <- old)
  .usrds_env$file_list <- NULL

  expect_snapshot(error = TRUE, load_usrds_file("PAYHIST"))
})

test_that("load_usrds_file() stops on an unknown file key", {
  local_csv_file("payhist", made_up_payhist())

  expect_snapshot(error = TRUE, load_usrds_file("NOT_A_FILE"))
})

test_that("load_usrds_file() stops when the mapped file has gone", {
  path <- local_csv_file("payhist", made_up_payhist())
  unlink(path)

  expect_error(load_usrds_file("PAYHIST"), "File not found", fixed = TRUE)
})
