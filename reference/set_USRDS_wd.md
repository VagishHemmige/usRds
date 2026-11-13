# Set the USRDS working directory

Sets the USRDS working directory for the current session, or optionally
saves it permanently in the user's `.Renviron` file as the environment
variable `USRDS_WD`, then maps the USRDS files found there.

## Usage

``` r
set_USRDS_wd(
  path,
  permanent = FALSE,
  format_preference = c("parquet", "sas7bdat", "csv"),
  on_incomplete = c("warn", "error")
)
```

## Arguments

- path:

  Path to the USRDS data folder

- permanent:

  Logical; if TRUE, appends the setting to `.Renviron` for persistence

- format_preference:

  Character vector of formats to use, most preferred first: any of
  `"parquet"`, `"sas7bdat"` and `"csv"`. Formats left out are ignored.
  Applies for the rest of the session.

- on_incomplete:

  What to do when only part of a year's claim-file group is present:
  `"warn"` (the default) or `"error"`.

## Value

The normalized path, invisibly

## Details

The map keeps one file per USRDS file and year. Files are recognised by
name (the file names in Appendix B and the package's claim-file tables),
wherever they sit under `path`, without regard to case. Files with other
names are counted and set aside. When a file exists in more than one
format, the first format in `format_preference` is used by every
function that reads it. Two copies of a file in the same format are an
error. If only part of a year's group of claim files is present (for
example some, but not all, of the 2007 institutional files), the years
and missing files are reported.

## Examples

``` r
if (FALSE) { # \dontrun{
set_USRDS_wd("C:/Data/USRDS")          # Session only
set_USRDS_wd("C:/Data/USRDS", TRUE)    # Persistent across sessions

# Use SAS files where both SAS and Parquet exist
set_USRDS_wd("C:/Data/USRDS", format_preference = c("sas7bdat", "parquet"))
} # }
```
