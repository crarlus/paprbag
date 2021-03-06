% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/BestUco.R
\name{BestUco}
\alias{BestUco}
\title{Estimate the Codon usage from a sequence}
\usage{
BestUco(Seq, Frame, Strand)
}
\arguments{
\item{Seq}{A DNAStringSet object}

\item{Frame}{Translation frame (0,1,2) of the putative peptide sequence}

\item{Strand}{Strand ('r' = reverse strand, 'f' =  forward strand)}
}
\value{
Returns a data.frame of the codon usage, i.e. the relative frequency of each codon (columns), for each sequence (rows)
}
\description{
Obtain the Codon Usage from the estimated Best Frame
}
\seealso{
\code{\link{seqinr::uco}}
}
\author{
Carlus Deneke
}
