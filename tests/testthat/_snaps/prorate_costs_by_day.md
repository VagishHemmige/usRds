# prorate_costs_by_day() warns when it drops claims with missing or reversed dates (#66)

    Code
      result <- prorate_costs_by_day(claims)
    Condition
      Warning:
      3 claims could not be spread over days and were left out, with their amounts:
      * 2 with a missing CLM_FROM or CLM_THRU
      * 1 with CLM_THRU before CLM_FROM

