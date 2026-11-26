# verify_medicare_primary() stops when coverage dates are not Dates (#5)

    Code
      verify_medicare_primary(patients(), "index", medicare_coverage_df = history)
    Condition
      Error in `verify_medicare_primary()`:
      ! `BEGDATE` in the payer history must be of class Date, not character.

# verify_medicare_primary() warns about patients missing from payhist it loads (#5)

    Code
      result <- verify_medicare_primary(extra, index_date = "index")
    Condition
      Warning:
      1 USRDS_ID(s) in `df` are not present in `payhist`; these patients will be classified as FALSE.

