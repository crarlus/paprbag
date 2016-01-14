#' @title  Predict ReadSet
#' @description This function is a wrapper for function 'Predict.ReadSet'
#' @param Path2Forest A path to a randomForest object of class ranger in .rds format
#' @param Path2ReadFiles A path to a fasta file containing the read files
#' @param saveLocation A path to the direcory where the output should be written to
#' @param OutputFilename The name of the outputfile (without file extension) Default = "Output")
#' @param Return.Predictions Should the predictions be returned
#' @param Save.AsTSV Should the output saved in tsv (tab separated format) instead of rds format ?
#' @param ... Further arguments passed to function 'Predict.ReadSet'
#' @return Either the predictions (if Return.Predictions == T ) or TRUE/FALSE if Outputfile exists
#' #' @seealso \link[ranger]{predict.ranger}
#' @seealso \link{Predict.ReadSet}
#' @export
#' @author Carlus Deneke
Predict.ReadSet.fromFiles <- function(Path2Forest, Path2ReadFiles, saveLocation, OutputFilename = "Output", Return.Predictions = F, Save.AsTSV = F, ...){

  # require(Biostrings)

  if(verbose) Time0 <- proc.time()
  # load data
  if(!file.exists(Path2Forest)) {
    stop("Path2Forest does not exist")
  } else {
    forest <- readRDS(Path2Forest)
  }
  if(verbose) Time1 <- proc.time()
  if(verbose) print(paste("Forest loading took", paste(round(Time1[1:3] - Time0[1:3],1), collapse = ","),"s" ))

  if(!file.exists(Path2ReadFiles) ) {
    stop("Path2ReadFiles does not exist")
  } else {
    Reads <- Biostrings::readDNAStringSet(Path2ReadFiles)
  }


  if(!file.exists(saveLocation) ) {
    stop("Directory saveLocation does not exist")
  }


  # call
  Prediction <- Predict.ReadSet (ForestObject = forest, ReadObject = Reads, ...)


  # save
  if(Save.AsTSV == T){
    OutputFilename <- paste(OutputFilename,"tsv",sep=".")
    write.table(Prediction$predictions, file = file.path(saveLocation,OutputFilename), sep="\t")
  } else {
    OutputFilename <- paste(OutputFilename,"rds",sep=".")
    saveRDS(Prediction, file = file.path(saveLocation,OutputFilename))
  }

  # return
  if(Return.Predictions == T) {
    return(Prediction)
  } else {
    file.exists(file.path(file.path(saveLocation,OutputFilename)) )
  }


} # end function
