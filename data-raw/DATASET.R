## code to prepare internal file datasets goes here

IN_HCPCS <- readxl::read_excel("data-raw/File lists for functions/IN_HCPCS.xlsx")
IN_ICD<- readxl::read_excel("data-raw/File lists for functions/IN_ICD.xlsx")
PS_HCPCS <- readxl::read_excel("data-raw/File lists for functions/PS_HCPCS.xlsx")
PS_ICD<- readxl::read_excel("data-raw/File lists for functions/PS_ICD.xlsx")

source("data-raw/sysdata-metadata_helpers.R")

metadata_b <- .load_usrds_metadata_b("data-raw/USRDS_Res_Guide_Appendix_B_2024.xlsx")
metadata_c <- .load_usrds_metadata_c("data-raw/USRDS_Res_Guide_Appendix_C_2024.xlsx")



usethis::use_data(IN_HCPCS, IN_ICD, PS_HCPCS, PS_ICD, metadata_b, metadata_c, overwrite = TRUE, internal=TRUE)
