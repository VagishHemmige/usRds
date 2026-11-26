# usRds (development version)

* `NEWS.md` added to record user-facing changes from here on. Earlier changes
  are described in the pull requests on GitHub
  (<https://github.com/VagishHemmige/usRds/pulls?q=is%3Apr+is%3Amerged>).

* `adjust_costs_for_inflation()` now finds the CPI for each claim's month in
  any locale; in a non-English session every `_ADJUSTED` amount used to be
  `NA` (#105).
