#' @title Find patterns in all 6-frame translations of a read
#' @description For a list of read sequences, translate into all 6-frames and search for patterns in each frame
#' @details The matches in the individual frames are combined
#' @param Reads_Seq DNAStringObject
#' @param Patterns Vector of patterns
#' @param Prefix How should the columns of pattern matches be called
#' @return A data.frame containing the matched patterns (columns)
#' @author Carlus Deneke
FindPatternsIn6frames <- function(Reads_Seq, Patterns, Prefix = "AAPattern"){

  Reads_Seq_Biostrings_subseqs_f <- lapply(1:3, function(pos)  Biostrings::subseq(Reads_Seq, start=pos))
  Reads_Seq_Biostrings_subseqs_r <- lapply(1:3, function(pos)  Biostrings::subseq(Biostrings::reverseComplement(Reads_Seq), start=pos))

  Reads_TranslatedSeq_bs_3frame_f <- lapply(Reads_Seq_Biostrings_subseqs_f, function(seq) Biostrings::translate(seq,if.fuzzy.codon="solve",genetic.code = Biostrings::getGeneticCode("11")) )
  f1 <- FindPatternsInAAseq(Reads_TranslatedSeq_bs_3frame_f[[1]], Patterns, Prefix = Prefix)
  f2 <- FindPatternsInAAseq(Reads_TranslatedSeq_bs_3frame_f[[2]], Patterns, Prefix = Prefix)
  f3 <- FindPatternsInAAseq(Reads_TranslatedSeq_bs_3frame_f[[3]], Patterns, Prefix = Prefix)

  Reads_TranslatedSeq_bs_3frame_r <- lapply(Reads_Seq_Biostrings_subseqs_r, function(seq) Biostrings::translate(seq,if.fuzzy.codon="solve",genetic.code = Biostrings::getGeneticCode("11")) )
  f4 <- FindPatternsInAAseq(Reads_TranslatedSeq_bs_3frame_r[[1]], Patterns, Prefix = Prefix)
  f5 <- FindPatternsInAAseq(Reads_TranslatedSeq_bs_3frame_r[[2]], Patterns, Prefix = Prefix)
  f6 <- FindPatternsInAAseq(Reads_TranslatedSeq_bs_3frame_r[[3]], Patterns, Prefix = Prefix)

  # Combine
  Combined <- f1
  Combined[which(f2 ==T,arr.ind = T)] <- T
  Combined[which(f3 ==T,arr.ind = T)] <- T
  Combined[which(f4 ==T,arr.ind = T)] <- T
  Combined[which(f5 ==T,arr.ind = T)] <- T
  Combined[which(f6 ==T,arr.ind = T)] <- T

  return(Combined)

}
