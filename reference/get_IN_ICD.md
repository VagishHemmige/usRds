# Retrieve diagnosis codes from Institutional claims

Extracts all claims containing specified ICD-9 or ICD-10 diagnosis codes
from institutional billing data for the selected years. The data may be
stored in CSV, SAS, or Parquet format. The function automatically loads
and combines matching files and can optionally filter to a subset of
USRDS_IDs.

## Usage

``` r
get_IN_ICD(icd_codes = NULL, years, usrds_ids = NULL)
```

## Arguments

- icd_codes:

  Optional. Character vector of ICD diagnosis codes (without periods).
  If NULL (default), returns all diagnosis claims for the selected years
  (and USRDS_IDs, if specified).

- years:

  Integer vector of calendar years to include.

- usrds_ids:

  Optional. Vector of USRDS_IDs to restrict the output to specific
  patients.

## Value

A data frame with columns: `USRDS_ID`, `CODE`, and `CLM_FROM`.

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

# Retrieve all diagnosis claims for selected patients
result_all <- get_IN_ICD(icd_codes = NULL, years = 2015, usrds_ids = c(1, 2))
} # }
```
