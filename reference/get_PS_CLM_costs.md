# Retrieve claims costs from Physician/Supplier claims

Extracts all claims costs from physician/supplier billing data for the
selected years, optionally filtering by USRDS_IDs.

## Usage

``` r
get_PS_CLM_costs(years, usrds_ids = NULL, remove_missing_values = TRUE)
```

## Arguments

- years:

  Integer vector of calendar years to include. Range is 2013-2021.

- usrds_ids:

  Optional. Vector of USRDS_IDs to restrict results to.

- remove_missing_values:

  If `TRUE` (the default), drop claims whose `CLM_PMT_AMT` is missing: a
  missing payment is an unknown amount, not a payment of zero (#54).
  This matches
  [`get_PS_REV_costs()`](https://vagishhemmige.github.io/usRds/reference/get_PS_REV_costs.md),
  which drops lines with a missing `PMTAMT`.

## Value

A data frame with one row per Physician/Supplier claim. Column
descriptions are from Appendix B of the 2025 Researcher's Guide (table
`PS_CLM_2023`):

- USRDS_ID:

  Patient ID

- HCFASAF:

  Claim type (labelled factor)

- CLM_FROM, CLM_THRU:

  From and through dates of service (Date)

- CLM_PMT_AMT:

  Amount paid by Medicare

- CARR_CLM_PRMRY_PYR_PD_AMT:

  Amount paid by primary payer (not Medicare)

- NCH_CLM_PRVDR_PMT_AMT:

  Total payments to the provider

- NCH_CLM_BENE_PMT_AMT:

  Total payment to beneficiary

- NCH_CARR_SBMT_CHRG_AMT:

  Submitted charge amount

- NCH_CARR_ALOW_CHRG_AMT:

  Allowed charge amount

- CARR_CLM_CASH_DDCTBL_APPLY_AMT:

  Cash deductible amount

These are claim totals: do not add them to line-item amounts from
[`get_PS_REV_costs()`](https://vagishhemmige.github.io/usRds/reference/get_PS_REV_costs.md)
for the same claims.

## Examples

``` r
if (FALSE) { # \dontrun{
get_PS_CLM_costs(years = 2016:2018, usrds_ids=1:1000)
get_PS_CLM_costs(years = 2014:2017, usrds_ids=2000:4100)
} # }
```
