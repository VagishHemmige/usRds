# End of claims-based follow-up

For each row, finds the last day of follow-up for a claims-based
outcome: the earliest of death, the end of the Medicare-primary coverage
spell containing the index date, the date the claims are complete to, a
study end date, and a maximum length of follow-up. Every end date is the
last day observed, so a patient is followed from `index_date` through
`followup_end`, both included.

## Usage

``` r
claims_followup_end(
  df,
  index_date,
  coverage_end,
  death_date = NULL,
  claims_end,
  study_end = NULL,
  max_days = NULL
)
```

## Arguments

- df:

  A data frame with a column `USRDS_ID` and the columns named below.

- index_date:

  The name of a `Date` column in `df`: the first day of follow-up. A
  missing value means follow-up never starts: `followup_end` is then
  `NA`, with reason `"no_index"`.

- coverage_end:

  The name of a `Date` column in `df` holding the end of the
  Medicare-primary spell that contains the index date, as returned by
  [`verify_medicare_primary()`](https://vagishhemmige.github.io/usRds/reference/verify_medicare_primary.md)
  through `coverage_end_variable`. A missing value means the patient has
  no Medicare-primary spell at the index date: `followup_end` is then
  `NA`, with reason `"no_coverage"`.

- death_date:

  Optional name of a `Date` column in `df` holding the date of death
  (for example `DIED` from the `patients` file). A missing value means
  the patient is not known to have died.

- claims_end:

  Required. The last date the claims are complete to, for the release in
  use (`as.Date("2023-12-31")` for the 2025 standard analysis files). It
  has no default because it changes with every release.

- study_end:

  Optional last day of the study: a `Date`, or the name of a `Date`
  column in `df`.

- max_days:

  Optional largest number of whole days after the index date; the last
  day is `index_date + max_days`.

## Value

`df` with two added columns: `followup_end` (`Date`) and
`followup_end_reason`, one of `"death"`, `"coverage_end"`,
`"claims_end"`, `"study_end"`, `"max_days"`, `"no_coverage"` or
`"no_index"`. When two ends fall on the same day, the reason is the
first in that order. A missing index date takes precedence over missing
coverage.

## Details

Claims end before the payer history and the death records do: in the
2025 standard analysis files, claims are complete through 2023-12-31
while the core files run through 2024-12-31 (Researcher's Guide 2025,
Section 5, "Introduction"). An open payer spell is given the end of the
data period as its `ENDDATE` (Section 4, "ESRD Payer Sequence File"), so
the coverage end alone does not stop follow-up when the claims stop. The
2017 Annual Data Report (Volume 2, ESRD Analytical Methods,
hospitalization) censors at death, at the end of Medicare Parts A and B
or Medicare primary, and at December 31.

## Examples

``` r
patients <- data.frame(
  USRDS_ID = c(1, 2),
  index = as.Date(c("2015-01-01", "2015-01-01")),
  DIED = as.Date(c("2015-03-01", NA)),
  coverage_end = as.Date(c("2016-12-31", "2015-06-30"))
)
claims_followup_end(
  patients,
  index_date = "index",
  coverage_end = "coverage_end",
  death_date = "DIED",
  claims_end = as.Date("2023-12-31"),
  max_days = 364
)
#>   USRDS_ID      index       DIED coverage_end followup_end followup_end_reason
#> 1        1 2015-01-01 2015-03-01   2016-12-31   2015-03-01               death
#> 2        2 2015-01-01       <NA>   2015-06-30   2015-06-30        coverage_end
```
