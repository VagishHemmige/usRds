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


}

get_IN_ICD<-function(ICDcodelist,yearlist) {

  .File_List_clean%>%
    inner_join(IN_ICD) %>%
    filter(Year %in% yearlist)%>%
    pmap(.load_individual_file_IN_ICD,ICDcodelist)%>%
    bind_rows()%>%
    return()

}
