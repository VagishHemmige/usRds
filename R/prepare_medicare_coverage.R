#' Build Medicare-primary coverage spells once, for repeated checks
#'
#' Keeps the payer history rows whose `PAYER` is one of `payers` and merges
#' spans that touch or overlap, including a span nested inside an earlier one,
#' into one spell per row. Pass the result to [verify_medicare_primary()] as
#' `medicare_coverage_df` when it is called many times, for example once per
#' risk set in a matching loop: prepared coverage is used as it is, while raw
#' payer history is filtered and merged again on every call.
#'
#' @param payhist A data frame from the `payhist` file, with columns
#'   `USRDS_ID`, `PAYER`, `BEGDATE` and `ENDDATE`. `BEGDATE` and `ENDDATE`
#'   must be of class `Date`. `PAYER` may hold Appendix C `$PAYCAT.` codes or
#'   their labels.
#' @param payers Payers whose spans make up the coverage, as Appendix C
#'   `$PAYCAT.` codes or their labels. The default, `c("MPAB", "MPO")`, is
#'   Medicare fee-for-service primary pay for both Part A and Part B, or for
#'   one of them: Medicare primary coverage (Researcher's Guide 2025, Example
#'   8 and Section 4, Table 7). `"MPAB"` alone requires both parts. Secondary
#'   payer (`MSP-EGHP`, `MSP-nonEGHP`), `HMO` and `WAIT` spans are not
#'   Medicare primary, and claims are incomplete for them; see
#'   [verify_medicare_primary()].
#'
#' @return A data frame of class `usrds_medicare_coverage`, with one row per
#'   spell and columns `USRDS_ID`, `BEGDATE` and `ENDDATE`. Attributes record
#'   the `payers` used and the `USRDS_ID`s present in `payhist`, so
#'   [verify_medicare_primary()] can still warn about patients with no payer
#'   history at all. Patients with history but no eligible spell have no row.
#' @export
#'
#' @examples
#' payer_history <- data.frame(
#'   USRDS_ID = c(1, 1, 2),
#'   PAYER = c("MPAB", "MPAB", "MSP-EGHP"),
#'   BEGDATE = as.Date(c("2009-01-01", "2009-07-01", "2009-01-01")),
#'   ENDDATE = as.Date(c("2009-06-30", "2010-12-31", "2010-12-31"))
#' )
#' coverage <- prepare_medicare_coverage(payer_history)
#' coverage
#'
#' patients <- data.frame(
#'   USRDS_ID = c(1, 2),
#'   index = as.Date(c("2010-06-01", "2010-06-01"))
#' )
#' verify_medicare_primary(
#'   patients,
#'   index_date = "index",
#'   medicare_coverage_df = coverage
#' )
prepare_medicare_coverage <- function(payhist, payers = c("MPAB", "MPO")) {
  if (!inherits(payhist, "data.frame")) {
    cli::cli_abort("{.arg payhist} must be a data frame.")
  }
  missing <- setdiff(c("USRDS_ID", "PAYER", "BEGDATE", "ENDDATE"), names(payhist))
  if (length(missing) > 0) {
    cli::cli_abort(
      "{.arg payhist} is missing required column{?s} {.field {missing}}."
    )
  }
  payers <- .check_payers(payers)

  spells <- .build_medicare_spells(payhist, payers)

  structure(
    spells,
    class = c("usrds_medicare_coverage", class(spells)),
    payers = payers,
    payhist_ids = unique(payhist$USRDS_ID)
  )
}

# Appendix C 2025 `$PAYCAT.` codes and labels: PAYER holds either, depending
# on whether payhist was loaded with factor labels.
.paycat_labels <- c(
  "HMO" = "HEALTH MAINTENANCE ORGANIZATION (HMO) PLAN, A TYPE OF MEDICARE ADVANTAGE PLAN",
  "MPAB" = "MEDICARE FFS PRIMARY PAY, FOR BOTH PART A AND PART B",
  "MPO" = "MEDICARE FFS PRIMARY PAY, FOR OTHER",
  "MSP-EGHP" = "MEDICARE FFS SECONDARY PAYER WITH EMPLOYER GROUP HEALTH PLAN(EGHP)",
  "MSP-nonEGHP" = "MEDICARE FFS SECONDARY PAYER, WITHOUT EMPLOYER GROUP HEALTH PLAN(EGHP)",
  "OTH" = "OTHER/UNKNOWN",
  "WAIT" = "90 DAY WAITING PERIOD"
)

