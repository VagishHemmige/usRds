#' Verify that a patient has Medicare primary coverage
#'
#' This function accepts a data frame `df`, an index date option `index_date` which is either a fixed date or
#' the name of a date variable in quotes, and a variable `lookback_days` that encodes how many days of Medicare
#' coverage are necessary.
#'
#' An optional variable `medicare_coverage_df` allows for a df containing information from the `payhist` file to be passed to the function.  If left
#' NULL, then the function will load the data via the `load_usrds_file` function, which can be very inefficient for multiple function calls.
#'
#' It returns the same dataframe with a new variable `medicare_primary_TF` that takes the values `TRUE`
#' or `FALSE`.
#'
#' Optionally, the start dates and end dates of Medicare primary coverage for that coverage spell can also be returned by specifying names for
#' the return variables in the `coverage_start_variable` and `coverage_end_variable` parameters.  If unspecified, these parameters will not be returned.
#'
#' When the function reads `payhist` itself, setting `cache = TRUE` keeps the
#' processed coverage for later calls. Payer history passed as
#' `medicare_coverage_df` is never cached; use [prepare_medicare_coverage()]
#' instead.
#'
#' Medicare primary coverage means a `PAYER` listed in `payers`. By default
#' that is `MPAB` (Medicare fee-for-service primary pay for both Part A and
#' Part B) or `MPO` (Medicare fee-for-service primary pay for other), from the
#' Appendix C `$PAYCAT.` format; the Researcher's Guide 2025 (Section 4,
#' "Payer History") notes that Medicare claims are complete only for
#' Medicare-primary enrollees. `PAYER` may hold these codes or their Appendix
#' C labels, so payer history loaded with or without `factor_labels` gives the
#' same result.
#'
#' When `verify_medicare_primary()` is called many times, for example once
#' per risk set in a matching loop, build the coverage spells once with
#' [prepare_medicare_coverage()] and pass the result as
#' `medicare_coverage_df`. Raw payer history passed as `medicare_coverage_df`
#' is filtered and merged again on every call.
#' `BEGDATE` and `ENDDATE` must be of class `Date`. Spans that touch or
#' overlap, including a span nested inside an earlier one, are merged into
#' one spell. Patients with no rows in `payhist` get `FALSE`, with a warning.
#'
#' @param df is a data frame, presumably one with a single row per patient.  Data frame *must* contain
#' a column named `USRDS_ID`.
#'
#' @param index_date either a fixed date or the name of a date variable in quotes
#'
#' @param lookback_days is the number of days of Medicare as primary necessary.  Default value is 365.
#'
#' @param medicare_coverage_df is an optional parameter containing a df from
#'   the `payhist` file, or the result of [prepare_medicare_coverage()], which
#'   is used as it is.
#'
#' @param coverage_start_variable is the name of the variable containing the start date of Medicare primary coverage for the coverage spell containing the
#' `index_date`.  The default value of NULL specifies no variable returned.
#'
#' @param coverage_end_variable is the name of the variable containing the end date of Medicare primary coverage for the coverage spell containing the
#' `index_date`.  The default value of NULL specifies no variable returned.
#'
#' @param cache whether or not to cache, or use a previously cached version, of the medicare coverage data frame.  This can save substantial amounts of
#' time in a loop. The cache is used only when it was built from the same
#' USRDS folder and covers every patient in `df`; otherwise `payhist` is read
#' again and the cache replaced. It is cleared whenever the files are mapped
#' again with [set_USRDS_wd()]. Ignored when `medicare_coverage_df` is given.
#'
#' @param payers Payers that count as Medicare primary, as Appendix C
#'   `$PAYCAT.` codes or their labels. `NULL` (the default) means `c("MPAB", "MPO")`, or,
#'   when `medicare_coverage_df` comes from [prepare_medicare_coverage()], the
#'   payers it was prepared with. Payers that disagree with prepared coverage
#'   are an error.
#'
#' @return The original `df` data fame with the variable `medicare_primary_TF` added
#'
#' @export
#'
#' @examples
#' payer_history <- data.frame(
#'   USRDS_ID = c(1, 1, 2),
#'   PAYER = c("MPAB", "MPAB", "MSP-EGHP"),
#'   BEGDATE = as.Date(c("2009-01-01", "2009-07-01", "2009-01-01")),
#'   ENDDATE = as.Date(c("2009-06-30", "2010-12-31", "2010-12-31"))
#' )
#' patients <- data.frame(
#'   USRDS_ID = c(1, 2),
#'   index = as.Date(c("2010-06-01", "2010-06-01"))
#' )
#' verify_medicare_primary(
#'   patients,
#'   index_date = "index",
#'   medicare_coverage_df = payer_history,
#'   coverage_start_variable = "coverage_start"
#' )

