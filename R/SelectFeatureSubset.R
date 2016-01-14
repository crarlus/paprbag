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
