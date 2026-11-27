# Retrieve Institutional costs Claims

Searches institutional claim files for costs for specified USRDS_IDs in
specified years. Handles CSV, SAS, and Parquet formats.

## Usage

``` r
get_IN_REV_costs(years, usrds_ids = NULL, drop_total_lines = TRUE)
```

## Arguments

- years:

  Integer vector of years to include.

- usrds_ids:

  Optional vector of USRDS_IDs to filter to specific patients.

- drop_total_lines:

  If `TRUE` (the default), drop lines with revenue center code `0001`.
  The 2025 Researcher's Guide (Section 5, "Institutional Claims Details
  and Revenue Center Details") reports that the `0001` line's `REV_CH`
  is the sum of the claim's other lines' `REV_CH`, so keeping it counts
  the charges twice. The Guide does not describe `REVPMT` on that line;
  dropping the line removes its `REVPMT` too. Lines whose code is
  missing are kept. In files that have `CDTYPE` (det files before 2008,
  which also hold diagnosis and procedure lines), only revenue center
  lines (`CDTYPE` `"R"`) are dropped or have their codes padded; the
  other lines, including those with a missing or blank `CDTYPE`, are
  returned unchanged for now.

## Value

A data frame with one row per revenue center line and columns
`USRDS_ID`, `CLM_FROM` and `CLM_THRU` (claim from and through dates),
`REV_DT` (revenue center date), `CODE` (revenue center code, as text
with its leading zeros), `REV_CH` (revenue center total charge),
`REVPMT` (revenue center payment amount) and `HCFASAF` (claim type, as a
factor). Dates are of class `Date`. Descriptions are from Appendix B of
the 2025 Researcher's Guide (for example table `OP_DET_2023`). A column
a file does not have is `NA` for that file's lines. Dates stored as text
that cannot be read become `NA`, with a warning naming the file and
column.

With `CLM_FROM` and `CLM_THRU`, the result can go straight into
[`prorate_costs_by_day()`](https://vagishhemmige.github.io/usRds/reference/prorate_costs_by_day.md).
Do not add these amounts to claim totals from
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
