library(tidyverse)
library(readr)
library(stringr)
library(lubridate)
library(dplyr)
library(purrr)

# Set base directory
base_dir <- "data-raw/Dialysis center file list"

message("📂 Scanning for CSV files...")
File_List_csv_clean <- tibble(FileName = list.files(
  path = base_dir, pattern = "csv", recursive = TRUE, full.names = TRUE)) %>%
  filter(!str_detect(FileName, "ICH")) %>%
  filter(str_detect(FileName, "FAC"))

message("📂 Scanning for TXT files...")
File_List_txt_clean <- tibble(FileName = list.files(
  path = base_dir, pattern = "txt", recursive = TRUE, full.names = TRUE)) %>%
  filter(!str_detect(FileName, "readme"))

# Define CSV reader
dialysis_read_csv <- function(x) {
  message("📄 Reading CSV: ", x)
  read_csv(x, col_types = cols(Zip = col_character()),
           locale = locale(encoding = "latin1")) %>%
    rename_with(toupper) %>%
    rename(TOTSTAS = '# OF DIALYSIS STATIONS') %>%
    rename_with(~case_when(
      . == "PROFIT OR NON-PROFIT" ~ "PROFIT_STATUS",
      . == "PROFIT OR NON-PROFIT?" ~ "PROFIT_STATUS",
      TRUE ~ .
    ))
}

# Define TXT reader
dialysis_read_txt <- function(x) {
  message("📄 Reading TXT: ", x)
  read_delim(x, "\t", escape_double = FALSE,
             col_types = cols(phyzip = col_character()),
             trim_ws = TRUE) %>%
    rename_with(toupper) %>%
    rename(ZIP = PHYZIP) %>%
    rename(PROFIT_STATUS = OWNTYPE)
}

# Read CSVs
message("📥 Reading all CSV files...")
data_csv_clean <- File_List_csv_clean %>%
  mutate(file_contents = map(FileName, dialysis_read_csv))

# Read TXTs
message("📥 Reading all TXT files...")
data_txt_clean <- File_List_txt_clean %>%
  mutate(file_contents = map(FileName, dialysis_read_txt))







# Combine both
data_combined_clean <- bind_rows(data_csv_clean, data_txt_clean)







# ✅ Simplified and reliable date extractor

extract_date_from_filename <- function(filename) {
  library(stringr)
  library(lubridate)
  library(dplyr)

  if (is.na(filename) || filename == "") return(as.Date(NA))

  # Pattern 1: YYYYMMDD
  ymd_match <- str_extract(filename, "20[0-9]{6}")

  # Pattern 2: Month_YYYY or Month-YYYY
  month_year_match <- str_match(
    filename,
    "(?i)(January|February|March|April|May|June|July|August|September|October|November|December)[_-]?(20[0-9]{2})"
  )

  # Pattern 3: MM_YYYY or MM-YYYY
  mmyyyy_match <- str_match(filename, "(\\d{2})[\\-_](20\\d{2})")

  # Parse month name pattern
  date_month_year <- if (!is.na(month_year_match[1, 1])) {
    month_str <- month_year_match[1, 2]
    year_str <- month_year_match[1, 3]
    month_num <- match(tolower(month_str), tolower(month.name))
    ymd(sprintf("%s-%02d-01", year_str, month_num))
  } else {
    NA
  }

  # Parse numeric month-year pattern
  date_mmyyyy <- if (!is.na(mmyyyy_match[1, 1])) {
    month <- mmyyyy_match[1, 2]
    year <- mmyyyy_match[1, 3]
    ymd(sprintf("%s-%s-01", year, month))
  } else {
    NA
  }

  case_when(
    !is.na(ymd_match) ~ ymd(ymd_match),
    !is.na(date_month_year) ~ date_month_year,
    !is.na(date_mmyyyy) ~ date_mmyyyy,
    TRUE ~ as.Date(NA)
  )
}

data_combined_final <- data_combined_clean %>%
  mutate(DateStart = map_vec(FileName, extract_date_from_filename))%>%
  arrange(DateStart) %>%
  mutate(DateEnd = lead(DateStart) - days(1))

data_combined_final <- data_combined_final %>%
  mutate(file_contents = map(file_contents, ~ {
    if (!is.null(.)) {
      mutate(., across(everything(), as.character))
    } else {
      .
    }
  }))

data_combined_final_unnested<-data_combined_final%>%unnest(file_contents)

message("✅ Finished processing ", nrow(data_combined_clean), " files.")
