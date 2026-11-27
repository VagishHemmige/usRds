# exclude takes folder names only

    Code
      .map_USRDS_files(exclude = "old/backup", quiet = TRUE)
    Condition
      Error in `.map_USRDS_files()`:
      ! `exclude` takes folder names, not paths: "old/backup".
      i Give the name of the folder to skip, for example "backup"; every folder with that name is skipped.

---

    Code
      .map_USRDS_files(exclude = c("old", NA), quiet = TRUE)
    Condition
      Error in `.map_USRDS_files()`:
      ! `exclude` must be a character vector of folder names, with no missing or empty values.

---

    Code
      .map_USRDS_files(exclude = "", quiet = TRUE)
    Condition
      Error in `.map_USRDS_files()`:
      ! `exclude` must be a character vector of folder names, with no missing or empty values.

# usrds_files('duplicates') lists every copy after a failed scan

    Code
      usrds_files("mapped")
    Condition
      Error in `usrds_files()`:
      ! No USRDS files are mapped: the last scan of the USRDS folder stopped with an error.
      i See why with `usRds::usrds_files("duplicates")`, `usRds::usrds_files("excluded")` or `usRds::usrds_files("unrecognised")`, then call `set_USRDS_wd()` again with your USRDS folder and `exclude`.

# a scan that excludes every file says so and keeps its reports

    Code
      .map_USRDS_files(exclude = "backup", quiet = TRUE)
    Condition
      Error in `.map_USRDS_files()`:
      ! No USRDS files found in '<USRDS_WD>'.
      i Files must be '.csv', '.sas7bdat' or '.parquet', named as in the USRDS delivery (for example 'patients.sas7bdat' or 'ps2010a.csv').
      i 1 file with a name usRds does not recognise was set aside, for example 'notes.csv'.
      i 1 file in excluded folders ("backup") was skipped. List them with `usRds::usrds_files("excluded")`.

# the summary reports the files skipped in excluded folders

    Code
      invisible(.map_USRDS_files(exclude = c("backup", "old")))
    Message
      v Mapped 1 USRDS file: 1 Parquet.
      i 3 files in excluded folders were skipped (backup: 2 and old: 1). List them with `usRds::usrds_files("excluded")`.

# the duplicate error explains the format order and suggests exclude

    Code
      .map_USRDS_files(quiet = TRUE)
    Condition
      Error in `.map_USRDS_files()`:
      ! 1 USRDS file has more than one copy in the same format, so its claims would be read more than once.
      x patients.parquet (2 copies): ESRD Core/patients.parquet; backup/patients.parquet
      i Paths are relative to '<USRDS_WD>'. List every copy with `usRds::usrds_files("duplicates")`.
      i Only copies in the format that will be read count: for each file and year, the first format in `format_preference` that is present is read, and copies in other formats are only reported.
      i Keep one copy of each file under `USRDS_WD` (move backups elsewhere), or skip the folders that hold the extra copies: run your `set_USRDS_wd()` call again with those folders added to `exclude` (for example `exclude = "backup"`), keeping your other arguments.

