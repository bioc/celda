#' @title Cell and feature clustering with Celda
#' @description Clusters the rows and columns of a count matrix containing
#'  single-cell data into L modules and K subpopulations, respectively. The
#'  \code{useAssay} \link{assay} slot in
#'  \code{altExpName} \link{altExp} slot will be used if
#'  it exists. Otherwise, the \code{useAssay}
#'  \link{assay} slot in \code{x} will be used if
#'  \code{x} is a \linkS4class{SingleCellExperiment} object.
#' @param x A \linkS4class{SingleCellExperiment}
#'  with the matrix located in the assay slot under \code{useAssay}.
#'  Rows represent features and columns represent cells. Alternatively,
#'  any matrix-like object that can be coerced to a sparse matrix of class
#'  "dgCMatrix" can be directly used as input. The matrix will automatically be
#'  converted to a \linkS4class{SingleCellExperiment} object.
#' @param useAssay A string specifying the name of the
#'  \link{assay} slot to use. Default "counts".
#' @param altExpName The name for the \link{altExp} slot
#'  to use. Default "featureSubset".
#' @param sampleLabel Vector or factor. Denotes the sample label for each cell
#'  (column) in the count matrix.
#' @param K Integer. Number of cell populations.
#' @param L Integer. Number of feature modules.
#' @param alpha Numeric. Concentration parameter for Theta. Adds a pseudocount
#'  to each cell population in each sample. Default 1.
#' @param beta Numeric. Concentration parameter for Phi. Adds a pseudocount to
#'  each feature module in each cell population. Default 1.
#' @param delta Numeric. Concentration parameter for Psi. Adds a pseudocount to
#'  each feature in each module. Default 1.
#' @param gamma Numeric. Concentration parameter for Eta. Adds a pseudocount to
#'  the number of features in each module. Default 1.
#' @param algorithm String. Algorithm to use for clustering cell subpopulations.
#'  One of 'EM' or 'Gibbs'. The EM algorithm for cell clustering is faster,
#'  especially for larger numbers of cells. However, more chains may be required
#'  to ensure a good solution is found. Default 'EM'.
#' @param stopIter Integer. Number of iterations without improvement in the log
#'  likelihood to stop inference. Default 10.
#' @param maxIter Integer. Maximum number of iterations of Gibbs sampling to
#'  perform. Default 200.
#' @param splitOnIter Integer. On every \code{splitOnIter} iteration,
#'  a heuristic
#'  will be applied to determine if a cell population or feature module should
#'  be reassigned and another cell population or feature module should be split
#'  into two clusters. To disable splitting, set to -1. Default 10.
#' @param splitOnLast Integer. After \code{stopIter} iterations have been
#'  performed without improvement, a heuristic will be applied to determine if
#'  a cell population or feature module should be reassigned and another cell
#'  population or feature module should be split into two clusters. If a split
#'  occurs, then 'stopIter' will be reset. Default TRUE.
#' @param seed Integer. Passed to \link[withr]{with_seed}. For reproducibility,
#'  a default value of 12345 is used. If NULL, no calls to
#'  \link[withr]{with_seed} are made.
#' @param nchains Integer. Number of random cluster initializations. Default 3.
#' @param zInitialize Chararacter. One of 'random', 'split', or 'predefined'.
#'  With 'random', cells are randomly assigned to a populations. With 'split',
#'  cells will be split into sqrt(K) populations and then each population will
#'  be subsequently split into another sqrt(K) populations. With 'predefined',
#'  values in \code{zInit} will be used to initialize \code{z}. Default 'split'.
#' @param yInitialize Character. One of 'random', 'split', or 'predefined'.
#'  With 'random', features are randomly assigned to a modules. With 'split',
#'  features will be split into sqrt(L) modules and then each module will be
#'  subsequently split into another sqrt(L) modules. With 'predefined', values
#'  in \code{yInit} will be used to initialize \code{y}. Default 'split'.
#' @param zInit Integer vector. Sets initial starting values of z. 'zInit'
#'  is only used when `zInitialize = 'predfined'`. Default NULL.
#' @param yInit Integer vector. Sets initial starting values of y.
#'  'yInit' is only be used when `yInitialize = "predefined"`. Default NULL.
#' @param countChecksum Character. An MD5 checksum for the counts matrix.
#'  Default NULL.
#' @param logfile Character. Messages will be redirected to a file named
#'  `logfile`. If NULL, messages will be printed to stdout.  Default NULL.
#' @param verbose Logical. Whether to print log messages. Default TRUE.
#' @return A \linkS4class{SingleCellExperiment} object. Function
#'  parameter settings are stored in \link{metadata}
#'  \code{"celda_parameters"} in \link{altExp} slot.
#'  In \link{altExp} slot,
#'  columns \code{celda_sample_label} and \code{celda_cell_cluster} in
#'  \link{colData} contain sample labels and celda cell
#'  population clusters. Column \code{celda_feature_module} in
#'  \link{rowData} contains feature modules.
#' @seealso \link{celda_G} for feature clustering and \link{celda_C} for
#'  clustering cells. \link{celdaGridSearch} can be used to run multiple
#'  values of K/L and multiple chains in parallel.
#' @import Rcpp RcppEigen
#' @export
setGeneric("celda_CG",
    function(x,
        useAssay = "counts",
        altExpName = "featureSubset",
        sampleLabel = NULL,
        K,
        L,
        alpha = 1,
        beta = 1,
        delta = 1,
        gamma = 1,
        algorithm = c("EM", "Gibbs"),
        stopIter = 10,
        maxIter = 200,
        splitOnIter = 10,
        splitOnLast = TRUE,
        seed = 12345,
        nchains = 3,
        zInitialize = c("split", "random", "predefined"),
        yInitialize = c("split", "random", "predefined"),
        countChecksum = NULL,
        zInit = NULL,
        yInit = NULL,
        logfile = NULL,
        verbose = TRUE) {
    standardGeneric("celda_CG")})


