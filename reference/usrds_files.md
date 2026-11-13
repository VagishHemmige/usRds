# List the USRDS files mapped by `set_USRDS_wd()`

Returns what
[`set_USRDS_wd()`](https://vagishhemmige.github.io/usRds/reference/set_USRDS_wd.md)
found when it last mapped the USRDS folder: the files the package reads,
and the files it set aside or flagged.

## Usage

``` r
usrds_files(
  which = c("mapped", "other_formats", "unrecognised", "unread_duplicates", "incomplete")
)
```

## Arguments

- which:

  Which list to return:

  - `"mapped"`: the files the package reads, one per file and year.

  - `"other_formats"`: copies in another format that were set aside
    because of `format_preference`.

  - `"unrecognised"`: files whose names usRds does not recognise as
    USRDS files. Most are usually your own files; a USRDS file listed
    here would never be read.

  - `"unread_duplicates"`: files with more than one copy in a format
    that is not being read.

  - `"incomplete"`: years where only part of a claim-file group is
    present, with the missing files in the `missing` list column.

## Value

A tibble.

## Examples

``` r
if (FALSE) { # \dontrun{
set_USRDS_wd("C:/Data/USRDS")
usrds_files()
usrds_files("unrecognised")
} # }
```
