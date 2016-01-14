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
#' #' @examples
#' \dontrun{
#' Create.TrainingDataSet (Path2Files = NULL, OSlabels = NULL, savePath = NULL,CompressOption = T)
#' }
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

  # extract OS labels
  ReadLabel_OS <- as.factor(unlist(foreach(i = 1:length(FeatureTables)) %do% {
    IDFromFeatureFileName <- GetOSid(FeatureFiles[i])
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

