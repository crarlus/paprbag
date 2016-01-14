#' Match a DNA sequence and its reverse complement
#' @description  Convert vector of sequences to its reverse complement and match symmetric partners
#' @param seq A list of strings containing DNA sequences
#' @return A vector of matching indices
#' @author Carlus Deneke
Match.SymmetricPartners <- function(seq){
  # require(seqinr, quietly = T)
  match(sapply(seq, function(x) seqinr::c2s(base::rev(seqinr::comp(seqinr::s2c(x)))) ),base::tolower(seq) )
}
