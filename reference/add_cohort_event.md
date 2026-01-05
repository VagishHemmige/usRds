# Add an event variable to a USRDS cohort

This function accepts two data frames. One is a USRDS longitudinal
cohort. The second is a data frame with dates representing an event. The
resulting output is a USRDS longitudinal cohort with the events added to
the data frame

## Usage

``` r
add_cohort_event(
  USRDS_cohort,
  event_data_frame,
  event_date,
  event_variable_name
)
```

## Arguments

- USRDS_cohort:

  is a USRDS cohort created using the
  [`create_usrds_cohort()`](https://vagishhemmige.github.io/usRds/reference/create_usrds_cohort.md)
  function

- event_data_frame:

  is a data frame with a date variable (delineated via the `event_date`
  option).

- event_date:

  is a character string naming a date variable in `event_data_frame`
  that specifies when each patient experiences the event

- event_variable_name:

  is a string with the variable name for the new event variable created

## Value

A data frame with columns `cohort_start_date` and `cohort_end_date` for
each row

## Examples

``` r
if (FALSE) { # \dontrun{
} # }
```
