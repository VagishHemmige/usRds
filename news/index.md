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

- New
  [`claims_followup_end()`](https://vagishhemmige.github.io/usRds/reference/claims_followup_end.md)
  finds the last day of claims-based follow-up: the earliest of death,
  the end of Medicare-primary coverage, the date the claims are complete
  to, a study end date and a maximum length
  ([\#23](https://github.com/VagishHemmige/usRds/issues/23)).

- [`establish_dx_date()`](https://vagishhemmige.github.io/usRds/reference/establish_dx_date.md)
  gains `date_as` (date the diagnosis at the confirming claim, as
  before, or at the first claim), `window_days` (largest gap between two
  non-inpatient claims) and `inpatient_types`. REBUS inpatient stays
  (`HCFASAF` code `M`) now count as inpatient claims
  ([\#4](https://github.com/VagishHemmige/usRds/issues/4)).

- [`get_IN_REV_costs()`](https://vagishhemmige.github.io/usRds/reference/get_IN_REV_costs.md)
  returns `CLM_THRU`, `REV_DT` and the revenue center `CODE`, so its
  output can be prorated, and drops revenue center `0001` total lines by
  default (`drop_total_lines`), which counted each claim twice
  ([\#112](https://github.com/VagishHemmige/usRds/issues/112),
  [\#66](https://github.com/VagishHemmige/usRds/issues/66)).

- `get_PS_CLM_costs(remove_missing_values = TRUE)` now drops claims with
  a missing `CLM_PMT_AMT`; the argument had no effect before
  ([\#54](https://github.com/VagishHemmige/usRds/issues/54)).

- New
  [`prepare_medicare_coverage()`](https://vagishhemmige.github.io/usRds/reference/prepare_medicare_coverage.md)
  builds the Medicare-primary coverage spells from the payer history
  once. Passing its result to
  [`verify_medicare_primary()`](https://vagishhemmige.github.io/usRds/reference/verify_medicare_primary.md)
  skips rebuilding them on every call, which made checks inside a
  matching loop slow
  ([\#5](https://github.com/VagishHemmige/usRds/issues/5)).

- [`set_USRDS_wd()`](https://vagishhemmige.github.io/usRds/reference/set_USRDS_wd.md)
  gains `exclude`, folder names to skip (default
  `getOption("usRds.exclude")`, also used when usRds maps the folder on
  loading), and its help explains which copy of a file is read.
  [`usrds_files()`](https://vagishhemmige.github.io/usRds/reference/usrds_files.md)
  gains `"duplicates"` (every same-format copy that stops the map) and
  `"excluded"`; these and `"unrecognised"` are available even after a
  failed scan
  ([\#125](https://github.com/VagishHemmige/usRds/issues/125)).

- [`verify_medicare_primary()`](https://vagishhemmige.github.io/usRds/reference/verify_medicare_primary.md)
  gains `payers`, the payers that count as Medicare primary, as codes or
  labels; the default is still `MPAB` and `MPO`
  ([\#5](https://github.com/VagishHemmige/usRds/issues/5)).

- [`verify_medicare_primary()`](https://vagishhemmige.github.io/usRds/reference/verify_medicare_primary.md)
  accepts payer codes (`MPAB`, `MPO`) as well as their labels, merges
  coverage spans nested inside earlier ones, stops when coverage dates
  are not `Date`s, and warns about patients missing from the payer
  history it loads
  ([\#5](https://github.com/VagishHemmige/usRds/issues/5)).
