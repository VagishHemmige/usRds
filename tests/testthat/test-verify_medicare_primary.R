medicare_ab <- "MEDICARE FFS PRIMARY PAY, FOR BOTH PART A AND PART B"

payhist <- function() {
  data.frame(
    USRDS_ID = c(1, 1, 2, 3),
    PAYER = c(
      medicare_ab,
      medicare_ab,
      medicare_ab,
      "EMPLOYER GROUP HEALTH PLAN"
    ),
    BEGDATE = as.Date(c(
      "2009-01-01",
      "2009-07-01",
      "2010-03-01",
      "2009-01-01"
    )),
    ENDDATE = as.Date(c("2009-06-30", "2010-12-31", "2010-12-31", "2010-12-31"))
  )
}

patients <- function() {
  data.frame(
    USRDS_ID = c(1, 2, 3),
    index = as.Date(c("2010-06-01", "2010-06-01", "2010-06-01"))
  )
}

test_that("verify_medicare_primary() needs Medicare primary for the whole lookback", {
  result <- verify_medicare_primary(
    patients(),
    index_date = "index",
    medicare_coverage_df = payhist(),
    coverage_start_variable = "coverage_start",
    coverage_end_variable = "coverage_end"
  )

  expect_equal(result$medicare_primary_TF, c(TRUE, FALSE, FALSE))
  expect_equal(
    result$coverage_start,
    as.Date(c("2009-01-01", "2010-03-01", NA))
  )
  expect_equal(result$coverage_end, as.Date(c("2010-12-31", "2010-12-31", NA)))
  expect_named(
    result,
    c(
      "USRDS_ID",
      "index",
      "medicare_primary_TF",
      "coverage_start",
      "coverage_end"
    )
  )
})

test_that("verify_medicare_primary() accepts a fixed index date", {
  result <- verify_medicare_primary(
    patients(),
    index_date = as.Date("2010-02-01"),
    medicare_coverage_df = payhist()
  )

  expect_equal(result$medicare_primary_TF, c(TRUE, FALSE, FALSE))
  expect_named(result, c("USRDS_ID", "index", "medicare_primary_TF"))
})

test_that("verify_medicare_primary() uses its argument, not a data column named lookback_days", {
  df <- patients()
  df$lookback_days <- 0

  result <- verify_medicare_primary(
    df,
    index_date = "index",
    medicare_coverage_df = payhist()
  )

  expect_equal(result$medicare_primary_TF, c(TRUE, FALSE, FALSE))
})

# Replaces load_usrds_file() with a stand-in that returns payhist() rows for
# the requested patients and counts how often it is called.
local_payhist_reader <- function(env = parent.frame()) {
  calls <- new.env()
  calls$n <- 0
  testthat::local_mocked_bindings(
    load_usrds_file = function(file_key, usrds_ids = NULL, ...) {
      calls$n <- calls$n + 1
      rows <- payhist()
      rows[rows$USRDS_ID %in% usrds_ids, ]
    },
    .env = env
  )
  withr::local_envvar(USRDS_WD = "/usrds/folder-a", .local_envir = env)
  old <- .usrds_env$medicare_history
  withr::defer(.usrds_env$medicare_history <- old, envir = env)
  .usrds_env$medicare_history <- NULL
  calls
}

test_that("verify_medicare_primary() reuses the cache for patients it covers", {
  calls <- local_payhist_reader()

  first <- suppressMessages(
    verify_medicare_primary(patients(), index_date = "index", cache = TRUE)
  )
  second <- verify_medicare_primary(
    patients()[1, ],
    index_date = "index",
    cache = TRUE
  )

  expect_equal(calls$n, 1)
  expect_equal(second$medicare_primary_TF, first$medicare_primary_TF[1])
})

test_that("verify_medicare_primary() rereads payhist for patients not in the cache", {
  calls <- local_payhist_reader()

  suppressMessages(
    verify_medicare_primary(patients()[2, ], index_date = "index", cache = TRUE)
  )
  result <- suppressMessages(
    verify_medicare_primary(patients(), index_date = "index", cache = TRUE)
  )

  expect_equal(calls$n, 2)
  expect_equal(result$medicare_primary_TF, c(TRUE, FALSE, FALSE))
})

test_that("verify_medicare_primary() does not use a cache from another folder", {
  calls <- local_payhist_reader()

  suppressMessages(
    verify_medicare_primary(patients(), index_date = "index", cache = TRUE)
  )
  withr::local_envvar(USRDS_WD = "/usrds/folder-b")
  suppressMessages(
    verify_medicare_primary(patients(), index_date = "index", cache = TRUE)
  )

  expect_equal(calls$n, 2)
})

test_that("verify_medicare_primary() neither uses nor fills the cache with medicare_coverage_df", {
  calls <- local_payhist_reader()

  verify_medicare_primary(
    patients(),
    index_date = "index",
    medicare_coverage_df = payhist(),
    cache = TRUE
  )

  expect_null(.usrds_env$medicare_history)
  expect_equal(calls$n, 0)
})
