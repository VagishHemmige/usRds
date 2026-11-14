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
  function. It must not yet have been passed to
  [`finalize_usrds_cohort()`](https://vagishhemmige.github.io/usRds/reference/finalize_usrds_cohort.md).

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
# Made-up patients; real cohorts usually start from a USRDS file
patients <- data.frame(
  USRDS_ID = c(1, 2),
  start = as.Date(c("2020-01-01", "2020-03-01")),
  end = as.Date(c("2020-12-31", "2020-12-31"))
)
cohort <- create_usrds_cohort(patients, start_date = "start", end_date = "end")
admissions <- data.frame(USRDS_ID = 2, admit_date = as.Date("2020-06-01"))
cohort <- add_cohort_event(
  cohort,
  admissions,
  event_date = "admit_date",
  event_variable_name = "hospitalized"
)
cohort
#>   USRDS_ID      start        end cohort_start_date cohort_stop_date tstart
#> 1        1 2020-01-01 2020-12-31        2020-01-01       2020-12-31  18262
#> 2        2 2020-03-01 2020-12-31        2020-03-01       2020-06-01  18322
#> 3        2 2020-03-01 2020-12-31        2020-06-01       2020-12-31  18414
#>   tstop hospitalized
#> 1 18627            0
#> 2 18414            1
#> 3 18627            0
```
