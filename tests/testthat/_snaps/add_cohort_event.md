# add_cohort_event() refuses a finalized cohort

    Code
      add_cohort_event(finalized, events, "event_date", "hospitalized")
    Condition
      Error:
      ! USRDS_cohort has already been finalized, so events can no longer be added. Call add_cohort_event() before finalize_usrds_cohort().

