test_that("establish_dx_date() needs one inpatient claim or two other claims", {
  claims <- data.frame(
    USRDS_ID = c(1, 2, 2, 3),
    CLM_FROM = as.Date(c(
      "2010-03-01",
      "2010-02-01",
      "2010-01-01",
      "2010-01-01"
    )),
    HCFASAF = c(
      "Inpatient",
      "Physician/Supplier",
      "Physician/Supplier",
      "Physician/Supplier"
    )
  )

  result <- establish_dx_date(claims)

  expect_equal(result$USRDS_ID, c(1, 2))
  expect_equal(result$date_established, as.Date(c("2010-03-01", "2010-02-01")))
  expect_equal(result$diagnosis, c("diagnosis", "diagnosis"))
})

test_that("establish_dx_date() labels with the argument, not a data column of the same name", {
  claims <- data.frame(
    USRDS_ID = 1,
    CLM_FROM = as.Date("2010-03-01"),
    HCFASAF = "Inpatient",
    diagnosis_established = "from the data"
  )

  result <- establish_dx_date(claims, diagnosis_established = "diabetes")

  expect_equal(result$diagnosis, "diabetes")
})
