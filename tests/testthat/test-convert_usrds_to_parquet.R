test_that("convert_usrds_to_parquet() maps each CSV and SAS file to a Parquet path", {
  source_dir <- withr::local_tempdir()
  target_dir <- file.path(withr::local_tempdir(), "out")
  dir.create(file.path(source_dir, "core"))
  file.create(file.path(source_dir, "core", "patients.csv"))
  file.create(file.path(source_dir, "ps2010a.sas7bdat"))
  file.create(file.path(source_dir, "readme.txt"))
  calls <- character()
  local_mocked_bindings(
    .parquetize_usrds_file = function(input_path, output_path, overwrite = FALSE) {
      calls <<- c(calls, as.character(output_path))
      invisible(output_path)
    }
  )

  result <- convert_usrds_to_parquet(source_dir, target_dir)

  expect_setequal(
    calls,
    file.path(target_dir, c("core/patients.parquet", "ps2010a.parquet"))
  )
  expect_setequal(result$ext, c("csv", "sas7bdat"))
})

test_that(".codes_as_character() converts CODE and DIAG only when present", {
  df <- data.frame(CODE = c(389, 4280), OTHER = 1)

  result <- .codes_as_character(df)

  expect_type(result$CODE, "character")
  expect_type(result$OTHER, "double")
  expect_false("DIAG" %in% names(result))
})
