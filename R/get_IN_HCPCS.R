
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

get_IN_HCPCS<-function(HCPCScodelist,yearlist) {

  .File_List_clean%>%
    inner_join(IN_HCPCS) %>%
    filter(Year %in% yearlist)%>%
    pmap(.load_individual_file_IN_HCPCS,HCPCScodelist)%>%
    bind_rows()%>%
    return()

}
