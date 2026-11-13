local_usrds_folder <- function(files, env = parent.frame()) {
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

test_that("usrds_files() returns each list from the last mapping", {
  local_usrds_folder(c(
    "ESRD Core/patients.parquet",
    "ESRD Core/patients.csv",
    "ESRD Core/rxhist.sas7bdat",
    "old/rxhist.csv",
    "old/2/rxhist.csv",
    "analysis/my_cohort.csv",
    "5) ESRD Institution/det2007a.sas7bdat"
  ))
  suppressWarnings(.map_USRDS_files(quiet = TRUE))

  expect_equal(
    usrds_files()$file_name,
    c("det2007a.sas7bdat", "patients.parquet", "rxhist.sas7bdat")
  )
  expect_setequal(
    usrds_files("other_formats")$file_name,
    c("patients.csv", "rxhist.csv", "rxhist.csv")
  )
  expect_equal(usrds_files("unrecognised")$file_name, "my_cohort.csv")
  expect_equal(usrds_files("unread_duplicates")$file_name, "rxhist.csv")
  expect_equal(unique(usrds_files("incomplete")$Year), 2007)
})

test_that("usrds_files() explains when nothing is mapped", {
  local_usrds_folder("ESRD Core/patients.csv")
  .usrds_env$file_list <- NULL

  expect_snapshot(usrds_files(), error = TRUE)
})

test_that("usrds_files() rejects an unknown list name", {
  local_usrds_folder("ESRD Core/patients.csv")
  .map_USRDS_files(quiet = TRUE)

  expect_error(usrds_files("everything"), class = "rlang_error")
})
