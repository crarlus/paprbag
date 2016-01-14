#' Extract the Organism ID (PRJNA accession)
GetOSid <- function(x) {
  require(stringr)
  str_extract(x, 'PRJ[A-Z]{2}[0-9]+')
}
