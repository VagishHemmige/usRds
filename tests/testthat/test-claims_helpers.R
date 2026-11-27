test_that(".filter_in() keeps every row when values is NULL", {
  df <- data.frame(CODE = c("A", "B"))

  expect_equal(.filter_in(df, "CODE", NULL), df)
})

test_that(".filter_in() keeps rows whose column is in values", {
  df <- data.frame(CODE = c("A", "B", "C"))

  expect_equal(.filter_in(df, "CODE", c("A", "C"))$CODE, c("A", "C"))
})

test_that(".filter_in() uses its argument, not a column named values", {
  df <- data.frame(CODE = c("A", "B"), values = c("B", "B"))

  expect_equal(.filter_in(df, "CODE", "A")$CODE, "A")
})

test_that(".parse_claim_dates() reads DATE9. and ISO text and keeps Date (#33)", {
  claims <- data.frame(
    CLM_FROM = c("01JAN2010", "15FEB2010"),
    CLM_THRU = c("2010-01-03", "2010-02-15"),
    OTHER = as.Date(c("2010-01-01", "2010-02-01"))
  )

  result <- expect_no_warning(
    .parse_claim_dates(claims, c("CLM_FROM", "CLM_THRU", "OTHER"), "x.csv")
  )

  expect_equal(result$CLM_FROM, as.Date(c("2010-01-01", "2010-02-15")))
  expect_equal(result$CLM_THRU, as.Date(c("2010-01-03", "2010-02-15")))
  expect_equal(result$OTHER, claims$OTHER)
})

test_that(".parse_claim_dates() treats blank and '.' as missing, without warning (#33)", {
  claims <- data.frame(CLM_THRU = c("01JAN2010", "", ".", NA))

  result <- expect_no_warning(.parse_claim_dates(claims, "CLM_THRU", "x.csv"))

  expect_equal(result$CLM_THRU, as.Date(c("2010-01-01", NA, NA, NA)))
})

test_that(".parse_claim_dates() warns with a count, not the values (#33)", {
  claims <- data.frame(CLM_THRU = c("01JAN2010", "13/45/2010", "12345"))

  expect_snapshot(
    result <- .parse_claim_dates(claims, "CLM_THRU", "inc2010a.csv")
  )
  expect_equal(result$CLM_THRU, as.Date(c("2010-01-01", NA, NA)))
})

test_that(".parse_claim_dates() reads each value on its own, so one bad value spoils no other (#33)", {
  claims <- data.frame(CLM_FROM = c("2010-01-01", "01FEB2010", "not a date"))

  expect_warning(
    result <- .parse_claim_dates(claims, "CLM_FROM", "x.csv"),
    class = "usrds_unparsed_dates"
  )

  expect_equal(result$CLM_FROM, as.Date(c("2010-01-01", "2010-02-01", NA)))
})

test_that(".parse_claim_dates() does not guess the order of slash dates (#33)", {
  claims <- data.frame(CLM_FROM = c("01/02/2010", "01FEB2010"))

  expect_warning(
    result <- .parse_claim_dates(claims, "CLM_FROM", "x.csv"),
    class = "usrds_unparsed_dates"
  )

  expect_equal(result$CLM_FROM, as.Date(c(NA, "2010-02-01")))
})

test_that(".parse_claim_dates() reads numbers as 1970-based days only when asked (#33)", {
  claims <- data.frame(CLM_FROM = c(14610, 14641))

  expect_equal(
    .parse_claim_dates(claims, "CLM_FROM", "x.parquet", numeric_as_unix_days = TRUE)$CLM_FROM,
    as.Date(c("2010-01-01", "2010-02-01"))
  )
  expect_warning(
    .parse_claim_dates(claims, "CLM_FROM", "x.csv"),
    class = "usrds_unparsed_dates"
  )
})

test_that(".hcfasaf_factor() labels every Appendix C claim type, including DME (#27)", {
  codes <- c("I", "M", "O", "D", "N", "H", "S", "Q", "P", "E")

  result <- .hcfasaf_factor(codes)

  expect_s3_class(result, "factor")
  expect_false(anyNA(result))
  expect_equal(as.character(result[codes == "E"]), "Durable Medical Equipment")
  expect_equal(as.character(result[codes == "Q"]), "Quarterly dialysis (PMMIS)")
  expect_equal(as.character(result[codes == "M"]), "Inpatient (REBUS)")
})

test_that(".hcfasaf_factor() warns about codes not in Appendix C (#27)", {
  expect_snapshot(result <- .hcfasaf_factor(c("I", "Z", NA)))
  expect_equal(as.character(result), c("Inpatient", NA, NA))
})

test_that("establish_dx_date() keeps patients with DME claims (#27)", {
  claims <- data.frame(
    USRDS_ID = c(1, 1),
    CLM_FROM = as.Date(c("2015-01-01", "2015-02-01")),
    HCFASAF = .hcfasaf_factor(c("E", "P"))
  )

  expect_equal(establish_dx_date(claims)$USRDS_ID, 1)
})
