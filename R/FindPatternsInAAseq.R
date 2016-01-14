# #' @title Find patterns of amino acids
# #' @description For a list of sequences, search the occurences of specified patterns
# #' @param Seq AAStringSet object
# #' @param Patterns Vector of patterns
# #' @param Prefix How should the columns of pattern matches be called
# #' @param aggregate Should the individual pattern matches be aggregated into a single column?
# #' @return A data.frame containing the matched patterns (columns)
#' @author Carlus Deneke
FindPatternsInAAseq <- function(Seq, Patterns, aggregate = F, Prefix = "AAPattern"){

  # Preparation
  BestTranslation_string <- base::strsplit(toString(Seq),split=", ",fixed=T)[[1]]
  BestTranslation_string <- gsub("*","u",BestTranslation_string,fixed=T) # # stringr cannot handle "**", therefore replace all "*" by "u"

  MatchTable <- t(do.call(rbind, lapply(Patterns, function(pattern) stringr::str_detect(BestTranslation_string,pattern) ) ))

  if(aggregate == T){
    Aggregated <- data.frame(rowSums(MatchTable) )
    colnames(Aggregated) <- paste(Prefix,"aggregated",sep="_")
  }

  colnames(MatchTable) <- paste(Prefix,1:length(Patterns),sep="_")
  rownames(MatchTable) <- names(Seq)

  return(MatchTable)

}
