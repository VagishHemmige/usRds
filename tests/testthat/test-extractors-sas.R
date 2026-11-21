# Offline tests of the SAS branch of the claim extractors. haven cannot write
# .sas7bdat files, so haven::read_sas() is replaced by a function returning
# made-up rows, and the file map points at a path that is never opened.

local_claims_sas <- function(file_root, rows, env = parent.frame()) {
  old <- .usrds_env$file_list
  .usrds_env$file_list <- data.frame(
    file_path = file.path(tempdir(), paste0(file_root, ".sas7bdat")),
    file_name = paste0(file_root, ".sas7bdat"),
    file_root = file_root,
    file_suffix = "sas7bdat",
    Year = 2010,
    file_directory = "Institution"
  )
  withr::defer(.usrds_env$file_list <- old, envir = env)
  testthat::local_mocked_bindings(
    read_sas = function(data_file, col_select = NULL, ...) {
      rows[, intersect(col_select, names(rows)), drop = FALSE]
    },
    .package = "haven",
    .env = env
  )
}

test_that("get_IN_ICD() keeps HCFASAF from SAS files (#1)", {
  local_claims_sas(
    "det2010a",
    data.frame(
      USRDS_ID = c(1, 2, 3),
      CODE = c("B451", "B451", "Z999"),
      CLM_FROM = as.Date(c("2010-01-01", "2010-02-15", "2010-03-01")),
      HCFASAF = c("I", "O", "I")
    )
  )

  result <- suppressMessages(get_IN_ICD(icd_codes = "B451", years = 2010))

  expect_named(result, c("USRDS_ID", "CODE", "CLM_FROM", "HCFASAF"))
  expect_equal(
    as.character(result$HCFASAF),
    c("Inpatient", "Outpatient")
  )
})

test_that("get_PS_ICD() keeps HCFASAF from SAS files (#1)", {
  local_claims_sas(
    "ps2010a",
    data.frame(
      USRDS_ID = c(1, 2, 3),
      DIAG = c("B451", "Z999", "B451"),
      CLM_FROM = as.Date(c("2010-01-01", "2010-02-15", "2010-03-01")),
      CLM_THRU = as.Date(c("2010-01-02", "2010-02-15", "2010-03-03")),
      HCFASAF = c("P", "P", "P")
    )
  )

  result <- suppressMessages(get_PS_ICD(icd_codes = "B451", years = 2010))

  expect_named(
    result,
    c("USRDS_ID", "DIAG", "CLM_FROM", "CLM_THRU", "HCFASAF")
  )
  expect_equal(
    as.character(result$HCFASAF),
    c("Physician/Supplier", "Physician/Supplier")
  )
})

test_that("establish_dx_date() keeps patients when years mix SAS and CSV (#1)", {
  csv_path <- withr::local_tempfile(fileext = ".csv")
  utils::write.csv(
    data.frame(
      USRDS_ID = c(1, 2),
      CODE = c("B451", "B451"),
      CLM_FROM = c("01JAN2011", "01FEB2011"),
      HCFASAF = c("O", "O")
    ),
    csv_path,
    row.names = FALSE
  )
  local_claims_sas(
    "det2010a",
    data.frame(
      USRDS_ID = c(1, 2),
      CODE = c("B451", "B451"),
      CLM_FROM = as.Date(c("2010-01-01", "2010-02-01")),
      HCFASAF = c("O", "O")
    )
  )
  .usrds_env$file_list <- rbind(
    .usrds_env$file_list,
    data.frame(
      file_path = csv_path,
      file_name = "det2011a.csv",
      file_root = "det2011a",
      file_suffix = "csv",
      Year = 2011,
      file_directory = "Institution"
    )
  )

  claims <- suppressMessages(get_IN_ICD(icd_codes = "B451", years = 2010:2011))
  result <- establish_dx_date(claims)

  expect_equal(result$USRDS_ID, c(1, 2), ignore_attr = TRUE)
  expect_equal(
    result$date_established,
    as.Date(c("2011-01-01", "2011-02-01")),
    ignore_attr = TRUE
  )
})
