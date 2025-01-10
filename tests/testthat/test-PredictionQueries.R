context("PredictionQueries")

test_that("getPredictionTopPredictors", {
  
  data <- getPredictionTopPredictors(
    connectionHandler = connectionHandler, 
    schema = schema
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  testthat::expect_true('databaseName' %in% colnames(data))
  testthat::expect_true('covariateName' %in% colnames(data))
  testthat::expect_true('covariateValue' %in% colnames(data))
  testthat::expect_true('covariateCount' %in% colnames(data))
  testthat::expect_true('covariateMean' %in% colnames(data))
  testthat::expect_true('covariateStDev' %in% colnames(data))
  testthat::expect_true('withNoOutcomeCovariateMean' %in% colnames(data))
  testthat::expect_true('withOutcomeCovariateMean' %in% colnames(data))
  testthat::expect_true('standardizedMeanDiff' %in% colnames(data))
  testthat::expect_true('rn' %in% colnames(data))
  
  data <- getPredictionTopPredictors(
    connectionHandler = connectionHandler, 
    schema = schema, numberPredictors = 1
  )
  testthat::expect_true(max(data$rn) <= 1)
  
})

test_that("getPredictionCohorts", {
  
  data <- getPredictionCohorts(
    connectionHandler = connectionHandler, 
    schema = schema
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  testthat::expect_true('cohortId' %in% colnames(data))
  testthat::expect_true('cohortName' %in% colnames(data))
  testthat::expect_true('type' %in% colnames(data))
  
})


test_that("getPredictionModelDesigns", {
  
  data <- getPredictionModelDesigns(
    connectionHandler = connectionHandler, 
    schema = schema
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  testthat::expect_true('modelDesignId' %in% colnames(data))
  testthat::expect_true('modelType' %in% colnames(data))
  testthat::expect_true('developmentTargetName' %in% colnames(data))
  testthat::expect_true('developmentOutcomeName' %in% colnames(data))
  testthat::expect_true('timeAtRisk' %in% colnames(data))
  testthat::expect_true('covariateSettingsJson' %in% colnames(data))
  testthat::expect_true('populationSettingsJson' %in% colnames(data))
  testthat::expect_true('meanAuroc' %in% colnames(data))
  testthat::expect_true('noDiagnosticDatabases' %in% colnames(data))
  testthat::expect_true('noDevelopmentDatabases' %in% colnames(data))
  testthat::expect_true('noValidationDatabases' %in% colnames(data))
  
  data <- getPredictionModelDesigns(
    connectionHandler = connectionHandler, 
    schema = schema, 
    targetIds = 1, 
    outcomeIds = 3
  )
  
  testthat::expect_true(nrow(data) > 0)
  testthat::expect_true(max(data$developmentTargetId) == 1)
  testthat::expect_true(max(data$developmentOutcomeId) == 3)
  
})


test_that("getPredictionPerformances", {
  
  data <- getPredictionPerformances(
    connectionHandler = connectionHandler, 
    schema = schema
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  testthat::expect_true('performanceId' %in% colnames(data))
  testthat::expect_true('modelDesignId' %in% colnames(data))
  testthat::expect_true('developmentTargetName' %in% colnames(data))
  testthat::expect_true('developmentOutcomeName' %in% colnames(data))
  testthat::expect_true('validationTargetName' %in% colnames(data))
  testthat::expect_true('validationOutcomeName' %in% colnames(data))
  testthat::expect_true('validationTimeAtRisk' %in% colnames(data))
  testthat::expect_true('timeStamp' %in% colnames(data))
  testthat::expect_true('auroc' %in% colnames(data))
  testthat::expect_true('auroc95lb' %in% colnames(data))
  testthat::expect_true('auroc95ub' %in% colnames(data))
  testthat::expect_true('calibrationInLarge' %in% colnames(data))
  testthat::expect_true('eStatistic' %in% colnames(data))
  testthat::expect_true('brierScore' %in% colnames(data))
  testthat::expect_true('auprc' %in% colnames(data))
  testthat::expect_true('populationSize' %in% colnames(data))
  testthat::expect_true('outcomeCount' %in% colnames(data))
  testthat::expect_true('evalPercent' %in% colnames(data))
  testthat::expect_true('outcomePercent' %in% colnames(data))
  
  data <- getPredictionPerformances(
    connectionHandler = connectionHandler, 
    schema = schema, 
    modelDesignId = 1
  )
  
  testthat::expect_true(nrow(data) > 0)
  testthat::expect_true(max(data$modelDesignId) == 1)
  
})

# TODO
# getPredictionDiagnostics
# getPredictionPerformanceTable
# getPredictionDiagnosticTable
# getPredictionHyperParamSearch
# getPredictionIntercept


