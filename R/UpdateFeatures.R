#' @title Update all features in a specified folder
#' @description Update all features in a specified folder. Save features in subfolder "Features". Backup old features if desired.
#' @param Path2File A path to the location of the read files
#' @param Cores Multicore functionality for linux systems.
#' @param Backup Do you want to backup old features
#' @param AAindex_Selection Parameter for Features
#' @return Returns TRUE if completed
UpdateFeatures <- function(Path2File, Cores = 1, Backup = T, ...){

  require(foreach)
  require(Biostrings)

  if(Cores > 1) {
    require(doParallel)
    registerDoParallel(cores=Cores)
  }

  print(paste("A log-file is recorded under",file.path(Path2File,"FeatureCreation.log") ))
  con = file(file.path(Path2File,"FeatureCreation.log"), open = "a")
  sink(file=con, append=T, split=F)
  print(paste("New run for folder",Path2File,"on",date() ))
  print(sys.call())

  StartTime <- proc.time()[3]

  ReadFiles <- list.files(Path2File, pattern = "fasta$|mason$", full.names = T)

  # loop over all read files
  FeatureCheck <- foreach(i = 1: length(ReadFiles)) %dopar% {

    CurrentReadFile <- ReadFiles[i]
    print(paste("Creating features for file",CurrentReadFile,":",i))

    # Load data
    ReadData <- readDNAStringSet(CurrentReadFile)

    # Obtain features
    Features <- CreateFeaturesFromReads (Reads = ReadData, ...)

    # check feature qualitiy
    Check <- CheckFeatures(Features)
    if(!Check) {warning(paste("Feature check negative for file", CurrentReadFile)); return(0)}

    # Backup Features
    SaveFeatureFile(Filename=CurrentReadFile, Features=Features, Path2File = Path2File, Backup = Backup)

    # Write Log
    print(paste("New feature set created for", CurrentReadFile,"on",date() ))
    print(paste("FeatureTable has dim",nrow(Features),",",ncol(Features),"and contains groups:",paste(attr(Features,"FeatureGroups"),collapse = ",") ))
    print(paste("Feature table contains the following features:",paste(colnames(Features), collapse = ",") ))
    if(Backup) print(paste("Backup of old feature version stored in subfolder Backup"))
    cat("\n")

    return(T)
  }

  EndTime <- proc.time()[3]

  print(paste("Feature creation took",EndTime - StartTime) )
  cat("#################\n")

  sink()
  close(con)

  return(T)

} # end function

