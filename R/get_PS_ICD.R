#' Load and filter a single PS ICD file
#'
#' Internal helper function to load and filter a single file by ICD codes.
#'
#' @noRd

.load_individual_file_PS_ICD<-function(file_path,file_root,file_suffix,Year,file_directory,ICDcodelist)
{
  print(file_path)
  print(file_root)
  print(file_suffix)
  print(Year)
  print(file_directory)
  print(ICDcodelist)
  if( file_suffix=="csv")
  {
    temp<-read_csv(file_path)%>%
      rename_with(toupper)%>%
      filter(DIAG %in% ICDcodelist)%>%
      select(USRDS_ID, DIAG, CLM_FROM, CLM_THRU)%>%
      mutate(CLM_FROM=dmy(CLM_FROM))%>%
      mutate(CLM_THRU=dmy(CLM_THRU))
    return(temp)
  }

  if( file_suffix=="sas7bdat")
  {
    temp<-haven::read_sas(file_path, col_select=c("USRDS_ID","CLM_FROM","DIAG", "CLM_THRU"))%>%
      rename_with(toupper)%>%
      filter(DIAG %in% ICDcodelist)%>%
      return(temp)
  }

  if( file_suffix=="parquet")
  {
    temp<-arrow::read_parquet(file_path)%>%
      rename_with(toupper)%>%
      select(USRDS_ID,CLM_FROM,DIAG, CLM_THRU)%>%
      filter(DIAG %in% ICDcodelist)%>%
      mutate(CLM_FROM=as_date(CLM_FROM))%>%
      mutate(CLM_THRU=as_date(CLM_THRU))%>%
      collect()
    return(temp)
  }


}


#' Searches Physician Supplier files for ICD codes in specific years
#'
#' This function searches all physician supplier files from the appropriate year
#'
#' @param ICDcodelist ICD codes to identify
#' @param yearlist Years to search
#'
#' @return Data frame
#' @export
#'
#' @examples
get_PS_ICD<-function(ICDcodelist,yearlist) {

  .usrds_env$file_list%>%
    inner_join(PS_ICD) %>%
    filter(Year %in% yearlist)%>%
    pmap(.load_individual_file_PS_ICD,ICDcodelist)%>%
    bind_rows()%>%
    return()

}
