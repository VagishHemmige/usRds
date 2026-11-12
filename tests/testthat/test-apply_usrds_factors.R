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
