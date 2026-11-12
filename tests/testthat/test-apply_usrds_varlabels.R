test_that("apply_usrds_varlabels() labels variables from Appendix B", {
  df <- data.frame(USRDS_ID = 1, born = as.Date("1950-01-01"))

  result <- apply_usrds_varlabels(df, "patients")

  expect_equal(labelled::var_label(result$born), "Date of birth")
})
