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