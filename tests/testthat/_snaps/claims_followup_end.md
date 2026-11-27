# claims_followup_end() warns when follow-up ends before the index (#23)

    Code
      result <- claims_followup_end(patient, index_date = "index", coverage_end = "coverage_end",
        death_date = "DIED", claims_end = as.Date("2023-12-31"))
    Condition
      Warning:
      1 row ends follow-up before `index_date`.

# claims_followup_end() checks its arguments (#23)

    Code
      claims_followup_end(patients, "index", "coverage_end", claims_end = "2023-12-31")
    Condition
      Error in `claims_followup_end()`:
      ! `claims_end` must be a single <Date>.

---

    Code
      claims_followup_end(patients, "index", "not_a_column", claims_end = as.Date(
        "2023-12-31"))
    Condition
      Error in `claims_followup_end()`:
      ! `coverage_end` must name a column of `df`.

---

    Code
      claims_followup_end(patients, "index", "coverage_end")
    Condition
      Error in `claims_followup_end()`:
      ! `claims_end` is required.
      i Give the date the claims in your release are complete to, for example `as.Date("2023-12-31")` for the 2025 standard analysis files.

# claims_followup_end() takes only whole days for max_days (#23)

    Code
      run(0.5)
    Condition
      Error in `claims_followup_end()`:
      ! `max_days` must be a single whole number of days, 0 or more.

