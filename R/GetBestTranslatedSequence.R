#' @title Translate nucleotide sequence into a amino acid sequence
#' @description Translate a nulceotide sequence into all possible 6-frames and decide for the frame with the fewest number of stop codons
#' @param Reads A DNAStringSet Object
#' @return Returns a list containing 'BestSeq' (Peptide sequence with the lowest number of stop codons),'MinStopCodons' (Number of stop codons in the selected frame), 'Frame' (putative frame),'Strand' (putative strand)
#' @author Carlus Deneke
GetBestTranslatedSequence <- function(Reads){

  #require(Biostrings)

  Reads_subseqs_f <- lapply(1:3, function(pos)  Biostrings::subseq(Reads, start=pos))
  Reads_subseqs_r <- lapply(1:3, function(pos)  Biostrings::subseq(Biostrings::reverseComplement(Reads), start=pos))

  Reads_TranslatedSeq_bs_3frame_f <- lapply(Reads_subseqs_f, function(seq) Biostrings::translate(seq,if.fuzzy.codon="solve",genetic.code = Biostrings::getGeneticCode("11")) )
  Reads_TranslatedSeq_bs_3frame_r <- lapply(Reads_subseqs_r, function(seq) Biostrings::translate(seq,if.fuzzy.codon="solve",genetic.code = Biostrings::getGeneticCode("11")) )

  AAfreq0f <- Biostrings::alphabetFrequency(Reads_TranslatedSeq_bs_3frame_f[[1]], as.prob=F)
  AAfreq1f <- Biostrings::alphabetFrequency(Reads_TranslatedSeq_bs_3frame_f[[2]], as.prob=F)
  AAfreq2f <- Biostrings::alphabetFrequency(Reads_TranslatedSeq_bs_3frame_f[[3]], as.prob=F)
  AAfreq0r <- Biostrings::alphabetFrequency(Reads_TranslatedSeq_bs_3frame_r[[1]], as.prob=F)
  AAfreq1r <- Biostrings::alphabetFrequency(Reads_TranslatedSeq_bs_3frame_r[[2]], as.prob=F)
  AAfreq2r <- Biostrings::alphabetFrequency(Reads_TranslatedSeq_bs_3frame_r[[3]], as.prob=F)

  StopCodons <- cbind(AAfreq0f[,27],AAfreq1f[,27],AAfreq2f[,27],AAfreq0r[,27],AAfreq1r[,27],AAfreq2r[,27])

  MinStopCodons <- apply(StopCodons,1,min)
  WhichMinStopCodons <- apply(StopCodons,1,which.min)

  BestTranslation <- c(Reads_TranslatedSeq_bs_3frame_f[[1]][which(WhichMinStopCodons == 1)],
                       Reads_TranslatedSeq_bs_3frame_f[[2]][which(WhichMinStopCodons == 2)],
                       Reads_TranslatedSeq_bs_3frame_f[[3]][which(WhichMinStopCodons == 3)],
                       Reads_TranslatedSeq_bs_3frame_r[[1]][which(WhichMinStopCodons == 4)],
                       Reads_TranslatedSeq_bs_3frame_r[[2]][which(WhichMinStopCodons == 5)],
                       Reads_TranslatedSeq_bs_3frame_r[[3]][which(WhichMinStopCodons == 6)])

  BestTranslation_ordered <- BestTranslation[match(names(Reads),names(BestTranslation) )]

  return(list(BestSeq=BestTranslation_ordered,MinStopCodons=MinStopCodons,Frame=WhichMinStopCodons %% 3,Strand=ifelse(WhichMinStopCodons <=3,'f','r')))

} # end function
