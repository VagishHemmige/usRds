# Convert all USRDS raw files in a directory to Parquet

Converts all `.csv` and `.sas7bdat` files under a source directory into
`.parquet` files, preserving relative folder structure. Uses Arrow to
read and convert data.

## Usage

``` r
convert_usrds_to_parquet(source_dir, target_dir, overwrite = FALSE)
```

## Arguments

- source_dir:

  Root directory of raw USRDS files.

- target_dir:

  Root directory for `.parquet` output.

- overwrite:

  Logical. Overwrite existing output files?

## Value

Invisibly returns a tibble with source and target file paths.

## Examples

``` r
if (FALSE) { # \dontrun{
# Needs USRDS files; writes only to target_dir
convert_usrds_to_parquet(
  source_dir = "path/to/usrds/sas_files",
  target_dir = "path/to/usrds/parquet"
)
} # }
```
