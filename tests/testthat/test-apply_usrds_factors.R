test_that("apply_usrds_factors() turns coded variables into labelled factors", {
  codes <- metadata_c[["REMCD"]]
  df <- data.frame(USRDS_ID = c(1, 2), CAN_REM_CD = codes$value[1:2])

  result <- apply_usrds_factors(df, "PATIENTS")

  expect_s3_class(result$CAN_REM_CD, "factor")
  expect_equal(as.character(result$CAN_REM_CD), codes$description[1:2])
})

test_that("apply_usrds_factors() leaves date-formatted variables alone", {
  df <- data.frame(USRDS_ID = 1, BORN = as.Date("1950-01-01"))

  result <- apply_usrds_factors(df, "PATIENTS")

  expect_s3_class(result$BORN, "Date")
})

# These two tests fail until R/sysdata.rda is rebuilt from
# data-raw/sysdata-metadata_helpers.R with line breaks removed (#18).
test_that("Appendix B names and formats in metadata_b have no line breaks (#18)", {
  expect_false(any(grepl("[\r\n]", metadata_b$variable)))
  expect_false(any(grepl("[\r\n]", metadata_b$format)))
})

test_that("apply_usrds_factors() labels MEDEVID columns whose names wrapped in Appendix B (#18)", {
  codes <- metadata_c[["YNUFMT"]]
  df <- data.frame(USRDS_ID = c(1, 2), COMO_DM_NOMEDS = codes$value[1:2])

  result <- apply_usrds_factors(df, "MEDEVID")

  expect_s3_class(result$COMO_DM_NOMEDS, "factor")
  expect_equal(as.character(result$COMO_DM_NOMEDS), codes$description[1:2])
})
