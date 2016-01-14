#' @title Get the AAindex property of a peptide sequence
#' @description For a peptide sequence, obtain properties associated to its amino acid content
#' @param AAfreq The relative frequency of amino acids in the peptide sequence obtained from function \code{\link{GetMonoPeptideFrequency}}
#' @param Vector of accession numbers to select a subset of the 544 amino acid indices
#' @return A data.frame containing the desired amino acid index stats (columns) for each sequence submitted (rows)
#' @references Adapted from aaindex in seqinr
#' @references Please cite the following references when making use of the database:
#' @references Kawashima, S. and Kanehisa, M. (2000) AAindex: amino acid index database. Nucleic Acids Res., 28:374.
GetAAindexStats <- function(AAfreq,AAindex_Selection){

  data(AAindexData)

  # Default selection of indices
  if(is.null(AAindex_Selection)) {AAindex_Selection <- c("BROC820101", "BUNA790103", "CHOP780207", "FAUJ880105", "FINA910103", "GEIM800103", "GEIM800105", "ISOY800107", "KHAG800101", "LEWP710101","MAXF760103",                                                         "OOBM850104", "PALJ810111", "PRAM820103", "QIAN880102", "QIAN880114", "QIAN880123", "QIAN880137", "RACS770103", "RACS820103", "RICJ880101", "RICJ880117",                                                         "ROBB760107", "TANS770106", "TANS770108", "VASM830101", "WERD780104", "AURR980102", "AURR980116", "AURR980118", "FUKS010109", "SUYM030101"); warning("No Amino acid inidices selected. Use default indices") }

  AAindex_rows <- match(AAindex_Selection,AAindexData$AccNo)
  if(any(is.na(AAindex_rows)) ) {
    warning(paste("The following AAindex names were not recognized:",paste(AAindex_Selection[is.na(AAindex_rows)],collapse = ",")))
    AAindex_rows <- AAindex_rows[!is.na(AAindex_rows)]
  }

  aaprop_List <- lapply(AAindex_rows, function(j) sapply(AAindexData[j,7:26],as.numeric))
  AAindexValue <- do.call(cbind,lapply(aaprop_List, function(aaprops) apply(AAfreq[,1:20], 1, function(aafreqs) aafreqs %*% aaprops) ) )

  colnames(AAindexValue) <- paste("AAindex",AAindex_Selection,sep="_")
  rownames(AAindexValue) <- rownames(AAfreq)

  return(AAindexValue)
} # end function
