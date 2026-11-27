# Changelog

## usRds 0.1.0.9000

- `NEWS.md` added to record user-facing changes from here on. Earlier
  changes are described in the pull requests on GitHub
  (<https://github.com/VagishHemmige/usRds/pulls?q=is%3Apr+is%3Amerged>).

- Claim extractors label `HCFASAF` code `E` as “Durable Medical
  Equipment”; it used to become `NA`, and
  [`establish_dx_date()`](https://vagishhemmige.github.io/usRds/reference/establish_dx_date.md)
  then dropped those claims. Code `Q` is now “Quarterly dialysis
  (PMMIS)”, as in Appendix C, and unknown codes give a warning
  ([\#27](https://github.com/VagishHemmige/usRds/issues/27)).

- [`adjust_costs_for_inflation()`](https://vagishhemmige.github.io/usRds/reference/adjust_costs_for_inflation.md)
  now finds the CPI for each claim’s month in any locale; in a
  non-English session every `_ADJUSTED` amount used to be `NA`
  ([\#105](https://github.com/VagishHemmige/usRds/issues/105)).

- New
  [`check_repo_for_usrds_data()`](https://vagishhemmige.github.io/usRds/reference/check_repo_for_usrds_data.md)
  lists files in a project folder that look like USRDS data (data file
  types, USRDS file names, `USRDS_ID` columns), by path only, checking
  the files git would commit
  ([\#49](https://github.com/VagishHemmige/usRds/issues/49)).

- [`verify_medicare_primary()`](https://vagishhemmige.github.io/usRds/reference/verify_medicare_primary.md)
  accepts payer codes (`MPAB`, `MPO`) as well as their labels, merges
  coverage spans nested inside earlier ones, stops when coverage dates
  are not `Date`s, and warns about patients missing from the payer
  history it loads
  ([\#5](https://github.com/VagishHemmige/usRds/issues/5)).
