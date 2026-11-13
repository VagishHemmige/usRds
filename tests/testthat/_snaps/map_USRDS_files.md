# .map_USRDS_files() sets aside files with names it does not recognise

    Code
      result <- .map_USRDS_files()
    Message
      v Mapped 1 USRDS file: 1 CSV.
      i 2 files with names usRds does not recognise were set aside, for example 'my_cohort.csv' and 'results2020.parquet'.

# .map_USRDS_files() stops when one file has two copies in the same format

    Code
      .map_USRDS_files(quiet = TRUE)
    Condition
      Error in `.map_USRDS_files()`:
      ! 1 USRDS file has more than one copy in the same format, so its claims would be read more than once.
      x inc2010a.csv (2 copies): 5) ESRD Institution/inc2010a.csv; backups/inc2010a.csv
      i Paths are relative to '<USRDS_WD>'.
      i Keep one copy of each file under `USRDS_WD` (move backups elsewhere), then run `set_USRDS_wd()` again.

# .map_USRDS_files() lists each duplicated file on its own line

    Code
      .map_USRDS_files(quiet = TRUE)
    Condition
      Error in `.map_USRDS_files()`:
      ! 2 USRDS files have more than one copy in the same format, so their claims would be read more than once.
      x inc2010a.csv (3 copies): 5) ESRD Institution/inc2010a.csv; backups/2019/inc2010a.csv; backups/inc2010a.csv
      x patients.sas7bdat (2 copies): ESRD Core/patients.sas7bdat; old/patients.SAS7BDAT
      i Paths are relative to '<USRDS_WD>'.
      i Keep one copy of each file under `USRDS_WD` (move backups elsewhere), then run `set_USRDS_wd()` again.

# .map_USRDS_files() only reports duplicates in a format it will not read

    Code
      result <- .map_USRDS_files()
    Message
      v Mapped 1 USRDS file: 1 Parquet.
      i 2 other copies in another format were set aside. Format order: "parquet", "sas7bdat", and "csv".
      ! 1 file has duplicate copies in a format that is not being read, for example 'patients.sas7bdat'. They are ignored now, but would stop mapping if that format were read.

# .map_USRDS_files() stops when no USRDS files are found

    Code
      .map_USRDS_files(quiet = TRUE)
    Condition
      Error in `.map_USRDS_files()`:
      ! No USRDS files found in '<USRDS_WD>'.
      i Files must be '.csv', '.sas7bdat' or '.parquet', named as in the USRDS delivery (for example 'patients.sas7bdat' or 'ps2010a.csv').
      i 1 file with a name usRds does not recognise was set aside, for example 'notes.csv'.

# .map_USRDS_files() warns when only part of a year's file group is present

    Code
      result <- .map_USRDS_files()
    Message
      v Mapped 2 USRDS files: 2 SAS.
    Condition
      Warning:
      Some years have only part of their USRDS file group.
      ! 2007: missing det2007c, det2007d, det2007e, det2007f, det2007g, det2007h and 5 more (read by get_IN_HCPCS(), get_IN_ICD(), get_IN_REV_costs())
      i Claims, diagnoses and costs for these years would be incomplete. Add the missing files, then run `set_USRDS_wd()` again.

# .map_USRDS_files() reports what it found

    Code
      invisible(.map_USRDS_files())
    Message
      v Mapped 2 USRDS files: 1 Parquet and 1 SAS.
      i 1 other copy in another format was set aside. Format order: "parquet", "sas7bdat", and "csv".

# set_USRDS_wd() checks the format preference

    Code
      set_USRDS_wd(dir, format_preference = "xlsx")
    Condition
      Error in `set_USRDS_wd()`:
      ! `format_preference` has unknown format "xlsx".
      i Use any of "parquet", "sas7bdat", and "csv".

---

    Code
      set_USRDS_wd(dir, format_preference = c("csv", "csv"))
    Condition
      Error in `set_USRDS_wd()`:
      ! `format_preference` lists "csv" more than once.

# .check_valid_years() explains when no files have been mapped

    Code
      .check_valid_years(2010, IN_ICD$file_root, "Institutional ICD files")
    Condition
      Error in `.check_valid_years()`:
      ! No USRDS files are mapped yet.
      i Run `set_USRDS_wd("<your USRDS folder>")` first.

