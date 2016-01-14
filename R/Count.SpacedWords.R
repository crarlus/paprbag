#' @title Compute SpacedWords
#' @description  Count the occurrence of all spaced words
#' @param Reads A DNAStringSet Object
#' @param k The length of the contingous words, i.e. the kmer size
#' @param l The length of the spaced words
#' @param prob If TRUE then the relative frequencies are returned (default TRUE)
#' @param symmetric If TRUE then kmers are returned in their canonical representation (i.e. including their reverse-complement) Default = T
#' @return A matrix containing the combined counts for all possible spacer-patterns
#' @seealso \link[Biostrings]{oligonucleotideFrequency}
#' @seealso \link{CreateFeaturesFromReads}
#' @family SpacedWordFeatures
#' @author Carlus Deneke
#' @importFrom foreach %do%
Count.SpacedWords <- function(Reads,k,l,prob=T,symmetric = T){

  #require(foreach)
  #require(seqinr)
  #require(Biostrings)



  if(k >= l) stop("l must be larger than k")

  # Enumerate patterns
  AllPatterns <- Enumerate.SpacerPatterns (k=k,l=l)

  # find all l-mers
  RawCounts <- Biostrings::oligonucleotideFrequency(Reads,width = l)

  ContiguousWords <- colnames(Biostrings::oligonucleotideFrequency(Reads[1:2],width = k))

  ContiguousWords_allPatterns <- foreach::foreach(Current.Pattern = AllPatterns) %do% {

    CombinedCounts_df <- do.call(cbind, foreach::foreach(i = 1:length(ContiguousWords) ) %do% {

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
  combinePatterns=T
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

