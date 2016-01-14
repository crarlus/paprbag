#' @title Estimate the Codon usage from a sequence
#' @description Obtain the Codon Usage from the estimated Best Frame
#' @param Seq A DNAStringSet object
#' @param Frame Translation frame (0,1,2) of the putative peptide sequence
#' @param Strand Strand ('r' = reverse strand, 'f' =  forward strand)
#' @return Returns a data.frame of the codon usage, i.e. the relative frequency of each codon (columns), for each sequence (rows)
#' @seealso \code{\link{seqinr::uco}}
BestUco <- function(Seq,Frame,Strand){
  # require(seqinr)

  UCO <- lapply(1:length(Seq),function(i) seqinr::uco(if(Strand[i] == "r") rev(seqinr::comp(Seq[[i]])) else Seq[[i]],frame=Frame[i],index="freq") )
  UCO <- do.call(rbind,UCO)
  colnames(UCO) <- paste("Codon",colnames(UCO),sep="_")
  rownames(UCO) <- names(Seq)

  return(UCO)
}