#' @rdname celda_CG
#' @export
setMethod("celda_CG",
    signature(x = "SingleCellExperiment"),
    function(x,
        useAssay = "counts",
        altExpName = "featureSubset",
        sampleLabel = NULL,
        K,
        L,
        alpha = 1,
        beta = 1,
        delta = 1,
        gamma = 1,
        algorithm = c("EM", "Gibbs"),
        stopIter = 10,
        maxIter = 200,
        splitOnIter = 10,
        splitOnLast = TRUE,
        seed = 12345,
        nchains = 3,
        zInitialize = c("split", "random", "predefined"),
        yInitialize = c("split", "random", "predefined"),
        countChecksum = NULL,
        zInit = NULL,
        yInit = NULL,
        logfile = NULL,
        verbose = TRUE) {

        xClass <- "SingleCellExperiment"

        if (!altExpName %in% SingleCellExperiment::altExpNames(x)) {
            stop(altExpName, " not in 'altExpNames(x)'. Run ",
                "selectFeatures(x) first!")
        }

        altExp <- SingleCellExperiment::altExp(x, altExpName)

        if (!useAssay %in% SummarizedExperiment::assayNames(altExp)) {
            stop(useAssay, " not in assayNames(altExp(x, altExpName))")
        }

        counts <- SummarizedExperiment::assay(altExp, i = useAssay)

        altExp <- .celdaCGWithSeed(counts = counts,
            xClass = xClass,
            useAssay = useAssay,
            sce = altExp,
            sampleLabel = sampleLabel,
            K = K,
            L = L,
            alpha = alpha,
            beta = beta,
            delta = delta,
            gamma = gamma,
            algorithm = match.arg(algorithm),
            stopIter = stopIter,
            maxIter = maxIter,
            splitOnIter = splitOnIter,
            splitOnLast = splitOnLast,
            seed = seed,
            nchains = nchains,
            zInitialize = match.arg(zInitialize),
            yInitialize = match.arg(yInitialize),
            countChecksum = countChecksum,
            zInit = zInit,
            yInit = yInit,
            logfile = logfile,
            verbose = verbose)
        SingleCellExperiment::altExp(x, altExpName) <- altExp
        return(x)
    }
)


