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

- remove_missing_values:

  If `TRUE` (the default), drop line items whose `PMTAMT` is missing.

## Value

A data frame with one row per Physician/Supplier claim line. Column
descriptions are from Appendix B of the 2025 Researcher's Guide (table
`PS_LINE_2023`):

- USRDS_ID:

  Patient ID

- HCFASAF:

  Claim type (labelled factor)

- CLM_FROM, CLM_THRU:

  From and through dates of service of the claim (Date)

- SBMTCH:

  Submitted charges

- ALOWCH:

  Allowed charges

- PMTAMT:

  Claim payment amount (for the line)

These are line-item amounts: do not add them to claim totals from
[`get_PS_CLM_costs()`](https://vagishhemmige.github.io/usRds/reference/get_PS_CLM_costs.md)
for the same claims.

## Examples

``` r
if (FALSE) { # \dontrun{
get_PS_REV_costs(years = 2006:2008, usrds_ids=1:1000)
get_PS_REV_costs(years = 2006:2008, usrds_ids=2000:4100)
} # }
```
