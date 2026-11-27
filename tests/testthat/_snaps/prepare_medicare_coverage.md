# prepare_medicare_coverage() rejects payer codes not in Appendix C

    Code
      prepare_medicare_coverage(coverage_payhist(), payers = c("MPAB", "MEDICARE"))
    Condition
      Error in `prepare_medicare_coverage()`:
      ! `payers` has value not in the Appendix C `$PAYCAT.` format: "MEDICARE".
      i Use the codes "HMO", "MPAB", "MPO", "MSP-EGHP", "MSP-nonEGHP", "OTH", and "WAIT" or their Appendix C labels.

# verify_medicare_primary() stops when payers disagree with prepared coverage

    Code
      verify_medicare_primary(coverage_patients(), index_date = "index",
      medicare_coverage_df = coverage, payers = c("MPAB", "MPO"))
    Condition
      Error in `verify_medicare_primary()`:
      ! `payers` ("MPAB" and "MPO") differs from the payers `medicare_coverage_df` was prepared with ("MPAB").
      i Leave `payers` as `NULL`, or call `prepare_medicare_coverage()` again with the payers you want.

# verify_medicare_primary() still warns about patients absent from prepared coverage's payhist

    Code
      result <- verify_medicare_primary(extra, index_date = "index",
        medicare_coverage_df = prepare_medicare_coverage(coverage_payhist()))
    Condition
      Warning:
      1 USRDS_ID(s) in `df` are not present in `medicare_coverage_df`.

# verify_medicare_primary() stops on overlapping spells in prepared coverage

    Code
      verify_medicare_primary(patients, "index", medicare_coverage_df = edited)
    Condition
      Error in `verify_medicare_primary()`:
      ! `medicare_coverage_df` has overlapping spells for 1 patient.
      i Build it with `prepare_medicare_coverage()` and pass it without changing its rows.

