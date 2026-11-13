# Builds a made-up USRDS folder of empty files and points USRDS_WD at it.
local_usrds_dir <- function(files, env = parent.frame()) {
  dir <- withr::local_tempdir(.local_envir = env)
  for (f in files) {
    dir.create(dirname(file.path(dir, f)), recursive = TRUE, showWarnings = FALSE)
    file.create(file.path(dir, f))
  }
  withr::local_envvar(USRDS_WD = dir, .local_envir = env)
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

test_that(".map_USRDS_files() lists USRDS files by root, suffix, year and folder", {
  local_usrds_dir(c(
    "ESRD Core/patients.csv",
    "Physician supplier/ps2010a.sas7bdat",
    "Other/notes2010.csv"
  ))

  result <- .map_USRDS_files(quiet = TRUE)

  expect_equal(result$file_name, c("patients.csv", "ps2010a.sas7bdat"))
  expect_equal(result$file_root, c("patients", "ps2010a"))
  expect_equal(result$file_suffix, c("csv", "sas7bdat"))
  expect_equal(result$Year, c(NA, 2010))
  expect_equal(result$file_directory, c("Core", "PS"))
})

test_that(".map_USRDS_files() keeps the columns the extractors pass to their readers", {
  local_usrds_dir("ESRD Core/patients.csv")

  result <- .map_USRDS_files(quiet = TRUE)

  expect_named(
    result,
    c("file_path", "file_name", "file_root", "file_suffix", "Year", "file_directory")
  )
})

test_that(".map_USRDS_files() ignores case in file names, extensions and folders", {
  local_usrds_dir(c(
    "5) ESRD INSTITUTION/INC2011A.SAS7BDAT",
    "esrd core/Patients.CSV"
  ))

  result <- .map_USRDS_files(quiet = TRUE)
  result <- result[order(result$file_root), ]

  expect_equal(result$file_root, c("inc2011a", "patients"))
  expect_equal(result$file_suffix, c("sas7bdat", "csv"))
  expect_equal(result$file_directory, c("Institution", "Core"))
})

test_that(".map_USRDS_files() finds USRDS files in any folder layout", {
  local_usrds_dir(c(
    "patients.sas7bdat",
    "my data/claims/ps2010a.csv",
    "my data/ps_clm_2019.parquet",
    "my data/pdenrol2015.csv"
  ))

  result <- .map_USRDS_files(quiet = TRUE)

  expect_equal(
    result$file_root,
    c("patients", "pdenrol2015", "ps2010a", "ps_clm_2019")
  )
  expect_equal(result$file_directory, rep(NA_character_, 4))
})

test_that(".map_USRDS_files() sets aside files with names it does not recognise", {
  local_usrds_dir(c(
    "ESRD Core/patients.csv",
    "ESRD Core/my_cohort.csv",
    "analysis/results2020.parquet"
  ))

  expect_snapshot(result <- .map_USRDS_files())
  expect_equal(result$file_name, "patients.csv")
  expect_setequal(
    .usrds_env$unrecognised$file_name,
    c("my_cohort.csv", "results2020.parquet")
  )
})

test_that(".map_USRDS_files() ignores folders left by an interrupted conversion", {
  local_usrds_dir(c(
    "ESRD Core/patients.csv",
    "ESRD Core/patients.parquet_chunks/part-0.parquet"
  ))

  result <- .map_USRDS_files(quiet = TRUE)

  expect_equal(result$file_name, "patients.csv")
})

test_that(".map_USRDS_files() keeps one format per file, Parquet first by default", {
  local_usrds_dir(c(
    "ESRD Core/patients.csv",
    "ESRD Core/patients.sas7bdat",
    "ESRD Core/patients.parquet",
    "ESRD Core/rxhist.csv",
    "ESRD Core/rxhist.sas7bdat"
  ))

  result <- .map_USRDS_files(quiet = TRUE)
  result <- result[order(result$file_root), ]

  expect_equal(result$file_name, c("patients.parquet", "rxhist.sas7bdat"))
})

test_that(".map_USRDS_files() follows a custom format preference", {
  local_usrds_dir(c("ESRD Core/patients.csv", "ESRD Core/patients.parquet"))

  result <- .map_USRDS_files(format_preference = c("csv", "parquet"), quiet = TRUE)

  expect_equal(result$file_name, "patients.csv")
})

test_that(".map_USRDS_files() leaves out formats not in the preference", {
  local_usrds_dir(c("ESRD Core/patients.csv", "ESRD Core/rxhist.parquet"))

  result <- .map_USRDS_files(format_preference = "parquet", quiet = TRUE)

  expect_equal(result$file_name, "rxhist.parquet")
})

test_that(".map_USRDS_files() stops when one file has two copies in the same format", {
  local_usrds_dir(c(
    "5) ESRD Institution/inc2010a.csv",
    "backups/inc2010a.csv"
  ))

  expect_snapshot(.map_USRDS_files(quiet = TRUE), error = TRUE, transform = function(x) {
    gsub(Sys.getenv("USRDS_WD"), "<USRDS_WD>", x, fixed = TRUE)
  })
})

test_that(".map_USRDS_files() lists each duplicated file on its own line", {
  local_usrds_dir(c(
    "5) ESRD Institution/inc2010a.csv",
    "backups/inc2010a.csv",
    "backups/2019/inc2010a.csv",
    "ESRD Core/patients.sas7bdat",
    "old/patients.SAS7BDAT"
  ))

  expect_snapshot(.map_USRDS_files(quiet = TRUE), error = TRUE, transform = function(x) {
    gsub(Sys.getenv("USRDS_WD"), "<USRDS_WD>", x, fixed = TRUE)
  })
  expect_equal(.usrds_env$duplicates$file_name, c("inc2010a.csv", "patients.sas7bdat"))
})

test_that(".map_USRDS_files() only reports duplicates in a format it will not read", {
  local_usrds_dir(c(
    "ESRD Core/patients.parquet",
    "ESRD Core/patients.sas7bdat",
    "old/patients.sas7bdat"
  ))

  expect_snapshot(result <- .map_USRDS_files())
  expect_equal(result$file_name, "patients.parquet")
  expect_equal(.usrds_env$unread_duplicates$file_name, "patients.sas7bdat")
})

test_that(".map_USRDS_files() stops on duplicates once their format is read", {
  local_usrds_dir(c(
    "ESRD Core/patients.parquet",
    "ESRD Core/patients.sas7bdat",
    "old/patients.sas7bdat"
  ))

  expect_error(
    .map_USRDS_files(format_preference = c("sas7bdat", "parquet"), quiet = TRUE),
    class = "usrds_duplicate_files"
  )
})

test_that(".map_USRDS_files() clears the previous map when mapping fails", {
  dir <- local_usrds_dir("ESRD Core/patients.csv")
  .map_USRDS_files(quiet = TRUE)
  dir.create(file.path(dir, "ESRD Core", "old"))
  file.create(file.path(dir, "ESRD Core", "old", "patients.csv"))

  expect_error(.map_USRDS_files(quiet = TRUE))
  expect_null(.usrds_env$file_list)
})

test_that(".map_USRDS_files() stops when no USRDS files are found", {
  local_usrds_dir("Other/notes.csv")

  expect_snapshot(.map_USRDS_files(quiet = TRUE), error = TRUE, transform = function(x) {
    gsub(Sys.getenv("USRDS_WD"), "<USRDS_WD>", x, fixed = TRUE)
  })
})

test_that(".map_USRDS_files() warns when only part of a year's file group is present", {
  local_usrds_dir(c(
    "5) ESRD Institution/det2007a.sas7bdat",
    "5) ESRD Institution/det2007b.sas7bdat"
  ))

  expect_snapshot(result <- .map_USRDS_files())

  incomplete <- .usrds_env$incomplete
  in_icd_2007 <- incomplete[incomplete$lookup == "IN_ICD" & incomplete$Year == 2007, ]
  expect_equal(in_icd_2007$n_present, 2)
  expect_equal(in_icd_2007$n_expected, 13)
  expect_setequal(
    in_icd_2007$missing[[1]],
    setdiff(IN_ICD$file_root[IN_ICD$Year == 2007], c("det2007a", "det2007b"))
  )
})

test_that(".map_USRDS_files() does not flag a year whose group is complete or absent", {
  roots <- IN_ICD$file_root[IN_ICD$Year == 2012]
  local_usrds_dir(file.path("5) ESRD Institution", paste0(roots, ".parquet")))

  suppressWarnings(.map_USRDS_files(quiet = TRUE))

  incomplete <- .usrds_env$incomplete
  expect_equal(nrow(incomplete[incomplete$lookup == "IN_ICD", ]), 0)
})

test_that(".map_USRDS_files() can stop on an incomplete group", {
  local_usrds_dir("5) ESRD Institution/det2007a.sas7bdat")

  expect_error(
    .map_USRDS_files(on_incomplete = "error", quiet = TRUE),
    class = "usrds_incomplete_files"
  )
})

test_that(".map_USRDS_files() reports what it found", {
  local_usrds_dir(c(
    "ESRD Core/patients.csv",
    "ESRD Core/patients.parquet",
    "ESRD Core/rxhist.sas7bdat"
  ))

  expect_snapshot(invisible(.map_USRDS_files()))
})

test_that("set_USRDS_wd() checks the format preference", {
  dir <- local_usrds_dir("ESRD Core/patients.csv")

  expect_snapshot(set_USRDS_wd(dir, format_preference = "xlsx"), error = TRUE)
  expect_snapshot(
    set_USRDS_wd(dir, format_preference = c("csv", "csv")),
    error = TRUE
  )
})

test_that("set_USRDS_wd() stores the format preference used by later mapping", {
  dir <- local_usrds_dir(c("ESRD Core/patients.csv", "ESRD Core/patients.parquet"))

  suppressMessages(set_USRDS_wd(dir, format_preference = c("csv", "parquet")))
  result <- .map_USRDS_files(quiet = TRUE)

  expect_equal(result$file_name, "patients.csv")
})

test_that(".check_valid_years() explains when no files have been mapped", {
  local_usrds_dir("ESRD Core/patients.csv")
  .usrds_env$file_list <- NULL

  expect_snapshot(
    .check_valid_years(2010, IN_ICD$file_root, "Institutional ICD files"),
    error = TRUE
  )
})

test_that(".map_USRDS_files() clears the cached Medicare coverage", {
  local_usrds_dir("ESRD Core/patients.csv")
  .usrds_env$medicare_history <- list(data = data.frame(), usrds_ids = 1)

  .map_USRDS_files(quiet = TRUE)

  expect_null(.usrds_env$medicare_history)
})

test_that(".onLoad() leaves Arrow's options alone", {
  withr::local_envvar(USRDS_WD = NA)
  withr::local_options(arrow.skip_nul = NULL)

  .onLoad(NULL, "usRds")

  expect_null(getOption("arrow.skip_nul"))
})

test_that(".local_arrow_options() sets arrow.skip_nul only until the caller exits", {
  withr::local_options(arrow.skip_nul = NULL)
  reader <- function() {
    .local_arrow_options()
    getOption("arrow.skip_nul")
  }

  expect_true(reader())
  expect_null(getOption("arrow.skip_nul"))
})

test_that(".onLoad() is silent when USRDS_WD is not set", {
  withr::local_envvar(USRDS_WD = NA)
  old <- .usrds_env$file_list
  withr::defer(.usrds_env$file_list <- old)

  expect_silent(.onLoad(NULL, "usRds"))
})

test_that(".onLoad() is silent when the USRDS folder has an incomplete group", {
  local_usrds_dir("5) ESRD Institution/det2007a.sas7bdat")

  expect_silent(.onLoad(NULL, "usRds"))
  expect_equal(.usrds_env$file_list$file_root, "det2007a")
})
