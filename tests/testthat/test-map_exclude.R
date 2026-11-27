# Folder exclusion and failed-scan reports for the file map (#125).
# Builds a made-up USRDS folder of empty files and points USRDS_WD at it.
local_usrds_dir <- function(files, env = parent.frame()) {
  dir <- withr::local_tempdir(.local_envir = env)
  for (f in files) {
    dir.create(dirname(file.path(dir, f)), recursive = TRUE, showWarnings = FALSE)
    file.create(file.path(dir, f))
  }
  withr::local_envvar(USRDS_WD = dir, .local_envir = env)
  withr::local_options(usRds.exclude = NULL, .local_envir = env)
  old <- as.list(.usrds_env)
  withr::defer(
    {
      rm(list = ls(.usrds_env, all.names = TRUE), envir = .usrds_env)
      list2env(old, .usrds_env)
    },
    envir = env
  )
  dir
}

test_that("exclude skips copies in the named folders", {
  local_usrds_dir(c(
    "5) ESRD Institution/inc2010a.csv",
    "backup/inc2010a.csv",
    "old/Backup/patients.parquet",
    "ESRD Core/patients.parquet"
  ))

  result <- .map_USRDS_files(exclude = "backup", quiet = TRUE)

  expect_equal(
    sort(substring(result$file_path, nchar(Sys.getenv("USRDS_WD")) + 2)),
    c("5) ESRD Institution/inc2010a.csv", "ESRD Core/patients.parquet")
  )
  expect_equal(
    usrds_files("excluded")$relative_path,
    c("backup/inc2010a.csv", "old/Backup/patients.parquet")
  )
})

test_that("exclude matches whole folder names, in any case", {
  local_usrds_dir(c(
    "ESRD Core/patients.parquet",
    "backups/rxhist.parquet",
    "my_backup/payhist.parquet",
    "BACKUP/residenc.parquet"
  ))

  result <- .map_USRDS_files(exclude = "Backup", quiet = TRUE)

  expect_setequal(result$file_root, c("patients", "rxhist", "payhist"))
  expect_equal(usrds_files("excluded")$relative_path, "BACKUP/residenc.parquet")
})

test_that("a file under two excluded folders is listed once", {
  local_usrds_dir(c(
    "ESRD Core/patients.parquet",
    "old/backup/patients.parquet"
  ))

  .map_USRDS_files(exclude = c("old", "backup"), quiet = TRUE)

  expect_equal(usrds_files("excluded")$relative_path, "old/backup/patients.parquet")
})

test_that("files directly in the USRDS folder are never excluded", {
  local_usrds_dir("patients.parquet")

  result <- .map_USRDS_files(exclude = "backup", quiet = TRUE)

  expect_equal(result$file_name, "patients.parquet")
  expect_equal(nrow(usrds_files("excluded")), 0)
})

test_that("the usRds.exclude option applies when no exclude is given, as on load", {
  local_usrds_dir(c("ESRD Core/patients.parquet", "backup/patients.parquet"))
  withr::local_options(usRds.exclude = "backup")

  expect_silent(.onLoad(NULL, "usRds"))
  expect_equal(.usrds_env$file_list$file_name, "patients.parquet")
  expect_equal(usrds_files("excluded")$relative_path, "backup/patients.parquet")
})

test_that("set_USRDS_wd() uses the option by default and an explicit exclude replaces it", {
  dir <- local_usrds_dir(c("ESRD Core/patients.parquet", "backup/patients.parquet"))
  withr::local_options(usRds.exclude = "backup")

  suppressMessages(set_USRDS_wd(dir))
  expect_equal(nrow(usrds_files("excluded")), 1)

  expect_error(
    suppressMessages(set_USRDS_wd(dir, exclude = character())),
    class = "usrds_duplicate_files"
  )
})

test_that("set_USRDS_wd() stores exclude for later mapping", {
  dir <- local_usrds_dir(c("ESRD Core/patients.parquet", "backup/patients.parquet"))

  suppressMessages(set_USRDS_wd(dir, exclude = "backup"))
  result <- .map_USRDS_files(quiet = TRUE)

  expect_equal(nrow(result), 1)
  expect_equal(nrow(usrds_files("excluded")), 1)
})

test_that("exclude takes folder names only", {
  local_usrds_dir("ESRD Core/patients.parquet")

  expect_snapshot(.map_USRDS_files(exclude = "old/backup", quiet = TRUE), error = TRUE)
  expect_snapshot(.map_USRDS_files(exclude = c("old", NA), quiet = TRUE), error = TRUE)
  expect_snapshot(.map_USRDS_files(exclude = "", quiet = TRUE), error = TRUE)
})

