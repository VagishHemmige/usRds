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


}

get_PS_ICD<-function(ICDcodelist,yearlist) {

  .File_List_clean%>%
    inner_join(PS_ICD) %>%
    filter(Year %in% yearlist)%>%
    pmap(.load_individual_file_PS_ICD,ICDcodelist)%>%
    bind_rows()%>%
    return()

}
