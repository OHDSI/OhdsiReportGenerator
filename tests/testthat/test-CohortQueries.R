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
  