test_that("usrds_files('duplicates') lists every copy after a failed scan", {
  roots <- sprintf("ps_clm_%d", 2010:2021)
  local_usrds_dir(c(
    paste0("6) Physician supplier/", roots, ".parquet"),
    paste0("copy/", roots, ".parquet")
  ))

  expect_error(.map_USRDS_files(quiet = TRUE), class = "usrds_duplicate_files")

  duplicates <- usrds_files("duplicates")
  expect_equal(nrow(duplicates), 24)
  expect_equal(length(unique(duplicates$file_name)), 12)
  expect_true(all(c("file_name", "Year", "file_suffix", "relative_path") %in% names(duplicates)))
  expect_snapshot(usrds_files("mapped"), error = TRUE)
})

test_that("excluding the preferred copy can expose duplicates in the next format", {
  dir <- local_usrds_dir(c(
    "ESRD Core/patients.parquet",
    "exports/patients.csv",
    "exports/2019/patients.csv"
  ))

  result <- .map_USRDS_files(quiet = TRUE)
  expect_equal(result$file_name, "patients.parquet")
  expect_equal(nrow(usrds_files("other_formats")), 2)
  expect_equal(usrds_files("unread_duplicates")$file_name, "patients.csv")

  expect_error(
    .map_USRDS_files(exclude = "ESRD Core", quiet = TRUE),
    class = "usrds_duplicate_files"
  )
  expect_equal(
    usrds_files("duplicates")$relative_path,
    c("exports/2019/patients.csv", "exports/patients.csv")
  )

  retry <- .map_USRDS_files(exclude = c("ESRD Core", "2019"), quiet = TRUE)
  expect_equal(
    substring(retry$file_path, nchar(dir) + 2),
    "exports/patients.csv"
  )
  expect_equal(nrow(usrds_files("duplicates")), 0)
})

test_that("a retry with the same format_preference keeps the chosen format", {
  local_usrds_dir(c(
    "ESRD Core/patients.parquet",
    "exports/patients.csv",
    "backup/patients.csv"
  ))
  csv_first <- c("csv", "parquet", "sas7bdat")

  expect_error(
    .map_USRDS_files(format_preference = csv_first, quiet = TRUE),
    class = "usrds_duplicate_files"
  )
  retry <- .map_USRDS_files(
    format_preference = csv_first,
    exclude = "backup",
    quiet = TRUE
  )

  expect_equal(retry$file_suffix, "csv")
  expect_equal(usrds_files("excluded")$relative_path, "backup/patients.csv")
})

test_that("a stop on an incomplete group still maps the files found", {
  local_usrds_dir(c(
    "5) ESRD Institution/det2007a.sas7bdat",
    "backup/det2007b.sas7bdat"
  ))

  expect_error(
    .map_USRDS_files(exclude = "backup", on_incomplete = "error", quiet = TRUE),
    class = "usrds_incomplete_files"
  )
  expect_equal(usrds_files("mapped")$file_name, "det2007a.sas7bdat")
  expect_gt(nrow(usrds_files("incomplete")), 0)
  expect_equal(usrds_files("excluded")$relative_path, "backup/det2007b.sas7bdat")
})

test_that("a scan that excludes every file says so and keeps its reports", {
  local_usrds_dir(c("backup/patients.parquet", "Other/notes.csv"))

  expect_snapshot(
    .map_USRDS_files(exclude = "backup", quiet = TRUE),
    error = TRUE,
    transform = function(x) gsub(Sys.getenv("USRDS_WD"), "<USRDS_WD>", x, fixed = TRUE)
  )
  expect_equal(usrds_files("excluded")$relative_path, "backup/patients.parquet")
  expect_equal(usrds_files("unrecognised")$file_name, "notes.csv")
  expect_equal(nrow(usrds_files("duplicates")), 0)
})

test_that("a new scan clears the previous scan's reports", {
  dir <- local_usrds_dir(c("ESRD Core/patients.parquet", "backup/patients.parquet"))
  expect_error(.map_USRDS_files(quiet = TRUE), class = "usrds_duplicate_files")
  expect_equal(nrow(usrds_files("duplicates")), 2)

  .map_USRDS_files(exclude = "backup", quiet = TRUE)

  expect_equal(nrow(usrds_files("duplicates")), 0)
  expect_equal(nrow(usrds_files("excluded")), 1)
})

test_that("the summary reports the files skipped in excluded folders", {
  local_usrds_dir(c(
    "ESRD Core/patients.parquet",
    "backup/patients.parquet",
    "backup/rxhist.parquet",
    "old/payhist.parquet"
  ))

  expect_snapshot(invisible(.map_USRDS_files(exclude = c("backup", "old"))))
})

test_that("the duplicate error explains the format order and suggests exclude", {
  local_usrds_dir(c("ESRD Core/patients.parquet", "backup/patients.parquet"))

  expect_snapshot(
    .map_USRDS_files(quiet = TRUE),
    error = TRUE,
    transform = function(x) gsub(Sys.getenv("USRDS_WD"), "<USRDS_WD>", x, fixed = TRUE)
  )
})
