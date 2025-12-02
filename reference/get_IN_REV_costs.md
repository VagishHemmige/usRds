# Retrieve Institutional costs Claims

Searches institutional claim files for costs for specified USRDS_IDs in
specified years. Handles CSV, SAS, and Parquet formats.

## Usage

``` r
get_IN_REV_costs(years, usrds_ids = NULL)
```

## Arguments

- years:

  Integer vector of years to include.

- usrds_ids:

  Optional vector of USRDS_IDs to filter to specific patients.

## Value

A data frame with columns: `USRDS_ID`, `CLM_FROM`, `HCPCS`, `REV_CH`,
`REVPMT`

## Details

If `usrds_ids` is `NULL`, all claims are returned.

## Examples

``` r
if (FALSE) { # \dontrun{
get_IN_REV_costs(years = 2012:2016, usrds_ids=1:1000)
} # }
```
