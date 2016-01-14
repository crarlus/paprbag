#' Make Features Symmetric by combining a dna string with its reverse complement
Make.Symmetric <- function(Data){

  ColNames <- sapply(strsplit(colnames(Data),"_"), function(x) tail(x,1))

  Combo_raw <- cbind(ColNames,ColNames[Match.SymmetricPartners (ColNames)] )
  Combo <- apply(apply(Combo_raw,1,function(x) sort(x) ),2,function(y) paste(y,collapse="_") )
  Dups <- which(duplicated(Combo))
  Majoranas <- which(apply(Combo_raw, 1, function(x) x[1] == x[2]) )

  United <- Data + Data[,Match.SymmetricPartners (ColNames)]
  colnames(United) <- Combo
  United[,Majoranas] <- United[,Majoranas]/2
  United <- United[,-Dups]

  #colnames(United) <- paste(sapply(strsplit(colnames(Data),"_"), function(x) x[-length(x)])[-Dups],colnames(United),sep="_")

  return(United)

}