.check_payers <- function(payers, call = rlang::caller_env()) {
  if (!is.character(payers) || length(payers) == 0 || anyNA(payers)) {
    cli::cli_abort(
      "{.arg payers} must be a character vector of payer codes.",
      call = call
    )
  }
  # Labels are turned into their codes, so either can be given.
  codes <- ifelse(
    payers %in% .paycat_labels,
    names(.paycat_labels)[match(payers, .paycat_labels)],
    payers
  )
  unknown <- payers[!codes %in% names(.paycat_labels)]
  if (length(unknown) > 0) {
    cli::cli_abort(
      c(
        "{.arg payers} has value{?s} not in the Appendix C {.code $PAYCAT.}
        format: {.val {unknown}}.",
        "i" = "Use the codes {.val {names(.paycat_labels)}} or their
        Appendix C labels."
      ),
      call = call
    )
  }
  unique(unname(codes))
}

# Keeps the payhist rows for `payers` and merges touching or overlapping
# spans into spells (USRDS_ID, BEGDATE, ENDDATE).
.build_medicare_spells <- function(payhist, payers, call = rlang::caller_env()) {
  for (col in c("BEGDATE", "ENDDATE")) {
    if (!inherits(payhist[[col]], "Date")) {
      rlang::abort(
        paste0(
          "`", col, "` in the payer history must be of class Date, not ",
          class(payhist[[col]])[1], "."
        ),
        call = call
      )
    }
  }

  eligible_payers <- c(payers, unname(.paycat_labels[payers]))

  payhist |>
    dplyr::filter(as.character(.data$PAYER) %in% .env$eligible_payers) |>
    dplyr::select("USRDS_ID", "BEGDATE", "ENDDATE") |>
    dplyr::arrange(.data$USRDS_ID, .data$BEGDATE) |>

    #Combine lines where there is no gap between the lines and they are the same patient.
    #A gap is measured from the latest end date so far, not the previous
    #row's, so a span nested inside an earlier one does not split it (#5).
    dplyr::group_by(.data$USRDS_ID) |>
    dplyr::arrange(.data$BEGDATE, .by_group = TRUE) |>
    #Dates are compared as day numbers. A missing end date does not
    #extend the spell, so (as before #5) the next span starts a new spell
    #instead of every later span being split.
    dplyr::mutate(
      end_day = as.numeric(.data$ENDDATE),
      prev_end = dplyr::lag(
        cummax(dplyr::if_else(is.na(.data$end_day), -Inf, .data$end_day))
      ),

      # start a new group if there is a gap
      new_group = dplyr::if_else(
        is.na(.data$prev_end) |
          as.numeric(.data$BEGDATE) > .data$prev_end + 1,
        1L,
        0L
      ),
      group_id = cumsum(.data$new_group)
    ) |>
    dplyr::group_by(.data$USRDS_ID, .data$group_id) |>
    dplyr::summarise(
      BEGDATE = min(.data$BEGDATE),
      #A missing end date adds nothing to the spell; a spell whose end
      #dates are all missing keeps a missing end (#5).
      ENDDATE = if (all(is.na(.data$ENDDATE))) {
        .data$ENDDATE[1]
      } else {
        max(.data$ENDDATE, na.rm = TRUE)
      },
      .groups = "drop"
    ) |>
    dplyr::select(-"group_id")
}

# Prepared coverage can be edited after prepare_medicare_coverage() built it;
# overlapping spells would make a patient row match two spells.
.check_disjoint_spells <- function(coverage, call = rlang::caller_env()) {
  ordered <- coverage[order(coverage$USRDS_ID, coverage$BEGDATE), ]
  same_patient <- ordered$USRDS_ID[-1] == ordered$USRDS_ID[-nrow(ordered)]
  overlaps <- same_patient &
    as.numeric(ordered$BEGDATE[-1]) <= as.numeric(ordered$ENDDATE[-nrow(ordered)])
  overlaps[is.na(overlaps)] <- FALSE
  if (any(overlaps)) {
    ids <- unique(ordered$USRDS_ID[-1][overlaps])
    cli::cli_abort(
      c(
        "{.arg medicare_coverage_df} has overlapping spells for
        {length(ids)} patient{?s}.",
        "i" = "Build it with {.fn prepare_medicare_coverage} and pass it
        without changing its rows."
      ),
      call = call
    )
  }
  invisible(coverage)
}
