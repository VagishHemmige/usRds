test_that("USRDS cohort workflow supports chained tmerge operations", {

  ## ---- Baseline data -----------------------------------------------------

  df <- data.frame(
    USRDS_ID = c(1, 2, 3),
    start    = as.Date(c("2005-01-01", "2006-01-01", "2007-01-01")),
    end      = as.Date(c("2010-01-01", "2011-01-01", "2012-01-01"))
  )

  ## ---- Create cohort -----------------------------------------------------

  cohort <- create_usrds_cohort(
    df = df,
    start_date = "start",
    end_date   = "end"
  )

  ## ---- Cohort invariants -------------------------------------------------

  expect_identical(attr(cohort, "cohort_type"), "USRDS_cohort")
  expect_true(all(c("tstart", "tstop") %in% names(cohort)))
  expect_true(all(cohort$tstop > cohort$tstart))
  expect_equal(nrow(cohort), 3)

  ## ---- Add first event ---------------------------------------------------

  origin <- as.Date("2000-01-01")

  events1 <- data.frame(
    USRDS_ID = c(1, 1, 3),
    event_day = origin + cohort$tstart[c(1,1, 3)] + c(100, 150, 200)
  )

  cohort <- add_cohort_event(
    USRDS_cohort = cohort,
    event_data_frame = events1,
    event_date = "event_day",
    event_variable_name = "event1"
  )

  expect_true("event1" %in% names(cohort))
  expect_true(all(cohort$event1 >= 0))

  ## ---- Add second (recurrent) event -------------------------------------

  events2 <- data.frame(
    USRDS_ID = c(1, 1, 2),
    event_day = as.Date(origin + cohort$tstart[c(1, 1, 2)] + c(125, 500, 400))
  )

  cohort <- add_cohort_event(
    USRDS_cohort = cohort,
    event_data_frame = events2,
    event_date = "event_day",
    event_variable_name = "event2"
  )

  #Test covariates without explicit values
  covariates1<-data.frame(
    USRDS_ID= c(1,2,3),
    covariate_day = as.Date(origin + c(1827, 2192, 2557) + c(125, 380, 10))
  )

  cohort<- add_cohort_covariate(
    USRDS_cohort= cohort,
    covariate_data_frame=covariates1,
    covariate_date= "covariate_day",
    covariate_variable_name = "covariate_variable_1"
  )

  #Test covariates without explicit values
  covariates2<-data.frame(
    USRDS_ID= c(1,1,1,2,2,2,2,3,3,3),
    covariate_day = as.Date(origin +
                              c(1827,1827,1827, 2192, 2192,2192,2192, 2557,2557,2557) +
                              c(-145, 10,40, 10,20,40,60,-3, 360, 370)),
    MELD=c(10,30,20,24,23,12,NA,3,55,33)
  )

  cohort<- add_cohort_covariate(
    USRDS_cohort= cohort,
    covariate_data_frame=covariates2,
    covariate_date= "covariate_day",
    covariate_variable_name = "covariate_variable_2",
    covariate_value="MELD"
  )

  expect_true("event2" %in% names(cohort))
  expect_true(all(cohort$event2 >= 0))

  ## ---- tmerge stability checks ------------------------------------------

  expect_true(all(cohort$tstop > cohort$tstart))
  expect_identical(attr(cohort, "cohort_type"), "USRDS_cohort")

})
