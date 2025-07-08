#' Load and filter a single IN ICD file
#'
#' Internal helper function to load and filter a single file by ICD codes.
#'
#' @noRd

.load_individual_file_IN_ICD<-function(file_path,file_root,file_suffix,Year,file_directory,ICDcodelist)
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
      filter(CODE %in% ICDcodelist)%>%
      select(USRDS_ID, CODE, CLM_FROM)%>%
      mutate(CLM_FROM=dmy(CLM_FROM))
    return(temp)
  }

  if( file_suffix=="sas7bdat")
  {
    temp<-haven::read_sas(file_path, col_select=c("USRDS_ID","CLM_FROM","CODE"))%>%
      rename_with(toupper)%>%
      filter(CODE %in% ICDcodelist)%>%
      return(temp)
  }

  if( file_suffix=="parquet")
  {
    temp<-arrow::read_parquet(file_path)%>%
      rename_with(toupper)%>%
      select(USRDS_ID,CLM_FROM,CODE)%>%
      filter(CODE %in% ICDcodelist)%>%
      mutate(CLM_FROM=as_date(CLM_FROM))%>%
      collect()
    return(temp)
  }


}

#' Searches Institutional files for ICD codes in specific years
#'
#' This function searches all Institutional files from the appropriate year
#'
#' @param ICDcodelist ICD codes to identify
#' @param yearlist Years to search
#'
#' @return Data frame
#' @export
#' @importFrom dplyr inner_join

#' @examples
get_IN_ICD<-function(ICDcodelist,yearlist) {

  .usrds_env$file_list%>%
    inner_join(IN_ICD) %>%
    filter(Year %in% yearlist)%>%
    select(-file_name)%>%
    pmap(.load_individual_file_IN_ICD,ICDcodelist)%>%
    bind_rows()%>%
    return()

}
