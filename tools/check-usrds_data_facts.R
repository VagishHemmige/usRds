# check-usrds_data_facts.R: check that tools/usrds_data_facts.R keeps
# values out of its shareable report.
#
# Builds a made-up USRDS-like folder in tempdir() (USRDS_ID 1, 2, 3; round
# dates; no real data), runs usrds_data_facts() on it, and stops with an
# error if a planted sentinel value, an unrecognised file name or the folder
# path reaches the report, or if the sentinels are missing from the local
# diagnostics file. Also checks the helpers directly.
#
# Run from the package root:
#   Rscript tools/check-usrds_data_facts.R
# CI runs it on pull requests that touch tools/ or R/
# (.github/workflows/tools-check.yaml).

stopifnot(file.exists("DESCRIPTION"), file.exists("tools/usrds_data_facts.R"))
Sys.unsetenv("USRDS_WD")
Sys.setenv(USRDS_LIVE_TESTS = "false")
pkgload::load_all(".", quiet = TRUE)
source("tools/usrds_data_facts.R")

failures <- character()
# `ok` is evaluated here, so a check that errors counts as failed.
check <- function(ok, what) {
  ok <- tryCatch(isTRUE(ok), error = function(e) FALSE)
  if (ok) {
    cat("ok    ", what, "\n")
  } else {
    cat("FAILED", what, "\n")
    failures <<- c(failures, what)
  }
}

sentinel <- "SYNTHETIC_PATIENT_123"

# ---- Helpers ----
summary <- tryCatch(
  .code_summary(c("P", sentinel, NA), c("P", "E")),
  error = function(e) list(shown = conditionMessage(e), other = character())
)
check(!grepl(sentinel, summary$shown, fixed = TRUE),
      ".code_summary() does not show a value outside the allowed codes")
check(sentinel %in% summary$other,
      ".code_summary() returns that value for the diagnostics file")
check(grepl("'P'", summary$shown, fixed = TRUE),
      ".code_summary() shows an allowed code")

no_list <- tryCatch(
  .code_summary(c("P", sentinel), character()),
  error = function(e) list(shown = sentinel)
)
check(!grepl(sentinel, no_list$shown, fixed = TRUE) &&
        !grepl("'P'", no_list$shown, fixed = TRUE),
      ".code_summary() shows no values when there is no Appendix C list")

check(all(c("E", "I", "P") %in% .appendix_c_codes("HCFASAF")),
      ".appendix_c_codes('HCFASAF') finds the Appendix C codes")
check(length(.appendix_c_codes("NOT_A_USRDS_COLUMN")) == 0,
      ".appendix_c_codes() finds nothing for an unknown column")

# ---- Whole report on a made-up folder ----
folder <- file.path(tempdir(), "made-up-usrds")
unlink(folder, recursive = TRUE)
dir.create(file.path(folder, "core"), recursive = TRUE)
dir.create(file.path(folder, "claims"))

utils::write.csv(
  data.frame(
    USRDS_ID = c(1, 2, 3),
    PAYER = c("MPAB", sentinel, "MPO"),
    BEGDATE = "01JAN2010"
  ),
  file.path(folder, "core", "payhist.csv"),
  row.names = FALSE
)
utils::write.csv(
  data.frame(
    USRDS_ID = c(1, 2, 3),
    DIAG = "B451",
    CLM_FROM = c("01JAN2010", "02/15/2010", "13/01/2010"),
    CLM_THRU = "02JAN2010",
    HCFASAF = c("P", "E", sentinel)
  ),
  file.path(folder, "claims", "ps2010a.csv"),
  row.names = FALSE
)
writeLines("x", file.path(folder, "core", paste0("patient_", sentinel, ".csv")))
writeLines("not a SAS file", file.path(folder, "core", "rxhist.sas7bdat"))

report_file <- file.path(tempdir(), "facts-report.txt")
diagnostics_file <- file.path(tempdir(), "facts-diagnostics.txt")
unlink(c(report_file, diagnostics_file))
# The script prints its report; keep that out of this check's output.
ran <- tryCatch({
  invisible(utils::capture.output(suppressMessages(usrds_data_facts(
    folder,
    out_file = report_file,
    diagnostics_file = diagnostics_file,
    n_rows = 100
  ))))
  TRUE
}, error = function(e) {
  cat("usrds_data_facts() stopped:", conditionMessage(e), "\n")
  FALSE
})
check(ran, "usrds_data_facts() runs on the made-up folder")
report <- if (file.exists(report_file)) readLines(report_file) else character()
diagnostics <- if (file.exists(diagnostics_file)) readLines(diagnostics_file) else character()

check(!any(grepl(sentinel, report, fixed = TRUE)),
      "report: no sentinel value or unrecognised file name")
check(!any(grepl(folder, report, fixed = TRUE)) &&
        !any(grepl(normalizePath(folder, winslash = "/"), report, fixed = TRUE)),
      "report: no folder path")
check(!any(grepl("'[^']*' [0-9<]", report)),
      "report: no counts after codes")
check(any(grepl("'MPAB'", report, fixed = TRUE)) &&
        any(grepl("'E'", report, fixed = TRUE)),
      "report: allowed codes are shown, so the checks above are not empty")
check(any(grepl("rxhist.sas7bdat: FAILS", report, fixed = TRUE)),
      "report: a SAS file that does not open is reported")
check(sum(grepl(sentinel, diagnostics, fixed = TRUE)) >= 3,
      "diagnostics: the sentinel values and file name are kept locally")

if (length(failures) > 0) {
  cat("\n", length(failures), "check(s) failed.\n")
  quit(status = 1)
}
cat("\nAll checks passed.\n")
