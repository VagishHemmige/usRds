# Internal: Map USRDS data files in the working directory

Scans the directory set by the USRDS_WD environment variable and stores
a cleaned file list in the package's internal environment for downstream
use.

## Usage

``` r
.map_USRDS_files()
```

## Details

This function is intended for internal use only and is automatically run
on package load if USRDS_WD is set.
