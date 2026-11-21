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
