test_that("plotCmEstimates", {
  
  data <- getCMEstimation(
    connectionHandler = connectionHandler,
    schema = schema, 
    targetIds = 1002, 
    outcomeIds = 3, 
    comparatorIds = 2002
  )
  
  p <- plotCmEstimates(
    cmData = data,
    cmMeta = NULL, 
    cohortNames = data.frame(
      cohortName = c('target', 'comp'), 
      cohortId = c(1002,2002)
    ),
    selectedAnalysisId = 1
  )
  
  testthat::expect_type(p, "list")
  testthat::expect_s3_class(p[[1]], "forestplot")
  
  # check without counts
  p <- plotCmEstimates(
    cmData = data,
    cmMeta = NULL, 
    cohortNames = data.frame(
      cohortName = c('target', 'comp'), 
      cohortId = c(1002,2002)
    ),
    includeCounts = FALSE,
    selectedAnalysisId = 1
  )
  
  testthat::expect_type(p, "list")
  testthat::expect_s3_class(p[[1]], "forestplot")
  
  # check with meta
  cmMeta <- getCmMetaEstimation(
    connectionHandler = connectionHandler,
    schema = schema, 
    targetIds = 1002, 
    outcomeIds = 3, 
    comparatorIds = 2002
  )
  
  p <- plotCmEstimates(
    cmData = data,
    cmMeta = cmMeta, 
    cohortNames = data.frame(
      cohortName = c('target', 'comp'), 
      cohortId = c(1002,2002)
    ),
    includeCounts = FALSE,
    selectedAnalysisId = 1
  )
  
  testthat::expect_type(p, "list")
  testthat::expect_s3_class(p[[1]], "forestplot")
  
  # check with dignostics

  cmDiagnostics <- getCmDiagnosticsData(
    connectionHandler = connectionHandler,
    schema = schema, 
    targetIds = 1002, 
    outcomeIds = 3, 
    comparatorIds = 2002
  )
  
  p <- plotCmEstimates(
    cmData = data,
    cmMeta = cmMeta, 
    cmDiagnostics = cmDiagnostics,
    cohortNames = data.frame(
      cohortName = c('target', 'comp'), 
      cohortId = c(1002,2002)
    ),
    includeCounts = FALSE,
    selectedAnalysisId = 1
  )
  
  testthat::expect_type(p, "list")
  testthat::expect_s3_class(p[[1]], "forestplot")
  
})


test_that("plotSccsEstimates", {
  
  data <- getSccsEstimation(
    connectionHandler = connectionHandler,
    schema = schema, 
    targetIds = 1, 
    outcomeIds = 3 
  )
  
  meta <- getSccsMetaEstimation(
    connectionHandler = connectionHandler,
    schema = schema, 
    targetIds = 1, 
    outcomeIds = 3 
  )
  
  diag <- getSccsDiagnosticsData(
    connectionHandler = connectionHandler,
    schema = schema, 
    targetIds = 1, 
    outcomeIds = 3 
  )
  
  p <- plotSccsEstimates(
    sccsData = data,
    sccsMeta = NULL,
    includeCounts = TRUE, 
    selectedAnalysisId = 1
  )
  
  testthat::expect_type(p, "list")
  testthat::expect_s3_class(p[[1]], "forestplot")
  
  p <- plotSccsEstimates(
    sccsData = data,
    sccsMeta = NULL,
    includeCounts = FALSE, 
    selectedAnalysisId = 1
  )
  
  testthat::expect_type(p, "list")
  testthat::expect_s3_class(p[[1]], "forestplot")
  
  p <- plotSccsEstimates(
    sccsData = data,
    sccsMeta = meta,
    includeCounts = TRUE, 
    selectedAnalysisId = 1
  )
  
  testthat::expect_type(p, "list")
  testthat::expect_s3_class(p[[1]], "forestplot")
  
  p <- plotSccsEstimates(
    sccsData = data,
    sccsMeta = meta,
    sccsDiagnostics = diag,
    includeCounts = TRUE, 
    selectedAnalysisId = 1
  )
  
  testthat::expect_type(p, "list")
  testthat::expect_s3_class(p[[1]], "forestplot")
  
})

#plotSccsEstimates