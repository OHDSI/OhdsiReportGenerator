context("Helpers")

test_that("getTargetTable", {
  
  targetTable <- getTargetTable(
    connectionHandler, 
    schema
    )
  
  testthat::expect_true(nrow(targetTable) > 0)
  
  testthat::expect_true("cohortId" %in% colnames(targetTable))
  testthat::expect_true("cohortName" %in% colnames(targetTable))
  testthat::expect_true("subsetParent" %in% colnames(targetTable))
  testthat::expect_true("subsetDefinitionId" %in% colnames(targetTable))
  testthat::expect_true("numDatabase" %in% colnames(targetTable))
  testthat::expect_true("databaseString" %in% colnames(targetTable))
  testthat::expect_true("minSubjectCount" %in% colnames(targetTable))
  testthat::expect_true("maxSubjectCount" %in% colnames(targetTable))
  
  
})

test_that("getParentTable", {
  
  targetTable <- getTargetTable(
    connectionHandler, 
    schema
  )
  
  parentTable <- getParentTable(targetTable)
  
  testthat::expect_true(nrow(parentTable) > 0)
  
  testthat::expect_true("cohortId" %in% colnames(parentTable))
  testthat::expect_true("cohortName" %in% colnames(parentTable))
  testthat::expect_true("subsetParent" %in% colnames(parentTable))
  testthat::expect_true("subsetDefinitionId" %in% colnames(parentTable))
  testthat::expect_true("numDatabase" %in% colnames(parentTable))
  testthat::expect_true("databaseString" %in% colnames(parentTable))
  testthat::expect_true("minSubjectCount" %in% colnames(parentTable))
  testthat::expect_true("maxSubjectCount" %in% colnames(parentTable))
  
  testthat::expect_true("numChildren" %in% colnames(parentTable))
  testthat::expect_true("minChildrenSubjectCount" %in% colnames(parentTable))
  testthat::expect_true("maxChildrenSubjectCount" %in% colnames(parentTable))
  
})
