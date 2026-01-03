# Retrieve claims costs from Physician/Supplier claims

Extracts all claims costs from physician/supplier billing data for the
selected years, optionally filtering by USRDS_IDs. Option to
`remove_missing_values` defaults to TRUE

## Usage

``` r
get_PS_CLM_costs(years, usrds_ids = NULL, remove_missing_values = TRUE)
```

## Arguments

- years:

  Integer vector of calendar years to include. Range is 2013-2021.

- usrds_ids:

  Optional. Vector of USRDS_IDs to restrict results to.

## Value

A data frame with columns: `USRDS_ID`, `HCFASAF`, `CLM_FROM`,
`CLM_THRU`, `CLM_PMT_AMT`,
`CARR_CLM_PRMRY_PYR_PD_AMT`,`NCH_CLM_PRVDR_PMT_AMT`,`NCH_CLM_BENE_PMT_AMT`,`NCH_CARR_SBMT_CHRG_AMT`,
`NCH_CARR_ALOW_CHRG_AMT`,`CARR_CLM_CASH_DDCTBL_APPLY_AMT`

## Examples

``` r
if (FALSE) { # \dontrun{
get_PS_CLM_costs(years = 2016:2018, usrds_ids=1:1000)
get_PS_CLM_costs(years = 2014:2017, usrds_ids=2000:4100)
} # }
```
