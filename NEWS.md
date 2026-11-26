# usRds (development version)

* `NEWS.md` added to record user-facing changes from here on. Earlier changes
  are described in the pull requests on GitHub
  (<https://github.com/VagishHemmige/usRds/pulls?q=is%3Apr+is%3Amerged>).

* `adjust_costs_for_inflation()` now finds the CPI for each claim's month in
  any locale; in a non-English session every `_ADJUSTED` amount used to be
  `NA` (#105).

* New `check_repo_for_usrds_data()` lists files in a project folder that look
  like USRDS data (data file types, USRDS file names, `USRDS_ID` columns), by
  path only, checking the files git would commit (#49).

* `verify_medicare_primary()` accepts payer codes (`MPAB`, `MPO`) as well as
  their labels, merges coverage spans nested inside earlier ones, stops when
  coverage dates are not `Date`s, and warns about patients missing from the
  payer history it loads (#5).