#' @rdname celda_CG
#' @examples
#' data(celdaCGSim)
#' sce <- celda_CG(celdaCGSim$counts,
#'     K = celdaCGSim$K,
#'     L = celdaCGSim$L,
#'     sampleLabel = celdaCGSim$sampleLabel,
#'     nchains = 1)
#' @export
setMethod("celda_CG",
    signature(x = "ANY"),
    function(x,
        useAssay = "counts",
        altExpName = "featureSubset",
        sampleLabel = NULL,
        K,
        L,
        alpha = 1,
        beta = 1,
        delta = 1,
        gamma = 1,
        algorithm = c("EM", "Gibbs"),
        stopIter = 10,
        maxIter = 200,
        splitOnIter = 10,
        splitOnLast = TRUE,
        seed = 12345,
        nchains = 3,
        zInitialize = c("split", "random", "predefined"),
        yInitialize = c("split", "random", "predefined"),
        countChecksum = NULL,
        zInit = NULL,
        yInit = NULL,
        logfile = NULL,
        verbose = TRUE) {

        # Convert to sparse matrix
        x <- methods::as(x, "CsparseMatrix")

        ls <- list()
        ls[[useAssay]] <- x
        sce <- SingleCellExperiment::SingleCellExperiment(assays = ls)
        SingleCellExperiment::altExp(sce, altExpName) <- sce
        xClass <- "matrix"

        altExp <- .celdaCGWithSeed(counts = x,
            xClass = xClass,
            useAssay = useAssay,
            sce = SingleCellExperiment::altExp(sce, altExpName),
            sampleLabel = sampleLabel,
            K = K,
            L = L,
            alpha = alpha,
            beta = beta,
            delta = delta,
            gamma = gamma,
            algorithm = match.arg(algorithm),
            stopIter = stopIter,
            maxIter = maxIter,
            splitOnIter = splitOnIter,
            splitOnLast = splitOnLast,
            seed = seed,
            nchains = nchains,
            zInitialize = match.arg(zInitialize),
            yInitialize = match.arg(yInitialize),
            countChecksum = countChecksum,
            zInit = zInit,
            yInit = yInit,
            logfile = logfile,
            verbose = verbose)
        SingleCellExperiment::altExp(sce, altExpName) <- altExp
        return(sce)
    }
)


.celdaCGWithSeed <- function(counts,
    xClass,
    useAssay,
    sce,
    sampleLabel,
    K,
    L,
    alpha,
    beta,
    delta,
    gamma,
    algorithm,
    stopIter,
    maxIter,
    splitOnIter,
    splitOnLast,
    seed,
    nchains,
    zInitialize,
    yInitialize,
    countChecksum,
    zInit,
    yInit,
    logfile,
    verbose) {

    .validateCounts(counts)

    if (is.null(seed)) {
        celdaCGMod <- .celda_CG(
            counts = counts,
            sampleLabel = sampleLabel,
            K = K,
            L = L,
            alpha = alpha,
            beta = beta,
            delta = delta,
            gamma = gamma,
            algorithm = algorithm,
            stopIter = stopIter,
            maxIter = maxIter,
            splitOnIter = splitOnIter,
            splitOnLast = splitOnLast,
            nchains = nchains,
            zInitialize = zInitialize,
            yInitialize = yInitialize,
            countChecksum = countChecksum,
            zInit = zInit,
            yInit = yInit,
            logfile = logfile,
            verbose = verbose,
            reorder = TRUE
        )
    } else {
        with_seed(
            seed,
            celdaCGMod <- .celda_CG(
                counts = counts,
                sampleLabel = sampleLabel,
                K = K,
                L = L,
                alpha = alpha,
                beta = beta,
                delta = delta,
                gamma = gamma,
                algorithm = algorithm,
                stopIter = stopIter,
                maxIter = maxIter,
                splitOnIter = splitOnIter,
                splitOnLast = splitOnLast,
                nchains = nchains,
                zInitialize = zInitialize,
                yInitialize = yInitialize,
                countChecksum = countChecksum,
                zInit = zInit,
                yInit = yInit,
                logfile = logfile,
                verbose = verbose,
                reorder = TRUE
            )
        )
    }

    sce <- .createSCEceldaCG(celdaCGMod = celdaCGMod,
        sce = sce,
        xClass = xClass,
        useAssay = useAssay,
        algorithm = algorithm,
        stopIter = stopIter,
        maxIter = maxIter,
        splitOnIter = splitOnIter,
        splitOnLast = splitOnLast,
        nchains = nchains,
        zInitialize = zInitialize,
        yInitialize = yInitialize,
        zInit = zInit,
        yInit = yInit,
        logfile = logfile,
        verbose = verbose)
    return(sce)
}


