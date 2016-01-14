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
#' Run.Training (Path2FeatureFile = Path2FeatureFile, Path2LabelFile = Path2LabelFile, SelectedFeatures = NULL, savePath = savePath, ReturnForest = F, verbose = T, min.node.size = 1, num.trees = 100, mtry = NULL, importance = 'impurity', num.threads = NULL)
#' }
#' @export
#' @author Carlus Deneke
#' @family TrainingFunctions
Run.Training <- function(Path2FeatureFile, Path2LabelFile = NULL, SelectedFeatures = NULL, savePath = NULL, ReturnForest = F, verbose = T, min.node.size = 1, num.trees = 100, mtry = NULL, importance = 'impurity', num.threads = NULL, ...){


  if(!file.exists(Path2FeatureFile) ) stop("Feature file does not exist")


  # load dependencies
  #require(foreach, quietly = T)
  #require(data.table, quietly = T)
  # require(ranger)


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
