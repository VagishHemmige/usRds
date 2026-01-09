# Verify that a patient has Medicare primary coverage

This function accepts a data frame `df`, an index date option
`index_date` which is either a fixed date or the name of a date variable
in quotes, and a variable `lookback_days` that encodes how many days of
Medicare coverage are necessary.

## Usage

``` r
verify_medicare_primary(df, index_date, lookback_days = 365)
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

## Value

The original `df` data fame with the variable `medicare_primary_TF`
added

## Details

It returns the same dataframe with a new variable `medicare_primary_TF`
that takes the values `TRUE` or `FALSE`.

## Examples

``` r
if (FALSE) { # \dontrun{

test_df<-data.frame(
USRDS_ID=c(30, 111112),
initial_dates=as.Date(c("1994-01-01", "2019-01-01"))
)

verify_medicare_primary(df=test_df, index_date = "initial_dates", lookback_days = 365)

} # }
```
