# finalize_usrds_cohort() refuses an already finalized cohort

    Code
      finalize_usrds_cohort(finalized, baseline_date_variable = "start")
    Condition
      Error:
      ! USRDS_cohort has already been finalized; its tstart and tstop are already relative to the baseline. Call finalize_usrds_cohort() once, on the cohort returned by create_usrds_cohort() and the add_cohort_*() functions.

---

    Code
      finalize_usrds_cohort(finalized)
    Condition
      Error:
      ! USRDS_cohort has already been finalized; its tstart and tstop are already relative to the baseline. Call finalize_usrds_cohort() once, on the cohort returned by create_usrds_cohort() and the add_cohort_*() functions.

