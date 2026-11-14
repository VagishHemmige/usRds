# Establish date a diagnosis is made

Given a data frame of claims created with a `get_*_ICD` command, this
function will keep the date of either the second outpatient or first
inpatient claim with that code, using the `HCFASAF` variable to classify
claims as outpatient or inpatient.

## Usage

``` r
establish_dx_date(df, diagnosis_established = "diagnosis")
```

## Arguments

- df:

  data frame of claims created by a `get_*_ICD` function

- diagnosis_established:

  A string stored in the `diagnosis` column of the result, naming the
  diagnosis being dated (for example `"cryptococcus"`).

## Value

A data frame filtered to keep the claim which establishes that a
diagnosis has been made

## Examples

``` r
if (FALSE) { # \dontrun{
# Codes are matched exactly, so list every billable code (#3):
# ICD-9 117.5 and ICD-10-CM B45.0-B45.3, B45.7-B45.9, without periods
cryptococcus_icd <- c(
  "1175", "B450", "B451", "B452", "B453", "B457", "B458", "B459"
)

# Retrieve claims for all patients in selected years
result <- get_IN_ICD(icd_codes = cryptococcus_icd, years = 2013:2018)

establish_dx_date(result)
} # }
```
