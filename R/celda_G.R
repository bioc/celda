#' @title Feature clustering with Celda
#' @description Clusters the rows of a count matrix containing single-cell data
#'  into L modules. The
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
#' @param L Integer. Number of feature modules.
#' @param beta Numeric. Concentration parameter for Phi. Adds a pseudocount to
#'  each feature module in each cell. Default 1.
#' @param delta Numeric. Concentration parameter for Psi. Adds a pseudocount to
#'  each feature in each module. Default 1.
#' @param gamma Numeric. Concentration parameter for Eta. Adds a pseudocount to
#'  the number of features in each module. Default 1.
#' @param stopIter Integer. Number of iterations without improvement in the
#'  log likelihood to stop inference. Default 10.
#' @param maxIter Integer. Maximum number of iterations of Gibbs sampling to
#'  perform. Default 200.
#' @param splitOnIter Integer. On every `splitOnIter` iteration, a heuristic
#'  will be applied to determine if a feature module should be reassigned and
#'  another feature module should be split into two clusters. To disable
#'  splitting, set to -1. Default 10.
#' @param splitOnLast Integer. After `stopIter` iterations have been
#'  performed without improvement, a heuristic will be applied to determine if
#'  a cell population should be reassigned and another cell population should be
#'  split into two clusters. If a split occurs, then `stopIter` will be reset.
#'  Default TRUE.
#' @param seed Integer. Passed to \link[withr]{with_seed}. For reproducibility,
#'  a default value of 12345 is used. If NULL, no calls to
#'  \link[withr]{with_seed} are made.
#' @param nchains Integer. Number of random cluster initializations. Default 3.
#' @param yInitialize Chararacter. One of 'random', 'split', or 'predefined'.
#'  With 'random', features are randomly assigned to a modules. With 'split',
#'  features will be split into sqrt(L) modules and then each module will be
#'  subsequently split into another sqrt(L) modules. With 'predefined', values
#'  in `yInit` will be used to initialize `y`. Default 'split'.
#' @param yInit Integer vector. Sets initial starting values of y.
#'  `yInit` can only be used when `yInitialize = 'predefined'`. Default NULL.
#' @param countChecksum Character. An MD5 checksum for the `counts` matrix.
#'  Default NULL.
#' @param logfile Character. Messages will be redirected to a file named
#'  \code{logfile}. If NULL, messages will be printed to stdout. Default NULL.
#' @param verbose Logical. Whether to print log messages. Default TRUE.
#' @return A \linkS4class{SingleCellExperiment} object. Function
#'  parameter settings are stored in the \link{metadata}
#'  \code{"celda_parameters"} slot. Column \code{celda_feature_module} in
#'  \link{rowData} contains feature modules.
#' @seealso \link{celda_C} for cell clustering and \link{celda_CG} for
#'  simultaneous clustering of features and cells. \link{celdaGridSearch} can
#'  be used to run multiple values of L and multiple chains in parallel.
#' @examples
#' data(celdaGSim)
#' sce <- celda_G(celdaGSim$counts, L = celdaGSim$L, nchains = 1)
#' @export
setGeneric("celda_G",
    function(x,
        useAssay = "counts",
        altExpName = "featureSubset",
        L,
        beta = 1,
        delta = 1,
        gamma = 1,
        stopIter = 10,
        maxIter = 200,
        splitOnIter = 10,
        splitOnLast = TRUE,
        seed = 12345,
        nchains = 3,
        yInitialize = c("split", "random", "predefined"),
        countChecksum = NULL,
        yInit = NULL,
        logfile = NULL,
        verbose = TRUE) {
    standardGeneric("celda_G")})


