#' @title Update all features in a specified folder
#' @description Update all features in a specified folder. Save features in subfolder "Features". Backup old features if desired.
#' @param Path2File A path to the location of the read files
#' @param savePath Path where features should be saved to
#' @param Cores Multicore functionality for linux systems.
#' @param Backup Do you want to backup old features
#' @param AAindex_Selection Parameter for Features
#' @param pattern File extension of read files. Used as regex filter (default "fasta$|mason$")
#' @param verbose Write a logfile ("FeatureCreation.log") and verbose output
#' @param ... Parameters passed to function CreateFeaturesFromReads
#' @return Returns TRUE if completed
#' @author Carlus Deneke
#' @seealso Wraps \code{\link{CreateFeaturesFromReads}}
#' @importFrom foreach %dopar%
UpdateFeatures <- function(Path2File, savePath = Path2File, Cores = 1, Backup = T, pattern = "fasta$|mason$", verbose = T,...){

  require(foreach)
  require(Biostrings)

  if(Cores > 1) {
    #require(doParallel)
    doParallel::registerDoParallel(cores=Cores)
  }

  if(verbose == T){
    print(paste("A log-file is recorded under",file.path(Path2File,"FeatureCreation.log") ))
    con = file(file.path(Path2File,"FeatureCreation.log"), open = "a")
    sink(file=con, append=T, split=F)
    print(paste("New run for folder",Path2File,"on",date() ))
    print(sys.call())
  }

  if(verbose == T) StartTime <- proc.time()[3]

  ReadFiles <- list.files(Path2File, pattern = pattern, full.names = T)

  # loop over all read files
  FeatureCheck <- foreach::foreach(i = 1: length(ReadFiles)) %dopar% {

    CurrentReadFile <- ReadFiles[i]
    print(paste("Creating features for file",CurrentReadFile,":",i))

    # Load data
    ReadData <-  Biostrings::readDNAStringSet(CurrentReadFile)

    # Obtain features
    Features <- CreateFeaturesFromReads (Reads = ReadData, ...)

    # check feature qualitiy
    Check <- CheckFeatures(Features)
    if(!Check) {warning(paste("Feature check negative for file", CurrentReadFile)); return(0)}

    # Backup Features
    SaveFeatureFile(Filename=CurrentReadFile, Features=Features, savePath = savePath, Backup = Backup)

    # Write Log
    if(verbose == T) print(paste("New feature set created for", CurrentReadFile,"on",date() ))
    if(verbose == T) print(paste("FeatureTable has dim",nrow(Features),",",ncol(Features),"and contains groups:",paste(attr(Features,"FeatureGroups"),collapse = ",") ))
    if(verbose == T) print(paste("Feature table contains the following features:",paste(colnames(Features), collapse = ",") ))
    if(verbose == T) if(Backup) print(paste("Backup of old feature version stored in subfolder Backup"))
    if(verbose == T) cat("\n")

    return(T)
  }

  if(verbose == T) EndTime <- proc.time()[3]

  if(verbose == T) print(paste("Feature creation took",EndTime - StartTime) )
  if(verbose == T) cat("#################\n")

  if(verbose == T) sink()
  if(verbose == T) close(con)

  return(T)

} # end function

