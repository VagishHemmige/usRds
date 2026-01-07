# Finalize a USRDS cohort

This function accepts a data frame that is a USRDS longitudinal cohort,
and returns the same object with the `tstart` and `tstop` variables
shifted so that each patient's first observation has `tstart`=0.

## Usage

``` r
finalize_usrds_cohort(USRDS_cohort)
```

## Arguments

- USRDS_cohort:

  is a USRDS cohort created using the
  [`create_usrds_cohort()`](https://vagishhemmige.github.io/usRds/reference/create_usrds_cohort.md)
  function \#'

## Value

A data frame that is a USRDS cohort object

## Examples

``` r
if (FALSE) { # \dontrun{
} # }
```
