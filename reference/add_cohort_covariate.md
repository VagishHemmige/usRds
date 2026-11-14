# Add a covariate variable to a USRDS cohort

This function accepts two data frames. One is a USRDS longitudinal
cohort. The second is a data frame with dates representing covariates.
The resulting output is a USRDS longitudinal cohort with the covariates
added to the data frame as time-varying covariates.

## Usage

``` r
add_cohort_covariate(
  USRDS_cohort,
  covariate_data_frame,
  covariate_date,
  covariate_value = NULL,
  covariate_variable_name
)
```

## Arguments

- USRDS_cohort:

  is a USRDS cohort created using the
  [`create_usrds_cohort()`](https://vagishhemmige.github.io/usRds/reference/create_usrds_cohort.md)
  function. It must not yet have been passed to
  [`finalize_usrds_cohort()`](https://vagishhemmige.github.io/usRds/reference/finalize_usrds_cohort.md).

- covariate_data_frame:

  is a data frame with a date variable (delineated via the
  `covariate_date` option).

- covariate_date:

  is a character string naming a date variable in `covariate_data_frame`
  that specifies the date of onset of the covariate

- covariate_value:

  is an optional variable which encodes the value taken by the
  time-dependent covariate on the date encoded in `covariate_date`. If
  `covariate_value` is not specified,

- covariate_variable_name:

  is a string with the variable name for the new covariate variable
  created

## Value

A USRDS longitudinal cohort with additional rows created as needed and a
new time-varying covariate column named `covariate_variable_name`.

## Details

Both `USRDS_cohort` and `condition_data_frame` must contain `USRDS_ID`.

Examples of characteristics

- That a patient has developed a specific medical condition

- That a patient has, in the past, experienced an event of interest

- Patient ZIP code

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
cohort
#>   USRDS_ID      start        end cohort_start_date cohort_stop_date tstart
#> 1        1 2020-01-01 2020-12-31        2020-01-01       2020-04-01  18262
#> 2        1 2020-01-01 2020-12-31        2020-04-01       2020-12-31  18353
#> 3        2 2020-03-01 2020-12-31        2020-03-01       2020-12-31  18322
#>   tstop diabetes
#> 1 18353        0
#> 2 18627        1
#> 3 18627        0
```
