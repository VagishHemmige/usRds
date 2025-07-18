## code to prepare internal file datasets goes here

#This code creates the files needed to extract ICD codes and HCPCS codes
IN_HCPCS <- readxl::read_excel("data-raw/File lists for functions/IN_HCPCS.xlsx")
IN_ICD<- readxl::read_excel("data-raw/File lists for functions/IN_ICD.xlsx")
PS_HCPCS <- readxl::read_excel("data-raw/File lists for functions/PS_HCPCS.xlsx")
PS_ICD<- readxl::read_excel("data-raw/File lists for functions/PS_ICD.xlsx")

#This code creates the code necessary in order for the labelling functions to work
source("data-raw/sysdata-metadata_helpers.R")
metadata_b <- .load_usrds_metadata_b("data-raw/USRDS_Res_Guide_Appendix_B_2024.xlsx")
metadata_c <- .load_usrds_metadata_c("data-raw/USRDS_Res_Guide_Appendix_C_2024.xlsx")

#This code creates the code necessary in order for the get_*_ICD functions to be able to use wildcards
source(("data-raw/parse_icd_reference.R"))
icd_reference <- .parse_icd_reference(
  "data-raw/ICD-9-CM-v32-master-descriptions/CMS32_DESC_LONG_DX.txt",
  "data-raw/ICD10/icd10cm-codes-2026.txt"
)

#Extract HCPCS reference
hcpcs_reference <- readxl::read_excel("data-raw/hcpc2025_jul_anweb_v3/HCPC2025_JUL_ANWEB_v3.xlsx")


usethis::use_data(IN_HCPCS, IN_ICD, PS_HCPCS, PS_ICD, metadata_b, metadata_c,icd_reference, hcpcs_reference,
                  overwrite = TRUE, internal=TRUE)
