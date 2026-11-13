test_that("add_cohort_event() ignores an event data column named origin_date", {
  cohort <- create_usrds_cohort(
    data.frame(
      USRDS_ID = 1,
      start = as.Date("2010-01-01"),
      end = as.Date("2010-12-31")
    ),
    start_date = "start",
    end_date = "end"
  )
  events <- data.frame(
    USRDS_ID = 1,
    event_date = as.Date("2010-06-01"),
    origin_date = as.Date("2000-01-01")
  )

  result <- add_cohort_event(cohort, events, "event_date", "hospitalized")

  expect_equal(
    result$tstop[result$hospitalized == 1],
    as.numeric(as.Date("2010-06-01"))
  )
})

test_that("add_cohort_event() refuses a finalized cohort", {
  cohort <- create_usrds_cohort(
    data.frame(
      USRDS_ID = 1,
      start = as.Date("2010-01-01"),
      end = as.Date("2010-12-31")
    ),
    start_date = "start",
    end_date = "end"
  )
  finalized <- finalize_usrds_cohort(cohort)
  events <- data.frame(USRDS_ID = 1, event_date = as.Date("2010-06-01"))

  expect_snapshot(
    add_cohort_event(finalized, events, "event_date", "hospitalized"),
    error = TRUE
  )
})
