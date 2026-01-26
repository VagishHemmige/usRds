# Prorate costs by day

Given a data frame of claims with cost data from claims which
potentially span multiple days, this function will prorate the costs
evenly over the duration of the claim.

## Usage

``` r
prorate_costs_by_day(cost_data_frame)
```

## Arguments

- df:

  data frame of cost data created by a `get_*_*_*costs` function

## Value

A data frame with costs prorated, with the original variable name
changed.

## Details

The original cost variables will be removed, and replaced by variables
with the same name but with "\_PRORATED" added to the variable na,e.

## Examples

``` r
if (FALSE) { # \dontrun{
prorate_costs_by_day()
} # }
```
