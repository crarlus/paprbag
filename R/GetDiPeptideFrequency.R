#' Get the frequency of di-peptides
#' @param Seq An AAStringSet object
#' @param prob Should relative frequncies be returned
#' @return A data.frame object containing the frequencies (columns) for the submitted sequences (rows)

GetDiPeptideFrequency <- function(Seq,prob=F){

  require(Biostrings)

  AAalphabet <- alphabet(AAString("AA"))[1:20]
  paste2 <- function(x,y) paste(x,y,sep="")
  DiPeptideAlphabet <- c(outer(AAalphabet,AAalphabet,"paste2"))
  myAADict <- AAStringSet(DiPeptideAlphabet)

  DiPepFreq <- t(vcountPDict(myAADict,Seq, fixed=TRUE) )

  # relative frequenies
  if(prob==T) DiPepFreq <- DiPepFreq/width(Seq)

  colnames(DiPepFreq) <- paste("DiPep",DiPeptideAlphabet,sep="_")
  rownames(DiPepFreq) <- names(Seq)

  return(DiPepFreq)

}
