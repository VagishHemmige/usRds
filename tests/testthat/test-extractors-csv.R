# Offline tests of the CSV branch of the claim extractors, using made-up
# three-row files in a temporary folder. Real-data tests are in the
# test-get_*.R files.

local_claims_csv <- function(file_root, rows, env = parent.frame()) {
  dir <- withr::local_tempdir(.local_envir = env)
  path <- file.path(dir, paste0(file_root, ".csv"))
  utils::write.csv(rows, path, row.names = FALSE)
  old <- .usrds_env$file_list
  .usrds_env$file_list <- data.frame(
    file_path = path,
    file_name = paste0(file_root, ".csv"),
    file_root = file_root,
    file_suffix = "csv",
    Year = 2010,
    file_directory = "Institution"
  )
  withr::defer(.usrds_env$file_list <- old, envir = env)
  path
}

test_that("get_IN_ICD() filters CSV claims by code and ID", {
  local_claims_csv("det2010a", data.frame(
    USRDS_ID = c(1, 2, 3),
    CODE = c("B451", "B451", "Z999"),
    CLM_FROM = c("01JAN2010", "15FEB2010", "01MAR2010"),
    HCFASAF = c("I", "O", "I")
  ))

  result <- suppressMessages(get_IN_ICD(icd_codes = "B451", years = 2010, usrds_ids = 1))

  expect_equal(result$USRDS_ID, 1, ignore_attr = TRUE)
  expect_equal(result$CLM_FROM, as.Date("2010-01-01"), ignore_attr = TRUE)
  expect_equal(as.character(result$HCFASAF), "Inpatient")
})

test_that("get_PS_ICD() filters CSV claims by code", {
  local_claims_csv("ps2010a", data.frame(
    USRDS_ID = c(1, 2, 3),
    DIAG = c("B451", "Z999", "B451"),
    CLM_FROM = c("01JAN2010", "15FEB2010", "01MAR2010"),
    CLM_THRU = c("02JAN2010", "15FEB2010", "03MAR2010"),
    HCFASAF = c("P", "P", "P")
  ))

  result <- suppressMessages(get_PS_ICD(icd_codes = "B451", years = 2010))

  expect_equal(result$USRDS_ID, c(1, 3), ignore_attr = TRUE)
  expect_equal(result$CLM_THRU, as.Date(c("2010-01-02", "2010-03-03")), ignore_attr = TRUE)
  expect_equal(as.character(result$HCFASAF), c("Physician/Supplier", "Physician/Supplier"))
})

test_that("get_IN_HCPCS() filters CSV claims by HCPCS code", {
  local_claims_csv("rev2010a", data.frame(
    USRDS_ID = c(1, 2, 3),
    HCPCS = c("J1234", "J9999", "J1234"),
    CLM_FROM = c("01JAN2010", "15FEB2010", "01MAR2010"),
    HCFASAF = c("O", "O", "I"),
    REVPMT = c(10, 20, 30),
    REV_CH = c(15, 25, 35)
  ))

  result <- suppressMessages(get_IN_HCPCS(hcpcs_codes = "J1234", years = 2010))

  expect_equal(result$USRDS_ID, c(1, 3), ignore_attr = TRUE)
  expect_equal(result$CLM_FROM, as.Date(c("2010-01-01", "2010-03-01")), ignore_attr = TRUE)
})
