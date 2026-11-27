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
  on_incomplete = c("warn", "error"),
  exclude = getOption("usRds.exclude", character())
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

- exclude:

  Names of folders to skip, anywhere under `path`, compared without
  regard to case with each folder in a file's path: `"backup"` skips
  `old/Backup/ps2015a.parquet` but not `backups/ps2015a.parquet`. Files
  directly in `path` are never skipped. The default,
  `getOption("usRds.exclude")`, lets you set it once in a project's
  `.Rprofile`, for example
  `options(usRds.exclude = c("backup", "old"))`, so it also applies when
  usRds maps the folder on loading. An explicit value replaces the
  option; [`character()`](https://rdrr.io/r/base/character.html) skips
  nothing. Applies for the rest of the session.

## Value

The normalized path, invisibly

## Details

The map keeps one file per USRDS file and year. Files are recognised by
name (the file names in Appendix B and the package's claim-file tables),
wherever they sit under `path`, without regard to case. Files with other
names are counted and set aside
([`usrds_files()`](https://vagishhemmige.github.io/usRds/reference/usrds_files.md)
lists them). Folders named in `exclude` are skipped.

**Which copy is read.** For each file and year, the first format in
`format_preference` that is present is read by every function that reads
that file, and copies in other formats are only reported. So a CSV
export next to a Parquet file is harmless, but two copies in the format
that will be read (for example a second `ps2015a.parquet` in a backup
folder) are an error, because reading both would count their claims
twice. The error lists the copies; `usrds_files("duplicates")` lists all
of them, even after the error. Move the extra copies out of `path`, or
skip their folders with `exclude`. usRds never chooses between
same-format copies itself.

If only part of a year's group of claim files is present (for example
some, but not all, of the 2007 institutional files), the years and
missing files are reported.

## Examples

``` r
if (FALSE) { # \dontrun{
set_USRDS_wd("C:/Data/USRDS")          # Session only
set_USRDS_wd("C:/Data/USRDS", TRUE)    # Persistent across sessions

# Skip folders that hold stray copies
set_USRDS_wd("C:/Data/USRDS", exclude = c("backup", "old exports"))
usrds_files("excluded")

# Use SAS files where both SAS and Parquet exist
set_USRDS_wd("C:/Data/USRDS", format_preference = c("sas7bdat", "parquet"))
} # }
```
