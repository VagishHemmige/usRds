# Using usRds to access data within the USRDS file system

This vignette demonstrates how to load and filter USRDS data files using
the `usRds` package. It covers both general file loading and specific
extractors for common tasks.

## Prerequisite: Set the Working Directory

All examples assume that you have already set your working directory
with:

``` r
set_USRDS_wd("/path/to/usrds_data")
```

## Option 1: General File Loader

You can load any recognized USRDS file using:

``` r
df <- load_usrds_file(file_key = "PATIENTS", year = 2006)
```

This function will:

- Locate the file using internal variables created by the package when
  loaded or
  [`set_USRDS_wd()`](https://vagishhemmige.github.io/usRds/reference/set_USRDS_wd.md)
  is run
- Use `.parquet` if available, falling back to `.sas7bdat` or `.csv`
- Read the file using the best available method for that format
- You can also use `col_select` to choose specific variables, and
  `usrds_ids` to filter by patient. Set `factor_labels = TRUE` and
  `var_labels = TRUE` to apply value and variable labels:

### Labeling Options

The
[`load_usrds_file()`](https://vagishhemmige.github.io/usRds/reference/load_usrds_file.md)
function supports two options for enriching the data with documentation
from the USRDS Researcher’s Guide:

- `factor_labels = TRUE` applies value labels (e.g., turning codes like
  `"1"` into `"Male"`) using **Appendix C**.
- `var_labels = TRUE` attaches human-readable variable descriptions (as
  a `"label"` attribute) using **Appendix B**.

These options help make the raw USRDS data easier to interpret.

``` r
# Apply both value and variable labels
df <- load_usrds_file("RXHIST", factor_labels = TRUE, var_labels = TRUE)
```

To see what files are available:

``` r
list_available_usrds_files("IN")
```

## Option 2: Filtered Extractors (`get_*()` Functions) for Institutional and Physician/Supplier Files

The `usRds` package includes purpose-built extractor functions designed
to read and filter commonly used USRDS claims files. These functions are
optimized for performance and usability, automatically handling file
formats and filtering during load.

### Available Functions

- [`get_IN_ICD()`](https://vagishhemmige.github.io/usRds/reference/get_IN_ICD.md)
  – diagnoses from institutional claims
- [`get_IN_HCPCS()`](https://vagishhemmige.github.io/usRds/reference/get_IN_HCPCS.md)
  – HCPCS procedure codes from institutional claims
- [`get_PS_ICD()`](https://vagishhemmige.github.io/usRds/reference/get_PS_ICD.md)
  – diagnoses from physician/supplier claims
- [`get_PS_HCPCS()`](https://vagishhemmige.github.io/usRds/reference/get_PS_HCPCS.md)
  – HCPCS procedure codes from physician/supplier claims

### Key Arguments

All of the `get_*()` functions share the following arguments:

- `icd_codes` or `hcpcs_codes`: A character vector of diagnosis or
  procedure codes to filter. If `NULL`, all codes are returned.
- `years`: A numeric vector of years to include (e.g., `2006`,
  `2006:2008`)
- `usrds_ids` (optional): A character or numeric vector of `USRDS_ID`s
  to filter to a specific cohort. If omitted, all IDs are included.

### Examples

``` r
# Example: Extract ICD-9 codes from institutional claims
dx <- get_IN_ICD(icd_codes = c("042", "V08"), years = 2006:2007)

# Example: Extract HCPCS code "81003" from physician/supplier claims
ps <- get_PS_HCPCS(hcpcs_codes = "81003", years = 2006)

# Example: Filter to a specific cohort of patients
subset <- get_PS_ICD(
  icd_codes = "25000",
  years = 2012,
  usrds_ids = c("100001234", "100005678")
)
```

Each `get_*()` function:

- Automatically uses `.parquet` files if available for best performance
- Falls back to `.sas7bdat` or `.csv` when needed
- Applies filtering inline for efficiency
- Accepts optional filtering by `usrds_ids` or codes

These functions are optimized for the format of each file. **Parquet
files provide the fastest performance**, especially for large-scale
extraction.

## Summary

- Use
  [`load_usrds_file()`](https://vagishhemmige.github.io/usRds/reference/load_usrds_file.md)
  for unfiltered access to raw data
- Use `get_*()` functions for fast, focused queries by diagnosis or
  procedure code
- All functions are optimized for the available file type, and Parquet
  is preferred for maximum speed
