# add_cohort_covariate() refuses a finalized cohort

    Code
      add_cohort_covariate(finalized, covariates, "covariate_date",
        covariate_variable_name = "diabetes")
    Condition
      Error:
      ! USRDS_cohort has already been finalized, so covariates can no longer be added. Call add_cohort_covariate() before finalize_usrds_cohort().

