#' Check valididity of feature table
#' @param Features A data.frame containing the features
#' @return FALSE if found a NA value otherwise TRUE
#' @author Carlus Deneke
CheckFeatures <- function(Features){

  if(any(is.na(Features))){
    warning("Some features are NA");return(F)
  } else {
    return(T)
  }
}
