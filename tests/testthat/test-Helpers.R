context("Helpers")

test_that("getExampleConnectionDetails", {
  
  con <- getExampleConnectionDetails()
  testthat::expect_s3_class(con, 'ConnectionDetails')
  
})

# TODO
# removeSpaces
# formatCohortType
# getTars
# addTar
# getAnalyses
# getDbs