#' @rdname celda_G
#' @export
setMethod("celda_G",
    signature(x = "SingleCellExperiment"),
    function(x,
        useAssay = "counts",
        altExpName = "featureSubset",
        L,
        beta = 1,
        delta = 1,
        gamma = 1,
        stopIter = 10,
        maxIter = 200,
        splitOnIter = 10,
        splitOnLast = TRUE,
        seed = 12345,
        nchains = 3,
        yInitialize = c("split", "random", "predefined"),
        countChecksum = NULL,
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

        altExp <- .celdaGWithSeed(counts = counts,
            xClass = xClass,
            useAssay = useAssay,
            sce = altExp,
            L = L,
            beta = beta,
            delta = delta,
            gamma = gamma,
            stopIter = stopIter,
            maxIter = maxIter,
            splitOnIter = splitOnIter,
            splitOnLast = splitOnLast,
            seed = seed,
            nchains = nchains,
            yInitialize = match.arg(yInitialize),
            countChecksum = countChecksum,
            yInit = yInit,
            logfile = logfile,
            verbose = verbose)
        SingleCellExperiment::altExp(x, altExpName) <- altExp
        return(x)
    }
)


#' @rdname celda_G
#' @export
setMethod("celda_G",
    signature(x = "ANY"),
    function(x,
        useAssay = "counts",
        altExpName = "featureSubset",
        L,
        beta = 1,
        delta = 1,
        gamma = 1,
        stopIter = 10,
        maxIter = 200,
        splitOnIter = 10,
        splitOnLast = TRUE,
        seed = 12345,
        nchains = 3,
        yInitialize = c("split", "random", "predefined"),
        countChecksum = NULL,
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

        altExp <- .celdaGWithSeed(counts = x,
            xClass = xClass,
            useAssay = useAssay,
            sce = SingleCellExperiment::altExp(sce, altExpName),
            L = L,
            beta = beta,
            delta = delta,
            gamma = gamma,
            stopIter = stopIter,
            maxIter = maxIter,
            splitOnIter = splitOnIter,
            splitOnLast = splitOnLast,
            seed = seed,
            nchains = nchains,
            yInitialize = match.arg(yInitialize),
            countChecksum = countChecksum,
            yInit = yInit,
            logfile = logfile,
            verbose = verbose)
        SingleCellExperiment::altExp(sce, altExpName) <- altExp
        return(sce)
    }
)


.celdaGWithSeed <- function(counts,
    xClass,
    useAssay,
    sce,
    L,
    beta,
    delta,
    gamma,
    stopIter,
    maxIter,
    splitOnIter,
    splitOnLast,
    seed,
    nchains,
    yInitialize,
    countChecksum,
    yInit,
    logfile,
    verbose) {

    .validateCounts(counts)

    if (is.null(seed)) {
        celdaGMod <- .celda_G(counts = counts,
            L = L,
            beta = beta,
            delta = delta,
            gamma = gamma,
            stopIter = stopIter,
            maxIter = maxIter,
            splitOnIter = splitOnIter,
            splitOnLast = splitOnLast,
            nchains = nchains,
            yInitialize = yInitialize,
            countChecksum = countChecksum,
            yInit = yInit,
            logfile = logfile,
            verbose = verbose,
            reorder = TRUE)
    } else {
        with_seed(
            seed,
            celdaGMod <- .celda_G(counts = counts,
                L = L,
                beta = beta,
                delta = delta,
                gamma = gamma,
                stopIter = stopIter,
                maxIter = maxIter,
                splitOnIter = splitOnIter,
                splitOnLast = splitOnLast,
                nchains = nchains,
                yInitialize = yInitialize,
                countChecksum = countChecksum,
                yInit = yInit,
                logfile = logfile,
                verbose = verbose,
                reorder = TRUE)
        )
    }

    sce <- .createSCEceldaG(celdaGMod = celdaGMod,
        sce = sce,
        xClass = xClass,
        useAssay = useAssay,
        stopIter = stopIter,
        maxIter = maxIter,
        splitOnIter = splitOnIter,
        splitOnLast = splitOnLast,
        nchains = nchains,
        yInitialize = yInitialize,
        yInit = yInit,
        logfile = logfile,
        verbose = verbose)
    return(sce)
}

