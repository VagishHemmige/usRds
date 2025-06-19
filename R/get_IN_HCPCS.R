#' Load and filter a single IN HCPCS file
#'
#' Internal helper function to load and filter a single file by HCPCS codes.
#'
#' @noRd
.load_individual_file_IN_HCPCS<-function(file_path,file_root,file_suffix,Year,file_directory,HCPCScodelist)
{
  print(file_path)
  print(file_root)
  print(file_suffix)
  print(Year)
  print(file_directory)
  print(HCPCScodelist)
  if( file_suffix=="csv")
  {
    temp<-read_csv(file_path)%>%
      rename_with(toupper)%>%
      filter(HCPCS %in% HCPCScodelist)%>%
      mutate(CLM_FROM=dmy(CLM_FROM))
    return(temp)
  }

  if( file_suffix=="sas7bdat")
  {
    temp<-haven::read_sas(file_path, col_select=c("USRDS_ID","CLM_FROM","HCPCS", "REV_CH"))%>%
      rename_with(toupper)%>%
      filter(HCPCS %in% HCPCScodelist)
    return(temp)
  }


}

#' Searches Institutional files for HCPCS codes in specific years
#'
#' This function searches all physician supplier files from the appropriate year
#'
#' @param HCPCScodelist ICD codes to identify
#' @param yearlist Years to search
#'
#' @return Data frame
#' @export
#'
#' @examples
get_IN_HCPCS<-function(HCPCScodelist,yearlist) {

  .File_List_clean%>%
    inner_join(IN_HCPCS) %>%
    filter(Year %in% yearlist)%>%
    pmap(.load_individual_file_IN_HCPCS,HCPCScodelist)%>%
    bind_rows()%>%
    return()

}
