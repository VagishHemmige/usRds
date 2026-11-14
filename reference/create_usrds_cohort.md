# Initialize a cohort of USRDS patients

Initializes a cohort of USRDS patients. Data set must have a variable
named USRDS_ID.

## Usage

``` r
create_usrds_cohort(df, start_date, end_date)
```

## Arguments

- df:

  is a data frame used to initialize a USRDS data frame. Typically, this
  is a data frame created from the `PATIENTS` file, potentially merged
  with the `MEDEVID` file or other files with baseline variables which
  are to be time-invariant. `USRDS_ID` must be unique or the function
  will error.

- start_date:

  is a fixed data or a date variable in the `df` data frame specifying
  when each patient is considered to enter the cohort.

- end_date:

  is a fixed data or a date variable in the `df` data frame specifying
  when each patient is considered to exit the cohort.

## Value

A data frame and tmerge class object with columns `cohort_start_date`
and `cohort_stop_date` added, which take values based on the
`start_date` and `end_date` passed to the function, as well as `tstart`
and `tstop` helper numbers

## Examples

``` r
# Made-up patients; real cohorts usually start from a USRDS file
patients <- data.frame(
  USRDS_ID = c(1, 2),
  start = as.Date(c("2020-01-01", "2020-03-01")),
  end = as.Date(c("2020-12-31", "2020-12-31"))
)
cohort <- create_usrds_cohort(patients, start_date = "start", end_date = "end")
cohort
#>   USRDS_ID      start        end cohort_start_date cohort_stop_date tstart
#> 1        1 2020-01-01 2020-12-31        2020-01-01       2020-12-31  18262
#> 2        2 2020-03-01 2020-12-31        2020-03-01       2020-12-31  18322
#>   tstop
#> 1 18627
#> 2 18627
```
