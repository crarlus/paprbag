#' Save Features into Rdata file
#' @details Save the Features generated from the ReadFile. It will be saved in a folder "Features" which is located in the same diectorory as the location of the Readfile. A backup will be saved in the subdirectory 'Backup'.
#' @param Filename The name of the orginal read file (e.g. *.fasta or *.mason)
#' @param Features A data.frame containing the features
#' @param Path2File Complete path to the location of the read fike
#' @param Backup Should old feature file be backed up?
#' @return Returns TRUE if completely run
SaveFeatureFile <- function(Filename, Features, Path2File, Backup = T) {

  if(!dir.exists(file.path(Path2File,"Features")) ) dir.create(file.path(Path2File,"Features"),showWarnings = F)

  OutputName <- paste("Features_",strsplit(tail(strsplit(Filename,"/")[[1]],1),".",fixed=T)[[1]][1],".rds",sep="")

  if(file.exists(file.path(Path2File,"Features",OutputName)) & Backup == T ) {
    if(!dir.exists(file.path(Path2File,"Features","Backup")) ) dir.create(file.path(Path2File,"Features","Backup"),showWarnings = F)
    file.copy(from = file.path(Path2File,"Features",OutputName) ,to = file.path(Path2File,"Features","Backup",OutputName), overwrite = T)
  }

  # Save
  saveRDS(Features,file.path(Path2File,"Features",OutputName))

  return(T) # exit status
}
