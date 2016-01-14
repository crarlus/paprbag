#' @title Create features from reads
#' @description This function extracts all kind of different features from a set of DNA sequences
#' @details Make Stats from DNAString object, based on nucleotide sequence itself and the best translation into an amino acid sequence
#' @param Reads A DNAStringSet object
#' @param Do.NTMotifs Should features based on specified (genomic) sequence motifs (see NTMotifs) be computed
#' @param NTMotifs Vector of characters containing the sequence motifs
#' @param AllowedMismatches How many Mismatches are allowed for the motif search
#' @param bothStrands Should the motifs be search on both strands?
#' @param Do.SpacedWords Should the occurrence of spaced words be computed?
#' @param k.spaced Specify the word length
#' @param l.spaced Specify the word length including spacers
#' @param SingleSpacerPattern Integer value to pick a single spacer pattern of all possible patterns
#' @param combineSpacerPatterns combine different patterns: combine column wise: add
#' @param Do.PeptideFeatures Should the DNA sequence be translated and peptide features be computed?
#' @param Do.DiPep Should the monopeptide frequency be computed?
#' @param Do.DiPep Should the dipeptide frequency be computed?
#' @param Do.AAprops Should the amino acid properties be computed?
#' @param Do.AAindex Should properties based on the AAindex stats be computed?
#' @param AAindex_Selection Which AAindex properties should be computed: Vector of accession numbers
#' @param Do.UCO Should the codon usage frequency be computed?
#' @param Do.PepPatterns Should peptide pattern counts be computed?
#' @param Patterns A vector of charaters for the peptide pattern search
#' @param SearchPatternsSixFrame Should the patterns be searched in all 6 frames?
#' @param AggregatePatterns Should the indidual patterns be aggregated into a single column?
#' @return A data.frame containing the different features as columns. Each row repesents a DNA-string
#' @examples
#' data(ReadData)
#' CreateFeaturesFromReads (Reads = ReadData)
#' @author Carlus Deneke
#' @export
CreateFeaturesFromReads <- function(Reads,
                                    NT_kmax = 4,
                                    SymmetricFeatures = T,
                                    Do.NTMotifs = F,
                                    NTMotifs = NULL,
                                    AllowedMismatches = 0,
                                    bothStrands = T,
                                    Do.SpacedWords = T,
                                    k.spaced = 4,
                                    l.spaced = 6,
                                    SingleSpacerPattern = 0,
                                    combineSpacerPatterns = T,
                                    Do.PeptideFeatures = T,
                                    Do.MonoPep = T,
                                    Do.DiPep = T,
                                    Do.AAprops = T,
                                    Do.AAindex = T,
                                    AAindex_Selection = NULL,
                                    Do.UCO = T,
                                    Do.PepPatterns = F,
                                    Patterns =NULL,
                                    SearchPatternsSixFrame = F,
                                    AllowedPeptideMismatches = 0,
                                    AggregatePatterns = F
) {

  require(seqinr, quietly = T)
  require(Biostrings, quietly = T)
  require(foreach, quietly = T)

  # select features
  # default:

  # -------------------
  # A. Nucleotide features:

  # 1. Nucleotide frequencies

  Features <- data.frame(do.call(cbind,foreach(k = 1:NT_kmax) %do% GetOligonucleotideFrequency(Reads, k = k, prob=T, symmetric = SymmetricFeatures) ) )

  # -----
  # 2. Motifs

  if(Do.NTMotifs ==  T & is.character(NTMotifs) ) {

    MotifCount <- data.frame(do.call(cbind,lapply(NTMotifs,function(pattern) vcountPattern(pattern = pattern,subject = Reads, fixed = T, max.mismatch=AllowedMismatches) ) ) )

    if(bothStrands == T) {

      require(seqinr)
      MotifCount_revcomp <- data.frame(do.call(cbind,lapply(NTMotifs,function(pattern) vcountPattern(pattern = c2s(rev(comp(s2c(pattern)))),subject = Reads, fixed = T, max.mismatch=AllowedMismatches) ) ) )

      MotifCount <- MotifCount+MotifCount_revcomp

      # Correct double counting of Majorana sequences
      Majoranas <- which(NTMotifs == sapply(NTMotifs, function(x) c2s(rev(comp(s2c(x))))) )
      MotifCount[,Majoranas] <- MotifCount[,Majoranas] / 2
    }

    colnames(MotifCount) <- paste("Motifs",NTMotifs,sep="_")
    Features <- cbind(Features,MotifCount)
  }

  # 3. Spaced-word counts
  if(Do.SpacedWords == T){
    SpacedWords.Counts <- Count.SpacedWords (Reads = Reads,k = k.spaced,l = l.spaced, SinglePattern = SingleSpacerPattern, combinePatterns = combineSpacerPatterns, symmetric = SymmetricFeatures )
    Features <- cbind(Features,SpacedWords.Counts)
  }


  # -----
  # B: Protein features

  if(Do.PeptideFeatures == T){

    # 0. Find best translation (aka with fewest stop codons)
    BestTranslation <- suppressWarnings(GetBestTranslatedSequence(Reads) )
    #  if(length(BestTranslation) !=4) stop("BestTranslation has wrong length") else print("BestTranslation is valid")

    # 1. Peptide frequency
    if(Do.MonoPep) {
    AAfreq <- GetMonoPeptideFrequency(BestTranslation$BestSeq, prob=T)
    Features <- cbind(Features,AAfreq)
    }

    # 1b) Dipeptide
    if(Do.DiPep) {
      DiPeptides <- GetDiPeptideFrequency (BestTranslation$BestSeq,prob=T)
      Features <- cbind(Features,DiPeptides)
    }

    # ----
    # 2. Protein Properties
    if(Do.AAprops) {
      AA_Props <- AA_PhysChemProps(AAfreq)
      Features <- cbind(Features,AA_Props)
    }

    # ------
    # 3. AAindex
    if(Do.AAindex){
      AAindexStats <- GetAAindexStats(AAfreq,AAindex_Selection = AAindex_Selection)
      Features <- cbind(Features,AAindexStats)
    }

    # -----
    # 4. UCO
    if(Do.UCO){
      Reads_Seq <- lapply(Reads,function(x) s2c(as.character(x) ) )
      Codon_freqs <- BestUco (Reads_Seq,Frame=BestTranslation$Frame,Strand=BestTranslation$Strand)
      Features <- cbind(Features,Codon_freqs)
    }

    # -------
    # 5. Prosite or custom peptide patterns

    if(Do.PepPatterns){

      if(is.null(Patterns)) {
        data(prosite_Top20)
        Patterns <- prosite_Top20
      }

      if(SearchPatternsSixFrame == T) {
        PepPatterns <- suppressWarnings(FindPatternsIn6frames(Reads, Patterns, AllowedMismatches = AllowedPeptideMismatches) )
      } else {
        PepPatterns <- FindPatternsInAAseq(BestTranslation$BestSeq, Patterns, AllowedMismatches = AllowedPeptideMismatches, aggregate = AggregatePatterns)
      }

      Features <- cbind(Features, PepPatterns)
    }

  } # end do peptide features

  # Return

  GroupNames <- unique(sapply(colnames(Features),function(x) strsplit(x,split="_")[[1]][1]))
  attr(Features, "FeatureGroups") <- GroupNames

  return(Features)

}

