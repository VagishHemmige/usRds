
<!-- README.md is generated from README.Rmd. Please edit that file -->

# usRds

<!-- badges: start -->
<!-- badges: end -->

This is a prototype of an R package to facilitate analysis of the United
States Renal Data System using R, “usRds”. The package assumes that the
user already has obtained the data from the USRDS system, and that all
files are in CSV or SAS format. To install the package, type the
following into R:

devtools::install_github(“VagishHemmige/usRds”)

You will need to use the **set_USRDS_wd** function to establish the
directory where the USRDS files are stored, and the **map_USRDS_files**
function afterward to set up the main functions to extract data from the
USRDS:

get_IN_HCPCS  
get_IN_ICD  
get_PS_ICD  
get_PS_HCPCS

Much more, including help files, vignettes, etc. will be coming soon!

## Installation

You can install the development version of usRds from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("VagishHemmige/usRds")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(usRds)
## basic example code
```
