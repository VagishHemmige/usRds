

#' Set USRDS working directory
#'
#' This function sets the working directory where the USRDS files are stored
#'
#' @param x The path to the directory where the USRDS files are stored
#'
#' @return Invisibly returns the path as a character string.
#' @export
#'
#' @examples
set_USRDS_wd<-function(x) {


    .USRDS_wd<<-x
}


