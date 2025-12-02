# Retrieve Institutional HCPCS Claims

Searches institutional claim files for specified HCPCS codes in
specified years. Supports filtering by HCPCS and optionally by
USRDS_IDs. Handles CSV, SAS, and Parquet formats.

Searches institutional claim files for specified HCPCS codes in
specified years. Supports filtering by HCPCS and optionally by
USRDS_IDs. Handles CSV, SAS, and Parquet formats.

## Usage

``` r
get_IN_HCPCS(hcpcs_codes = NULL, years, usrds_ids = NULL)

get_IN_HCPCS(hcpcs_codes = NULL, years, usrds_ids = NULL)
```

## Arguments

- hcpcs_codes:

  Optional character vector of HCPCS codes to search for. If `NULL`, all
  codes are returned.

- years:

  Integer vector of years to include.

- usrds_ids:

  Optional vector of USRDS_IDs to filter to specific patients.

## Value

A data frame with columns: `USRDS_ID`, `CLM_FROM`, `HCPCS`, `REV_CH`

A data frame with columns: `USRDS_ID`, `CLM_FROM`, `HCPCS`, `REV_CH`

## Details

If `hcpcs_codes` is `NULL`, all HCPCS-coded claims are returned.

If `hcpcs_codes` is `NULL`, all HCPCS-coded claims are returned.

## Examples

``` r
if (FALSE) { # \dontrun{
get_IN_HCPCS(c("J1234", "A4567"), years = 2012:2016)
get_IN_HCPCS(NULL, years = 2012:2016)  # All HCPCS claims
} # }
if (FALSE) { # \dontrun{
get_IN_HCPCS(c("J1234", "A4567"), years = 2012:2016)
get_IN_HCPCS(NULL, years = 2012:2016)  # All HCPCS claims
} # }
```
