# Verify that a patient has Medicare primary coverage

This function accepts a data frame `df`, an index date option
`index_date` which is either a fixed date or the name of a date variable
in quotes, and a variable `lookback_days` that encodes how many days of
Medicare coverage are necessary.

## Usage

``` r
verify_medicare_primary(
  df,
  index_date,
  lookback_days = 365,
  medicare_coverage_df = NULL,
  coverage_start_variable = NULL,
  coverage_end_variable = NULL,
  cache = FALSE,
  payers = NULL
)
```

## Arguments

- df:

  is a data frame, presumably one with a single row per patient. Data
  frame *must* contain a column named `USRDS_ID`.

- index_date:

  either a fixed date or the name of a date variable in quotes

- lookback_days:

  is the number of days of Medicare as primary necessary. Default value
  is 365.

- medicare_coverage_df:

  is an optional parameter containing a df from the `payhist` file, or
  the result of
  [`prepare_medicare_coverage()`](https://vagishhemmige.github.io/usRds/reference/prepare_medicare_coverage.md),
  which is used as it is.

- coverage_start_variable:

  is the name of the variable containing the start date of Medicare
  primary coverage for the coverage spell containing the `index_date`.
  The default value of NULL specifies no variable returned.

- coverage_end_variable:

  is the name of the variable containing the end date of Medicare
  primary coverage for the coverage spell containing the `index_date`.
  The default value of NULL specifies no variable returned.

- cache:

  whether or not to cache, or use a previously cached version, of the
  medicare coverage data frame. This can save substantial amounts of
  time in a loop. The cache is used only when it was built from the same
  USRDS folder and covers every patient in `df`; otherwise `payhist` is
  read again and the cache replaced. It is cleared whenever the files
  are mapped again with
  [`set_USRDS_wd()`](https://vagishhemmige.github.io/usRds/reference/set_USRDS_wd.md).
  Ignored when `medicare_coverage_df` is given.

- payers:

  Payers that count as Medicare primary, as Appendix C `$PAYCAT.` codes
  or their labels. `NULL` (the default) means `c("MPAB", "MPO")`, or,
  when `medicare_coverage_df` comes from
  [`prepare_medicare_coverage()`](https://vagishhemmige.github.io/usRds/reference/prepare_medicare_coverage.md),
  the payers it was prepared with. Payers that disagree with prepared
  coverage are an error.

## Value

The original `df` data fame with the variable `medicare_primary_TF`
added

## Details

An optional variable `medicare_coverage_df` allows for a df containing
information from the `payhist` file to be passed to the function. If
left NULL, then the function will load the data via the
`load_usrds_file` function, which can be very inefficient for multiple
function calls.

It returns the same dataframe with a new variable `medicare_primary_TF`
that takes the values `TRUE` or `FALSE`.

Optionally, the start dates and end dates of Medicare primary coverage
for that coverage spell can also be returned by specifying names for the
return variables in the `coverage_start_variable` and
`coverage_end_variable` parameters. If unspecified, these parameters
will not be returned.

When the function reads `payhist` itself, setting `cache = TRUE` keeps
the processed coverage for later calls. Payer history passed as
`medicare_coverage_df` is never cached; use
[`prepare_medicare_coverage()`](https://vagishhemmige.github.io/usRds/reference/prepare_medicare_coverage.md)
instead.

`medicare_primary_TF` is `TRUE` when the patient is continuously covered
by the payers in `payers` from `lookback_days` before the index date
through the index date. With the default payers, `MPAB` (Medicare
fee-for-service primary pay for both Part A and Part B) and `MPO`
(Medicare fee-for-service primary pay, for other), that is Medicare
primary coverage: the Researcher's Guide 2025 uses these two codes for a
Medicare-primary cohort (Example 8) and notes that Medicare claims are
complete only for Medicare-primary enrollees (Section 4, "Payer
History", Table 7). Use `payers = "MPAB"` to require both Part A and
Part B. Other codes change what the flag means: `MSP-EGHP` and
`MSP-nonEGHP` are Medicare as secondary payer, `HMO` is Medicare
Advantage and `WAIT` the 90-day waiting period, and claims are
incomplete for all of them. `PAYER` may hold codes or their Appendix C
labels, so payer history loaded with or without `factor_labels` gives
the same result.

When `verify_medicare_primary()` is called many times, for example once
per risk set in a matching loop, build the coverage spells once with
[`prepare_medicare_coverage()`](https://vagishhemmige.github.io/usRds/reference/prepare_medicare_coverage.md)
and pass the result as `medicare_coverage_df`. Raw payer history passed
as `medicare_coverage_df` is filtered and merged again on every call.
`BEGDATE` and `ENDDATE` must be of class `Date`. Spans that touch or
overlap, including a span nested inside an earlier one, are merged into
one spell. Patients with no rows in `payhist` get `FALSE`, with a
warning.

## Examples

``` r
payer_history <- data.frame(
  USRDS_ID = c(1, 1, 2),
  PAYER = c("MPAB", "MPAB", "MSP-EGHP"),
  BEGDATE = as.Date(c("2009-01-01", "2009-07-01", "2009-01-01")),
  ENDDATE = as.Date(c("2009-06-30", "2010-12-31", "2010-12-31"))
)
patients <- data.frame(
  USRDS_ID = c(1, 2),
  index = as.Date(c("2010-06-01", "2010-06-01"))
)
verify_medicare_primary(
  patients,
  index_date = "index",
  medicare_coverage_df = payer_history,
  coverage_start_variable = "coverage_start"
)
#>   USRDS_ID      index medicare_primary_TF coverage_start
#> 1        1 2010-06-01                TRUE     2009-01-01
#> 2        2 2010-06-01               FALSE           <NA>
```
