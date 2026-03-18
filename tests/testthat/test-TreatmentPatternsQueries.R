test_that("cohorts used in treatment patterns analysis", {
  analysisCohorts <- getAnalysisCohorts(
    connectionHandler = connectionHandler,
    schema = "main"
  )
  
  testthat::expect_true("databaseName" %in% colnames(analysisCohorts))
  testthat::expect_true("databaseId" %in% colnames(analysisCohorts))
  testthat::expect_true("analysisId" %in% colnames(analysisCohorts))
  testthat::expect_true("targetCohortName" %in% colnames(analysisCohorts))
  testthat::expect_true("targetCohortId" %in% colnames(analysisCohorts))
  testthat::expect_true("eventCohortList" %in% colnames(analysisCohorts))
  testthat::expect_true("exitCohortList" %in% colnames(analysisCohorts))
})

test_that("get pathways", {
  pathways <- getTreatmentPathways(
    connectionHandler = connectionHandler,
    schema = "main",
    analysisIds = c(2),
    targetIds = c(11),
    databaseIds = c("388020256"),
    databaseNames = c("Synthea")
  )

  testthat::expect_true("databaseName" %in% colnames(pathways))
  testthat::expect_true("databaseId" %in% colnames(pathways))
  testthat::expect_true("analysisId" %in% colnames(pathways))
  testthat::expect_true("targetCohortName" %in% colnames(pathways))
  testthat::expect_true("targetCohortId" %in% colnames(pathways))
  testthat::expect_true("pathway" %in% colnames(pathways))
  testthat::expect_true("freq" %in% colnames(pathways))
  testthat::expect_true("age" %in% colnames(pathways))
  testthat::expect_true("indexYear" %in% colnames(pathways))
  testthat::expect_true("sex" %in% colnames(pathways))
  testthat::expect_true(all(pathways$analysisId == 2))
})

test_that("get event duration", {
  eventDuration <- getEventDuration(
    connectionHandler = connectionHandler,
    schema = "main",
    analysisIds = c(1, 2)
  )


  testthat::expect_true("databaseName" %in% colnames(eventDuration))
  testthat::expect_true("databaseId" %in% colnames(eventDuration))
  testthat::expect_true("analysisId" %in% colnames(eventDuration))
  testthat::expect_true("targetCohortName" %in% colnames(eventDuration))
  testthat::expect_true("targetCohortId" %in% colnames(eventDuration))
  testthat::expect_true("eventName" %in% colnames(eventDuration))
  testthat::expect_true("rank" %in% colnames(eventDuration))
  testthat::expect_true("eventCount" %in% colnames(eventDuration))
  testthat::expect_true("durationAverage" %in% colnames(eventDuration))
  testthat::expect_true("durationMax" %in% colnames(eventDuration))
  testthat::expect_true("durationMin" %in% colnames(eventDuration))
  testthat::expect_true("durationMedian" %in% colnames(eventDuration))
  testthat::expect_true("p25Value" %in% colnames(eventDuration))
  testthat::expect_true("p75Value" %in% colnames(eventDuration))
  testthat::expect_true("standardDeviation" %in% colnames(eventDuration))
})