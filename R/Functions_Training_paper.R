# functions for training


#' The workhorse function for the training workflow
#' @details Trains a random forest classification algorithm on the Feature file in Trainingfolder using the labels from LabelFile or LabelType. Saves the output (the random forest object) in a new subfolder of TrainingData
#' @param Path2FeatureFile Path to feature file in rds format. Rows are independent data, columns are features. May also contain the label information  (no default)
#' @param Path2LabelFile Either a path to a file containing the label data or (default: NULL)
#' @param SelectedFeatures Either a vector of column numbers, or a vector of feature group names (default: NULL)
#' @param savePath Path to where the forest object "randomForest.rds" is written to. If NULL, no output is written(default: NULL)
#' @param ReturnForest Whether the forest object should be returned or not (default: F)
#' @param verbose (default: T)
#' @param min.node.size Option for ranger: Minimal node size. (default: 1)
#' @param num.trees Option for ranger: Number of trees. (default: 100)
#' @param mtry Option for ranger: Number of variables to possibly split at in each node. Default is the (rounded down) square root of the number variables.
#' @param importance Option for ranger: Variable importance mode, one of 'none', 'impurity', 'permutation'. (default: 'impurity')
#' @param num.threads Option for ranger: Number of threads. Default is number of CPUs available.
#' @param ... Additional parameters passed to function ranger, see \code{\link{ranger::ranger}}
#' @return Returns either TRUE if forest has been saved successfully or returns the forest object itself
#' @examples
#' \dontrun{
#' Run.Training.workflow(TrainingFolder, LabelFile = NULL, LabelType = 'CDS', SelectedFeatures = c(1:40,67,99), OutputName = "myForest.new", Cores = 1, do.regression = F, rfAlgorithm = "random.forest", NodeSize = 1, balanced = T, replace = F, Ntree = 50, do.trace = T)
#' }
# Run.Training <- function(TrainingFolder, LabelFile = NULL, LabelType = 'OS', SelectedFeatures = NULL, SelectedRows = NULL,OutputName = NULL, Cores = 1, do.regression = F, ...){

