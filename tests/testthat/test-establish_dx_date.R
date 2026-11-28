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

test_that("establish_dx_date() counts REBUS inpatient stays as inpatient (#4)", {
  claims <- data.frame(
    USRDS_ID = 1,
    CLM_FROM = as.Date("2005-03-01"),
    HCFASAF = factor("Inpatient (REBUS)")
  )

  expect_equal(establish_dx_date(claims)$date_established, as.Date("2005-03-01"))
  expect_equal(
    nrow(establish_dx_date(claims, inpatient_types = "Inpatient")),
    0
  )
})

test_that("establish_dx_date(window_days =) needs two other claims close together (#4)", {
  # Patient 1: claims 100 days apart, then a third 20 days later.
  # Patient 2: claims 100 days apart only.
  claims <- data.frame(
    USRDS_ID = c(1, 1, 1, 2, 2),
    CLM_FROM = as.Date("2010-01-01") + c(0, 100, 120, 0, 100),
    HCFASAF = "Physician/Supplier"
  )

  no_window <- establish_dx_date(claims)
  windowed <- establish_dx_date(claims, window_days = 30)

  expect_equal(no_window$date_established, as.Date("2010-01-01") + c(100, 100))
  expect_equal(windowed$USRDS_ID, 1)
  expect_equal(windowed$date_established, as.Date("2010-01-01") + 120)
})

test_that("establish_dx_date(date_as = \"first\") dates the earliest claim in the window (#4)", {
  # Patient 1: two outpatient claims; patient 2: an outpatient claim, then an
  # inpatient claim; patient 3: an old claim outside the window, then a pair.
  claims <- data.frame(
    USRDS_ID = c(1, 1, 2, 2, 3, 3, 3),
    CLM_FROM = as.Date("2010-01-01") + c(0, 10, 0, 5, 0, 200, 210),
    HCFASAF = c(
      "Outpatient", "Outpatient",
      "Outpatient", "Inpatient",
      "Outpatient", "Outpatient", "Outpatient"
    )
  )

  confirming <- establish_dx_date(claims, window_days = 30)
  first <- establish_dx_date(claims, date_as = "first", window_days = 30)

  expect_equal(confirming$date_established, as.Date("2010-01-01") + c(10, 5, 210))
  expect_equal(first$date_established, as.Date("2010-01-01") + c(0, 0, 200))
})

test_that("establish_dx_date() keeps today's dates by default (#4)", {
  claims <- data.frame(
    USRDS_ID = c(1, 1, 1, 2),
    CLM_FROM = as.Date("2010-01-01") + c(0, 400, 800, 0),
    HCFASAF = c("Outpatient", "Outpatient", "Inpatient", "Physician/Supplier")
  )

  expect_equal(
    establish_dx_date(claims)$date_established,
    as.Date("2010-01-01") + 400
  )
})

test_that("establish_dx_date() needs two other claims on different days (#4)", {
  # Patient 1: two outpatient rows on one day. Patient 2: two rows on one day,
  # then a third 10 days later. Patient 3: an inpatient row on the same day
  # as an outpatient row.
  claims <- data.frame(
    USRDS_ID = c(1, 1, 2, 2, 2, 3, 3),
    CLM_FROM = as.Date("2010-01-01") + c(0, 0, 0, 0, 10, 0, 0),
    HCFASAF = c(
      "Outpatient", "Outpatient",
      "Outpatient", "Outpatient", "Outpatient",
      "Outpatient", "Inpatient"
    )
  )

  days <- establish_dx_date(claims)
  rows <- establish_dx_date(claims, count_by = "rows")

  expect_equal(days$USRDS_ID, c(2, 3))
  expect_equal(days$date_established, as.Date("2010-01-01") + c(10, 0))
  expect_equal(rows$USRDS_ID, c(1, 2, 3))
  expect_equal(rows$date_established, as.Date("2010-01-01") + c(0, 0, 0))
})

test_that("establish_dx_date(count_by = \"days\") measures window_days between days (#4)", {
  # Two rows on day 0, then one on day 40: with a 30-day window the two days
  # are too far apart, though the two day-0 rows are 0 days apart.
  claims <- data.frame(
    USRDS_ID = 1,
    CLM_FROM = as.Date("2010-01-01") + c(0, 0, 40),
    HCFASAF = "Outpatient"
  )

  expect_equal(nrow(establish_dx_date(claims, window_days = 30)), 0)
  expect_equal(
    establish_dx_date(claims, window_days = 30, count_by = "rows")$date_established,
    as.Date("2010-01-01")
  )
  expect_equal(
    establish_dx_date(claims, window_days = 40, date_as = "first")$date_established,
    as.Date("2010-01-01")
  )
})

test_that("establish_dx_date() warns about claims with a missing CLM_FROM (#4)", {
  # Patient 1: one dated and one undated outpatient claim, so no diagnosis.
  # Patient 2: undated inpatient claim, plus two dated outpatient claims.
  # Patient 3: dated claims only.
  claims <- data.frame(
    USRDS_ID = c(1, 1, 2, 2, 2, 3),
    CLM_FROM = as.Date(c(
      "2010-01-01", NA, NA, "2010-02-01", "2010-03-01", "2010-01-01"
    )),
    HCFASAF = c(
      "Outpatient", "Outpatient",
      "Inpatient", "Outpatient", "Outpatient",
      "Inpatient"
    )
  )
  dated <- claims[!is.na(claims$CLM_FROM), ]

  expect_snapshot(result <- establish_dx_date(claims))
  expect_equal(result, establish_dx_date(dated))
  expect_equal(result$USRDS_ID, c(2, 3))
  expect_no_warning(establish_dx_date(claims, on_missing_date = "ignore"))
  expect_no_warning(establish_dx_date(dated))
  expect_snapshot(
    error = TRUE,
    establish_dx_date(claims, on_missing_date = "error")
  )
})

test_that("establish_dx_date() checks its options (#4)", {
  claims <- data.frame(
    USRDS_ID = 1,
    CLM_FROM = as.Date("2010-01-01"),
    HCFASAF = "Inpatient"
  )

  expect_snapshot(error = TRUE, establish_dx_date(claims, window_days = -1))
  expect_snapshot(error = TRUE, establish_dx_date(claims, date_as = "last"))
  expect_snapshot(error = TRUE, establish_dx_date(claims, count_by = "claims"))
  expect_snapshot(
    error = TRUE,
    establish_dx_date(claims, on_missing_date = "drop")
  )
})

test_that("establish_dx_date() requires CLM_FROM to be a Date", {
  claims <- data.frame(
    USRDS_ID = c(1, 1),
    CLM_FROM = as.POSIXct(c("2010-01-01", "2010-01-11"), tz = "UTC"),
    HCFASAF = "Outpatient"
  )

  expect_snapshot(error = TRUE, establish_dx_date(claims, window_days = 30))
})
