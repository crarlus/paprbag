#' Match the OSid (Bioproject id) to a vector of
#' @param OSid A vector of query ids
#' @param OSlabels A vector with label information named with the corresponding ids
#' @return Returns a vector of labels of the queried ids
MatchOSlabel <- function(OSid,OSlabels) {
  OSlabels[match(OSid,names(OSlabels))]
}
