% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/FindPatternsIn6frames.R
\name{FindPatternsIn6frames}
\alias{FindPatternsIn6frames}
\title{Find patterns in all 6-frame translations of a read}
\usage{
FindPatternsIn6frames(Reads_Seq, Patterns, Prefix = "AAPattern")
}
\arguments{
\item{Reads_Seq}{DNAStringObject}

\item{Patterns}{Vector of patterns}

\item{Prefix}{How should the columns of pattern matches be called}
}
\value{
A data.frame containing the matched patterns (columns)
}
\description{
For a list of read sequences, translate into all 6-frames and search for patterns in each frame
}
\details{
The matches in the individual frames are combined
}
\author{
Carlus Deneke
}