verify_medicare_primary <- function(
  df,
  index_date,
  lookback_days = 365,
  medicare_coverage_df = NULL,
  coverage_start_variable = NULL,
  coverage_end_variable = NULL,
  cache = FALSE,
  payers = NULL
) {
  #Error checking

  #Check that df is an appropriate data frame
  if (!inherits(df, "data.frame")) {
    rlang::abort("`df` must be a data frame.")
  }

  #Check that medicare_coverage_df is an appropriate data frame
  if (
    !inherits(medicare_coverage_df, "data.frame") &&
      !is.null(medicare_coverage_df)
  ) {
    rlang::abort("`medicare_coverage_df` must be a data frame or NULL.")
  }

  if (nrow(df) == 0) {
    rlang::abort("`df` must have at least one row.")
  }

  if (!"USRDS_ID" %in% names(df)) {
    rlang::abort("`df` must contain a column named `USRDS_ID`.")
  }

  if (
    !is.null(medicare_coverage_df) &&
      !"USRDS_ID" %in% names(medicare_coverage_df)
  ) {
    rlang::abort(
      "`medicare_coverage_df` must contain a column named `USRDS_ID`."
    )
  }

  if (all(is.na(df$USRDS_ID))) {
    rlang::abort("`df$USRDS_ID` cannot be all missing.")
  }

  #Confirm that index_date is of the right form
  if (inherits(index_date, "Date")) {
    # ok
  } else if (is.character(index_date) && length(index_date) == 1) {
    if (!index_date %in% names(df)) {
      rlang::abort(
        "`index_date` must be a Date or the name of a date column in `df`."
      )
    }
    if (!inherits(df[[index_date]], "Date")) {
      rlang::abort(
        paste0("`df$", index_date, "` must be of class Date.")
      )
    }
  } else {
    rlang::abort(
      "`index_date` must be a Date or a single character string naming a Date column in `df`."
    )
  }

  #Verify that lookback_days is an integer greater than zero.
  if (
    !is.numeric(lookback_days) ||
      length(lookback_days) != 1 ||
      lookback_days <= 0 ||
      lookback_days %% 1 != 0
  ) {
    rlang::abort(
      "`lookback_days` must be a single integer greater than 0."
    )
  }

  if (is.character(index_date)) {
    if (any(is.na(df[[index_date]]))) {
      rlang::warn(
        paste0(
          "`df$",
          index_date,
          "` contains missing values; ",
          "these patients will be classified as FALSE."
        )
      )
    }
  }

  prepared <- inherits(medicare_coverage_df, "usrds_medicare_coverage")

  #Warning if df containus USRDS_IDs that are not in the medicare_coverage_df (assuming the latter is not NULL)
  if (!is.null(medicare_coverage_df)) {
    payhist_ids <- if (prepared) {
      attr(medicare_coverage_df, "payhist_ids")
    } else {
      medicare_coverage_df$USRDS_ID
    }
    missing_ids <- setdiff(df$USRDS_ID, payhist_ids)

    if (length(missing_ids) > 0) {
      rlang::warn(paste0(
        length(missing_ids),
        " USRDS_ID(s) in `df` are not present in `medicare_coverage_df`."
      ))
    }
  }

  if (!is.null(medicare_coverage_df) && !prepared) {
    required_cols <- c("USRDS_ID", "PAYER", "BEGDATE", "ENDDATE")
    missing <- setdiff(required_cols, names(medicare_coverage_df))
    if (length(missing) > 0) {
      rlang::abort(
        paste0(
          "`medicare_coverage_df` is missing required columns: ",
          paste(missing, collapse = ", ")
        )
      )
    }
  }

  if (!is.null(coverage_start_variable)) {
    if (
      !is.character(coverage_start_variable) ||
        length(coverage_start_variable) > 1
    ) {
      rlang::abort(
        "`coverage_start_variable` must be NULL or a single character string."
      )
    } else if (coverage_start_variable %in% names(df)) {
      rlang::abort(
        "Value of `coverage_start_variable` must not already be a variable in `df`."
      )
    }
  }

  if (!is.null(coverage_end_variable)) {
    if (
      !is.character(coverage_end_variable) || length(coverage_end_variable) > 1
    ) {
      rlang::abort(
        "`coverage_end_variable` must be NULL or a single character string."
      )
    } else if (coverage_end_variable %in% names(df)) {
      rlang::abort(
        "Value of `coverage_end_variable` must not already be a variable in `df`."
      )
    }
  }

  if (!is.logical(cache) || length(cache) != 1 || is.na(cache)) {
    rlang::abort("`cache` must be a single TRUE or FALSE value.")
  }

  if (!is.null(payers)) {
    payers <- .check_payers(payers)
  }
  if (prepared) {
    prepared_payers <- attr(medicare_coverage_df, "payers")
    if (!is.null(payers) && !setequal(payers, prepared_payers)) {
      cli::cli_abort(c(
        "{.arg payers} ({.val {payers}}) differs from the payers
        {.arg medicare_coverage_df} was prepared with
        ({.val {prepared_payers}}).",
        "i" = "Leave {.arg payers} as {.code NULL}, or call
        {.fn prepare_medicare_coverage} again with the payers you want."
      ))
    }
    payers <- prepared_payers
  } else {
    if (is.null(payers)) {
      payers <- c("MPAB", "MPO")
    }
  }

  #--------------------------------------------------------------------------------------------

  # Now we begin the code which executes the purpose of the function

  #Convert index_date if necessary to something that can be used
  if (is.character(index_date) && length(index_date) == 1) {
    df <- df |> dplyr::mutate(.index_date = .data[[index_date]])
  } else {
    df <- df |> dplyr::mutate(.index_date = as.Date(.env$index_date))
  }

  #Open Medicare history file, keep rows where the payer is Medicare primary,
  #and merge them into spells

  usrds_ids <- unique(df$USRDS_ID)
  use_cache <- cache && is.null(medicare_coverage_df)

  if (prepared) {
    medicare_history <- medicare_coverage_df
  } else if (use_cache && .medicare_cache_covers(usrds_ids, payers)) {
    medicare_history <- .usrds_env$medicare_history$data
  } else {
    if (is.null(medicare_coverage_df)) {
      medicare_coverage_df <- load_usrds_file("payhist", usrds_ids = usrds_ids)

      missing_ids <- setdiff(usrds_ids, medicare_coverage_df$USRDS_ID)
      if (length(missing_ids) > 0) {
        rlang::warn(paste0(
          length(missing_ids),
          " USRDS_ID(s) in `df` are not present in `payhist`; ",
          "these patients will be classified as FALSE."
        ))
      }
    }

    medicare_history <- .build_medicare_spells(medicare_coverage_df, payers)

    if (use_cache) {
      .usrds_env$medicare_history <- list(
        data = medicare_history,
        usrds_ids = usrds_ids,
        usrds_wd = Sys.getenv("USRDS_WD"),
        payers = payers
      )
      cli::cli_inform(
        "Medicare coverage cached for {length(usrds_ids)} patient{?s}."
      )
    }
  }

  medicare_history <- dplyr::tibble(
    USRDS_ID = medicare_history$USRDS_ID,
    usrds_package_medicare_begdate = medicare_history$BEGDATE,
    usrds_package_medicare_enddate = medicare_history$ENDDATE
  )

  #Join patient cohort to medicare history data
  patients_clean <- dplyr::left_join(
    df,
    medicare_history,
    dplyr::join_by(
      "USRDS_ID",
      dplyr::between(
        ".index_date",
        "usrds_package_medicare_begdate",
        "usrds_package_medicare_enddate"
      )
    )
  )

  #Create variable that marks FFS coverage on day of claim through 365 days prior
  #Logic here depends strongly on nature of between join in dplyr
  patients_clean <- patients_clean |>
    dplyr::mutate(
      medicare_primary_TF = ifelse(
        !is.na(.data$usrds_package_medicare_begdate) &
          .data$.index_date - .data$usrds_package_medicare_begdate >=
            .env$lookback_days,
        TRUE,
        FALSE
      )
    )

  #Copy start and end variables for coverage to user specified variables if not null
  if (!is.null(coverage_start_variable)) {
    patients_clean[[
      coverage_start_variable
    ]] <- patients_clean$usrds_package_medicare_begdate
  }
  if (!is.null(coverage_end_variable)) {
    patients_clean[[
      coverage_end_variable
    ]] <- patients_clean$usrds_package_medicare_enddate
  }

  patients_clean <- patients_clean |>
    dplyr::select(
      -".index_date",
      -"usrds_package_medicare_begdate",
      -"usrds_package_medicare_enddate"
    )

  return(patients_clean)
}

# TRUE when the cached Medicare coverage was built from the current USRDS
# folder, for the same payers, and includes every patient in `usrds_ids`.
.medicare_cache_covers <- function(usrds_ids, payers) {
  cached <- .usrds_env$medicare_history
  is.list(cached) &&
    identical(cached$usrds_wd, Sys.getenv("USRDS_WD")) &&
    setequal(cached$payers, payers) &&
    all(usrds_ids %in% cached$usrds_ids)
}