.celda_CG <- function(counts,
                      sampleLabel = NULL,
                      K,
                      L,
                      alpha = 1,
                      beta = 1,
                      delta = 1,
                      gamma = 1,
                      algorithm = c("EM", "Gibbs"),
                      stopIter = 10,
                      maxIter = 200,
                      splitOnIter = 10,
                      splitOnLast = TRUE,
                      nchains = 3,
                      zInitialize = c("split", "random", "predefined"),
                      yInitialize = c("split", "random", "predefined"),
                      countChecksum = NULL,
                      zInit = NULL,
                      yInit = NULL,
                      logfile = NULL,
                      verbose = TRUE,
                      reorder = TRUE) {
  .logMessages(paste(rep("-", 50), collapse = ""),
    logfile = logfile,
    append = FALSE,
    verbose = verbose
  )

  .logMessages("Starting Celda_CG: Clustering cells and genes.",
    logfile = logfile,
    append = TRUE,
    verbose = verbose
  )

  .logMessages(paste(rep("-", 50), collapse = ""),
    logfile = logfile,
    append = TRUE,
    verbose = verbose
  )

  startTime <- Sys.time()

  counts <- .processCounts(counts)
  if (is.null(countChecksum)) {
    countChecksum <- .createCountChecksum(counts)
  }

  sampleLabel <- .processSampleLabels(sampleLabel, ncol(counts))
  s <- as.integer(sampleLabel)

  algorithm <- match.arg(algorithm)
  algorithmFun <- ifelse(algorithm == "Gibbs",
    ".cCCalcGibbsProbZ",
    ".cCCalcEMProbZ"
  )
  zInitialize <- match.arg(zInitialize)
  yInitialize <- match.arg(yInitialize)

  allChains <- seq(nchains)

  # Pre-compute lgamma values
  lggamma <- lgamma(seq(0, nrow(counts) + L) + gamma)
  lgdelta <- c(NA, lgamma((seq(nrow(counts) + L) * delta)))

  bestResult <- NULL
  for (i in allChains) {
    ## Initialize cluster labels
    .logMessages(date(),
      ".. Initializing 'z' in chain",
      i,
      "with",
      paste0("'", zInitialize, "' "),
      logfile = logfile,
      append = TRUE,
      verbose = verbose
    )

    .logMessages(date(),
      ".. Initializing 'y' in chain",
      i,
      "with",
      paste0("'", yInitialize, "' "),
      logfile = logfile,
      append = TRUE,
      verbose = verbose
    )

    if (zInitialize == "predefined") {
      if (is.null(zInit)) {
        stop("'zInit' needs to specified when initilize.z == 'given'.")
      }
      z <- .initializeCluster(K,
        ncol(counts),
        initial = zInit,
        fixed = NULL
      )
    } else if (zInitialize == "split") {
      z <- .initializeSplitZ(
        counts,
        K = K,
        alpha = alpha,
        beta = beta
      )
    } else {
      z <- .initializeCluster(K,
        ncol(counts),
        initial = NULL,
        fixed = NULL
      )
    }

    if (yInitialize == "predefined") {
      if (is.null(yInit)) {
        stop("'yInit' needs to specified when initilize.y == 'given'.")
      }
      y <- .initializeCluster(L,
        nrow(counts),
        initial = yInit,
        fixed = NULL
      )
    } else if (yInitialize == "split") {
      y <- .initializeSplitY(counts,
        L,
        beta = beta,
        delta = delta,
        gamma = gamma
      )
    } else {
      y <- .initializeCluster(L,
        nrow(counts),
        initial = NULL,
        fixed = NULL
      )
    }

    zBest <- z
    yBest <- y

    ## Calculate counts one time up front
    p <- .cCGDecomposeCounts(counts, s, z, y, K, L)
    mCPByS <- p$mCPByS
    nTSByC <- p$nTSByC
    nTSByCP <- p$nTSByCP
    nCP <- p$nCP
    nByG <- p$nByG
    nByC <- p$nByC
    nByTS <- p$nByTS
    nGByTS <- p$nGByTS
    nGByCP <- p$nGByCP
    nM <- p$nM
    nG <- p$nG
    nS <- p$nS
    rm(p)

    ll <- .cCGCalcLL(
      K = K,
      L = L,
      mCPByS = mCPByS,
      nTSByCP = nTSByCP,
      nByG = nByG,
      nByTS = nByTS,
      nGByTS = nGByTS,
      nS = nS,
      nG = nG,
      alpha = alpha,
      beta = beta,
      delta = delta,
      gamma = gamma
    )

    iter <- 1L
    numIterWithoutImprovement <- 0L
    doCellSplit <- TRUE
    doGeneSplit <- TRUE
    while (iter <= maxIter & numIterWithoutImprovement <= stopIter) {
      ## Gibbs sampling for each gene
      lgbeta <- lgamma(seq(0, max(nCP)) + beta)
      nextY <- .cGCalcGibbsProbY(
        counts = nGByCP,
        nTSByC = nTSByCP,
        nByTS = nByTS,
        nGByTS = nGByTS,
        nByG = nByG,
        y = y,
        L = L,
        nG = nG,
        beta = beta,
        delta = delta,
        gamma = gamma,
        lgbeta = lgbeta,
        lggamma = lggamma,
        lgdelta = lgdelta
      )
      nTSByCP <- nextY$nTSByC
      nGByTS <- nextY$nGByTS
      nByTS <- nextY$nByTS
      nTSByC <- .rowSumByGroupChange(counts, nTSByC, nextY$y, y, L)
      y <- nextY$y

      ## Gibbs or EM sampling for each cell
      nextZ <- do.call(algorithmFun, list(
        counts = nTSByC,
        mCPByS = mCPByS,
        nGByCP = nTSByCP,
        nCP = nCP,
        nByC = nByC,
        z = z,
        s = s,
        K = K,
        nG = L,
        nM = nM,
        alpha = alpha,
        beta = beta
      ))
      mCPByS <- nextZ$mCPByS
      nTSByCP <- nextZ$nGByCP
      nCP <- nextZ$nCP
      nGByCP <- .colSumByGroupChange(counts, nGByCP, nextZ$z, z, K)
      z <- nextZ$z

      ## Perform split on i-th iteration defined by splitOnIter
      tempLl <- .cCGCalcLL(
        K = K,
        L = L,
        mCPByS = mCPByS,
        nTSByCP = nTSByCP,
        nByG = nByG,
        nByTS = nByTS,
        nGByTS = nGByTS,
        nS = nS,
        nG = nG,
        alpha = alpha,
        beta = beta,
        delta = delta,
        gamma = gamma
      )

      if (L > 2 & iter != maxIter &
        (((numIterWithoutImprovement == stopIter &
          !all(tempLl >= ll)) & isTRUE(splitOnLast)) |
          (splitOnIter > 0 & iter %% splitOnIter == 0 &
            isTRUE(doGeneSplit)))) {
        .logMessages(date(),
          " .... Determining if any gene clusters should be split.",
          logfile = logfile,
          append = TRUE,
          sep = "",
          verbose = verbose
        )
        res <- .cCGSplitY(counts,
          y,
          mCPByS,
          nGByCP,
          nTSByC,
          nTSByCP,
          nByG,
          nByTS,
          nGByTS,
          nCP,
          s,
          z,
          K,
          L,
          nS,
          nG,
          alpha,
          beta,
          delta,
          gamma,
          yProb = t(nextY$probs),
          maxClustersToTry = max(L / 2, 10),
          minCell = 3
        )
        .logMessages(res$message,
          logfile = logfile,
          append = TRUE,
          verbose = verbose
        )

        # Reset convergence counter if a split occured
        if (!isTRUE(all.equal(y, res$y))) {
          numIterWithoutImprovement <- 1L
          doGeneSplit <- TRUE
        } else {
          doGeneSplit <- FALSE
        }

        ## Re-calculate variables
        y <- res$y
        nTSByCP <- res$nTSByCP
        nByTS <- res$nByTS
        nGByTS <- res$nGByTS
        nTSByC <- .rowSumByGroup(counts, group = y, L = L)
      }

      if (K > 2 & iter != maxIter &
        (((numIterWithoutImprovement == stopIter &
          !all(tempLl > ll)) & isTRUE(splitOnLast)) |
          (splitOnIter > 0 & iter %% splitOnIter == 0 &
            isTRUE(doCellSplit)))) {
        .logMessages(date(),
          " .... Determining if any cell clusters should be split.",
          logfile = logfile,
          append = TRUE,
          sep = "",
          verbose = verbose
        )
        res <- .cCGSplitZ(counts,
          mCPByS,
          nTSByC,
          nTSByCP,
          nByG,
          nByTS,
          nGByTS,
          nCP,
          s,
          z,
          K,
          L,
          nS,
          nG,
          alpha,
          beta,
          delta,
          gamma,
          zProb = t(nextZ$probs),
          maxClustersToTry = K,
          minCell = 3
        )
        .logMessages(res$message,
          logfile = logfile,
          append = TRUE,
          verbose = verbose
        )

        # Reset convergence counter if a split occured
        if (!isTRUE(all.equal(z, res$z))) {
          numIterWithoutImprovement <- 0L
          doCellSplit <- TRUE
        } else {
          doCellSplit <- FALSE
        }

        ## Re-calculate variables
        z <- res$z
        mCPByS <- res$mCPByS
        nTSByCP <- res$nTSByCP
        nCP <- res$nCP
        nGByCP <- .colSumByGroup(counts, group = z, K = K)
      }

      ## Calculate complete likelihood
      tempLl <- .cCGCalcLL(
        K = K,
        L = L,
        mCPByS = mCPByS,
        nTSByCP = nTSByCP,
        nByG = nByG,
        nByTS = nByTS,
        nGByTS = nGByTS,
        nS = nS,
        nG = nG,
        alpha = alpha,
        beta = beta,
        delta = delta,
        gamma = gamma
      )
      if ((all(tempLl > ll)) | iter == 1) {
        zBest <- z
        yBest <- y
        llBest <- tempLl
        numIterWithoutImprovement <- 1L
      } else {
        numIterWithoutImprovement <- numIterWithoutImprovement + 1L
      }
      ll <- c(ll, tempLl)

      .logMessages(date(),
        " .... Completed iteration: ",
        iter,
        " | logLik: ",
        tempLl,
        logfile = logfile,
        append = TRUE,
        sep = "",
        verbose = verbose
      )
      iter <- iter + 1L
    }

    names <- list(
      row = rownames(counts),
      column = colnames(counts),
      sample = levels(sampleLabel)
    )

    result <- list(
      z = zBest,
      y = yBest,
      completeLogLik = ll,
      finalLogLik = llBest,
      K = K,
      L = L,
      alpha = alpha,
      beta = beta,
      delta = delta,
      gamma = gamma,
      sampleLabel = sampleLabel,
      names = names,
      countChecksum = countChecksum
    )

    class(result) <- "celda_CG"

    if (is.null(bestResult) ||
      result$finalLogLik > bestResult$finalLogLik) {
      bestResult <- result
    }

    .logMessages(date(),
      ".. Finished chain",
      i,
      logfile = logfile,
      append = TRUE,
      verbose = verbose
    )
  }

  ## Peform reordering on final Z and Y assigments:
  bestResult <- methods::new("celda_CG",
    clusters = list(z = zBest, y = yBest),
    params = list(
      K = as.integer(K),
      L = as.integer(L),
      alpha = alpha,
      beta = beta,
      delta = delta,
      gamma = gamma,
      countChecksum = countChecksum
    ),
    completeLogLik = ll,
    finalLogLik = llBest,
    sampleLabel = sampleLabel,
    names = names
  )
  if (isTRUE(reorder)) {
    bestResult <- .reorderCeldaCG(counts = counts, res = bestResult)
  }

  endTime <- Sys.time()
  .logMessages(paste(rep("-", 50), collapse = ""),
    logfile = logfile,
    append = TRUE,
    verbose = verbose
  )
  .logMessages("Completed Celda_CG. Total time:",
    format(difftime(endTime, startTime)),
    logfile = logfile,
    append = TRUE,
    verbose = verbose
  )
  .logMessages(paste(rep("-", 50), collapse = ""),
    logfile = logfile,
    append = TRUE,
    verbose = verbose
  )

  return(bestResult)
}


