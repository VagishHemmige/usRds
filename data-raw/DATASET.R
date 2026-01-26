## code to prepare internal file datasets goes here

#This code creates the files needed to extract ICD codes and HCPCS codes
IN_HCPCS <- readxl::read_excel("data-raw/File lists for functions/IN_HCPCS.xlsx")
IN_ICD<- readxl::read_excel("data-raw/File lists for functions/IN_ICD.xlsx")
IN_CLM_COSTS <- readxl::read_excel("data-raw/File lists for functions/IN_CLM_COSTS.xlsx")
IN_REV_COSTS<- readxl::read_excel("data-raw/File lists for functions/IN_REV_COSTS.xlsx")
PS_HCPCS <- readxl::read_excel("data-raw/File lists for functions/PS_HCPCS.xlsx")
PS_ICD<- readxl::read_excel("data-raw/File lists for functions/PS_ICD.xlsx")
PS_REV_COSTS <- readxl::read_excel("data-raw/File lists for functions/PS_REV_COSTS.xlsx")
PS_CLM_COSTS <- readxl::read_excel("data-raw/File lists for functions/PS_CLM_COSTS.xlsx")
PDE <- readxl::read_excel("data-raw/File lists for functions/PDE.xlsx")

#This code creates the code necessary in order for the labelling functions to work
source("data-raw/sysdata-metadata_helpers.R")
metadata_b <- .load_usrds_metadata_b("data-raw/USRDS_Res_Guide_Appendix_B_2024.xlsx")
metadata_c <- .load_usrds_metadata_c("data-raw/USRDS_Res_Guide_Appendix_C_2024.xlsx")

#This code creates the code necessary in order for the get_*_ICD functions to be able to use wildcards
source(("data-raw/parse_icd_reference.R"))
icd_reference <- .parse_icd_reference(
  "data-raw/ICD9/Diagnosis codes/CMS32_DESC_LONG_DX.txt",
  "data-raw/ICD10/Diagnosis codes/icd10cm-codes-2026.txt"
)

#Extract HCPCS reference
#hcpcs_reference <- readxl::read_excel("data-raw/hcpc2025_jul_anweb_v3/HCPC2025_JUL_ANWEB_v3.xlsx")

#Extract medical inflation data from

medical_cpi <- bind_rows(blscrapeR::bls_api("CUUR0000SAM", startyear = 2006, endyear = 2015),
                         blscrapeR::bls_api("CUUR0000SAM", startyear = 2016, endyear = 2025))

usethis::use_data(IN_HCPCS,
                  IN_ICD,
                  PS_HCPCS,
                  PS_ICD,
                  IN_CLM_COSTS,
                  IN_REV_COSTS,
                  PS_CLM_COSTS,
                  PS_REV_COSTS,
                  PDE,
                  metadata_b,
                  metadata_c,
                  icd_reference,
                  medical_cpi,
             #    hcpcs_reference,
                  overwrite = TRUE, internal=TRUE)
