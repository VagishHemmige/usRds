# Prorate costs by day

Given a data frame of claims with cost data from claims which
potentially span multiple days, this function will prorate the costs
evenly over the duration of the claim.

## Usage

``` r
prorate_costs_by_day(cost_data_frame)
```

## Arguments

- cost_data_frame:

  data frame of cost data created by a `get_*_*_*costs` function

## Value

A data frame with costs prorated, with the original variable name
changed.

## Details

The original cost variables will be removed, and replaced by variables
with the same name but with "\_PRORATED" added to the variable name.

The amount columns processed are those returned by
[`get_PS_CLM_costs()`](https://vagishhemmige.github.io/usRds/reference/get_PS_CLM_costs.md),
[`get_IN_CLM_costs()`](https://vagishhemmige.github.io/usRds/reference/get_IN_CLM_costs.md),
[`get_PS_REV_costs()`](https://vagishhemmige.github.io/usRds/reference/get_PS_REV_costs.md)
and
[`get_IN_REV_costs()`](https://vagishhemmige.github.io/usRds/reference/get_IN_REV_costs.md):
`CLM_PMT_AMT`, `CARR_CLM_PRMRY_PYR_PD_AMT`, `NCH_CLM_PRVDR_PMT_AMT`,
`NCH_CLM_BENE_PMT_AMT`, `NCH_CARR_SBMT_CHRG_AMT`,
`NCH_CARR_ALOW_CHRG_AMT`, `CARR_CLM_CASH_DDCTBL_APPLY_AMT`, `CLM_TOT`,
`CLM_AMT`, `SBMTCH`, `ALOWCH`, `PMTAMT`, `REV_CH` and `REVPMT`, and the
same columns with `_ADJUSTED` added by
[`adjust_costs_for_inflation()`](https://vagishhemmige.github.io/usRds/reference/adjust_costs_for_inflation.md).
Other columns are kept unchanged on every day of the claim.

A claim whose `CLM_FROM` or `CLM_THRU` is missing, or whose `CLM_THRU`
is before its `CLM_FROM`, cannot be spread over days. It is left out of
the result, with a warning giving how many claims were left out for each
reason, so prorated totals can fall short of the input.

## Examples

``` r
claims <- data.frame(
  USRDS_ID = c(1, 2),
  CLM_FROM = as.Date(c("2010-01-01", "2010-02-01")),
  CLM_THRU = as.Date(c("2010-01-03", "2010-02-01")),
  PMTAMT = c(30, 20)
)
prorate_costs_by_day(claims)
#>   USRDS_ID   CLM_FROM   CLM_THRU service_date PMTAMT_PRORATED
#> 1        1 2010-01-01 2010-01-03   2010-01-01              10
#> 2        1 2010-01-01 2010-01-03   2010-01-02              10
#> 3        1 2010-01-01 2010-01-03   2010-01-03              10
#> 4        2 2010-02-01 2010-02-01   2010-02-01              20
```
