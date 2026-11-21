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
