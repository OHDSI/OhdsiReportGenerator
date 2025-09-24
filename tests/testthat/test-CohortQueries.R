context("CohortQueries")

test_that("getCohortDefinitions", {
  
  cohorts <- getCohortDefinitions(
    connectionHandler = connectionHandler,
    schema = schema
  )
  
  testthat::expect_true(nrow(cohorts) > 0)
  
  testthat::expect_true('cohortDefinitionId' %in% colnames(cohorts))
  testthat::expect_true('cohortName' %in% colnames(cohorts))
  testthat::expect_true('description' %in% colnames(cohorts))
  testthat::expect_true('json' %in% colnames(cohorts))
  testthat::expect_true('sqlCommand' %in% colnames(cohorts))
  testthat::expect_true('subsetParent' %in% colnames(cohorts))
  testthat::expect_true('isSubset' %in% colnames(cohorts))
  testthat::expect_true('subsetDefinitionId' %in% colnames(cohorts))
  
})

test_that("processCohorts", {
  
  cohorts <- getCohortDefinitions(
    connectionHandler = connectionHandler,
    schema = schema
  )

  parents <- processCohorts(cohorts)
  
  # check correct number of parents
  testthat::expect_true(sum(is.na(cohorts$subsetDefinitionId)) == length(parents$parents))
  
  # check all cohorts are in the parents list
  testthat::expect_true(nrow(do.call('rbind', parents$cohortList)) == nrow(cohorts))
  
})


test_that("getCohortSubsetDefinitions", {
  
  subsetDef <- getCohortSubsetDefinitions(
    connectionHandler,
    schema
    )
  
  # make sure results are returned
  testthat::expect_true(nrow(subsetDef) > 0)
  
  firstJson <- ParallelLogger::convertJsonToSettings(subsetDef$json[1])
  
  # check key entries
  testthat::expect_true('name' %in% names(firstJson))
  testthat::expect_true('definitionId' %in% names(firstJson))
  testthat::expect_true('subsetOperators' %in% names(firstJson))
  
})


test_that("getCohortInclusionStats", {
  
  result <- getCohortInclusionStats(
    connectionHandler,
    schema
  )
  
  # check key entries
  testthat::expect_true('databaseId' %in% colnames(result))
  testthat::expect_true('databaseName' %in% colnames(result))
  testthat::expect_true('cohortDefinitionId' %in% colnames(result))
  testthat::expect_true('cohortName' %in% colnames(result))
  testthat::expect_true('inclusionRuleMask' %in% colnames(result))
  testthat::expect_true('personCount' %in% colnames(result))
  testthat::expect_true('modeId' %in% colnames(result))
})


test_that("getCohortInclusionRules", {
  
  result <- getCohortInclusionRules(
    connectionHandler,
    schema
  )
  
  # check key entries
  testthat::expect_true('cohortDefinitionId' %in% colnames(result))
  testthat::expect_true('cohortName' %in% colnames(result))
  testthat::expect_true('ruleName' %in% colnames(result))
  testthat::expect_true('ruleSequence' %in% colnames(result))
})

test_that("getCohortInclusionSummary", {
  
  result <- getCohortInclusionSummary(
    connectionHandler,
    schema
  )
  
  # check key entries
  testthat::expect_true('cohortDefinitionId' %in% colnames(result))
  testthat::expect_true('cohortName' %in% colnames(result))
  testthat::expect_true('baseCount' %in% colnames(result))
  testthat::expect_true('finalCount' %in% colnames(result))
  testthat::expect_true('modeId' %in% colnames(result))
  testthat::expect_true('databaseName' %in% colnames(result))
  testthat::expect_true('databaseId' %in% colnames(result))
})


test_that("getCohortMeta", {
  
  result <- getCohortMeta(
    connectionHandler,
    schema
  )
  
  # check key entries
  testthat::expect_true('cohortId' %in% colnames(result))
  testthat::expect_true('cohortName' %in% colnames(result))
  testthat::expect_true('generationStatus' %in% colnames(result))
  testthat::expect_true('startTime' %in% colnames(result))
  testthat::expect_true('endTime' %in% colnames(result))
  testthat::expect_true('databaseName' %in% colnames(result))
  testthat::expect_true('databaseId' %in% colnames(result))
})


test_that("getCohortCounts", {
  
  result <- getCohortCounts(
    connectionHandler,
    schema
  )
  
  # check key entries
  testthat::expect_true('cohortId' %in% colnames(result))
  testthat::expect_true('cohortName' %in% colnames(result))
  testthat::expect_true('cohortEntries' %in% colnames(result))
  testthat::expect_true('cohortSubjects' %in% colnames(result))
  testthat::expect_true('databaseName' %in% colnames(result))
  testthat::expect_true('databaseId' %in% colnames(result))
})
  