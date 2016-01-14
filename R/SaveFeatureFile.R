#' Save Features into Rdata file
#' @details Save the Features generated from the ReadFile. It will be saved in a folder "Features" which is located in the same diectorory as the location of the Readfile. A backup will be saved in the subdirectory 'Backup'.
#' @param Filename The name of the orginal read file (e.g. *.fasta or *.mason)
#' @param Features A data.frame containing the features
#' @param savePath Complete path to where feature files should be saved
#' @param Backup Should old feature file be backed up?
#' @return Returns TRUE if completely run
#' @author Carlus Deneke
SaveFeatureFile <- function(Filename, Features, savePath, Backup = F) {

  if(!dir.exists(file.path(savePath)) ) dir.create(file.path(savePath),showWarnings = F)

  OutputName <- paste("Features_",strsplit(tail(strsplit(Filename,"/")[[1]],1),".",fixed=T)[[1]][1],".rds",sep="")

  if(file.exists(file.path(savePath,OutputName)) & Backup == T ) {
    if(!dir.exists(file.path(savePath,"Backup")) ) dir.create(file.path(savePath,"Backup"),showWarnings = F)
    file.copy(from = file.path(savePath,OutputName) ,to = file.path(savePath,"Backup",OutputName), overwrite = T)
  }

  # Save
  saveRDS(Features,file.path(savePath,OutputName))

  return(T) # exit status
}
