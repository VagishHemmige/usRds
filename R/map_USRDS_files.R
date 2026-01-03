#' Internal: Map USRDS data files in the working directory
#'
#' Scans the directory set by the USRDS_WD environment variable and stores
#' a cleaned file list in the package's internal environment for downstream use.
#'
#' This function is intended for internal use only and is automatically
#' run on package load if USRDS_WD is set.
#'
#' @keywords internal
.map_USRDS_files <- function() {
  USRDS_wd <- Sys.getenv("USRDS_WD")
  if (USRDS_wd == "") {
    warning("USRDS_WD is not set. Use `set_USRDS_wd()` to configure your working directory.")
    return(invisible(NULL))
  }

  USRDS_directories <- c("ESRD Core", "ESRD transplant", "ESRD hospital",
                         "ESRD PartD", "ESRD Institution", "Physician supplier")

  list_and_clean <- function(pattern) {
    raw_files <- list.files(path = USRDS_wd, pattern = pattern, recursive = TRUE)
    tibble::tibble(file_path = raw_files) %>%
      filter(str_detect(file_path, paste(USRDS_directories, collapse = "|"))) %>%
      mutate(
        file_name = fs::path_file(file_path),
        file_path = file.path(USRDS_wd, file_path)
      )
  }

  File_List_clean <- bind_rows(
    list_and_clean("csv$"),
    list_and_clean("sas7bdat$"),
    list_and_clean("parquet$")
  ) %>%
    tidyr::separate(file_name, c("file_root", "file_suffix"), sep = "\\.(?=[^.]+$)", remove = FALSE) %>%
    mutate(
      Year = stringr::str_extract(file_root, "20[0-9]{2}"),
      Year = as.numeric(Year),
      file_directory = case_when(
        str_detect(file_path, "ESRD Core")          ~ "Core",
        str_detect(file_path, "ESRD transplant")    ~ "Transplant",
        str_detect(file_path, "ESRD hospital")      ~ "Hospital",
        str_detect(file_path, "ESRD PartD")         ~ "Part D",
        str_detect(file_path, "ESRD Institution")   ~ "Institution",
        str_detect(file_path, "Physician supplier") ~ "PS",
        TRUE ~ NA_character_
      )
    )

  .usrds_env$file_list <- File_List_clean
  invisible(File_List_clean)
}
