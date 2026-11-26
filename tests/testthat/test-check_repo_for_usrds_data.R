# Made-up files in temporary folders; only names and header lines matter.

local_project <- function(files, env = parent.frame()) {
  dir <- withr::local_tempdir(.local_envir = env)
  for (f in names(files)) {
    path <- file.path(dir, f)
    dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
    writeLines(files[[f]], path)
  }
  dir
}

test_that("check_repo_for_usrds_data() flags data formats, USRDS file names and ID columns", {
  dir <- local_project(list(
    "analysis.R" = "x <- 1",
    "patients.R" = "# a script named like a USRDS file",
    "out/results.csv" = c("group,n", "a,20"),
    "out/cohort.csv" = c("\"usrds_id\",\"age\"", "1,50"),
    "raw/patients.csv" = c("age", "50"),
    "raw/core.parquet" = "not really parquet",
    "raw/extract.sas7bdat" = "not really sas"
  ))

  result <- check_repo_for_usrds_data(dir, quiet = TRUE)

  expect_equal(
    result$path,
    c("out/cohort.csv", "raw/core.parquet", "raw/extract.sas7bdat", "raw/patients.csv")
  )
  expect_equal(
    result$reason,
    c(
      "identifier column (USRDS_ID)",
      "data file type (.parquet)",
      "data file type (.sas7bdat)",
      "USRDS file name"
    )
  )
})

test_that("check_repo_for_usrds_data() reads ID columns from tab and semicolon headers", {
  dir <- local_project(list(
    "a.tsv" = c("USRDS_ID\tage", "1\t50"),
    "b.txt" = c("age;USRDS_ID", "50;1"),
    "c.csv" = c("age,usrds_idx", "50,1")
  ))

  result <- check_repo_for_usrds_data(dir, quiet = TRUE)

  expect_equal(result$path, c("a.tsv", "b.txt"))
})

test_that("check_repo_for_usrds_data() accepts other identifier columns", {
  dir <- local_project(list("srtr_extract.csv" = c("PX_ID,age", "1,50")))

  default <- check_repo_for_usrds_data(dir, quiet = TRUE)
  srtr <- check_repo_for_usrds_data(dir, id_columns = c("USRDS_ID", "PX_ID"), quiet = TRUE)

  expect_equal(nrow(default), 0)
  expect_equal(srtr$reason, "identifier column (PX_ID)")
})

test_that("check_repo_for_usrds_data() skips synthetic test fixtures", {
  dir <- local_project(list(
    "tests/testthat/fixtures/synthetic-claims.csv" = c("USRDS_ID,DIAG", "1,N18.6"),
    "tests/testthat/fixtures/claims.csv" = c("USRDS_ID,DIAG", "1,N18.6")
  ))

  result <- check_repo_for_usrds_data(dir, quiet = TRUE)

  expect_equal(result$path, "tests/testthat/fixtures/claims.csv")
})

test_that("check_repo_for_usrds_data() uses git's list, so ignored files are not flagged", {
  skip_if(Sys.which("git") == "", "git not available")
  dir <- local_project(list(
    ".gitignore" = "private/",
    "private/patients.parquet" = "x",
    "shared/patients.parquet" = "x"
  ))
  system2("git", c("-C", shQuote(dir), "init", "-q"))

  result <- check_repo_for_usrds_data(dir, quiet = TRUE)

  expect_equal(result$path, "shared/patients.parquet")
  expect_equal(attr(result, "scan"), "git")
})

test_that("check_repo_for_usrds_data() scans the folder outside a git repository", {
  dir <- local_project(list("patients.parquet" = "x"))
  withr::local_envvar(GIT_CEILING_DIRECTORIES = dirname(dir))

  result <- check_repo_for_usrds_data(dir, quiet = TRUE)

  expect_equal(result$path, "patients.parquet")
  expect_equal(attr(result, "scan"), "folder")
})

test_that("check_repo_for_usrds_data() reports paths only", {
  dir <- local_project(list("cohort.csv" = c("USRDS_ID,age", "1,50")))
  withr::local_dir(dir)
  withr::local_envvar(GIT_CEILING_DIRECTORIES = dirname(dir))

  expect_snapshot(check_repo_for_usrds_data("."))
})

test_that("check_repo_for_usrds_data() says when nothing is found", {
  dir <- local_project(list("analysis.R" = "x <- 1"))
  withr::local_dir(dir)
  withr::local_envvar(GIT_CEILING_DIRECTORIES = dirname(dir))

  expect_snapshot(result <- check_repo_for_usrds_data("."))
  expect_equal(nrow(result), 0)
  expect_named(result, c("path", "reason"))
})

test_that("check_repo_for_usrds_data() stops on a missing folder", {
  withr::local_dir(withr::local_tempdir())

  expect_snapshot(error = TRUE, check_repo_for_usrds_data("no-such-folder"))
})
