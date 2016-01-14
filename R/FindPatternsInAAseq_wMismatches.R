#' @title Find patterns of amino acids
#' @description For a list of sequences, search the occurences of specified patterns
#' @param Seq AAStringSet object
#' @param Patterns Vector of patterns
#' @param Prefix How should the columns of pattern matches be called
#' @param aggregate Should the individual pattern matches be aggregated into a single column?
#' @return A data.frame containing the matched patterns (columns)
FindPatternsInAAseq_wMismatches <- function(Seqs,Patterns, AllowedMismatches = 0, aggregate = F, Prefix = "AAPattern"){

  MatchTable <- do.call(cbind,lapply(Patterns,function(pattern) vcountPattern(pattern = pattern,subject = Seqs, fixed = T, max.mismatch=AllowedMismatches) ) )

  if(aggregate == T){
    Aggregated <- data.frame(rowSums(MatchTable) )
    colnames(Aggregated) <- paste(Prefix,"aggregated",sep="_")
  }

  colnames(MatchTable) <- paste(Prefix,1:length(Patterns),sep="_")
  rownames(MatchTable) <- names(Seqs)

  return(MatchTable)
}
