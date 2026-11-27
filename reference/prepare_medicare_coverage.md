# Build Medicare-primary coverage spells once, for repeated checks

Keeps the payer history rows whose `PAYER` is one of `payers` and merges
spans that touch or overlap, including a span nested inside an earlier
one, into one spell per row. Pass the result to
[`verify_medicare_primary()`](https://vagishhemmige.github.io/usRds/reference/verify_medicare_primary.md)
as `medicare_coverage_df` when it is called many times, for example once
per risk set in a matching loop: prepared coverage is used as it is,
while raw payer history is filtered and merged again on every call.

## Usage

``` r
prepare_medicare_coverage(payhist, payers = c("MPAB", "MPO"))
```

## Arguments

- payhist:

  A data frame from the `payhist` file, with columns `USRDS_ID`,
  `PAYER`, `BEGDATE` and `ENDDATE`. `BEGDATE` and `ENDDATE` must be of
  class `Date`. `PAYER` may hold Appendix C `$PAYCAT.` codes or their
  labels.

- payers:

  Payers whose spans make up the coverage, as Appendix C `$PAYCAT.`
  codes or their labels. The default, `c("MPAB", "MPO")`, is Medicare
  fee-for-service primary pay for both Part A and Part B, or "for other"
  (Appendix C `$PAYCAT.` labels): Medicare primary coverage
  (Researcher's Guide 2025, Example 8 and Section 4, Table 7). `"MPAB"`
  alone requires both parts. Secondary payer (`MSP-EGHP`,
  `MSP-nonEGHP`), `HMO` and `WAIT` spans are not Medicare primary, and
  claims are incomplete for them; see
  [`verify_medicare_primary()`](https://vagishhemmige.github.io/usRds/reference/verify_medicare_primary.md).

## Value

A data frame of class `usrds_medicare_coverage`, with one row per spell
and columns `USRDS_ID`, `BEGDATE` and `ENDDATE`. Attributes record the
`payers` used and the `USRDS_ID`s present in `payhist`, so
[`verify_medicare_primary()`](https://vagishhemmige.github.io/usRds/reference/verify_medicare_primary.md)
can still warn about patients with no payer history at all. Patients
with history but no eligible spell have no row.

## Examples

``` r
payer_history <- data.frame(
  USRDS_ID = c(1, 1, 2),
  PAYER = c("MPAB", "MPAB", "MSP-EGHP"),
  BEGDATE = as.Date(c("2009-01-01", "2009-07-01", "2009-01-01")),
  ENDDATE = as.Date(c("2009-06-30", "2010-12-31", "2010-12-31"))
)
coverage <- prepare_medicare_coverage(payer_history)
coverage
#> # A tibble: 1 × 3
#>   USRDS_ID BEGDATE    ENDDATE   
#> *    <dbl> <date>     <date>    
#> 1        1 2009-01-01 2010-12-31

patients <- data.frame(
  USRDS_ID = c(1, 2),
  index = as.Date(c("2010-06-01", "2010-06-01"))
)
verify_medicare_primary(
  patients,
  index_date = "index",
  medicare_coverage_df = coverage
)
#>   USRDS_ID      index medicare_primary_TF
#> 1        1 2010-06-01                TRUE
#> 2        2 2010-06-01               FALSE
```
