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

## Examples

``` r
if (FALSE) { # \dontrun{
} # }
```
