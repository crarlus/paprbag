#' @title Print the default selection of aaindices and their description
#' @description Print the default selection of aaindices and their description
#' @return Prints the default selection of aaindices and their description in data.frame format
#' @author Carlus Deneke
default.AAindexSelection <- function(){
  Default.indices <-c("BROC820101", "BUNA790103", "CHOP780207", "FAUJ880105", "FINA910103", "GEIM800103", "GEIM800105", "ISOY800107", "KHAG800101", "LEWP710101","MAXF760103",                                                         "OOBM850104", "PALJ810111", "PRAM820103", "QIAN880102", "QIAN880114", "QIAN880123", "QIAN880137", "RACS770103", "RACS820103", "RICJ880101", "RICJ880117",                                                         "ROBB760107", "TANS770106", "TANS770108", "VASM830101", "WERD780104", "AURR980102", "AURR980116", "AURR980118", "FUKS010109", "SUYM030101")

  data(AAindexData)

  print(cbind(Accession=Default.indices,Description=AAindexData$PropDesc[match(Default.indices,AAindexData$AccNo)]) )

}
