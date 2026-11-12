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