# Calculate the loglikelihood for the celda_CG model
.cCGCalcLL <- function(K,
                       L,
                       mCPByS,
                       nTSByCP,
                       nByG,
                       nByTS,
                       nGByTS,
                       nS,
                       nG,
                       alpha,
                       beta,
                       delta,
                       gamma) {
  nG <- sum(nGByTS)

  ## Calculate for "Theta" component
  a <- nS * lgamma(K * alpha)
  b <- sum(lgamma(mCPByS + alpha))
  c <- -nS * K * lgamma(alpha)
  d <- -sum(lgamma(colSums(mCPByS + alpha)))

  thetaLl <- a + b + c + d

  ## Calculate for "Phi" component
  a <- K * lgamma(L * beta)
  b <- sum(lgamma(nTSByCP + beta))
  c <- -K * L * lgamma(beta)
  d <- -sum(lgamma(colSums(nTSByCP + beta)))

  phiLl <- a + b + c + d

  ## Calculate for "Psi" component
  a <- sum(lgamma(nGByTS * delta))
  b <- sum(lgamma(nByG + delta))
  c <- -nG * lgamma(delta)
  d <- -sum(lgamma(nByTS + (nGByTS * delta)))

  psiLl <- a + b + c + d

  ## Calculate for "Eta" side
  a <- lgamma(L * gamma)
  b <- sum(lgamma(nGByTS + gamma))
  c <- -L * lgamma(gamma)
  d <- -lgamma(sum(nGByTS + gamma))

  etaLl <- a + b + c + d

  final <- thetaLl + phiLl + psiLl + etaLl
  return(final)
}


