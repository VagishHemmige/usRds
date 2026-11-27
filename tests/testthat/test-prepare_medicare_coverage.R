# Made-up payer history: USRDS_IDs 1 to 4, round 2009-2010 dates.
# Patient 1: two touching MPAB spans; 2: one MPAB span starting 2010-03-01;
# 3: MSP-EGHP only; 4: MPO only.
coverage_payhist <- function() {
  data.frame(
    USRDS_ID = c(1, 1, 2, 3, 4),
    PAYER = c("MPAB", "MPAB", "MPAB", "MSP-EGHP", "MPO"),
    BEGDATE = as.Date(c(
      "2009-01-01",
      "2009-07-01",
      "2010-03-01",
      "2009-01-01",
      "2009-01-01"
    )),
    ENDDATE = as.Date(c(
      "2009-06-30",
      "2010-12-31",
      "2010-12-31",
      "2010-12-31",
      "2010-12-31"
    ))
  )
}

coverage_patients <- function() {
  data.frame(USRDS_ID = 1:4, index = as.Date("2010-06-01"))
}

test_that("prepare_medicare_coverage() returns one row per merged spell", {
  coverage <- prepare_medicare_coverage(coverage_payhist())

  expect_s3_class(coverage, "usrds_medicare_coverage")
  expect_equal(coverage$USRDS_ID, c(1, 2, 4))
  expect_equal(
    coverage$BEGDATE,
    as.Date(c("2009-01-01", "2010-03-01", "2009-01-01"))
  )
  expect_equal(coverage$ENDDATE, as.Date(rep("2010-12-31", 3)))
  expect_equal(attr(coverage, "payers"), c("MPAB", "MPO"))
})

test_that("prepare_medicare_coverage() keeps only the payers asked for", {
  coverage <- prepare_medicare_coverage(coverage_payhist(), payers = "MPAB")

  expect_equal(coverage$USRDS_ID, c(1, 2))
  expect_equal(attr(coverage, "payers"), "MPAB")
})

test_that("prepare_medicare_coverage() accepts Appendix C labels in PAYER", {
  labelled <- coverage_payhist()
  labelled$PAYER <- c(
    rep("MEDICARE FFS PRIMARY PAY, FOR BOTH PART A AND PART B", 3),
    "MEDICARE FFS SECONDARY PAYER WITH EMPLOYER GROUP HEALTH PLAN(EGHP)",
    "MEDICARE FFS PRIMARY PAY, FOR OTHER"
  )

  expect_equal(
    prepare_medicare_coverage(labelled),
    prepare_medicare_coverage(coverage_payhist())
  )
})

test_that("prepare_medicare_coverage() rejects payer codes not in Appendix C", {
  expect_snapshot(
    error = TRUE,
    prepare_medicare_coverage(coverage_payhist(), payers = c("MPAB", "MEDICARE"))
  )
})

test_that("verify_medicare_primary() gives the same answer from prepared coverage", {
  from_payhist <- verify_medicare_primary(
    coverage_patients(),
    index_date = "index",
    medicare_coverage_df = coverage_payhist(),
    coverage_start_variable = "coverage_start",
    coverage_end_variable = "coverage_end"
  )

  from_prepared <- verify_medicare_primary(
    coverage_patients(),
    index_date = "index",
    medicare_coverage_df = prepare_medicare_coverage(coverage_payhist()),
    coverage_start_variable = "coverage_start",
    coverage_end_variable = "coverage_end"
  )

  expect_equal(from_prepared, from_payhist)
  expect_equal(from_prepared$medicare_primary_TF, c(TRUE, FALSE, FALSE, TRUE))
})

test_that("verify_medicare_primary() does not rebuild prepared coverage", {
  coverage <- prepare_medicare_coverage(coverage_payhist())
  builds <- 0
  local_mocked_bindings(
    .build_medicare_spells = function(...) {
      builds <<- builds + 1
      stop("rebuilt")
    }
  )

  for (i in 1:3) {
    verify_medicare_primary(
      coverage_patients(),
      index_date = "index",
      medicare_coverage_df = coverage
    )
  }

  expect_equal(builds, 0)
})

test_that("verify_medicare_primary(payers =) limits the payers counted", {
  result <- verify_medicare_primary(
    coverage_patients(),
    index_date = "index",
    medicare_coverage_df = coverage_payhist(),
    payers = "MPAB"
  )

  expect_equal(result$medicare_primary_TF, c(TRUE, FALSE, FALSE, FALSE))
})

test_that("verify_medicare_primary() uses the payers of prepared coverage", {
  result <- verify_medicare_primary(
    coverage_patients(),
    index_date = "index",
    medicare_coverage_df = prepare_medicare_coverage(
      coverage_payhist(),
      payers = "MPAB"
    )
  )

  expect_equal(result$medicare_primary_TF, c(TRUE, FALSE, FALSE, FALSE))
})

test_that("verify_medicare_primary() stops when payers disagree with prepared coverage", {
  coverage <- prepare_medicare_coverage(coverage_payhist(), payers = "MPAB")

  expect_snapshot(
    error = TRUE,
    verify_medicare_primary(
      coverage_patients(),
      index_date = "index",
      medicare_coverage_df = coverage,
      payers = c("MPAB", "MPO")
    )
  )
})

test_that("verify_medicare_primary() still warns about patients absent from prepared coverage's payhist", {
  extra <- rbind(
    coverage_patients(),
    data.frame(USRDS_ID = 5, index = as.Date("2010-06-01"))
  )

  expect_snapshot(
    result <- verify_medicare_primary(
      extra,
      index_date = "index",
      medicare_coverage_df = prepare_medicare_coverage(coverage_payhist())
    )
  )
  expect_equal(result$medicare_primary_TF, c(TRUE, FALSE, FALSE, TRUE, FALSE))
})

test_that("payers accepts Appendix C labels as well as codes", {
  by_label <- prepare_medicare_coverage(
    coverage_payhist(),
    payers = "MEDICARE FFS PRIMARY PAY, FOR BOTH PART A AND PART B"
  )
  mixed <- verify_medicare_primary(
    coverage_patients(),
    index_date = "index",
    medicare_coverage_df = coverage_payhist(),
    payers = c("MPAB", "MEDICARE FFS PRIMARY PAY, FOR OTHER")
  )

  expect_equal(by_label, prepare_medicare_coverage(coverage_payhist(), payers = "MPAB"))
  expect_equal(attr(by_label, "payers"), "MPAB")
  expect_equal(mixed$medicare_primary_TF, c(TRUE, FALSE, FALSE, TRUE))
})
