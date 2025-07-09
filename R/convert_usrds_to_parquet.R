#' @keywords internal
.parquetize_usrds_file <- function(input_path, output_path, overwrite = FALSE) {
  if (!file.exists(input_path)) stop(paste("❌ Input file does not exist:", input_path))

  if (file.exists(output_path) && !overwrite) {
    message(paste("✅ Output already exists:", output_path))
    return(invisible(output_path))
  }

  fs::dir_create(dirname(output_path))
  file_ext <- tolower(tools::file_ext(input_path))

  if (file_ext == "sas7bdat") {
    temp_dir <- paste0(output_path, "_chunks")

    # 🔥 Cleanup stale chunk folder if it exists
    if (dir.exists(temp_dir)) {
      message("⚠️  Stale chunk folder found. Cleaning up:", temp_dir)
      fs::dir_delete(temp_dir)
    }

    parquetize::table_to_parquet(
      path_to_file = input_path,
      path_to_parquet = temp_dir,
      max_memory = 1000
    )
    ds <- arrow::open_dataset(temp_dir)
    arrow::write_parquet(ds, output_path)
    fs::dir_delete(temp_dir)
    message(paste("✅ Converted SAS to flat Parquet:", basename(input_path)))
    return(invisible(output_path))
  }

  if (file_ext == "csv") {
    df <- tryCatch({
      arrow::read_csv_arrow(input_path) %>% dplyr::rename_with(toupper)
    }, error = function(e) {
      message(paste("⚠️  Arrow failed. Falling back to readr::read_csv for:", basename(input_path)))
      tryCatch({
        readr::read_csv(input_path, show_col_types = FALSE) %>% dplyr::rename_with(toupper)
      }, error = function(e2) {
        message(paste("❌ Fallback also failed:", basename(input_path), "Error:", e2$message))
        return(NULL)
      })
    })

    if (is.null(df)) return(invisible(NULL))

    known_date_fields <- c("CLM_FROM", "CLM_THRU", "REV_DT", "SRVC_DT")
    date_cols <- intersect(names(df), known_date_fields)
    if (length(date_cols) > 0) {
      message(paste("📆 Parsing dates:", paste(date_cols, collapse = ", ")))
      df <- dplyr::mutate(df, dplyr::across(
        dplyr::all_of(date_cols),
        ~ lubridate::parse_date_time(., orders = c("d%b%y", "d%b%Y"))
      ))
    }

    arrow::write_parquet(df, output_path)
    message(paste("✅ Converted CSV using Arrow:", basename(input_path)))
    return(invisible(output_path))
  }

  stop(paste("❌ Unsupported file extension:", file_ext))
}

#' Convert all USRDS raw files in a directory to Parquet
#'
#' Converts all `.csv` and `.sas7bdat` files under a source directory into `.parquet`
#' files, preserving relative folder structure. Uses Arrow to read and convert data.
#'
#' @param source_dir Root directory of raw USRDS files.
#' @param target_dir Root directory for `.parquet` output.
#' @param overwrite Logical. Overwrite existing output files?
#'
#' @return Invisibly returns a tibble with source and target file paths.
#' @export
convert_usrds_to_parquet <- function(source_dir, target_dir, overwrite = FALSE) {
  if (!dir.exists(source_dir)) {
    stop(paste("Source directory does not exist:", source_dir))
  }

  file_list <- list.files(source_dir, recursive = TRUE, full.names = TRUE)
  file_df <- tibble::tibble(
    input_path = file_list,
    ext = tolower(tools::file_ext(file_list))
  ) %>%
    dplyr::filter(ext %in% c("csv", "sas7bdat")) %>%
    dplyr::mutate(
      relative_path = fs::path_rel(input_path, start = source_dir),
      output_path = fs::path(target_dir, fs::path_ext_set(relative_path, "parquet"))
    )

  purrr::walk2(
    file_df$input_path, file_df$output_path,
    ~.parquetize_usrds_file(.x, .y, overwrite = overwrite)
  )

  invisible(file_df)
}
