# Working with cost variables

usRds has four functions that extract amounts from Medicare claims, and
two that adjust them. The claim files carry several different amounts
for the same service, and they answer different questions. This page
says what each amount is, which ones to use for common questions, and
where the current functions fall short.

All column descriptions come from Appendix B of the 2025 USRDS
Researcher’s Guide, and the cautions from Section 5 of the Guide
(“Medicare Claims”). Check them against the Guide for the release you
are using: earlier releases may differ.

## The four extractors

| Function | Claims | One row per | Years in usRds |
|----|----|----|----|
| [`get_IN_CLM_costs()`](https://vagishhemmige.github.io/usRds/reference/get_IN_CLM_costs.md) | Institutional: inpatient, outpatient, skilled nursing, home health, hospice | claim | 2006–2021, and inpatient 2022 Q1 |
| [`get_IN_REV_costs()`](https://vagishhemmige.github.io/usRds/reference/get_IN_REV_costs.md) | Institutional | revenue center line | 2006–2021, and inpatient 2022 Q1 |
| [`get_PS_CLM_costs()`](https://vagishhemmige.github.io/usRds/reference/get_PS_CLM_costs.md) | Physician/Supplier and durable medical equipment (DME) | claim | 2013–2021 |
| [`get_PS_REV_costs()`](https://vagishhemmige.github.io/usRds/reference/get_PS_REV_costs.md) | Physician/Supplier and DME | claim line | 2006–2021 |

The year ranges are those of the package’s internal file tables, not of
the data. Files for later years exist (Appendix B 2025 describes 2023
files), but the package does not read them yet.

## What each amount is

**Kinds of amount.** A *submitted charge* is what the provider billed.
An *allowed amount* is what Medicare’s fee schedule allows for the
service. A *payment* is money actually paid, by Medicare or by someone
else. These can differ a great deal: submitted charges can be several
times the payment.

### Institutional claims: `get_IN_CLM_costs()`

| Column    | Appendix B description | Kind               |
|-----------|------------------------|--------------------|
| `CLM_TOT` | Total charges          | submitted charge   |
| `CLM_AMT` | Medicare payments      | payment (Medicare) |

For inpatient claims, the Guide notes that Medicare’s cost also includes
pass-through payments (for example indirect medical education, capital,
and kidney acquisition for transplant), found by multiplying `PER_DIEM`
by the covered days `CVR_DCNT`. usRds does not read these columns yet
([\#65](https://github.com/VagishHemmige/usRds/issues/65)), so `CLM_AMT`
alone understates inpatient cost.

### Institutional revenue lines: `get_IN_REV_costs()`

| Column   | Appendix B description        | Kind               |
|----------|-------------------------------|--------------------|
| `REV_CH` | Revenue center total charge   | submitted charge   |
| `REVPMT` | Revenue center payment amount | payment (Medicare) |

Revenue lines break a claim’s charges down by type of service. Two
cautions from the Guide:

- Revenue center code `0001` holds the sum of the claim’s other lines,
  so adding up `REV_CH` over every line counts charges twice. This
  function does not return the revenue center code, so you cannot drop
  those lines yet
  ([\#112](https://github.com/VagishHemmige/usRds/issues/112)).
- `REVPMT` exists for outpatient claims from 2001. Summed over a claim,
  it does not always match the claim’s `CLM_AMT`; the Guide found
  outpatient `REVPMT` totals about 3% higher.

The function also returns no `CLM_THRU`, so its output cannot go
straight into
[`prorate_costs_by_day()`](https://vagishhemmige.github.io/usRds/reference/prorate_costs_by_day.md)
([\#66](https://github.com/VagishHemmige/usRds/issues/66)).

### Physician/Supplier claims: `get_PS_CLM_costs()`

| Column | Appendix B description | Kind |
|----|----|----|
| `CLM_PMT_AMT` | Amount paid by Medicare | payment (Medicare) |
| `NCH_CLM_PRVDR_PMT_AMT` | Total payments to the provider | payment |
| `NCH_CLM_BENE_PMT_AMT` | Total payment to beneficiary | payment (to the patient) |
| `CARR_CLM_PRMRY_PYR_PD_AMT` | Amount paid by primary payer (not Medicare) | payment (other payer) |
| `NCH_CARR_SBMT_CHRG_AMT` | Submitted charge amount | submitted charge |
| `NCH_CARR_ALOW_CHRG_AMT` | Allowed charge amount | allowed amount |
| `CARR_CLM_CASH_DDCTBL_APPLY_AMT` | Cash deductible amount | deductible |

“Payment to beneficiary” is money Medicare paid *to the patient*, not
money the patient paid.

### Physician/Supplier lines: `get_PS_REV_costs()`

| Column   | Appendix B description              | Kind             |
|----------|-------------------------------------|------------------|
| `SBMTCH` | Submitted charges                   | submitted charge |
| `ALOWCH` | Allowed charges                     | allowed amount   |
| `PMTAMT` | Claim payment amount (for the line) | payment          |

Appendix B also lists line amounts for the beneficiary’s payment,
deductible and coinsurance, and the primary payer’s payment. usRds does
not read them yet
([\#65](https://github.com/VagishHemmige/usRds/issues/65)).

## Which amount to use

- **What Medicare spent:** `CLM_AMT` (institutional) and `CLM_PMT_AMT`
  (Physician/Supplier), from the claim-level functions. This is what is
  usually meant by Medicare cost.
- **Spending by type of service:** the line-level functions, with the
  cautions above.
- **What the service would cost at Medicare rates:** allowed amounts
  (`NCH_CARR_ALOW_CHRG_AMT`, `ALOWCH`), Physician/Supplier only.
- **Charges:** rarely the right measure of cost, because they reflect
  providers’ list prices rather than what anyone paid.

Two more points:

1.  **Don’t add claim totals and line amounts for the same claims.** The
    line amounts are a breakdown of the claim totals, so adding both
    counts the same money twice. This applies whatever you measure.

2.  **Choose the payer restriction to fit the question.** When Medicare
    is a secondary payer, or the patient is in a Medicare Advantage
    plan, the claims do not show the full cost of care. So the Annual
    Data Report’s per-person-per-year costs count only fee-for-service
    claims, during time when Medicare was the primary payer (2017 ADR,
    Volume 2, ESRD Analytical Methods, Chapter 9). Use the same
    restriction when you need complete costs per person. A total of what
    Medicare spent is a different question, and may rightly include
    Medicare’s payments as a secondary payer.

    [`verify_medicare_primary()`](https://vagishhemmige.github.io/usRds/reference/verify_medicare_primary.md)
    checks Medicare-primary coverage on one index date and the lookback
    before it. It does not check coverage over the whole follow-up, so
    periods of coverage during follow-up need their own check
    ([\#23](https://github.com/VagishHemmige/usRds/issues/23)).

## Adjusting and spreading amounts

[`adjust_costs_for_inflation()`](https://vagishhemmige.github.io/usRds/reference/adjust_costs_for_inflation.md)
adds an `_ADJUSTED` copy of each amount, converted to the dollars of a
month and year you choose with the medical care consumer price index
(BLS series CUUR0000SAM, 2006–2025 in the package). Each claim uses the
index for the month of its `CLM_FROM`.

[`prorate_costs_by_day()`](https://vagishhemmige.github.io/usRds/reference/prorate_costs_by_day.md)
spreads each claim’s amounts evenly over the days from `CLM_FROM` to
`CLM_THRU`, one row per day, so costs can be counted by day, month or
follow-up period. Claims with a missing or reversed date are left out,
with a warning.

The two work in either order. Here they are on two made-up claims:

``` r

library(usRds)

claims <- data.frame(
  USRDS_ID = c(1, 2),
  CLM_FROM = as.Date(c("2010-06-01", "2015-12-01")),
  CLM_THRU = as.Date(c("2010-06-03", "2015-12-01")),
  CLM_PMT_AMT = c(300, 100)
)

adjusted <- adjust_costs_for_inflation(
  claims,
  baseline_month = "December",
  baseline_year = 2015
)
adjusted
#>   USRDS_ID   CLM_FROM   CLM_THRU CLM_PMT_AMT CLM_PMT_AMT_ADJUSTED
#> 1        1 2010-06-01 2010-06-03         300             348.5882
#> 2        2 2015-12-01 2015-12-01         100             100.0000

daily <- prorate_costs_by_day(adjusted)
daily
#>   USRDS_ID   CLM_FROM   CLM_THRU service_date CLM_PMT_AMT_PRORATED
#> 1        1 2010-06-01 2010-06-03   2010-06-01                  100
#> 2        1 2010-06-01 2010-06-03   2010-06-02                  100
#> 3        1 2010-06-01 2010-06-03   2010-06-03                  100
#> 4        2 2015-12-01 2015-12-01   2015-12-01                  100
#>   CLM_PMT_AMT_ADJUSTED_PRORATED
#> 1                      116.1961
#> 2                      116.1961
#> 3                      116.1961
#> 4                      100.0000
```

Totals are kept by proration:

``` r

all.equal(
  sum(daily$CLM_PMT_AMT_ADJUSTED_PRORATED),
  sum(adjusted$CLM_PMT_AMT_ADJUSTED)
)
#> [1] TRUE
```

## Known gaps

- Some amounts are not read: inpatient pass-through payments, the
  institutional primary-payer and deductible amounts (from the 2015
  files), and the Physician/Supplier line beneficiary amounts
  ([\#65](https://github.com/VagishHemmige/usRds/issues/65)).
- [`get_IN_REV_costs()`](https://vagishhemmige.github.io/usRds/reference/get_IN_REV_costs.md)
  returns neither the revenue center code
  ([\#112](https://github.com/VagishHemmige/usRds/issues/112)) nor
  `CLM_THRU` ([\#66](https://github.com/VagishHemmige/usRds/issues/66)).
- `get_PS_CLM_costs(remove_missing_values = )` has no effect: claims
  with a missing payment are kept
  ([\#54](https://github.com/VagishHemmige/usRds/issues/54)).
  [`get_PS_REV_costs()`](https://vagishhemmige.github.io/usRds/reference/get_PS_REV_costs.md)
  drops lines with a missing `PMTAMT` unless
  `remove_missing_values = FALSE`.
- DME claims have claim type code `E`, which shows as `NA` in `HCFASAF`
  ([\#27](https://github.com/VagishHemmige/usRds/issues/27)).
- The package’s file tables stop at 2021 (2022 Q1 for inpatient claims).
