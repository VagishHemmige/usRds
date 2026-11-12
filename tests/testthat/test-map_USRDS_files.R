test_that(".map_USRDS_files() lists USRDS files by folder, root, suffix and year", {
  dir <- withr::local_tempdir()
  dir.create(file.path(dir, "ESRD Core"))
  dir.create(file.path(dir, "Physician supplier"))
  dir.create(file.path(dir, "Other"))
  file.create(file.path(dir, "ESRD Core", "patients.csv"))
  file.create(file.path(dir, "Physician supplier", "ps2010a.sas7bdat"))
  file.create(file.path(dir, "Other", "notes2010.csv"))
  withr::local_envvar(USRDS_WD = dir)
  old <- .usrds_env$file_list
  withr::defer(.usrds_env$file_list <- old)

  result <- .map_USRDS_files()
  result <- result[order(result$file_name), ]

  expect_equal(result$file_name, c("patients.csv", "ps2010a.sas7bdat"))
  expect_equal(result$file_root, c("patients", "ps2010a"))
  expect_equal(result$file_suffix, c("csv", "sas7bdat"))
  expect_equal(result$Year, c(NA, 2010))
  expect_equal(result$file_directory, c("Core", "PS"))
})
