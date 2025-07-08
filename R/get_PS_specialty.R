.load_individual_file_PS_specialty<-function(file_path,file_root,file_suffix,Year,file_directory,specialtycodelist,
                                            variablelist)
{
  print(file_path)
  print(file_root)
  print(file_suffix)
  print(Year)
  print(file_directory)
  print(specialtycodelist)


  if( file_suffix=="csv")
  {
    temp<-read_csv(file_path)%>%
      rename_with(toupper)%>%
      filter(SPCLTY %in% specialtycodelist)%>%
      select(all_of(variablelist))%>%
      mutate(CLM_FROM=dmy(CLM_FROM))
    return(temp)
  }

  if( file_suffix=="sas7bdat")
  {
    temp<-haven::read_sas(file_path, col_select=variablelist)%>%
      rename_with(toupper)%>%
      filter(SPCLTY %in% specialtycodelist)%>%
      return(temp)
  }


  if( file_suffix=="parquet")
  {
    temp<-arrow::read_parquet(file_path)%>%
      rename_with(toupper)%>%
      select(all_of(variablelist))%>%
      filter(SPCLTY %in% specialtycodelist)%>%
      mutate(CLM_FROM=as_date(CLM_FROM))%>%
      arrow::collect()
    return(temp)
  }

}



#' Extract PS specialty claims
#'
#' Returns claims filtered by specialty code from the PS HCPCS dataset.
#'
#' @param specialtycodelist A vector of specialty codes to keep.
#' @param yearlist A vector of years to include.
#' @param DIAG Logical, include DIAG column.
#' @param HCPCS Logical, include HCPCS column.
#' @param PLCSRV Logical, include PLCSRV column.
#'
#' @return A tibble with filtered and selected PS HCPCS data.
#' @export


get_PS_specialty<-function(specialtycodelist,yearlist, DIAG=FALSE, HCPCS=FALSE, PLCSRV=FALSE) {

  variablelist<-c("USRDS_ID","CLM_FROM","SPCLTY")

  if( DIAG==TRUE)
  {
    variablelist<-c(variablelist, "DIAG")
  }

  if( HCPCS==TRUE)
  {
    variablelist<-c(variablelist, "HCPCS")
  }

  if( PLCSRV==TRUE)
  {
    variablelist<-c(variablelist, "PLCSRV")
  }


  .usrds_env$file_list%>%
    inner_join(PS_HCPCS) %>%
    filter(Year %in% yearlist)%>%
    select(-file_name)%>%
    pmap(.load_individual_file_PS_specialty,specialtycodelist, variablelist)%>%
    bind_rows()%>%
    return()
}
