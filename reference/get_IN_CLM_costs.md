# Retrieve Institutional Claims

Searches institutional claim files for specified USRDS_IDs in specified
years. Supports filtering by USRDS_IDs. Handles CSV, SAS, and Parquet
formats.

## Usage

``` r
get_IN_CLM_costs(years, usrds_ids = NULL)
```

## Arguments

- years:

  Integer vector of years to include.

- usrds_ids:

  Optional vector of USRDS_IDs to filter to specific patients.

## Value

A data frame with one row per claim and columns `USRDS_ID`, `CLM_FROM`
and `CLM_THRU` (both `Date`), `CLM_TOT`, `CLM_AMT` and `HCFASAF` (claim
type, as a factor). Dates stored as text that cannot be read become
`NA`, with a warning naming the file and column.

## Details

If `usrds_ids` is `NULL`, all claims are returned.

## Examples

``` r
if (FALSE) { # \dontrun{
get_IN_CLM_costs(years = 2012:2016, usrds_ids=1:1000)
} # }
```
