# Apply SRTR variable labels to a data frame

Adds descriptive variable labels to a dataset using the SRTR SAF data
dictionary from the 'sRtr' package, which must be installed. 'sRtr' also
has its own
[`sRtr::apply_srtr_varlabels()`](https://rdrr.io/pkg/sRtr/man/apply_srtr_varlabels.html),
which can infer the dataset from a file loaded with
[`sRtr::load_srtr_file()`](https://rdrr.io/pkg/sRtr/man/load_srtr_file.html).

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
df <- data.frame(CAN_ABO = c("A", "O"))
df <- apply_srtr_varlabels(df, dataset_key = "CAND_KIPA")
labelled::var_label(df$CAN_ABO)
#> [1] "Patient/s Blood Type"
```
