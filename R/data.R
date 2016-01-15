# Documentation of data sets

#' @name AAindexData
#' @title List of 544 physicochemical and biological properties for the 20 amino-acids
#' @description
#' Data were imported from seqinr package.  Refer to the aaindex in seqinr for more details. See the reference section to cite this database in a publication.
#'
#' @format A data.frame with 544 rows and 26 columns
#' Each row represents a property
#' Columns 1 to 6 give information about the property "AccNo"      "PropDesc"   "LITDBNo"    "Author"     "ArtTitle"   "JournalRef"
#' Columns 7 to 26 give the property's values for the 20 amino acids
#' @source http://www.genome.jp/aaindex
#'
#' @references
#'
#'From the original aaindex documentation:
#'  Please cite the following references when making use of the database:
#'
#'  Kawashima, S. and Kanehisa, M. (2000) AAindex: amino acid index database. Nucleic Acids Res., 28:374.
#'Tomii, K. and Kanehisa, M. (1996) Analysis of amino acid indices and mutation matrices for sequence comparison and structure prediction of proteins. Protein Eng., 9:27-36.
#'Nakai, K., Kidera, A., and Kanehisa, M. (1988) Cluster analysis of amino acid indices for prediction of protein structure and function. Protein Eng. 2:93-100.
"AAindexData"

#' Amino acid properties
#' list of amino acid with properties tiny, small, aliphatic, aromatic, non.polar, polar, charged, basic and acidic
#' @seealso seqinr package
"AAproperty"

#' Genomic Motifs
#' 100 most frequent 8-mers in bacterial genomes
"GenomicMotifs"

#' Prosite patterns
#' @details 20 frequent prosite motifs
#' @source http://prosite.expasy.org/prosite_ref.html
#' @references
#' Sigrist CJA, de Castro E, Cerutti L, Cuche BA, Hulo N, Bridge A, Bougueleret L, Xenarios I.
#' New and continuing developments at PROSITE
#' Nucleic Acids Res. 2012; doi: 10.1093/nar/gks1067
"prosite_Top20"

#' Example read data
#' @details 21 read sequences of length 125 in "DNAStringSet" format
"ReadData"


#' Standard configuration for feature extraction
#' @details
#' Choice of parameters:
#'NT_kmax = 4,
#'SymmetricFeatures = T,
#'Do.NTMotifs = T,
#'NTMotifs = NULL,
#'AllowedMismatches = 1,
#'Do.SpacedWords = T,
#'k.spaced = 4,
#'l.spaced = 6,
#'Do.PeptideFeatures = T,
#'Do.MonoPep = T,
#'Do.DiPep = T,
#'Do.AAprops = T,
#'Do.AAindex = T,
#'AAindex_Selection = NULL,
#'Do.UCO = T,
#'Do.PepPatterns = F,
#'Patterns = NULL,
#'SearchPatternsSixFrame = T,
#'AllowedPeptideMismatches = 0,
#'AggregatePatterns = F
"Standard.configuration"

#' Pathogenicity labels
#' @details
#' The set of labels for 4286 bacterial strains (181 non-pathogens and 2838 pathogens)
#' TRUE means pathogenic and FALSE means non-pathogenic
#' The species' bioproject accession is obtained by names(Labels)
#' @references
#' PaPrBag Paper
"Labels"