# Takes raw counts matrix and converts it to a series of matrices needed for
# log likelihood calculation
# @param counts Integer matrix. Rows represent features and columns represent
# cells.
# @param s Integer vector. Contains the sample label for each cell (column) in
# the count matrix.
# @param z Numeric vector. Denotes cell population labels.
# @param y Numeric vector. Denotes feature module labels.
# @param K Integer. Number of cell populations.
# @param L Integer. Number of feature modules.
#' @importFrom Matrix colSums rowSums
.cCGDecomposeCounts <- function(counts, s, z, y, K, L) {
  nS <- length(unique(s))
  mCPByS <- matrix(as.integer(table(factor(z, levels = seq(K)), s)),
    ncol = nS
  )

  nTSByC <- .rowSumByGroup(counts, group = y, L = L)
  nGByCP <- .colSumByGroup(counts, group = z, K = K)
  nTSByCP <- .colSumByGroup(nTSByC, group = z, K = K)

  nByC <- colSums(counts)
  nByG <- rowSums(counts)
  nByTS <- .rowSumByGroup(matrix(nByG, ncol = 1), group = y, L = L)
  nCP <- .colSums(nTSByCP, nrow(nTSByCP), ncol(nTSByCP))
  nGByTS <- tabulate(y, L) + 1 ## Add pseudogene to each module
  nG <- nrow(counts)
  nM <- ncol(counts)

  return(list(
    mCPByS = mCPByS,
    nTSByC = nTSByC,
    nTSByCP = nTSByCP,
    nCP = nCP,
    nByG = nByG,
    nByC = nByC,
    nByTS = nByTS,
    nGByTS = nGByTS,
    nGByCP = nGByCP,
    nM = nM,
    nG = nG,
    nS = nS
  ))
}


