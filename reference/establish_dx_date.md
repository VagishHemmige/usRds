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

## Value

A data frame filtered to keep the claim which establishes that a
diagnosis has been made

## Examples

``` r
if (FALSE) { # \dontrun{
cryptococcus_icd <- c("1175", "B45")

# Retrieve claims for all patients in selected years
result <- get_IN_ICD(icd_codes = cryptococcus_icd, years = 2013:2018)

establish_dx_date(result)
} # }
```
