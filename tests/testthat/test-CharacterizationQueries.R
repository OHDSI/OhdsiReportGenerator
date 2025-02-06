context("CharacterizationQueries")

test_that("incidence rates", {
  
  incidence <- getIncidenceRates(
    connectionHandler = connectionHandler, 
    schema = schema
  )
  
  testthat::expect_true(nrow(incidence) > 0)
  
  testthat::expect_true( 'incidenceProportionP100p' %in% colnames(incidence))
  testthat::expect_true( 'incidenceRateP100py' %in% colnames(incidence))
  testthat::expect_true( 'personsAtRisk' %in% colnames(incidence))
  testthat::expect_true( 'personDays' %in% colnames(incidence))
  testthat::expect_true( 'databaseName' %in% colnames(incidence))
  testthat::expect_true( 'targetName' %in% colnames(incidence))
  testthat::expect_true( 'outcomeName' %in% colnames(incidence))
})


test_that("getTimeToEvent", {
  # check results are returned
  tte <- getTimeToEvent(
    connectionHandler = connectionHandler, 
    schema = 'main'
  )
  
  testthat::expect_true(nrow(tte) > 0)
  
  testthat::expect_true( 'databaseName' %in% colnames(tte))
  testthat::expect_true( 'targetName' %in% colnames(tte))
  testthat::expect_true( 'outcomeName' %in% colnames(tte))
  testthat::expect_true( 'outcomeType' %in% colnames(tte))
  testthat::expect_true( 'targetOutcomeType' %in% colnames(tte))
  testthat::expect_true( 'timeToEvent' %in% colnames(tte))
  testthat::expect_true( 'numEvents' %in% colnames(tte))
  testthat::expect_true( 'timeScale' %in% colnames(tte))
  
  # check restriction works
  tte <- getTimeToEvent(
    connectionHandler = connectionHandler, 
    schema = 'main', 
    targetIds = 1, 
    outcomeIds = 3
  )
  testthat::expect_true(unique(tte$targetId) == 1)
  testthat::expect_true(unique(tte$outcomeId) == 3)
})

test_that("getDechallengeRechallenge", {
  # check results are returned
  result <- getDechallengeRechallenge(
    connectionHandler = connectionHandler, 
    schema = 'main'
  )
  
  testthat::expect_true(nrow(result) > 0)
  
  testthat::expect_true( 'databaseName' %in% colnames(result))
  testthat::expect_true( 'targetName' %in% colnames(result))
  testthat::expect_true( 'outcomeName' %in% colnames(result))
  testthat::expect_true( 'dechallengeStopInterval' %in% colnames(result))
  testthat::expect_true( 'dechallengeEvaluationWindow' %in% colnames(result))
  testthat::expect_true( 'numExposureEras' %in% colnames(result))
  testthat::expect_true( 'numCases' %in% colnames(result))
  testthat::expect_true( 'pctDechallengeSuccess' %in% colnames(result))
  testthat::expect_true( 'pctRechallengeFail' %in% colnames(result))
  
  # check restriction works
  result <- getDechallengeRechallenge(
    connectionHandler = connectionHandler, 
    schema = 'main', 
    targetIds = 1, 
    outcomeIds = 3
  )
  testthat::expect_true(unique(result$targetId) == 1)
  testthat::expect_true(unique(result$outcomeId) == 3)
})


test_that("target counts", {
  # check results are returned
  countsT <- getTargetCounts(
    connectionHandler = connectionHandler, 
    schema = 'main'
  )
  
  testthat::expect_true(nrow(countsT) > 0)
  
  testthat::expect_true( 'databaseName' %in% colnames(countsT))
  testthat::expect_true( 'targetName' %in% colnames(countsT))
  testthat::expect_true( 'outcomeName' %in% colnames(countsT))
  testthat::expect_true( 'rowCount' %in% colnames(countsT))
  testthat::expect_true( 'personCount' %in% colnames(countsT))
  
  # check restriction works
  countsT2 <- getTargetCounts(
    connectionHandler = connectionHandler, 
    schema = 'main', 
    targetIds = 1, 
    outcomeIds = 3
  )
  testthat::expect_true(unique(countsT2$targetId) == 1)
  testthat::expect_true(unique(countsT2$outcomeId) == 3)
})


test_that("getCaseCounts", {
  # check results are returned
  counts <- getCaseCounts(
    connectionHandler = connectionHandler, 
    schema = 'main'
  )
  
  testthat::expect_true(nrow(counts) > 0)
  
  testthat::expect_true( 'databaseName' %in% colnames(counts))
  testthat::expect_true( 'targetName' %in% colnames(counts))
  testthat::expect_true( 'outcomeName' %in% colnames(counts))
  testthat::expect_true( 'rowCount' %in% colnames(counts))
  testthat::expect_true( 'personCount' %in% colnames(counts))
  
  # check restriction works
  counts <- getCaseCounts(
    connectionHandler = connectionHandler, 
    schema = 'main', 
    targetIds = 1, 
    outcomeIds = 3
  )
  testthat::expect_true(unique(counts$targetId) == 1)
  testthat::expect_true(unique(counts$outcomeId) == 3)
})


