# Retrieve Institutional costs Claims

Searches institutional claim files for costs for specified USRDS_IDs in
specified years. Handles CSV, SAS, and Parquet formats.

## Usage

``` r
get_IN_REV_costs(years, usrds_ids = NULL)
```

## Arguments

- years:

  Integer vector of years to include.

- usrds_ids:

  Optional vector of USRDS_IDs to filter to specific patients.

## Value

A data frame with one row per revenue center line and columns
`USRDS_ID`, `CLM_FROM` (Date), `REV_CH` (revenue center total charge),
`REVPMT` (revenue center payment amount) and `HCFASAF` (claim type, as a
factor). Descriptions are from Appendix B of the 2025 Researcher's Guide
(for example table `OP_DET_2023`).

It has no `CLM_THRU`, so it cannot go straight into
[`prorate_costs_by_day()`](https://vagishhemmige.github.io/usRds/reference/prorate_costs_by_day.md)
(GitHub \#66). It also has no revenue center code. The 2025 Researcher's
Guide (Section 5, "Institutional Claims Details and Revenue Center
Details") warns that revenue center code `0001` holds the sum of the
claim's other lines, so totals of `REV_CH` may count charges twice where
those lines are present. Do not add these amounts to claim totals from
[`get_IN_CLM_costs()`](https://vagishhemmige.github.io/usRds/reference/get_IN_CLM_costs.md)
for the same claims.

## Details

If `usrds_ids` is `NULL`, all claims are returned.

## Examples

``` r
if (FALSE) { # \dontrun{
get_IN_REV_costs(years = 2012:2016, usrds_ids=1:1000)
} # }
```
