# Apply SRTR variable labels to a data frame

Adds descriptive variable labels to a dataset using the SRTR SAF data
dictionary.

## Usage

``` r
apply_srtr_varlabels(df, dataset_key, verbose = FALSE)
```

## Arguments

- df:

  A data frame from a SAF file (e.g., CAND_KIPA, TX_KI).

- dataset_key:

  Character. The dataset name used in the SRTR dictionary (e.g.,
  "CAND_KIPA").

- verbose:

  Logical. If TRUE, prints each variable being labeled.

## Value

A data frame with variable labels added (invisible via print, viewable
via
[`labelled::var_label()`](https://larmarange.github.io/labelled/reference/var_label.html)).

## Examples

``` r
if (FALSE) { # \dontrun{
df <- read.csv("CAND_KIPA.parquet")
df <- apply_srtr_varlabels(df, dataset_key = "CAND_KIPA", verbose = TRUE)
labelled::var_label(df$ABO)
} # }
```
