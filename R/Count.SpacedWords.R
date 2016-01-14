# Compute SpacedWords
#' Count the occurrence of all spaced words
#' @param Reads
#' @param k The length of the contingous words, i.e. the kmer size
#' @param l The length of the spaced words
#' @return A matrix containing the combined counts for all possible spacer-patterns
#' @export
Count.SpacedWords <- function(Reads,k,l,combinePatterns=T,SinglePattern = 0,prob=T,symmetric = T){

  #require(foreach)
  #require(seqinr)
  #require(Biostrings)

  if(k >= l) stop("l must be larger than k")

  # Enumerate patterns
  AllPatterns <- Enumerate.SpacerPatterns (k=k,l=l)
  if( all(SinglePattern != 0) & is.numeric(SinglePattern) ) AllPatterns <- AllPatterns[SinglePattern]

  # find all l-mers
  RawCounts <- Biostrings::oligonucleotideFrequency(Reads,width = l)

  ContiguousWords <- colnames(Biostrings::oligonucleotideFrequency(Reads[1:2],width = k))

  ContiguousWords_allPatterns <- foreach::foreach(Current.Pattern = AllPatterns) %do% {

    CombinedCounts_df <- do.call(cbind,foreach::foreach(i = 1:length(ContiguousWords) ) %do% {

      Current.ContiguousWord <- seqinr::s2c(ContiguousWords[i])

      Current.SpacedWord <- seqinr::c2s(ifelse(Current.Pattern == 1,Current.ContiguousWord,"[acgt]"))

      # combine all to same spaced word and same pattern
      CombinedCounts <- rowSums(RawCounts[,grep(Current.SpacedWord,colnames(RawCounts),ignore.case = T)])

      return(CombinedCounts)

    }) # all kmers
    colnames(CombinedCounts_df) <- paste("Spaced",ContiguousWords,sep="_")

    return(CombinedCounts_df)
  } # all patterns

  # combine different patterns: combine column wise: add
  if(combinePatterns == T) {
    ContiguousWords_allPatterns <- Reduce('+',ContiguousWords_allPatterns)

    if(symmetric == T) {
      ContiguousWords_allPatterns <- Make.Symmetric(ContiguousWords_allPatterns)
      colnames(ContiguousWords_allPatterns) <- paste("Spaced",colnames(ContiguousWords_allPatterns),sep="_")
    }

  } else {
    ContiguousWords_allPatterns <- do.call(cbind,ContiguousWords_allPatterns)
    Starts <- grep(colnames(ContiguousWords_allPatterns)[1],colnames(ContiguousWords_allPatterns))
    if(length(Starts) > 1) Length <- Starts[2] - Starts[1] else Length <- ncol(ContiguousWords_allPatterns)
    colnames(ContiguousWords_allPatterns) <- unlist(lapply(1:length(Starts), function(i) sub("Spaced",paste("Spaced_Pattern",i,sep=""),colnames(ContiguousWords_allPatterns)[Starts[i]:(Starts[i]+Length-1)] ) ) )
  }


  if(prob==T) {
    return(ContiguousWords_allPatterns/length(Reads[[1]]) )
  } else {
    return(ContiguousWords_allPatterns)
  }

}# end function

