#' @title Identify features from random forest object
#' @param ForestObject An object of class 'ranger'
#' @return A list object containing the relevant feature type information
#' @author Carlus Deneke
IdentifyFeatures.FromForest <- function(ForestObject, verbose = F){
  if(class(ForestObject) != 'ranger') stop("ForestObject is not of class 'ranger'")

  Features <- names(ForestObject$variable.importance)
  FeatureGroups <- unique(sapply(strsplit(Features,split = "_"),function(x) x[1]) )

  Feature.Configuration <- list()

  # determing kmax
  if(any(FeatureGroups == "Poly")){
    kmax <- nchar(strsplit(grep("Poly_",Features,value = T)[1],"_")[[1]][2])
  } else if(any(FeatureGroups == "Poly")){
    kmax <- 5
  } else if(any(FeatureGroups == "Tetra")){
    kmax <- 4
  } else if(any(FeatureGroups == "Tri")){
    kmax <- 3
  } else if(any(FeatureGroups == "Di")){
    kmax <- 2
  } else if(any(FeatureGroups == "Mono")){
    kmax <- 1
  } else {
    stop("Kmax could not be inferred. Check feature names in forest object")
  }

  # determine feature conf
  Feature.Configuration$kmax <- kmax
  Feature.Configuration$Symmetric <- any(grepl("Mono_A_T",Features))
  Feature.Configuration$Do.NTMotifs <- any(FeatureGroups == "Motifs")
  Feature.Configuration$NTMotifs <- sub("Motifs_","",grep("Motifs_",Features,value=T))
  Feature.Configuration$AllowedMismatches <- 1
  Feature.Configuration$bothStrands <- T

  Feature.Configuration$Do.SpacedWords <- any(FeatureGroups == "Spaced")
  Feature.Configuration$k.spaced <- nchar(strsplit(grep("Spaced_",Features,value=T)[1],"_")[[1]][2])
  Feature.Configuration$l.spaced <- nchar(strsplit(grep("Spaced_",Features,value=T)[1],"_")[[1]][2]) + 2
  Feature.Configuration$SingleSpacerPattern <- 0
  Feature.Configuration$combineSpacerPatterns <- T
  Feature.Configuration$Do.PeptideFeatures <- any(any(FeatureGroups == "MonoPep"),  any(FeatureGroups == "DiPep"),  any(FeatureGroups == "AAprops"),  any(FeatureGroups == "AAindex"),  any(FeatureGroups == "Codon"))
  Feature.Configuration$Do.MonoPep <- any(FeatureGroups == "MonoPep")
  Feature.Configuration$Do.DiPep <- any(FeatureGroups == "DiPep")
  Feature.Configuration$Do.AAprops <- any(FeatureGroups == "AAprops")
  Feature.Configuration$Do.AAindex <- any(FeatureGroups == "AAindex")
  Feature.Configuration$AAindex_Selection <- sub("AAindex_","",grep("AAindex_",Features,value=T))
  Feature.Configuration$Do.UCO <- any(FeatureGroups == "Codon")
  Feature.Configuration$Do.PepPatterns <- F
  Feature.Configuration$Patterns <- NULL
  Feature.Configuration$SearchPatternsSixFrame <- F
  Feature.Configuration$AllowedPeptideMismatches <- 0
  Feature.Configuration$AggregatePatterns <- F

  if(verbose) {warning(paste("Assuming feature properties:",
                "AllowedMismatches =",Feature.Configuration$AllowedMismatches,
                "l.spaced =",Feature.Configuration$l.spaced
  ))
    }


    return(Feature.Configuration)

}
