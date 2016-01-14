#' @title Make a prediction from a set of reads
#' @param ForestObject A random forest object of class 'ranger'
#' @param ReadObject A DNAStringSet object containing the read sequences
#' @param Feature.Configuration A list containing all feature options. If set to NULL then features are extracted from forest object. See 'details' for more information. (Default = NULL)
#' @param verbose Print verbose output
#' @param num.threads Number of threads used for ranger prediction. Default is number of CPUs available.
#' @details If the user supplies the Feature.Configuration it should contain the following list objects
#' \itemize{
#'  \item{"parameter 1"}{Stuff1}
#'  \item{"parameter 2"}{Stuff2}
#' @return A prediction object of class 'ranger.prediction'
#' @export
##' \link[pkg]{function} e.g. \link[stringi]{stri_c}
##' \code{\link[MASS]{stats}}
##' @seealso allows you to point to other useful resources, either on the web, \url{http://www.r-project.org}, in your package \code{\link{functioname}}, or another package \code{\link[packagename]{functioname}}.
#
Predict.ReadSet <- function(ForestObject, ReadObject, Feature.Configuration = NULL, verbose = F, num.threads = NULL, ...){

  require(ranger)

  if(class(ForestObject) != 'ranger') stop("Forest object is not of class 'ranger'")
  if(class(ReadObject) != 'DNAStringSet') stop ("ReadObject is not of class DNAStringSet")

  # identify features
  if(is.null(Feature.Configuration)) {
    Feature.Configuration <- IdentifyFeatures.FromForest (ForestObject = ForestObject, verbose = verbose)
  }

  # Override configuration


  # create features
    if(verbose) Time1 <- proc.time()
    Features <- CreateFeaturesFromReads (ReadObject,
                                          NT_kmax = Feature.Configuration$kmax,
                                          SymmetricFeatures = Feature.Configuration$Symmetric,
                                          Do.NTMotifs = Feature.Configuration$Do.NTMotifs,
                                          NTMotifs = Feature.Configuration$NTMotifs,
                                          AllowedMismatches = Feature.Configuration$AllowedMismatches,
                                          bothStrands = Feature.Configuration$bothStrands,
                                          Do.SpacedWords = Feature.Configuration$Do.SpacedWords,
                                          k.spaced = Feature.Configuration$k.spaced,
                                          l.spaced = Feature.Configuration$l.spaced,
                                          SingleSpacerPattern = Feature.Configuration$SingleSpacerPattern,
                                          combineSpacerPatterns = Feature.Configuration$combineSpacerPatterns,
                                          Do.PeptideFeatures = Feature.Configuration$Do.PeptideFeatures,
                                          Do.MonoPep = Feature.Configuration$Do.MonoPep,
                                          Do.DiPep = Feature.Configuration$Do.DiPep,
                                          Do.AAprops = Feature.Configuration$Do.AAprops,
                                          Do.AAindex = Feature.Configuration$Do.AAindex,
                                          AAindex_Selection = Feature.Configuration$AAindex_Selection,
                                          Do.UCO = Feature.Configuration$Do.UCO,
                                          Do.PepPatterns = Feature.Configuration$Do.PepPatterns,
                                          Patterns =Feature.Configuration$Patterns,
                                          SearchPatternsSixFrame = Feature.Configuration$SearchPatternsSixFrame,
                                          AllowedPeptideMismatches = Feature.Configuration$AllowedPeptideMismatches,
                                          AggregatePatterns = Feature.Configuration$AggregatePatterns )

    if(verbose) Time2 <- proc.time()

  # save features
  # optional

  # make prediction
    if(!all.equal(names(ForestObject$variable.importance),colnames(Features) ) ) stop(paste("Feature names and forest features not identical. Check your feature settings. Forest features are",paste(names(ForestObject$variable.importance),collapse = ",")) )
    Prediction <- predict(ForestObject, data = Features, num.threads = num.threads, verbose = verbose)


    if(verbose) Time3 <- proc.time()

    if(verbose) print(paste("Feature extraction took", paste(round(Time2[1:3] - Time1[1:3],1), collapse = ","),"s" ))
    if(verbose) print(paste("Prediction took", paste(round(Time3[1:3] - Time2[1:3],1), collapse = ","),"s" ))
    if(verbose) print(paste("Total workflow took", paste(round(Time3[1:3] - Time1[1:3],1), collapse = ","),"s" ))

  # Remove forest object ?
    rm(ForestObject)
    gc()

  # return
      return(Prediction)
}


