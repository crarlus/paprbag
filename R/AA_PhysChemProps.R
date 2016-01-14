#' @title Obtain the physico-chemical properties from a peptide sequence
#' @description Computes different properties for a peptide sequence from the amino acid properties and the amino acid frequency of the sequence.
#' @param AAfreq The relative frequency of amino acids in a peptide sequence
#' @return A data.frame object containing the properties of the amino acid sequence (columns) for the sequences submitted (rows)
#' @seealso \code{\link[seqinr]{AAstat}}
#' @references Adapted from package 'seqinr'.
#' @author Carlus Deneke
#' @import
AA_PhysChemProps <- function(AAfreq){

  #require(seqinr)
  #data(SEQINR.UTIL, package = "seqinr")
  # SEQINR.UTIL$AA.PROPERTY
  data(AAproperty)

  AA_Props <- sapply(AAproperty, function(Property) apply(AAfreq,1,function(Read) sum(Read[paste("MonoPep",Property,sep="_")]) ) )
  colnames(AA_Props) <- paste("AAprops",colnames(AA_Props),sep="_")

  return(AA_Props)
}
