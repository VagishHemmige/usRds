# .parse_claim_dates() warns with a count, not the values (#33)

    Code
      result <- .parse_claim_dates(claims, "CLM_THRU", "inc2010a.csv")
    Condition
      Warning:
      CLM_THRU in 'inc2010a.csv': 2 values could not be read as dates and were set to `NA`.
      i Dates are read in the forms "31JAN2010" and "2010-01-31".

# .hcfasaf_factor() warns about codes not in Appendix C (#27)

    Code
      result <- .hcfasaf_factor(c("I", "Z", NA))
    Condition
      Warning:
      1 claim has a claim type (HCFASAF) not in Appendix C and was set to `NA`.
      i Unknown code: "Z".

