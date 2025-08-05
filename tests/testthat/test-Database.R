context("Database")

test_that("getExampleConnectionDetails", {
  
  dbs <- getDatabaseDetails(
    connectionHandler = connectionHandler, 
    schema = schema
  )
  
  testthat::expect_true(inherits(dbs, 'data.frame'))
  testthat::expect_true(nrow(dbs) > 0)
  
})
