context("EstimationQueries")

test_that("getCMEstimation", {
  
  data <- getCMEstimation(
    connectionHandler = connectionHandler,
    schema = schema
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  testthat::expect_true('databaseName' %in% colnames(data))
  testthat::expect_true('analysisId' %in% colnames(data))
  testthat::expect_true('description' %in% colnames(data))
  testthat::expect_true('targetName' %in% colnames(data))
  testthat::expect_true('comparatorName' %in% colnames(data))
  testthat::expect_true('outcomeName' %in% colnames(data))
  testthat::expect_true('calibratedRr' %in% colnames(data))
  testthat::expect_true('calibratedP' %in% colnames(data))
  testthat::expect_true('calibratedOneSidedP' %in% colnames(data))
  testthat::expect_true('calibratedLogRr' %in% colnames(data))
  testthat::expect_true('targetSubjects' %in% colnames(data))
  testthat::expect_true('comparatorSubjects' %in% colnames(data))
  testthat::expect_true('targetDays' %in% colnames(data))
  testthat::expect_true('comparatorDays' %in% colnames(data))
  testthat::expect_true('targetOutcomes' %in% colnames(data))
  testthat::expect_true('comparatorOutcomes' %in% colnames(data))
})


test_that("getCmDiagnosticsData", {
  
  data <- getCmDiagnosticsData(
    connectionHandler = connectionHandler,
    schema = schema
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  testthat::expect_true('databaseName' %in% colnames(data))
  testthat::expect_true('analysisId' %in% colnames(data))
  testthat::expect_true('description' %in% colnames(data))
  testthat::expect_true('targetName' %in% colnames(data))
  testthat::expect_true('comparatorName' %in% colnames(data))
  testthat::expect_true('outcomeName' %in% colnames(data))
  testthat::expect_true('maxSdm' %in% colnames(data))
  testthat::expect_true('sharedMaxSdm' %in% colnames(data))
  testthat::expect_true('equipoise' %in% colnames(data))
  testthat::expect_true('mdrr' %in% colnames(data))
  testthat::expect_true('attritionFraction' %in% colnames(data))
  testthat::expect_true('ease' %in% colnames(data))
  testthat::expect_true('balanceDiagnostic' %in% colnames(data))
  testthat::expect_true('sharedBalanceDiagnostic' %in% colnames(data))
  testthat::expect_true('equipoiseDiagnostic' %in% colnames(data))
  testthat::expect_true('mdrrDiagnostic' %in% colnames(data))
  testthat::expect_true('attritionDiagnostic' %in% colnames(data))
  testthat::expect_true('easeDiagnostic' %in% colnames(data))
  
  testthat::expect_true('unblind' %in% colnames(data))
  testthat::expect_true('summaryValue' %in% colnames(data))
  
})


test_that("getCmMetaEstimation", {
  
  # TODO get results into example?
  data <- getCmMetaEstimation(
    connectionHandler = connectionHandler,
    schema = schema
  )
  
  testthat::expect_true('databaseName' %in% colnames(data))
  testthat::expect_true('analysisId' %in% colnames(data))
  testthat::expect_true('description' %in% colnames(data))
  testthat::expect_true('targetName' %in% colnames(data))
  testthat::expect_true('comparatorName' %in% colnames(data))
  testthat::expect_true('outcomeName' %in% colnames(data))
  testthat::expect_true('calibratedRr' %in% colnames(data))
  testthat::expect_true('calibratedP' %in% colnames(data))
  testthat::expect_true('calibratedOneSidedP' %in% colnames(data))
  testthat::expect_true('calibratedLogRr' %in% colnames(data))
  testthat::expect_true('targetSubjects' %in% colnames(data))
  testthat::expect_true('comparatorSubjects' %in% colnames(data))
  testthat::expect_true('targetDays' %in% colnames(data))
  testthat::expect_true('comparatorDays' %in% colnames(data))
  testthat::expect_true('targetOutcomes' %in% colnames(data))
  testthat::expect_true('comparatorOutcomes' %in% colnames(data))
  testthat::expect_true('nDatabases' %in% colnames(data))
})

# TODO
# getSccsEstimation
# getSccsDiagnosticsData 
# getSccsMetaEstimation