#' @importFrom Matrix colSums
.celda_G <- function(counts,
                     L,
                     beta = 1,
                     delta = 1,
                     gamma = 1,
                     stopIter = 10,
                     maxIter = 200,
                     splitOnIter = 10,
                     splitOnLast = TRUE,
                     nchains = 3,
                     yInitialize = c("split", "random", "predefined"),
                     countChecksum = NULL,
                     yInit = NULL,
                     logfile = NULL,
                     verbose = TRUE,
                     reorder = TRUE) {
  .logMessages(paste(rep("-", 50), collapse = ""),
    logfile = logfile,
    append = FALSE,
    verbose = verbose
  )
  .logMessages("Starting Celda_G: Clustering genes.",
    logfile = logfile,
    append = TRUE,
    verbose = verbose
  )
  .logMessages(paste(rep("-", 50), collapse = ""),
    logfile = logfile,
    append = TRUE,
    verbose = verbose
  )
  start.time <- Sys.time()

  ## Error checking and variable processing
  counts <- .processCounts(counts)
  if (is.null(countChecksum)) {
    countChecksum <- .createCountChecksum(counts)
  }
  yInitialize <- match.arg(yInitialize)

  allChains <- seq(nchains)

  # Pre-compute lgamma values
  cs <- colSums(counts)
  lgbeta <- lgamma(seq(0, max(cs)) + beta)
  lggamma <- lgamma(seq(0, nrow(counts) + L) + gamma)
  lgdelta <- c(NA, lgamma((seq(nrow(counts) + L) * delta)))

  bestResult <- NULL
  for (i in allChains) {
    ## Randomly select y or y to supplied initial values
    ## Initialize cluster labels
    .logMessages(date(),
      ".. Initializing 'y' in chain",
      i,
      "with",
      paste0("'", yInitialize, "' "),
      logfile = logfile,
      append = TRUE,
      verbose = verbose
    )

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
    yBest <- y

    ## Calculate counts one time up front
    p <- .cGDecomposeCounts(counts = counts, y = y, L = L)
    nTSByC <- p$nTSByC
    nByG <- p$nByG
    nByTS <- p$nByTS
    nGByTS <- p$nGByTS
    nM <- p$nM
    nG <- p$nG
    rm(p)

    ## Calculate initial log likelihood
    ll <- .cGCalcLL(
      nTSByC = nTSByC,
      nByTS = nByTS,
      nByG = nByG,
      nGByTS = nGByTS,
      nM = nM,
      nG = nG,
      L = L,
      beta = beta,
      delta = delta,
      gamma = gamma
    )

    iter <- 1L
    numIterWithoutImprovement <- 0L
    doGeneSplit <- TRUE
    while (iter <= maxIter & numIterWithoutImprovement <= stopIter) {
      nextY <- .cGCalcGibbsProbY(
        counts = counts,
        nTSByC = nTSByC,
        nByTS = nByTS,
        nGByTS = nGByTS,
        nByG = nByG,
        y = y,
        nG = nG,
        L = L,
        beta = beta,
        delta = delta,
        gamma = gamma,
        lgbeta = lgbeta,
        lggamma = lggamma,
        lgdelta = lgdelta
      )
      nTSByC <- nextY$nTSByC
      nGByTS <- nextY$nGByTS
      nByTS <- nextY$nByTS
      y <- nextY$y

      ## Perform split on i-th iteration of no improvement in log
      ## likelihood
      tempLl <- .cGCalcLL(
        nTSByC = nTSByC,
        nByTS = nByTS,
        nByG = nByG,
        nGByTS = nGByTS,
        nM = nM,
        nG = nG,
        L = L,
        beta = beta,
        delta = delta,
        gamma = gamma
      )
      if (L > 2 & iter != maxIter &
        ((((numIterWithoutImprovement == stopIter &
          !all(tempLl >= ll))) & isTRUE(splitOnLast)) |
          (splitOnIter > 0 & iter %% splitOnIter == 0 &
            isTRUE(doGeneSplit)))) {
        .logMessages(date(),
          " .... Determining if any gene clusters should be split.",
          logfile = logfile,
          append = TRUE,
          sep = "",
          verbose = verbose
        )
        res <- .cGSplitY(counts,
          y,
          nTSByC,
          nByTS,
          nByG,
          nGByTS,
          nM,
          nG,
          L,
          beta,
          delta,
          gamma,
          yProb = t(nextY$probs),
          minFeature = 3,
          maxClustersToTry = max(L / 2, 10)
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
        nTSByC <- res$nTSByC
        nByTS <- res$nByTS
        nGByTS <- res$nGByTS
      }

      ## Calculate complete likelihood
      tempLl <- .cGCalcLL(
        nTSByC = nTSByC,
        nByTS = nByTS,
        nByG = nByG,
        nGByTS = nGByTS,
        nM = nM,
        nG = nG,
        L = L,
        beta = beta,
        delta = delta,
        gamma = gamma
      )
      if ((all(tempLl > ll)) | iter == 1) {
        yBest <- y
        llBest <- tempLl
        numIterWithoutImprovement <- 1L
      } else {
        numIterWithoutImprovement <- numIterWithoutImprovement + 1L
      }
      ll <- c(ll, tempLl)

      .logMessages(date(),
        ".... Completed iteration:",
        iter,
        "| logLik:",
        tempLl,
        logfile = logfile,
        append = TRUE,
        verbose = verbose
      )
      iter <- iter + 1
    }

    names <- list(row = rownames(counts), column = colnames(counts))

    result <- list(
      y = yBest,
      completeLogLik = ll,
      finalLogLik = llBest,
      L = L,
      beta = beta,
      delta = delta,
      gamma = gamma,
      countChecksum = countChecksum,
      names = names
    )

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

  bestResult <- methods::new("celda_G",
    clusters = list(y = yBest),
    params = list(
      L = as.integer(L),
      beta = beta,
      delta = delta,
      gamma = gamma,
      countChecksum = countChecksum
    ),
    completeLogLik = ll,
    finalLogLik = llBest,
    names = names
  )
  if (isTRUE(reorder)) {
    bestResult <- .reorderCeldaG(counts = counts, res = bestResult)
  }

  endTime <- Sys.time()
  .logMessages(paste0(rep("-", 50), collapse = ""),
    logfile = logfile,
    append = TRUE,
    verbose = verbose
  )
  .logMessages("Completed Celda_G. Total time:",
    format(difftime(endTime, start.time)),
    logfile = logfile,
    append = TRUE,
    verbose = verbose
  )
  .logMessages(paste0(rep("-", 50), collapse = ""),
    logfile = logfile,
    append = TRUE,
    verbose = verbose
  )

  return(bestResult)
}


# Calculate Log Likelihood For Single Set of Cluster Assignments
# (Gene Clustering)
# This function calculates the log-likelihood of a given set of cluster
# assigments for the samples
# represented in the provided count matrix.
# @param nTSByC Number of counts in each Transcriptional State per Cell.
# @param nByTS Number of counts per Transcriptional State.
# @param nGByTS Number of genes in each Transcriptional State.
# @param nG.in.Y  Number of genes in each of the cell cluster.
# @param gamma Numeric. Concentration parameter for Eta. Adds a pseudocount to
# the number of features in each module. Default 1.
# @param delta Numeric. Concentration parameter for Psi. Adds a pseudocount to
# each feature in each module. Default 1.
# @param beta Numeric. Concentration parameter for Phi. Adds a pseudocount to
# each feature module in each cell. Default 1.
# @keywords log likelihood
.cGCalcGibbsProbY <- function(counts,
                              nTSByC,
                              nByTS,
                              nGByTS,
                              nByG,
                              y,
                              L,
                              nG,
                              beta,
                              delta,
                              gamma,
                              lgbeta,
                              lggamma,
                              lgdelta,
                              doSample = TRUE) {

  ## Set variables up front outside of loop
  probs <- matrix(NA, ncol = nG, nrow = L)
  ix <- sample(seq(nG))
  for (i in ix) {
    probs[, i] <- cG_CalcGibbsProbY(index = i,
      counts = as.numeric(counts[i, ]),
      nTSbyC = nTSByC,
      nbyTS = nByTS,
      nGbyTS = nGByTS,
      nbyG = nByG,
      y = y,
      L = L,
      nG = nG,
      lg_beta = lgbeta,
      lg_gamma = lggamma,
      lg_delta = lgdelta,
      delta = delta
    )
    ## Sample next state and add back counts
    if (isTRUE(doSample)) {
      prevY <- y[i]
      y[i] <- .sampleLl(probs[, i])

      if (prevY != y[i]) {
        nTSByC[prevY, ] <- nTSByC[prevY, ] - counts[i, ]
        nGByTS[prevY] <- nGByTS[prevY] - 1L
        nByTS[prevY] <- nByTS[prevY] - nByG[i]

        nTSByC[y[i], ] <- nTSByC[y[i], ] + counts[i, ]
        nGByTS[y[i]] <- nGByTS[y[i]] + 1L
        nByTS[y[i]] <- nByTS[y[i]] + nByG[i]
      }
    }
  }

  return(list(
    nTSByC = nTSByC,
    nGByTS = nGByTS,
    nByTS = nByTS,
    y = y,
    probs = probs
  ))
}


# Calculate log-likelihood of celda_CG model
.cGCalcLL <- function(nTSByC,
                      nByTS,
                      nByG,
                      nGByTS,
                      nM,
                      nG,
                      L,
                      beta,
                      delta,
                      gamma) {
  nG <- sum(nGByTS)

  ## Calculate for "Phi" component
  a <- nM * lgamma(L * beta)
  b <- sum(lgamma(nTSByC + beta))
  c <- -nM * L * lgamma(beta)
  d <- -sum(lgamma(colSums(nTSByC + beta)))

  phiLl <- a + b + c + d

  ## Calculate for "Psi" component
  a <- sum(lgamma(nGByTS * delta))
  b <- sum(lgamma(nByG + delta))
  c <- -nG * lgamma(delta)
  d <- -sum(lgamma(nByTS + (nGByTS * delta)))

  psiLl <- a + b + c + d

  ## Calculate for "Eta" component
  a <- lgamma(L * gamma)
  b <- sum(lgamma(nGByTS + gamma))
  c <- -L * lgamma(gamma)
  d <- -sum(lgamma(sum(nGByTS + gamma)))

  etaLl <- a + b + c + d

  final <- phiLl + psiLl + etaLl
  return(final)
}


# Takes raw counts matrix and converts it to a series of matrices needed for
# log likelihood calculation
# @param counts Integer matrix. Rows represent features and columns represent
# cells.
# @param y Numeric vector. Denotes feature module labels.
# @param L Integer. Number of feature modules.
#' @importFrom Matrix rowSums
.cGDecomposeCounts <- function(counts, y, L) {
  if (any(y > L)) {
    stop("Assigned value of feature module greater than the total number",
        " of feature modules!")
  }

  nTSByC <- .rowSumByGroup(counts, group = y, L = L)
  nByG <- rowSums(counts)
  nByTS <- .rowSumByGroup(matrix(nByG, ncol = 1), group = y, L = L)
  nGByTS <- tabulate(y, L) + 1 ## Add pseudogene to each state
  nM <- ncol(counts)
  nG <- nrow(counts)

  return(list(
    nTSByC = nTSByC,
    nByG = nByG,
    nByTS = nByTS,
    nGByTS = nGByTS,
    nM = nM,
    nG = nG
  ))
}


.cGReDecomposeCounts <- function(counts, y, previousY, nTSByC, nByG, L) {
  ## Recalculate counts based on new label
  nTSByC <- .rowSumByGroupChange(counts, nTSByC, y, previousY, L)
  nByTS <- .rowSumByGroup(matrix(nByG, ncol = 1), group = y, L = L)
  nGByTS <- tabulate(y, L) + 1

  return(list(
    nTSByC = nTSByC,
    nByTS = nByTS,
    nGByTS = nGByTS
  ))
}


.prepareCountsForDimReductionCeldaG <- function(sce,
    useAssay,
    maxCells,
    minClusterSize,
    modules,
    normalize,
    scaleFactor,
    transformationFun) {

    counts <- SummarizedExperiment::assay(sce, i = useAssay)
    counts <- .processCounts(counts)
    y <- as.integer(SummarizedExperiment::rowData(sce)$celda_feature_module)
    L <- S4Vectors::metadata(sce)$celda_parameters$L
    beta <- S4Vectors::metadata(sce)$celda_parameters$beta
    delta <- S4Vectors::metadata(sce)$celda_parameters$delta
    gamma <- S4Vectors::metadata(sce)$celda_parameters$gamma
    cNames <- colnames(sce)
    rNames <- rownames(sce)

    if (is.null(maxCells) || maxCells > ncol(counts)) {
        maxCells <- ncol(counts)
        cellIx <- seq_len(ncol(counts))
    } else {
        cellIx <- sample(seq(ncol(counts)), maxCells)
    }

    fm <- .factorizeMatrixG(
        counts = counts,
        y = y,
        L = L,
        beta = beta,
        delta = delta,
        gamma = gamma,
        cNames = cNames,
        rNames = rNames,
        type = "counts")

    modulesToUse <- seq(nrow(fm$counts$cell))
    if (!is.null(modules)) {
        if (!all(modules %in% modulesToUse)) {
            stop(
                "'modules' must be a vector of numbers between 1 and ",
                modulesToUse,
                "."
            )
        }
        modulesToUse <- modules
    }

    norm <- t(normalizeCounts(fm$counts$cell[modulesToUse, cellIx],
        normalize = normalize,
        scaleFactor = scaleFactor,
        transformationFun = transformationFun))
    return(list(norm = norm, cellIx = cellIx))
}


.createSCEceldaG <- function(celdaGMod,
    sce,
    xClass,
    useAssay,
    stopIter,
    maxIter,
    splitOnIter,
    splitOnLast,
    nchains,
    yInitialize,
    yInit,
    logfile,
    verbose) {

    # add metadata
    S4Vectors::metadata(sce)[["celda_parameters"]] <- list(
        model = "celda_G",
        xClass = xClass,
        useAssay = useAssay,
        L = celdaGMod@params$L,
        beta = celdaGMod@params$beta,
        delta = celdaGMod@params$delta,
        gamma = celdaGMod@params$gamma,
        stopIter = stopIter,
        maxIter = maxIter,
        splitOnIter = splitOnIter,
        splitOnLast = splitOnLast,
        seed = celdaGMod@params$seed,
        nchains = nchains,
        yInitialize = yInitialize,
        countChecksum = celdaGMod@params$countChecksum,
        yInit = yInit,
        logfile = logfile,
        verbose = verbose,
        completeLogLik = celdaGMod@completeLogLik,
        finalLogLik = celdaGMod@finalLogLik,
        featureModuleLevels = sort(unique(celdaClusters(celdaGMod)$y)))

    SummarizedExperiment::rowData(sce)["rownames"] <- celdaGMod@names$row
    SummarizedExperiment::colData(sce)["colnames"] <-
        celdaGMod@names$column
    SummarizedExperiment::rowData(sce)["celda_feature_module"] <-
        as.factor(celdaClusters(celdaGMod)$y)

    return(sce)
}
