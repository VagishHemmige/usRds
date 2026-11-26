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
# Made-up payer history
payer_history <- data.frame(
  USRDS_ID = c(1, 2),
  PAYER = c("MPAB", "MPO"),
  BEGDATE = as.Date(c("2010-01-01", "2011-01-01"))
)
labelled_history <- apply_usrds_varlabels(payer_history, file_key = "PAYHIST")
labelled::var_label(labelled_history)
#> $USRDS_ID
#> [1] "USRDS Assigned Patient ID Number"
#> 
#> $PAYER
#> [1] "Payer Category"
#> 
#> $BEGDATE
#> [1] "Start date of this period"
#> 

if (FALSE) { # \dontrun{
df <- load_usrds_file("PATIENTS", var_labels = TRUE)
labelled::var_label(df$CDEATH)
} # }
```
