context("EstimationPlots")

test_that("plotCmEstimates", {
  
  data <- getCMEstimation(
    connectionHandler = connectionHandler,
    schema = schema, 
    targetIds = 1, 
    outcomeIds = 3, 
    comparatorIds = 2
  )
  
  p <- plotCmEstimates(
    cmData = data,
    cmMeta = NULL,
    targetName = 'target',
    comparatorName = 'comp',
    selectedAnalysisId = 1
  )
  
  testthat::expect_s3_class(p, "gforge_forestplot")
  
})


#plotSccsEstimates