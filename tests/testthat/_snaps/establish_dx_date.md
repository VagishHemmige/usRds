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

# establish_dx_date() requires CLM_FROM to be a Date

    Code
      establish_dx_date(claims, window_days = 30)
    Condition
      Error in `establish_dx_date()`:
      ! CLM_FROM must be of class <Date>, not <POSIXct>.
      i The `get_*_ICD()` extractors return dates; convert with `as.Date()` if the claims came from elsewhere.

