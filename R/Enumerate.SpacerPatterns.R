#' Enumerate all possible patterns of spacers
#' @param k Length of contingous word
#' @param l Length of spaced word
#' @return Returns a data.frame of all possible patterns, row-by-row
#' @seealso \link{CreateFeaturesFromReads}
#' @family SpacedWordFeatures
#' @author Carlus Deneke
Enumerate.SpacerPatterns <- function(k,l){
  Frees <- l-2
  Ones <- k-2

  if(k > l) stop("Continigient word can't be larger than spaced word")

  if(choose(Frees,Ones) > 100) stop(paste("Number of distinct patterns exceeds 100"))

  all <- expand.grid(rep(list(0:1), Frees),stringsAsFactors = F)
  constrained <- all[rowSums(all) == Ones,]
  #constrained <- apply(constrained,1,as.character)

  if(length(constrained) == 1) {
    Pattern_list <- append(1,append(constrained,1))
    #     Pattern_list <- unlist(append(1,append(constrained,1)))
  } else {
    Pattern_list <- t(apply(constrained,1, function(x) {
      Pattern <- append(x,1)
      Pattern <- unlist(append(1,Pattern))
      return(Pattern)
    }))
    rownames(Pattern_list) <- NULL
    colnames(Pattern_list) <- NULL
    Pattern_list <- lapply(seq_len(nrow(Pattern_list)), function(i) Pattern_list[i,])
  }

  return(Pattern_list)
}
