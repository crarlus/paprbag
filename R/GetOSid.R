#' Extract the Organism ID (PRJNA accession)
#' @param A string containing an NCBI project accession (e.g. xxxPRJNA1752xxx)
#' @return Returns a string with the extracted NCBI project accession
#' @author Carlus Deneke
GetOSid <- function(x) {
  #require(stringr)
  stringr::str_extract(x, 'PRJ[A-Z]{2}[0-9]+')
}