.prepareCountsForDimReductionCeldaCG <- function(sce,
    useAssay,
    maxCells,
    minClusterSize,
    modules,
    normalize,
    scaleFactor,
    transformationFun) {

    counts <- SummarizedExperiment::assay(sce, i = useAssay)
    counts <- .processCounts(counts)

    K <- S4Vectors::metadata(sce)$celda_parameters$K
    z <- as.integer(SummarizedExperiment::colData(sce)$celda_cell_cluster)
    y <- as.integer(SummarizedExperiment::rowData(sce)$celda_feature_module)
    L <- S4Vectors::metadata(sce)$celda_parameters$L
    alpha <- S4Vectors::metadata(sce)$celda_parameters$alpha
    beta <- S4Vectors::metadata(sce)$celda_parameters$beta

    delta <- S4Vectors::metadata(sce)$celda_parameters$delta
    gamma <- S4Vectors::metadata(sce)$celda_parameters$gamma
    sampleLabel <-
        SummarizedExperiment::colData(sce)$celda_sample_label
    cNames <- colnames(sce)
    rNames <- rownames(sce)
    sNames <- S4Vectors::metadata(sce)$celda_parameters$sampleLevels

    ## Checking if maxCells and minClusterSize will work
    if (!is.null(maxCells)) {
        if ((maxCells < ncol(counts)) &
                (maxCells / minClusterSize < K)) {
            stop("Cannot distribute ",
                maxCells,
                " cells among ",
                K,
                " clusters while maintaining a minumum of ",
                minClusterSize,
                " cells per cluster. Try increasing 'maxCells' or",
                " decreasing 'minClusterSize'.")
        }
    } else {
        maxCells <- ncol(counts)
    }

    fm <- .factorizeMatrixCG(
        counts = counts,
        K = K,
        z = z,
        y = y,
        L = L,
        alpha = alpha,
        beta = beta,
        delta = delta,
        gamma = gamma,
        sampleLabel = sampleLabel,
        cNames = cNames,
        rNames = rNames,
        sNames = sNames,
        type = "counts")
    modulesToUse <- seq(nrow(fm$counts$cell))
    if (!is.null(modules)) {
        if (!all(modules %in% modulesToUse)) {
            stop("'modules' must be a vector of numbers between 1 and ",
                modulesToUse,
                ".")
        }
        modulesToUse <- modules
    }

    ## Select a subset of cells to sample if greater than 'maxCells'
    totalCellsToRemove <- ncol(counts) - maxCells
    zInclude <- rep(TRUE, ncol(counts))

    if (totalCellsToRemove > 0) {
        zTa <- tabulate(z, K)

        ## Number of cells that can be sampled from each cluster without
        ## going below the minimum threshold
        clusterCellsToSample <- zTa - minClusterSize
        clusterCellsToSample[clusterCellsToSample < 0] <- 0

        ## Number of cells to sample after exluding smaller clusters
        ## Rounding can cause number to be off by a few, so ceiling is used
        ## with a second round of subtraction
        clusterNToSample <- ceiling((clusterCellsToSample /
                sum(clusterCellsToSample)) * totalCellsToRemove)
        diff <- sum(clusterNToSample) - totalCellsToRemove
        clusterNToSample[which.max(clusterNToSample)] <-
            clusterNToSample[which.max(clusterNToSample)] - diff

        ## Perform sampling for each cluster
        for (i in which(clusterNToSample > 0)) {
            zInclude[sample(which(z == i), clusterNToSample[i])] <- FALSE
        }
    }
    cellIx <- which(zInclude)

    norm <- t(normalizeCounts(fm$counts$cell[modulesToUse, cellIx],
        normalize = normalize,
        scaleFactor = scaleFactor,
        transformationFun = transformationFun))
    return(list(norm = norm, cellIx = cellIx))
}