test_that("getCaseBinaryFeatures", {
  # check results are returned
  data <- getCaseBinaryFeatures(
    connectionHandler = connectionHandler, 
    schema = 'main'
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  testthat::expect_true( 'databaseName' %in% colnames(data))
  testthat::expect_true( 'targetName' %in% colnames(data))
  testthat::expect_true( 'outcomeName' %in% colnames(data))
  testthat::expect_true( 'covariateName' %in% colnames(data))
  testthat::expect_true( 'sumValue' %in% colnames(data))
  
  # check restriction works
  data <- getCaseBinaryFeatures(
    connectionHandler = connectionHandler, 
    schema = 'main', 
    targetIds = 1, 
    outcomeIds = 3
  )
  testthat::expect_true(unique(data$targetCohortId) == 1)
  testthat::expect_true(unique(data$outcomeCohortId) == 3)
})

test_that("getTargetBinaryFeatures", {
  # check results are returned
  data <- getTargetBinaryFeatures(
    connectionHandler = connectionHandler, 
    schema = 'main'
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  testthat::expect_true( 'databaseName' %in% colnames(data))
  testthat::expect_true( 'targetName' %in% colnames(data))
  testthat::expect_true( 'outcomeName' %in% colnames(data))
  testthat::expect_true( 'covariateName' %in% colnames(data))
  testthat::expect_true( 'sumValue' %in% colnames(data))
  
  # check restriction works
  data <- getTargetBinaryFeatures(
    connectionHandler = connectionHandler, 
    schema = 'main', 
    targetIds = 1, 
    outcomeIds = 3
  )
  testthat::expect_true(unique(data$targetCohortId) == 1)
  testthat::expect_true(unique(data$outcomeCohortId) == 3)
})

test_that("getCharacterizationDemographics", {
  # age works
  data <- getCharacterizationDemographics(
    connectionHandler = connectionHandler, 
    schema = 'main', 
    type = 'age'
  )
  
  testthat::expect_true(nrow(data) > 0)
  testthat::expect_true(sum(data$cohortType == 'Cases') > 0)
  testthat::expect_true(sum(data$cohortType == 'Target') > 0)
  
  testthat::expect_true( 'databaseName' %in% colnames(data))
  testthat::expect_true( 'targetName' %in% colnames(data))
  testthat::expect_true( 'outcomeName' %in% colnames(data))
  testthat::expect_true( 'covariateName' %in% colnames(data))
  testthat::expect_true( 'sumValue' %in% colnames(data))
  testthat::expect_true( 'averageValue' %in% colnames(data))
  
  # sex works
  data <- getCharacterizationDemographics(
    connectionHandler = connectionHandler, 
    schema = 'main', 
    type = 'sex'
  )
  
  testthat::expect_true(nrow(data) > 0)
  testthat::expect_true(sum(data$cohortType == 'Cases') > 0)
  testthat::expect_true(sum(data$cohortType == 'Target') > 0)
  
  testthat::expect_true( 'databaseName' %in% colnames(data))
  testthat::expect_true( 'targetName' %in% colnames(data))
  testthat::expect_true( 'outcomeName' %in% colnames(data))
  testthat::expect_true( 'covariateName' %in% colnames(data))
  testthat::expect_true( 'sumValue' %in% colnames(data))
  testthat::expect_true( 'averageValue' %in% colnames(data))
  
  
  # other type fails
  testthat::expect_error(
    getCharacterizationDemographics(
      connectionHandler = connectionHandler, 
      schema = 'main', 
      type = 'none'
    )
  )
  
})

test_that("getTargetBinaryFeatures", {
  # check results are returned
  data <- getTargetBinaryFeatures(
    connectionHandler = connectionHandler, 
    schema = 'main'
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  testthat::expect_true( 'databaseName' %in% colnames(data))
  testthat::expect_true( 'targetName' %in% colnames(data))
  testthat::expect_true( 'outcomeName' %in% colnames(data))
  testthat::expect_true( 'covariateName' %in% colnames(data))
  testthat::expect_true( 'sumValue' %in% colnames(data))
  
  # check restriction works
  data <- getTargetBinaryFeatures(
    connectionHandler = connectionHandler, 
    schema = 'main', 
    targetIds = 1, 
    outcomeIds = 3
  )
  testthat::expect_true(unique(data$targetCohortId) == 1)
  testthat::expect_true(unique(data$outcomeCohortId) == 3)
})

test_that("getBinaryRiskFactors", {
  # age works
  data <-  getBinaryRiskFactors(
    connectionHandler = connectionHandler, 
    schema = 'main', 
    targetId = 1, 
    outcomeId = 3,
    analysisIds = c(1,3,410, 210)
  )
  
  testthat::expect_true(nrow(data) > 0)

  testthat::expect_true( 'databaseName' %in% colnames(data))
  testthat::expect_true( 'targetName' %in% colnames(data))
  testthat::expect_true( 'outcomeName' %in% colnames(data))
  testthat::expect_true( 'covariateName' %in% colnames(data))
  testthat::expect_true( 'caseCount' %in% colnames(data))
  testthat::expect_true( 'caseAverage' %in% colnames(data))
  testthat::expect_true( 'nonCaseCount' %in% colnames(data))
  testthat::expect_true( 'nonCaseAverage' %in% colnames(data))
  testthat::expect_true( 'SMD' %in% colnames(data))
  
  # add code to test values sum to 1
  data <-  getBinaryRiskFactors(
    connectionHandler = connectionHandler, 
    schema = 'main', 
    targetId = 1, 
    outcomeId = 3,
    analysisIds = c(1)
  )
  
  testthat::expect_true(sum(data$nonCaseAverage) == 1)
  testthat::expect_true(sum(data$caseAverage) == 1)
  
})


test_that("getContinuousRiskFactors", {
  # age works
  data <-  getContinuousRiskFactors(
    connectionHandler = connectionHandler, 
    schema = 'main', 
    targetId = 1, 
    outcomeId = 3
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  testthat::expect_true( 'databaseName' %in% colnames(data))
  testthat::expect_true( 'targetName' %in% colnames(data))
  testthat::expect_true( 'outcomeName' %in% colnames(data))
  testthat::expect_true( 'covariateName' %in% colnames(data))
  testthat::expect_true( 'caseCountValue' %in% colnames(data))
  testthat::expect_true( 'caseAverageValue' %in% colnames(data))
  testthat::expect_true( 'targetCountValue' %in% colnames(data))
  testthat::expect_true( 'targetAverageValue' %in% colnames(data))
  testthat::expect_true( 'SMD' %in% colnames(data))
  
})

test_that("getBinaryCaseSeries", {
  # age works
  data <-  getBinaryCaseSeries(
    connectionHandler = connectionHandler, 
    schema = 'main', 
    targetId = 1, 
    outcomeId = 3
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  testthat::expect_true( 'databaseName' %in% colnames(data))
  testthat::expect_true( 'targetName' %in% colnames(data))
  testthat::expect_true( 'outcomeName' %in% colnames(data))
  testthat::expect_true( 'covariateName' %in% colnames(data))
  testthat::expect_true( 'minPriorObservation' %in% colnames(data))
  testthat::expect_true( 'outcomeWashoutDays' %in% colnames(data))
  testthat::expect_true( 'casePostOutcomeDuration' %in% colnames(data))
  testthat::expect_true( 'casePreTargetDuration' %in% colnames(data))
  testthat::expect_true( 'riskWindowStart' %in% colnames(data))
  testthat::expect_true( 'startAnchor' %in% colnames(data))
  testthat::expect_true( 'riskWindowEnd' %in% colnames(data))
  testthat::expect_true( 'endAnchor' %in% colnames(data))
  testthat::expect_true( 'sumValue' %in% colnames(data))
  testthat::expect_true( 'averageValue' %in% colnames(data))
  testthat::expect_true( 'type' %in% colnames(data))
  
})

test_that("getContinuousCaseSeries", {
  # age works
  data <-  getContinuousCaseSeries(
    connectionHandler = connectionHandler, 
    schema = 'main', 
    targetId = 1, 
    outcomeId = 3
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  testthat::expect_true( 'databaseName' %in% colnames(data))
  testthat::expect_true( 'targetName' %in% colnames(data))
  testthat::expect_true( 'outcomeName' %in% colnames(data))
  testthat::expect_true( 'covariateName' %in% colnames(data))
  testthat::expect_true( 'minPriorObservation' %in% colnames(data))
  testthat::expect_true( 'outcomeWashoutDays' %in% colnames(data))
  testthat::expect_true( 'casePostOutcomeDuration' %in% colnames(data))
  testthat::expect_true( 'casePreTargetDuration' %in% colnames(data))
  testthat::expect_true( 'riskWindowStart' %in% colnames(data))
  testthat::expect_true( 'startAnchor' %in% colnames(data))
  testthat::expect_true( 'riskWindowEnd' %in% colnames(data))
  testthat::expect_true( 'endAnchor' %in% colnames(data))
  testthat::expect_true( 'countValue' %in% colnames(data))
  testthat::expect_true( 'averageValue' %in% colnames(data))
  testthat::expect_true( 'standardDeviation' %in% colnames(data))
  testthat::expect_true( 'type' %in% colnames(data))
  
})
