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

test_that("getSccsEstimation", {
  
  data <- getSccsEstimation(
    connectionHandler = connectionHandler,
    schema = schema
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  testthat::expect_true('databaseName' %in% colnames(data))
  testthat::expect_true('analysisId' %in% colnames(data))
  testthat::expect_true('description' %in% colnames(data))
  testthat::expect_true('targetName' %in% colnames(data))
  testthat::expect_true('outcomeName' %in% colnames(data))
  testthat::expect_true('calibratedRr' %in% colnames(data))
  testthat::expect_true('calibratedP' %in% colnames(data))
  testthat::expect_true('calibratedLogRr' %in% colnames(data))
  testthat::expect_true('calibratedSeLogRr' %in% colnames(data))
  testthat::expect_true('outcomeSubjects' %in% colnames(data))
  testthat::expect_true('outcomeEvents' %in% colnames(data))
  testthat::expect_true('outcomeObservationPeriods' %in% colnames(data))
  testthat::expect_true('covariateSubjects' %in% colnames(data))
  testthat::expect_true('covariateDays' %in% colnames(data))
  testthat::expect_true('covariateEras' %in% colnames(data))
  testthat::expect_true('covariateOutcomes' %in% colnames(data))
  testthat::expect_true('observedDays' %in% colnames(data))
})


test_that("getSccsDiagnosticsData", {
  
  data <- getSccsDiagnosticsData(
    connectionHandler = connectionHandler,
    schema = schema
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  testthat::expect_true('databaseName' %in% colnames(data))
  testthat::expect_true('analysisId' %in% colnames(data))
  testthat::expect_true('description' %in% colnames(data))
  testthat::expect_true('targetName' %in% colnames(data))
  testthat::expect_true('outcomeName' %in% colnames(data))
  testthat::expect_true('mdrr' %in% colnames(data))
  testthat::expect_true('ease' %in% colnames(data))
  testthat::expect_true('timeTrendP' %in% colnames(data))
  testthat::expect_true('preExposureP' %in% colnames(data))
  testthat::expect_true('mdrrDiagnostic' %in% colnames(data))
  testthat::expect_true('easeDiagnostic' %in% colnames(data))
  testthat::expect_true('timeTrendDiagnostic' %in% colnames(data))
  testthat::expect_true('preExposureDiagnostic' %in% colnames(data))
  testthat::expect_true('unblind' %in% colnames(data))
  testthat::expect_true('unblindForEvidenceSynthesis' %in% colnames(data))
  testthat::expect_true('summaryValue' %in% colnames(data))
  
})


test_that("getSccsMetaEstimation", {
  
  # TODO get results into example?
  data <- getSccsMetaEstimation(
    connectionHandler = connectionHandler,
    schema = schema
  )
  
  testthat::expect_true('databaseName' %in% colnames(data))
  testthat::expect_true('analysisId' %in% colnames(data))
  testthat::expect_true('description' %in% colnames(data))
  testthat::expect_true('targetName' %in% colnames(data))
  testthat::expect_true('outcomeName' %in% colnames(data))
  
  testthat::expect_true('outcomeSubjects' %in% colnames(data))
  testthat::expect_true('outcomeEvents' %in% colnames(data))
  testthat::expect_true('outcomeObservationPeriods' %in% colnames(data))
  testthat::expect_true('covariateSubjects' %in% colnames(data))
  testthat::expect_true('observedDays' %in% colnames(data))

  testthat::expect_true('calibratedRr' %in% colnames(data))
  testthat::expect_true('calibratedP' %in% colnames(data))
  testthat::expect_true('calibratedOneSidedP' %in% colnames(data))
  testthat::expect_true('calibratedLogRr' %in% colnames(data))
  testthat::expect_true('calibratedSeLogRr' %in% colnames(data))
  testthat::expect_true('nDatabases' %in% colnames(data))
})


test_that("getCmOutcomes", {
  
  data <- getCmOutcomes(
    connectionHandler = connectionHandler, 
    schema = schema
  )
  
  testthat::expect_true(nrow(data) > 0)
  testthat::expect_true(data$cohortDefinitionId[1] == 3)
  
  data <- getCmOutcomes(
    connectionHandler = connectionHandler, 
    schema = schema, 
    targetId = c(1002,1)
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  # not a target in the prediction results
  data <- getCmOutcomes(
    connectionHandler = connectionHandler, 
    schema = schema, 
    targetId = 5
  )
  
  testthat::expect_true(nrow(data) == 0)
  
  
  
})

test_that("getSccsOutcomes", {
  
  data <- getSccsOutcomes(
    connectionHandler = connectionHandler, 
    schema = schema
  )
  
  testthat::expect_true(nrow(data) > 0)
  testthat::expect_true(data$cohortDefinitionId[1] == 3)
  
  data <- getSccsOutcomes(
    connectionHandler = connectionHandler, 
    schema = schema, 
    targetId = c(1002,1, 1001)
  )
  
  testthat::expect_true(nrow(data) > 0)
  
  # not a target in the prediction results
  data <- getSccsOutcomes(
    connectionHandler = connectionHandler, 
    schema = schema, 
    targetId = 5
  )
  
  testthat::expect_true(nrow(data) == 0)
  
  
  
})

test_that("getSccsTable", {
  
dataA <- OhdsiReportGenerator:::getSccsTable(
    connectionHandler = connectionHandler,
    schema = schema,
    table = 'attrition',
    sccsTablePrefix = 'sccs_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data'
)

testthat::expect_true(nrow(dataA) > 0)
testthat::expect_true("databaseName" %in% colnames(dataA))
testthat::expect_true("outcomeName" %in% colnames(dataA))
testthat::expect_true("indicationName" %in% colnames(dataA))
testthat::expect_true("outcomeSubjects" %in% colnames(dataA))

dataAsub <- OhdsiReportGenerator:::getSccsTable(
  connectionHandler = connectionHandler,
  schema = schema,
  table = 'attrition',
  sccsTablePrefix = 'sccs_',
  cgTablePrefix = 'cg_',
  databaseTable = 'database_meta_data',
  analysisIds =  1, 
  databaseIds = 388020256, 
  covariateIds = 1001,
  exposureOutcomeIds = 2086096871
)

# check filtering works
testthat::expect_true(nrow(dataAsub) > 0)
testthat::expect_true(unique(dataAsub$exposuresOutcomeSetId) == 2086096871)
testthat::expect_true(unique(dataAsub$covariateId) == 1001)
testthat::expect_true(unique(dataAsub$databaseId) == 388020256)
testthat::expect_true(unique(dataAsub$analysisId) == 1)

dataAsub2 <- OhdsiReportGenerator:::getSccsTable(
  connectionHandler = connectionHandler,
  schema = schema,
  table = 'attrition',
  sccsTablePrefix = 'sccs_',
  cgTablePrefix = 'cg_',
  databaseTable = 'database_meta_data',
  analysisIds =  1, 
  databaseIds = 388020256, 
  covariateIds = 1001,
  outcomeIds = 3
)
# check filtering bt outcomeId works
testthat::expect_true(nrow(dataAsub2) > 0)
testthat::expect_true(unique(dataAsub2$outcomeId) == 3)
testthat::expect_true(unique(dataAsub2$covariateId) == 1001)
testthat::expect_true(unique(dataAsub2$databaseId) == 388020256)
testthat::expect_true(unique(dataAsub2$analysisId) == 1)


dataTt <- getSccsTable(
  connectionHandler = connectionHandler,
  schema = schema,
  table = 'time_trend',
  sccsTablePrefix = 'sccs_',
  cgTablePrefix = 'cg_',
  databaseTable = 'database_meta_data'
)
testthat::expect_true(nrow(dataTt) > 0)
testthat::expect_true("databaseName" %in% colnames(dataTt))
testthat::expect_true("outcomeName" %in% colnames(dataTt))
testthat::expect_true("indicationName" %in% colnames(dataTt))
testthat::expect_true("calendarYear" %in% colnames(dataTt))
testthat::expect_true("calendarMonth" %in% colnames(dataTt))
testthat::expect_true("observedSubjects" %in% colnames(dataTt))

dataTtSub <- getSccsTable(
  connectionHandler = connectionHandler,
  schema = schema,
  table = 'time_trend',
  sccsTablePrefix = 'sccs_',
  cgTablePrefix = 'cg_',
  databaseTable = 'database_meta_data',
  analysisIds =  1, 
  databaseIds = 388020256, 
  covariateIds = 1001,
  exposureOutcomeIds = 2086096871
)

# check filtering works
testthat::expect_true(nrow(dataTtSub) > 0)
testthat::expect_true(unique(dataTtSub$exposuresOutcomeSetId) == 2086096871)
testthat::expect_true(unique(dataTtSub$databaseId) == 388020256)
testthat::expect_true(unique(dataTtSub$analysisId) == 1)


dataSub <- getSccsTable(
  connectionHandler = connectionHandler,
  schema = schema,
  table = 'event_dep_observation',
  sccsTablePrefix = 'sccs_',
  cgTablePrefix = 'cg_',
  databaseTable = 'database_meta_data',
  analysisIds =  1, 
  databaseIds = 388020256, 
  covariateIds = 1001,
  exposureOutcomeIds = 2086096871
)

# check filtering works
testthat::expect_true(nrow(dataSub) > 0)
testthat::expect_true(unique(dataSub$exposuresOutcomeSetId) == 2086096871)
testthat::expect_true(unique(dataSub$databaseId) == 388020256)
testthat::expect_true(unique(dataSub$analysisId) == 1)

dataSub <- getSccsTable(
  connectionHandler = connectionHandler,
  schema = schema,
  table = 'age_spanning',
  sccsTablePrefix = 'sccs_',
  cgTablePrefix = 'cg_',
  databaseTable = 'database_meta_data',
  analysisIds =  1, 
  databaseIds = 388020256, 
  covariateIds = 1001,
  exposureOutcomeIds = 2086096871
)
# check filtering works
testthat::expect_true(nrow(dataSub) > 0)
testthat::expect_true(unique(dataSub$exposuresOutcomeSetId) == 2086096871)
testthat::expect_true(unique(dataSub$databaseId) == 388020256)
testthat::expect_true(unique(dataSub$analysisId) == 1)

dataSub <- getSccsTable(
  connectionHandler = connectionHandler,
  schema = schema,
  table = 'calendar_time_spanning',
  sccsTablePrefix = 'sccs_',
  cgTablePrefix = 'cg_',
  databaseTable = 'database_meta_data',
  analysisIds =  1, 
  databaseIds = 388020256, 
  covariateIds = 1001,
  exposureOutcomeIds = 2086096871
)
# check filtering works
testthat::expect_true(nrow(dataSub) > 0)
testthat::expect_true(unique(dataSub$exposuresOutcomeSetId) == 2086096871)
testthat::expect_true(unique(dataSub$databaseId) == 388020256)
testthat::expect_true(unique(dataSub$analysisId) == 1)


dataSub <- getSccsTable(
  connectionHandler = connectionHandler,
  schema = schema,
  table =  'spline',
  sccsTablePrefix = 'sccs_',
  cgTablePrefix = 'cg_',
  databaseTable = 'database_meta_data',
  analysisIds =  1, 
  databaseIds = 388020256, 
  covariateIds = 1001,
  exposureOutcomeIds = 2086096871
)
# check filtering works
testthat::expect_true(nrow(dataSub) > 0)
testthat::expect_true(unique(dataSub$exposuresOutcomeSetId) == 2086096871)
testthat::expect_true(unique(dataSub$databaseId) == 388020256)
testthat::expect_true(unique(dataSub$analysisId) == 1)

# invalid table
testthat::expect_error(getSccsTable(
  connectionHandler = connectionHandler,
  schema = schema,
  table =  'madeup',
  sccsTablePrefix = 'sccs_',
  cgTablePrefix = 'cg_',
  databaseTable = 'database_meta_data'
))

})


test_that("getSccsModel", {
  
allModels <- getSccsModel(
    connectionHandler = connectionHandler,
    schema = schema
    )
testthat::expect_true(nrow(allModels) > 0)
testthat::expect_true("databaseName" %in% colnames(allModels))
testthat::expect_true("analysisDescription" %in% colnames(allModels))
testthat::expect_true("targetName" %in% colnames(allModels))
testthat::expect_true("outcomeName" %in% colnames(allModels))
testthat::expect_true("indicationName" %in% colnames(allModels))
testthat::expect_true("covariateName" %in% colnames(allModels))
testthat::expect_true("rr" %in% colnames(allModels))
testthat::expect_true("exposuresOutcomeSetId" %in% colnames(allModels))

noModels <- getSccsModel(
  connectionHandler = connectionHandler,
  schema = schema, 
  databaseIds = 535454 # fake 
)
testthat::expect_true(nrow(noModels) == 0)

noModels <- getSccsModel(
  connectionHandler = connectionHandler,
  schema = schema, 
  exposureOutcomeSetIds = 4343 # fake
)
testthat::expect_true(nrow(noModels) == 0)


})


test_that("getSccsNegativeControlEstimates", {
  
  allNCs <- getSccsNegativeControlEstimates(
    connectionHandler = connectionHandler,
    schema = schema
  )
  testthat::expect_true(nrow(allNCs) > 0)
  testthat::expect_true("databaseName" %in% colnames(allNCs))
  testthat::expect_true("analysisDescription" %in% colnames(allNCs))
  testthat::expect_true("targetName" %in% colnames(allNCs))
  testthat::expect_true("outcomeName" %in% colnames(allNCs))
  testthat::expect_true("indicationName" %in% colnames(allNCs))
  testthat::expect_true("exposuresOutcomeSetId" %in% colnames(allNCs))
  
  dbNCs <- getSccsNegativeControlEstimates(
    connectionHandler = connectionHandler,
    schema = schema, 
    databaseIds = 388020256, 
    targetIds = 1
  )
  testthat::expect_true(unique(dbNCs$databaseId) == 388020256)
  testthat::expect_true(unique(dbNCs$targetId) == 1)
  
  oneNCs <- getSccsNegativeControlEstimates(
    connectionHandler = connectionHandler,
    schema = schema, 
    databaseIds = 388020256, 
    exposuresOutcomeSetIds = 1513783871
  )
  testthat::expect_true(unique(oneNCs$exposuresOutcomeSetId) == 1513783871)
  testthat::expect_true(unique(oneNCs$databaseId) == 388020256)
  
})



test_that("getSccsTimeToEvent", {
  
  allTte <- getSccsTimeToEvent(
    connectionHandler = connectionHandler,
    schema = schema
  )
  testthat::expect_true(nrow( allTte) > 0)
  testthat::expect_true("databaseName" %in% colnames( allTte))
  testthat::expect_true("analysisDescription" %in% colnames( allTte))
  testthat::expect_true("targetName" %in% colnames( allTte))
  testthat::expect_true("outcomeName" %in% colnames( allTte))
  testthat::expect_true("indicationName" %in% colnames( allTte))
  testthat::expect_true("exposuresOutcomeSetId" %in% colnames( allTte))
  
  
  # check filter
  filterTte <- getSccsTimeToEvent(
    connectionHandler = connectionHandler,
    schema = schema, 
    databaseIds = 388020256, 
    exposuresOutcomeSetIds = 2086096871, 
    analysisIds = 1
  )
  
  testthat::expect_true(unique(filterTte$databaseId) == 388020256)
  testthat::expect_true(unique(filterTte$exposuresOutcomeSetId) == 2086096871)
  testthat::expect_true(unique(filterTte$analysisId) == 1)
  
})