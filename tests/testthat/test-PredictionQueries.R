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
    targetIds = 1002, 
    outcomeIds = 3
  )
  
  testthat::expect_true(nrow(data) > 0)
  testthat::expect_true(max(data$developmentTargetId) == 1002)
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

test_that("getPredictionPerformances", {
  
  data <- getPredictionDiagnostics(
    connectionHandler = connectionHandler, 
    schema = schema
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  testthat::expect_true('diagnosticId' %in% colnames(data))
  testthat::expect_true('modelDesignId' %in% colnames(data))
  testthat::expect_true('developmentDatabaseName' %in% colnames(data))
  testthat::expect_true('developmentTargetName' %in% colnames(data))
  testthat::expect_true('developmentOutcomeName' %in% colnames(data))
  testthat::expect_true('probast1_1' %in% colnames(data))
  testthat::expect_true('probast1_2' %in% colnames(data))
  testthat::expect_true('probast2_1' %in% colnames(data))
  testthat::expect_true('probast2_2' %in% colnames(data))
  testthat::expect_true('probast2_3' %in% colnames(data))
  testthat::expect_true('probast3_4' %in% colnames(data))
  testthat::expect_true('probast3_6' %in% colnames(data))
  testthat::expect_true('probast4_1' %in% colnames(data))
  
  data <- getPredictionDiagnostics(
    connectionHandler = connectionHandler, 
    schema = schema, 
    modelDesignId = 1
  )
  
  testthat::expect_true(nrow(data) > 0)
  testthat::expect_true(max(data$modelDesignId) == 1)
  
})


test_that("getPredictionPerformances", {
  
  data <- getPredictionPerformanceTable(
    connectionHandler = connectionHandler, 
    schema = schema, 
    table = 'evaluation_statistics', 
    performanceId = 1
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  testthat::expect_true('performanceId' %in% colnames(data))
  testthat::expect_true('evaluation' %in% colnames(data))
  testthat::expect_true('metric' %in% colnames(data))
  testthat::expect_true('value' %in% colnames(data))
  testthat::expect_true(max(data$performanceId) == 1)
  
})

test_that("getPredictionDiagnosticTable", {
  
  data <- getPredictionDiagnosticTable(
    connectionHandler = connectionHandler, 
    schema = schema, 
    table = 'diagnostic_participants', 
    diagnosticId = 1
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  testthat::expect_true('diagnosticId' %in% colnames(data))
  testthat::expect_true('metric' %in% colnames(data))
  testthat::expect_true('value' %in% colnames(data))
  testthat::expect_true('probastId' %in% colnames(data))
  testthat::expect_true('parameter' %in% colnames(data))
  testthat::expect_true('paramvalue' %in% colnames(data))
  
  testthat::expect_true(max(data$diagnosticId) == 1)
  
})

test_that("getPredictionHyperParamSearch", {
  
  data <- getPredictionHyperParamSearch(
    connectionHandler = connectionHandler, 
    schema = schema, 
    modelDesignId = 1,
    databaseId = 1
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  # Does this differ by classifier?
  testthat::expect_true('metric' %in% colnames(data))
  testthat::expect_true('fold' %in% colnames(data))
  testthat::expect_true('value' %in% colnames(data))
  
})


test_that("getPredictionHyperParamSearch", {
  
  data <- getPredictionIntercept(
    connectionHandler = connectionHandler, 
    schema = schema, 
    modelDesignId = 1,
    databaseId = 1
  )
  
  testthat::expect_is(data, 'numeric')
  
})



