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
  function

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
if (FALSE) { # \dontrun{
} # }
```
