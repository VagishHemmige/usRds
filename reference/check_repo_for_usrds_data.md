# Check a project folder for files that look like USRDS data

Scans a project folder, usually a git repository, for files that look
like patient-level USRDS data, so they can be removed or ignored before
they are committed or shared. USRDS data are covered by a data use
agreement: a private repository is still a disclosure.

## Usage

``` r
check_repo_for_usrds_data(path = ".", id_columns = "USRDS_ID", quiet = FALSE)
```

## Arguments

- path:

  The project folder to check. Defaults to the working directory.

- id_columns:

  Column names that identify a patient. A text file whose header has any
  of them is reported. The default is `"USRDS_ID"`; add SRTR identifiers
  such as `"PX_ID"` or `"PERS_ID"` when the project also uses SRTR data.

- quiet:

  If `TRUE`, nothing is printed.

## Value

A data frame with one row per file reported and columns `path` (relative
to `path`) and `reason`, invisibly. Its `scan` attribute is `"git"` or
`"folder"`, saying which list of files was checked.

## Details

A file is reported when it is:

- a data file type: `.sas7bdat`, `.sas7bcat`, `.xpt`, `.parquet`,
  `.feather`, `.arrow`, `.dta` or `.sav`;

- named like a USRDS file (an Appendix B file name, with any year, or a
  claim file the package reads), with a `.csv`, `.tsv`, `.txt`, `.rds`,
  `.rda`, `.rdata`, `.xls` or `.xlsx` extension; or

- a `.csv`, `.tsv` or `.txt` file whose header line has a column in
  `id_columns` (case ignored).

Inside a git repository, the files checked are those git would commit:
tracked files, and untracked files that `.gitignore` does not exclude. A
file git already tracks is checked even if `.gitignore` lists it.
Outside one, or when git is not installed, every file under `path` is
checked, apart from the `.git` folder. Files under
`tests/testthat/fixtures/` whose names start with `synthetic-` are
skipped, as made-up test data.

The check is read-only. It reads file names, and the first line of
`.csv`, `.tsv` and `.txt` files to find column names. It does not read
any other content, and it reports paths only.

A clean result does not make a folder safe: data can sit in files with
other names or formats. See the article "Data protection and security"
on the package website.

## Examples

``` r
project <- tempfile("project")
dir.create(project)
writeLines(c("USRDS_ID,age", "1,50"), file.path(project, "cohort.csv"))
writeLines("x <- 1", file.path(project, "analysis.R"))
check_repo_for_usrds_data(project)
#> Warning: 1 file in /tmp/RtmpTFqPv3/project198f2dce61d3 may be USRDS data:
#> • cohort.csv: identifier column (USRDS_ID)
#> ℹ Checked all files (not a git repository, or git not found).
#> ℹ Move these files outside the project, or list untracked ones in .gitignore.
#> ℹ .gitignore does not stop git tracking a file it already tracks; remove such
#>   files from git with `git rm --cached <file>`. Data already pushed needs
#>   separate remediation.
unlink(project, recursive = TRUE)
```
