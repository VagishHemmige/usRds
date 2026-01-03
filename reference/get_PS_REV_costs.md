# Retrieve line item costs from Physician/Supplier claims

Extracts all line-item costs from physician/supplier billing data for
the selected years, optionally filtering by USRDS_IDs. Option to
`remove_missing_values` defaults to TRUE

## Usage

``` r
get_PS_REV_costs(years, usrds_ids = NULL, remove_missing_values = TRUE)
```

## Arguments

- years:

  Integer vector of calendar years to include.

- usrds_ids:

  Optional. Vector of USRDS_IDs to restrict results to.

## Value

A data frame with columns: `USRDS_ID`, `HCFASAF`, `CLM_FROM`,
`CLM_THRU`,`SBMTCH`, `ALOWCH`, `PMTAMT`

## Examples

``` r
if (FALSE) { # \dontrun{
get_PS_REV_costs(years = 2006:2008, usrds_ids=1:1000)
get_PS_REV_costs(years = 2006:2008, usrds_ids=2000:4100)
} # }
```
