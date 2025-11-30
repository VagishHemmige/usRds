# Load a USRDS file and optionally apply labels

This function loads a USRDS data file using the internal registry and
optionally applies:

- Factor labels using format definitions from [Appendix
  C](https://www.niddk.nih.gov/about-niddk/strategic-plans-reports/usrds/for-researchers/researchers-guide)

- Variable labels using descriptions from [Appendix
  B](https://www.niddk.nih.gov/about-niddk/strategic-plans-reports/usrds/for-researchers/researchers-guide)

## Usage

``` r
load_usrds_file(
  file_key,
  factor_labels = TRUE,
  var_labels = FALSE,
  usrds_ids = NULL,
  col_select = NULL,
  ...
)
```

## Arguments

- file_key:

  Character. File key (e.g., "PATIENTS", "RXHIST"). Case-insensitive
  match to registered file names.

- factor_labels:

  Logical. Whether to apply factor labels (from Appendix C). Default =
  TRUE.

- var_labels:

  Logical. Whether to apply variable labels (from Appendix B). Default =
  FALSE.

- usrds_ids:

  Optional. A vector of USRDS_IDs to retain in the file. Only applied if
  the file contains a `USRDS_ID` column.

- col_select:

  Optional. A character vector or tidyselect expression for selecting
  columns to load.

- ...:

  Additional arguments passed to the file reader (e.g., `as_factor` for
  `read_sas`)

## Value

A tibble with the contents of the selected file, optionally labeled with
factors and variable descriptions.

## Details

All variable names are standardized to uppercase after loading.

`col_select` supports tidyselect syntax for CSV and SAS files, and is
also available for Parquet files (resolved automatically to column
names).

## Examples

``` r
if (FALSE) { # \dontrun{
# Load the PATIENTS file and apply factor labels (Appendix C)
df <- load_usrds_file("PATIENTS", factor_labels = TRUE)

# Load the RXHIST file with both factor and variable labels
df <- load_usrds_file("RXHIST", factor_labels = TRUE, var_labels = TRUE)

# Select only columns starting with "CD" (works for all file types)
df <- load_usrds_file("PATIENTS", col_select = dplyr::starts_with("CD"))

# Load only specific columns by name
df <- load_usrds_file("PATIENTS", col_select = c("USRDS_ID", "CDEATH"))

# Filter to a subset of USRDS_IDs
df <- load_usrds_file("RXHIST", usrds_ids = c("100000123", "100000456"))
} # }
```
