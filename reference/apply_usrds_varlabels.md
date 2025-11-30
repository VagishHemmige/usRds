# Apply USRDS variable labels to a data frame

Adds descriptive variable labels using Appendix B of the USRDS
Researcher's Guide. Variable labels are applied using the `labelled`
package.

## Usage

``` r
apply_usrds_varlabels(df, file_key, verbose = FALSE)
```

## Arguments

- df:

  A data frame loaded from a USRDS file.

- file_key:

  Character. The canonical file key (e.g., "PATIENTS").

- verbose:

  Logical. If TRUE, prints each variable being labeled.

## Value

A data frame with variable labels added (invisible via print, viewable
via
[`labelled::var_label()`](https://larmarange.github.io/labelled/reference/var_label.html)).

## Examples

``` r
if (FALSE) { # \dontrun{
df <- load_usrds_file("PATIENTS", var_labels = TRUE)
labelled::var_label(df$CDEATH)
} # }
```