.createSCEceldaCG <- function(celdaCGMod,
    sce,
    xClass,
    useAssay,
    algorithm,
    stopIter,
    maxIter,
    splitOnIter,
    splitOnLast,
    nchains,
    zInitialize,
    yInitialize,
    zInit,
    yInit,
    logfile,
    verbose) {

    # add metadata
    S4Vectors::metadata(sce)[["celda_parameters"]] <- list(
        model = "celda_CG",
        xClass = xClass,
        useAssay = useAssay,
        sampleLevels = celdaCGMod@names$sample,
        K = celdaCGMod@params$K,
        L = celdaCGMod@params$L,
        alpha = celdaCGMod@params$alpha,
        beta = celdaCGMod@params$beta,
        delta = celdaCGMod@params$delta,
        gamma = celdaCGMod@params$gamma,
        algorithm = algorithm,
        stopIter = stopIter,
        maxIter = maxIter,
        splitOnIter = splitOnIter,
        splitOnLast = splitOnLast,
        seed = celdaCGMod@params$seed,
        nchains = nchains,
        zInitialize = zInitialize,
        yInitialize = yInitialize,
        countChecksum = celdaCGMod@params$countChecksum,
        zInit = zInit,
        yInit = yInit,
        logfile = logfile,
        verbose = verbose,
        completeLogLik = celdaCGMod@completeLogLik,
        finalLogLik = celdaCGMod@finalLogLik,
        cellClusterLevels = sort(unique(celdaClusters(celdaCGMod)$z)),
        featureModuleLevels = sort(unique(celdaClusters(celdaCGMod)$y)))

    SummarizedExperiment::rowData(sce)["rownames"] <- celdaCGMod@names$row
    SummarizedExperiment::colData(sce)["colnames"] <-
        celdaCGMod@names$column
    SummarizedExperiment::colData(sce)["celda_sample_label"] <-
        as.factor(celdaCGMod@sampleLabel)
    SummarizedExperiment::colData(sce)["celda_cell_cluster"] <-
        as.factor(celdaClusters(celdaCGMod)$z)
    SummarizedExperiment::rowData(sce)["celda_feature_module"] <-
        as.factor(celdaClusters(celdaCGMod)$y)

    return(sce)
}
