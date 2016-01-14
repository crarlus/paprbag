#' @title Get the Frequency of each amino acid
#' @description Get the Frequency of each amino acid
#' @param Seq An AAStringSet object
#' @param prob Should relative frequncies be returned
#' @return A data.frame object containing the frequencies (columns) for the submitted sequences (rows)
#' @author Carlus Deneke
GetMonoPeptideFrequency <- function(Seq,prob=F){

  #require(Biostrings)
  AAfreq <- Biostrings::alphabetFrequency(Seq,as.prob=prob)[,1:27]
  colnames(AAfreq) <- paste("MonoPep",colnames(AAfreq),sep="_")
  colnames(AAfreq)[27] <- paste("MonoPep","terminal",sep="_")
  rownames(AAfreq) <- names(Seq)
  return(AAfreq)
}
