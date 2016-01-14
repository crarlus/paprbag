#' Convert vector of sequences to its reverse complement and match symmetric partners
Match.SymmetricPartners <- function(seq){
  require(seqinr, quietly = T)
  match(sapply(seq, function(x) c2s(rev(comp(s2c(x)))) ),tolower(seq) )
}
