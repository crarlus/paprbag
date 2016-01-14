#' @title Get the ologonuleotide frequency
#' @description Obtain the frequency of oligonucleotides in a DNA sequence for different k-mer sizes
#' @param Seq A DNAStringSet object, i.e. a set of DNA sequences
#' @param k The k-mer size
#' @param prob Return the relative frequency
#' @param symmetric Do you want to reduce number of kmers by combining forard kmers and their reverse-complements? (Default: FALSE)
#' @return The ologonuleotide frequency for each sequence submitted for the choice of k
GetOligonucleotideFrequency <- function(Seq,k=1,prob=F,symmetric = F){

  require(Biostrings)

  if(k == 1) Prefix = "Mono" else if (k == 2)  Prefix = "Di"  else if (k == 3)  Prefix = "Tri"  else if (k == 4)  Prefix = "Tetra" else if (k == 5)  Prefix = "Penta" else  Prefix = "Poly"

  #   if(symmetric == T){
  #     freq <- Combine.SymmetricOligomers (Seq, width = k, prob=prob)
  #   } else {
  #     freq <- oligonucleotideFrequency(Seq, width=k, as.prob=prob)
  #     if(k == 1) {GC <- apply(freq[,2:3],1,sum); freq <- cbind(freq,GC=GC)}
  #   }
  freq <- oligonucleotideFrequency(Seq, width=k, as.prob=prob)

  if(symmetric == T){
    freq <- Make.Symmetric(freq)
  } else {
    if(k == 1) {GC <- apply(freq[,2:3],1,sum); freq <- cbind(freq,GC=GC)}
  }


  colnames(freq) <- paste(Prefix,colnames(freq),sep="_")
  rownames(freq) <- names(Seq)
  return(freq)

}
