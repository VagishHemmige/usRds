
<!-- README.md is generated from README.Rmd. Please edit that file -->

# usRds

<!-- badges: start -->

<!-- badges: end -->

This is a prototype of an R package to facilitate analysis of the United
States Renal Data System using R, “usRds”. The package assumes that the
user already has obtained the data from the USRDS system, and that all
files are in CSV, SAS, or parquet format.

To install the package, type the following into R:

‘devtools::install_github(“VagishHemmige/usRds”)’

You will need to use the **set_USRDS_wd()** function to establish the
directory where the USRDS files are stored:

``` r
library(usRds)

# Session only:
set_USRDS_wd("C:/Path/To/USRDS")

# Or set permanently:
set_USRDS_wd("C:/Path/To/USRDS", permanent = TRUE)
```

The following functions are used to extract claims and diagnosis data
from the USRDS files:

- **`get_IN_HCPCS()`** — Extract inpatient claims with specified HCPCS
  codes  
- **`get_IN_ICD()`** — Extract inpatient claims with specified ICD
  diagnosis codes  
- **`get_PS_ICD()`** — Extract Physician Supplier claims by ICD codes  
- **`get_PS_HCPCS()`** — Extract Physician Supplier claims by HCPCS
  codes

Each function searches across all supported file formats (`.csv`,
`.sas7bdat`, `.parquet`) and filters efficiently by year and code list.

See [Function Reference](reference/index.html) for full documentation.

Much more, including help files, vignettes, etc. will be coming soon!

## Installation

You can install the development version of usRds from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("VagishHemmige/usRds")
```
