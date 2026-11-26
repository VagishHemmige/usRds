# Apply USRDS factor labels to a data frame

Given a loaded USRDS dataset and the corresponding file key (e.g.,
"PATIENTS", "RXHIST"), this function uses internal metadata to convert
numerically coded variables to factors using value mappings from
Appendix C of the USRDS Researcher's Guide.

## Usage

``` r
apply_usrds_factors(df, file_key, verbose = FALSE)
```

## Arguments

- df:

  A data frame loaded from a USRDS file.

- file_key:

  Character. The canonical file key (e.g., "PATIENTS").

- verbose:

  Logical. If TRUE, print each variable being labeled.

## Value

A data frame with factor variables applied where applicable.

## Details

Variable formats are looked up from Appendix B. Only variables with
formats beginning with a dollar sign (e.g., \$REMCD.) and present in the
dataset will be converted.

## Examples

``` r
# Made-up payer history, coded as in the USRDS files
payer_history <- data.frame(
  USRDS_ID = c(1, 2),
  PAYER = c("MPAB", "MPO")
)
apply_usrds_factors(payer_history, file_key = "PAYHIST")
#>   USRDS_ID                                                PAYER
#> 1        1 MEDICARE FFS PRIMARY PAY, FOR BOTH PART A AND PART B
#> 2        2                  MEDICARE FFS PRIMARY PAY, FOR OTHER

if (FALSE) { # \dontrun{
# load_usrds_file() applies the labels itself by default
df <- load_usrds_file("PATIENTS", factor_labels = TRUE)
} # }
```
