% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/perplexity.R
\name{resamplePerplexity}
\alias{resamplePerplexity}
\alias{resamplePerplexity,SingleCellExperiment-method}
\alias{resamplePerplexity,ANY-method}
\title{Calculate and visualize perplexity of all models in a celdaList}
\usage{
resamplePerplexity(
  x,
  celdaList,
  useAssay = "counts",
  altExpName = "featureSubset",
  doResampling = FALSE,
  numResample = 5,
  seed = 12345
)

\S4method{resamplePerplexity}{SingleCellExperiment}(
  x,
  useAssay = "counts",
  altExpName = "featureSubset",
  doResampling = FALSE,
  numResample = 5,
  seed = 12345
)

\S4method{resamplePerplexity}{ANY}(
  x,
  celdaList,
  doResampling = FALSE,
  numResample = 5,
  seed = 12345
)
}
\arguments{
\item{x}{A numeric \link{matrix} of counts or a
\linkS4class{SingleCellExperiment} returned from \link{celdaGridSearch}
with the matrix located in the assay slot under \code{useAssay}.
Rows represent features and columns represent cells. Must contain
"celda_grid_search" slot in \code{metadata(x)} if \code{x} is a
\linkS4class{SingleCellExperiment} object.}

\item{celdaList}{Object of class 'celdaList'. Used only if \code{x} is a
matrix object.}

\item{useAssay}{A string specifying which \link{assay}
slot to use if \code{x} is a
\linkS4class{SingleCellExperiment} object. Default "counts".}

\item{altExpName}{The name for the \link{altExp} slot
to use. Default "featureSubset".}

\item{doResampling}{Boolean. If \code{TRUE}, then each cell in the counts
matrix will be resampled according to a multinomial distribution to introduce
noise before calculating perplexity. Default \code{FALSE}.}

\item{numResample}{Integer. The number of times to resample the counts matrix
for evaluating perplexity if \code{doResampling} is set to \code{TRUE}.
Default \code{5}.}

\item{seed}{Integer. Passed to \link[withr]{with_seed}. For reproducibility,
a default value of \code{12345} is used. If \code{NULL}, no calls to
\link[withr]{with_seed} are made.}
}
\value{
A \linkS4class{SingleCellExperiment} object or
 \code{celdaList} object with a \code{perplexity}
 property, detailing the perplexity of all K/L combinations that appeared in
 the celdaList's models.
}
\description{
Calculates the perplexity of each model's cluster assignments
 given the provided countMatrix, as well as resamplings of that count
 matrix, providing a distribution of perplexities and a better sense of the
 quality of a given K/L choice.
}
\examples{
data(sceCeldaCGGridSearch)
sce <- resamplePerplexity(sceCeldaCGGridSearch)
plotGridSearchPerplexity(sce)
data(celdaCGSim, celdaCGGridSearchRes)
celdaCGGridSearchRes <- resamplePerplexity(
  celdaCGSim$counts,
  celdaCGGridSearchRes
)
plotGridSearchPerplexity(celdaCGGridSearchRes)
}
