# Set the USRDS working directory

Sets the USRDS working directory for the current session, or optionally
saves it permanently in the user's `.Renviron` file as the environment
variable `USRDS_WD`.

## Usage

``` r
set_USRDS_wd(path, permanent = FALSE)
```

## Arguments

- path:

  Path to the USRDS data folder

- permanent:

  Logical; if TRUE, appends the setting to `.Renviron` for persistence

## Value

The normalized path, invisibly

## Examples

``` r
if (FALSE) { # \dontrun{
set_USRDS_wd("C:/Data/USRDS")          # Session only
set_USRDS_wd("C:/Data/USRDS", TRUE)    # Persistent across sessions
} # }
```
