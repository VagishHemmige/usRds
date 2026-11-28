# establish_dx_date() warns about claims with a missing CLM_FROM (#4)

    Code
      result <- establish_dx_date(claims)
    Condition
      Warning:
      Left out 2 claims with a missing CLM_FROM.
      i 1 of the 2 patients with such a claim got no diagnosis date.
      i For the others, an undated claim may have given an earlier date.
      i Set `on_missing_date` to "ignore" to silence this, or "error" to stop.

---

    Code
      establish_dx_date(claims, on_missing_date = "error")
    Condition
      Error in `establish_dx_date()`:
      ! 2 claims have a missing CLM_FROM.
      i Remove or date them, or set `on_missing_date` to "warn" or "ignore" to leave them out.

# establish_dx_date() checks its options (#4)

    Code
      establish_dx_date(claims, window_days = -1)
    Condition
      Error in `establish_dx_date()`:
      ! `window_days` must be a single number of days, 0 or more, or `Inf`.

---

    Code
      establish_dx_date(claims, date_as = "last")
    Condition
      Error in `establish_dx_date()`:
      ! `date_as` must be one of "confirming" or "first", not "last".

---

    Code
      establish_dx_date(claims, count_by = "claims")
    Condition
      Error in `establish_dx_date()`:
      ! `count_by` must be one of "days" or "rows", not "claims".

---

    Code
      establish_dx_date(claims, on_missing_date = "drop")
    Condition
      Error in `establish_dx_date()`:
      ! `on_missing_date` must be one of "warn", "error", or "ignore", not "drop".

# establish_dx_date() requires CLM_FROM to be a Date

    Code
      establish_dx_date(claims, window_days = 30)
    Condition
      Error in `establish_dx_date()`:
      ! CLM_FROM must be of class <Date>, not <POSIXct>.
      i Convert it with `as.Date()` before calling `establish_dx_date()`.

