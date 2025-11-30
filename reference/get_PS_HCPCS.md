# Retrieve HCPCS codes from Physician/Supplier claims

Extracts all claims from physician/supplier billing data for the
selected years, optionally filtering by HCPCS codes and/or USRDS_IDs.

## Usage

``` r
get_PS_HCPCS(hcpcs_codes = NULL, years, usrds_ids = NULL)
```

## Arguments

- hcpcs_codes:

  Optional. Character vector of HCPCS codes to filter by. If `NULL`,
  returns all codes.

- years:

  Integer vector of calendar years to include.

- usrds_ids:

  Optional. Vector of USRDS_IDs to restrict results to.

## Value

A data frame with columns: `USRDS_ID`, `HCPCS`, `CLM_FROM`

## Details

If `hcpcs_codes` is `NULL`, all HCPCS-coded claims are returned.

## Examples

``` r
if (FALSE) { # \dontrun{
get_PS_HCPCS(c("81003", "87086"), years = 2006:2008)
get_PS_HCPCS(NULL, years = 2006:2008)  # All HCPCS codes
} # }
```
