#' Load and filter a single PS HCPCS file
#'
#' Internal helper function to load and filter a single file by HCPCS codes.
#'
#' @noRd

.load_individual_file_PS_HCPCS<-function(file_path,file_root,file_suffix,Year,file_directory,HCPCScodelist,
                                        variablelist)
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
      select(all_of(variablelist))%>%
      mutate(CLM_FROM=dmy(CLM_FROM))
    return(temp)
  }

  if( file_suffix=="sas7bdat")
  {
    temp<-haven::read_sas(file_path, col_select=variablelist)%>%
      rename_with(toupper)%>%
      filter(HCPCS %in% HCPCScodelist)%>%
      return(temp)
  }


  if( file_suffix=="parquet")
  {
    temp<-arrow::read_parquet(file_path)%>%
      rename_with(toupper)%>%
      select(all_of(variablelist))%>%
      filter(HCPCS %in% HCPCScodelist)%>%
      mutate(CLM_FROM=as_date(CLM_FROM))%>%
      collect()
    return(temp)
  }


}


#' Searches Physician Supplier files for HCPCS codes in specific years
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
get_PS_HCPCS<-function(HCPCScodelist,yearlist) {

  .variablelist<-c("USRDS_ID","CLM_FROM","HCPCS")
  .File_List_clean%>%
    inner_join(PS_HCPCS) %>%
    filter(Year %in% yearlist)%>%
    pmap(.load_individual_file_PS_HCPCS,HCPCScodelist, .variablelist)%>%
    bind_rows()%>%
    return()
}