Run.Training <- function(Path2FeatureFile, Path2LabelFile = NULL, SelectedFeatures = NULL, savePath = NULL, ReturnForest = F, verbose = T, min.node.size = 1, num.trees = 100, mtry = NULL, importance = 'impurity', num.threads = NULL, ...){    
  

  if(!file.exists(Path2FeatureFile) ) stop("Feature file does not exist")

  
  # load dependencies
  #require(foreach, quietly = T)
  #require(data.table, quietly = T)
  require(ranger)
  

  # read in features
  Features <- readRDS(Path2FeatureFile )

  # perform feature selection
  if(!is.null(SelectedFeatures)) {
    Features <-  SelectFeatureSubset(Features,SelectedFeatures)
  } 

  # load label info
  if(is.null(Path2LabelFile)) {
    
    if(!any(grepl("Labels",colnames(Features) ) ) ) stop("Feature file does NOT contain a column with name 'Labels'")
    trainingData <- Features  
    
  } else {
    
    # read in label data
    if(!file.exists(Path2LabelFile) ) stop("Label file does not exist")    
    Labels <- readRDS(Path2LabelFile)    
    
    # Check if feature and labels have same length
    if(nrow(Features) != length(Labels) )  stop("Length of feature file and label file do not agree")
    
    # join feature and label data
    trainingData <- data.frame(Labels = Labels, Features)
  }
  
    
  
  # run forest
  rf <- ranger::ranger(dependent.variable.name = "Labels", data = trainingData, write.forest = T, probability = T, min.node.size = min.node.size, num.trees = num.trees, mtry = mtry, importance = importance, num.threads = num.threads, verbose = verbose, ...)
    

  # Save forest
  if(!is.null(savePath)) {
    dir.create(savePath, recursive = T)
    saveRDS(rf,file.path(savePath,"randomForest.rds"))  
  }
  
  
  # Return
  if(ReturnForest == T) {
    return(rf)
  } else {
    return(file.exists(file.path(savePath,"randomForest.rds")))  
  }

} # end function


  # ---

  # ---
  
  #' Function to select a subset of features from the feature table
  #' @param Features The original feature table as data.frame
  #' @param SelectedFeatures Either a numerical vector containing columns to be selected or a vector of character strings to select groups of features
  #' @return The subsetted feature table as data.frame 
  SelectFeatureSubset <- function(Features,SelectedFeatures){
    
    if(is.numeric(SelectedFeatures)){
      if(max(SelectedFeatures) > ncol(Features)) stop("Invalid input for Selected features")
      Features <- Features[,SelectedFeatures]
    } else if(is.character(SelectedFeatures)){
      SelectedFeatures <- unlist(sapply(SelectedFeatures,function(x) grep(paste(x,"_",sep=""),colnames(Features)) ) )
      Features <- Features[,SelectedFeatures]
    } else stop("Choice of SelectedFeatures not recognized")
    
    return(Features)  
    
  }

  # ---
  
  #' Extract the Organism ID (PRJNA accession)
  GetOSid <- function(x) {
    require(stringr)
    str_extract(x, 'PRJ[A-Z]{2}[0-9]+')     
  } 
  
  #' Match the OSid (Bioproject id) to a vector of 
  #' @param OSid A vector of query ids
  #' @param OSlabels A vector with label information named with the corresponding ids
  #' @return Returns a vector of labels of the queried ids
  MatchOSlabel <- function(OSid,OSlabels) {
    OSlabels[match(OSid,names(OSlabels))]
  }
  
  #' @title Create a new training data set
  #' @description Create a new training data set from a set of feature files. It concatenates all feature file into a data.table object. Read labels are assigned from the corresponding organism labels. Data are saved in specified folders.
  #' @details Saves 3 files in specified folder "TrainingFolder". 
  #' FeatureTable.rds containing the features in a data.frame object
  #' FeatureRowDescription.rds containing the read description and allows identification of Organism, Chromosome and read
  #' ReadLabel_OS.rds containing a label for each read based on the organisms label
  #' @param Path2Files A complete path to the read folder (i.e. it contains a subfolder 'Features')
  #' @param OSlabels A vector containing either 'HP' or 'NP' together with the name attributes pointing to the Organism identifier (Bioproject ID)
  #' @param savePath The name of the newly created training data set folder
  #' @param CompressOption Do you want to compress the saved files (takes time but saves disk space)?
  #' @return Returns True if completed. Feature and label files are saved in specified folder (see details)
  #' @export
  Create.TrainingDataSet <- function(Path2Files = NULL, OSlabels = NULL, savePath = NULL,CompressOption = T){

    require(foreach, quietly = T)
    require(data.table, quietly = T)
    
    # Checks:
    if(is.null(Path2Files)) stop("Please submit a path pointing to the read folder")
    if(is.null(OSlabels)) stop("Please submit a vector containing the labels of all organisms")
    if(is.null(savePath)) stop("Please submit a folder name for the new training data set")
    
    if(!dir.exists(Path2Files)) stop(paste("Path",Path2Files,"does not exist"))
    

    # list feature files & select subset
    FeatureFiles <- list.files(file.path(Path2Files,"Features"),pattern="Features",full.names=T)
    if(!is.null(SearchPatterns)) FeatureFiles <- unlist(lapply(SearchPatterns, function(pattern) grep(paste(pattern,"[_.]",sep=""),FeatureFiles,value=T,invert = F) ))
    
    if(length(FeatureFiles) == 0) stop("No feature files selected")
    
    # read in feature files
    FeatureTables <- foreach(i=1:length(FeatureFiles)) %do% { readRDS(FeatureFiles[i]) }
    
    # extract OS names
    FeatureTables_rownames <-  rbindlist(lapply(FeatureTables,function(x) data.frame(FullName=rownames(x),stringsAsFactors = F) ) )
    FeatureTables_rownames[,OSid:=list(OSid=GetOSid(FullName))]
    FeatureTables_rownames$OSid[is.na(FeatureTables_rownames$OSid)] <- "Human"
    
    # extract OS labels
    ReadLabel_OS <- as.factor(unlist(foreach(i = 1:length(FeatureTables)) %do% {
      IDFromFeatureFileName <- GetOSid(FeatureFiles[i])  
      #   return(rep(OSlabels[which(IDFromFeatureFileName == names(OSlabels) )],nrow(FeatureTables[[i]]) ) )
      return(rep(OSlabels[grep(paste(IDFromFeatureFileName,"$",sep=""),names(OSlabels))],nrow(FeatureTables[[i]]) ) )
    }))
    FeatureTables_rownames[,ReadOSLabel:=list(ReadOSLabel=ReadLabel_OS)]

    # join features files
    FeatureTables <- rbindlist(FeatureTables)
    
    # Convert back to pure data.frame
    FeatureTables <- data.frame(FeatureTables)
    rownames(FeatureTables) <- FeatureTables_rownames$FullName
    
    # create new folder
    dir.create(savePath)
    
    # save
    if(file.exists(file.path(savePath,"FeatureTable.rds"))) {
      stop(paste("File",file.path(savePath,"FeatureTable.rds"),"already exists.Abort"))
      
    } else {
      saveRDS(FeatureTables,file.path(savePath,"FeatureTable.rds"),compress = CompressOption)
      saveRDS(FeatureTables_rownames,file.path(savePath,"FeatureRowDescription.rds"),compress = CompressOption)
      saveRDS(ReadLabel_OS,file.path(savePath,"ReadLabel_OS.rds"),compress = CompressOption)  
      
      return(file.exists(file.path(savePath,"FeatureTable.rds")))
    }
    
    

    
    
  }# end function
  
  