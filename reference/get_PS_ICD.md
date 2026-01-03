# Retrieve diagnosis claims from Physician/Supplier files by ICD code

Extracts diagnosis-level claims from the USRDS Physician/Supplier (PS)
billing files for selected years and filters them by specified ICD-9 or
ICD-10 codes and/or USRDS_IDs. This function supports input files in
Parquet, CSV, or SAS format and automatically identifies and loads the
correct files for each year using the internal USRDS file list.

## Usage

``` r
get_PS_ICD(icd_codes = NULL, years, usrds_ids = NULL)
```

## Arguments

- icd_codes:

  Optional. Character vector of ICD-9/10 diagnosis codes (without
  periods). If `NULL`, returns all diagnosis claims for the selected
  years (filtered by `usrds_ids`, if specified).

- years:

  Integer vector of calendar years to include. Must match available
  years in the PS ICD file index.

- usrds_ids:

  Optional. Vector of USRDS_IDs to filter the data to specific patients.

## Value

A data frame with one row per diagnosis claim, containing:

- USRDS_ID:

  Patient ID

- DIAG:

  ICD diagnosis code (character)

- CLM_FROM:

  Claim start date (Date)

- CLM_THRU:

  Claim end date (Date)

- HCFASAF:

  Source file

## Details

When Parquet files are used, filtering by ICD code and USRDS_ID is
applied before collection for improved performance. For CSV and SAS
files, filtering occurs after reading the file into memory.

If `icd_codes` is `NULL`, all diagnosis claims for the specified years
(and optionally, specific USRDS_IDs) are returned.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get all Cryptococcosis-related diagnosis claims from 2013–2018
cryptococcus_icd <- c("1175", "B45")
result <- get_PS_ICD(icd_codes = cryptococcus_icd, years = 2013:2018)

# Return all diagnosis claims for selected patients in 2016–2017
result_all <- get_PS_ICD(
  icd_codes = NULL,
  years = c(2016, 2017),
  usrds_ids = c(100012345, 100078901)
)
} # }
```
