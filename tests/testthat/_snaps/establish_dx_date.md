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

