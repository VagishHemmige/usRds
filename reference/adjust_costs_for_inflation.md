# Adjust costs for inflation

Given a data frame of claims with cost data and a month and year, adjust
all costs to that month and year using CPI-M.

## Usage

``` r
adjust_costs_for_inflation(cost_data_frame, baseline_month, baseline_year)
```

## Arguments

- cost_data_frame:

  data frame of cost data created by a `get_*_*_*costs` function

- baseline_month:

  is the full name of the month.

- baseline_year:

  is a year in the 2006-2025 range.

## Value

The input data frame with an `_ADJUSTED` copy of each amount column, in
`baseline_month` `baseline_year` dollars. The original amount columns
are kept unchanged.

## Details

The original cost variables will be retained, and new variables created
that contain "\_ADJUSTED" appended to them.

Each claim is adjusted using the medical care consumer price index for
the month and year of its `CLM_FROM` date (BLS series CUUR0000SAM, US
city average, not seasonally adjusted, stored in the package). Claims
whose month is not in that table get `NA` adjusted amounts and a
warning.

The amount columns adjusted are those returned by
[`get_PS_CLM_costs()`](https://vagishhemmige.github.io/usRds/reference/get_PS_CLM_costs.md),
[`get_IN_CLM_costs()`](https://vagishhemmige.github.io/usRds/reference/get_IN_CLM_costs.md),
[`get_PS_REV_costs()`](https://vagishhemmige.github.io/usRds/reference/get_PS_REV_costs.md)
and
[`get_IN_REV_costs()`](https://vagishhemmige.github.io/usRds/reference/get_IN_REV_costs.md):
`CLM_PMT_AMT`, `CARR_CLM_PRMRY_PYR_PD_AMT`, `NCH_CLM_PRVDR_PMT_AMT`,
`NCH_CLM_BENE_PMT_AMT`, `NCH_CARR_SBMT_CHRG_AMT`,
`NCH_CARR_ALOW_CHRG_AMT`, `CARR_CLM_CASH_DDCTBL_APPLY_AMT`, `CLM_TOT`,
`CLM_AMT`, `SBMTCH`, `ALOWCH`, `PMTAMT`, `REV_CH` and `REVPMT`, and the
same columns with `_PRORATED` added by
[`prorate_costs_by_day()`](https://vagishhemmige.github.io/usRds/reference/prorate_costs_by_day.md).
Other columns are returned unchanged.

## Examples

``` r
claims <- data.frame(
  USRDS_ID = c(1, 2),
  CLM_FROM = as.Date(c("2010-06-01", "2015-12-01")),
  PMTAMT = c(100, 100)
)
adjust_costs_for_inflation(claims, baseline_month = "December",
                           baseline_year = 2015)
#>   USRDS_ID   CLM_FROM PMTAMT PMTAMT_ADJUSTED
#> 1        1 2010-06-01    100        116.1961
#> 2        2 2015-12-01    100        100.0000
```
