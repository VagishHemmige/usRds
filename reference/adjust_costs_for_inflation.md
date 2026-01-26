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

A data frame with costs adjusted for inflation, with the original
variable name changed.

## Details

The original cost variables will be retained, and new variables created
that contain "\_ADJUSTED" appended to them.

## Examples

``` r
if (FALSE) { # \dontrun{
adjust_costs_for_inflation()
} # }
```
