# Finalize a USRDS cohort

This function accepts a data frame that is a USRDS longitudinal cohort,
and returns the same object with the `tstart` and `tstop` variables
shifted to an appropriate baseline t=0 as specified by
`baseline_date_variable`.

## Usage

``` r
finalize_usrds_cohort(USRDS_cohort, baseline_date_variable = NULL)
```

## Arguments

- USRDS_cohort:

  is a USRDS cohort created using the
  [`create_usrds_cohort()`](https://vagishhemmige.github.io/usRds/reference/create_usrds_cohort.md)
  function

- baseline_date_variable, :

  if not NULL, includes the name of the variable in `USRDS_cohort` that
  determines the t0 date for each row of the cohort

## Value

A data frame that is a USRDS cohort object

## Details

Of note,`baseline_date_variable` does NOT have to be constant within
each patient. If the baseline is the time since most recent transplant,
for example, and a patient has multiple transplants within the
`USRDS_cohort`, it may be appropriate for different observations periods
for the same patient to use different baseline dates.

If `baseline_date_variable` is unspecified or specified as NULL, its
default value, a default baseline value will be calculated for each
patient such that each patient's first observation has `tstart`=0.

Finalize a cohort once, after all covariates and events have been added.
The returned cohort is marked as finalized, and passing it to
`finalize_usrds_cohort()` again is an error, because a second shift
would subtract the baseline twice.

## Examples

``` r
# Made-up patients; real cohorts usually start from a USRDS file
patients <- data.frame(
  USRDS_ID = c(1, 2),
  start = as.Date(c("2020-01-01", "2020-03-01")),
  end = as.Date(c("2020-12-31", "2020-12-31"))
)
cohort <- create_usrds_cohort(patients, start_date = "start", end_date = "end")
diagnoses <- data.frame(USRDS_ID = 1, dx_date = as.Date("2020-04-01"))
cohort <- add_cohort_covariate(
  cohort,
  diagnoses,
  covariate_date = "dx_date",
  covariate_variable_name = "diabetes"
)
admissions <- data.frame(USRDS_ID = 2, admit_date = as.Date("2020-06-01"))
cohort <- add_cohort_event(
  cohort,
  admissions,
  event_date = "admit_date",
  event_variable_name = "hospitalized"
)
finalize_usrds_cohort(cohort)
#> # A tibble: 4 × 9
#>   USRDS_ID start      end        cohort_start_date cohort_stop_date tstart tstop
#>      <dbl> <date>     <date>     <date>            <date>            <dbl> <dbl>
#> 1        1 2020-01-01 2020-12-31 2020-01-01        2020-04-01            0    91
#> 2        1 2020-01-01 2020-12-31 2020-04-01        2020-12-31           91   365
#> 3        2 2020-03-01 2020-12-31 2020-03-01        2020-06-01            0    92
#> 4        2 2020-03-01 2020-12-31 2020-06-01        2020-12-31           92   305
#> # ℹ 2 more variables: diabetes <int>, hospitalized <int>
```
