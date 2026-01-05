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
  are to be time-invariant

- start_date:

  is a fixed data or a date variable in the `df` data frame specifying
  when each patient is considered to enter the cohort.

- end_date:

  is a fixed data or a date variable in the `df` data frame specifying
  when each patient is considered to exit the cohort.

## Value

A data frame with columns `cohort_start_date` and `cohort_end_date`
added, which take values based on the `start_date` and `end_date` passed
to the function.

## Examples

``` r
if (FALSE) { # \dontrun{
} # }
```
