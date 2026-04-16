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
  
  testthat::expect_s3_class(p[[1]], "gforge_forestplot")
  
})


test_that("plotSccsEstimates", {
  
  data <- getSccsEstimation(
    connectionHandler = connectionHandler,
    schema = schema, 
    targetIds = 1, 
    outcomeIds = 3 
  )
  
  p <- plotSccsEstimates(
    sccsData = data,
    sccsMeta = NULL,
    targetName = 'target',
    selectedAnalysisId = 1
  )
  
  testthat::expect_s3_class(p, "gforge_forestplot")
  
})

#plotSccsEstimates