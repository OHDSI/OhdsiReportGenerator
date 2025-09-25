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

test_that("getPredictionOutcomes", {
  
data <- getPredictionOutcomes(
  connectionHandler = connectionHandler, 
  schema = schema
)

testthat::expect_true(nrow(data) > 0)

data <- getPredictionOutcomes(
  connectionHandler = connectionHandler, 
  schema = schema, 
  targetId = c(1002,1)
)

testthat::expect_true(nrow(data) > 0)

# not a target in the prediction results
data <- getPredictionOutcomes(
  connectionHandler = connectionHandler, 
  schema = schema, 
  targetId = 1
)

testthat::expect_true(nrow(data) == 0)
  
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

test_that("getFullPredictionPerformances", {
  
  data <- getFullPredictionPerformances(
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
  testthat::expect_true('modelType' %in% colnames(data))
  testthat::expect_true('evaluation' %in% colnames(data))
  testthat::expect_true('AUROC' %in% colnames(data))
  testthat::expect_true('95% lower AUROC' %in% colnames(data))
  testthat::expect_true('95% upper AUROC' %in% colnames(data))
  testthat::expect_true('calibrationInLarge mean prediction' %in% colnames(data))
  testthat::expect_true('Eavg' %in% colnames(data))
  testthat::expect_true('brier score' %in% colnames(data))
  testthat::expect_true('AUPRC' %in% colnames(data))
  testthat::expect_true('populationSize' %in% colnames(data))
  testthat::expect_true('outcomeCount' %in% colnames(data))
  
  data <- getFullPredictionPerformances(
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
  testthat::expect_true('probastId' %in% colnames(data))
  testthat::expect_true('probastDescription' %in% colnames(data))

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


test_that("getPredictionIntercept", {
  
  data <- getPredictionIntercept(
    connectionHandler = connectionHandler, 
    schema = schema, 
    modelDesignId = 1,
    databaseId = 1
  )
  
  testthat::expect_is(data, 'numeric')
  
})



test_that("getPredictionCovariates ", {
  
  alldata <- getPredictionCovariates (
    connectionHandler = connectionHandler, 
    schema = schema
  )
  
  testthat::expect_true(nrow(alldata) > 0)
  
  filterdata <- getPredictionCovariates (
    connectionHandler = connectionHandler, 
    schema = schema, 
    modelDesignId = 1,
    performanceIds = NULL
  )
  testthat::expect_true(unique(filterdata$modelDesignId) == 1)
  
  filterdata <- getPredictionCovariates (
    connectionHandler = connectionHandler, 
    schema = schema, 
    modelDesignId = NULL,
    performanceIds = 1
  )
  testthat::expect_true(unique(filterdata$performanceId) == 1)
  
})