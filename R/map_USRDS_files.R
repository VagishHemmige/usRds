#' Map USRDS data files in the working directory
#'
#' Scans the directory set with `set_USRDS_wd()` and identifies all relevant CSV and SAS files
#' in standard USRDS subdirectories. The resulting file list is parsed into a structured tibble
#' with file paths, inferred data types, and years.
#'
#' This function populates a global variable `.File_List_clean` for downstream use
#' in data extraction functions.
#'
#' @return A tibble with columns: `file_path`, `file_root`, `file_suffix`, `Year`, `file_directory`
#' @export
#'
#' @import dplyr
#'
#' @examples
#' \dontrun{
#' set_USRDS_wd("C:/path/to/usrds")
#' file_map <- map_USRDS_files()
#' head(file_map)
#' }

map_USRDS_files<-function() {


  #Define list of working directories
  .USRDS_directories<-c("ESRD core",
                       "ESRD transplant",
                       "ESRD hospital",
                       "ESRD PartD",
                       "ESRD Institution",
                       "Physician supplier")

  #Creates raw list of all CSVs stored in USRDS WD
  .File_List_csv_raw<<-list.files(path=.USRDS_wd, pattern="csv", recursive = TRUE)

  #Creates a clean data frame with file_name and file_path variables of CSVs
  .File_List_csv_clean<<-tibble(file_path=.File_List_csv_raw)%>%
    filter(str_detect(.File_List_csv_raw,paste(.USRDS_directories, collapse = "|")))%>%
    mutate(file_name=fs::path_file(file_path))%>%
    mutate(file_path=paste0(.USRDS_wd,"/",file_path))

  #Creates raw list of all SAS files stored in USRDS WD
  .File_List_sas_raw<<-list.files(path=.USRDS_wd, pattern="sas7bdat", recursive = TRUE)

  #Creates a clean data frame with file_name and file_path variables of SAS files
  .File_List_sas_clean<<-tibble(file_path=.File_List_sas_raw)%>%
    filter(str_detect(.File_List_sas_raw,paste(.USRDS_directories, collapse = "|")))%>%
    mutate(file_name=fs::path_file(file_path))%>%
    mutate(file_path=paste0(.USRDS_wd,"/",file_path))

  #Creates raw list of all parquet files stored in USRDS WD
  .File_List_parquet_raw<<-list.files(path=.USRDS_wd, pattern="parquet", recursive = TRUE)

  #Creates a clean data frame with file_name and file_path variables of Parquet files
  .File_List_parquet_clean<<-tibble(file_path=.File_List_parquet_raw)%>%
    filter(str_detect(.File_List_parquet_raw,paste(.USRDS_directories, collapse = "|")))%>%
    mutate(file_name=fs::path_file(file_path))%>%
    mutate(file_path=paste0(.USRDS_wd,"/",file_path))

  #Merge files, separate the root and suffix, create a label for year
  .File_List_clean<<-bind_rows(.File_List_csv_clean,.File_List_sas_clean, .File_List_parquet_clean )%>%
    separate(file_name, c("file_root","file_suffix"), sep="\\.")%>%
    mutate(Year=str_extract(file_root, "20[0-9][0-9]"))%>%
    mutate(Year=as.numeric(Year))%>%
    mutate(file_directory=case_when(
      str_detect(file_path,"ESRD core")~"Core",
      str_detect(file_path,"ESRD transplant")~"Transplant",
      str_detect(file_path,"ESRD hospital")~"Hospital",
      str_detect(file_path,"ESRD PartD")~"Part D",
      str_detect(file_path,"ESRD Institution")~"Institution",
      str_detect(file_path,"Physician supplier")~"PS"
    ))
}
