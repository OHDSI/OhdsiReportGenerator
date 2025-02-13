context("PredictionReport")

test_that("create prediction report", {
  
  testthat::expect_true(!file.exists(file.path(tempdir(), 'main.html')))
  
  OhdsiReportGenerator:::createPredictionReport(
    connectionHandler, 
    schema = schema,
    plpTablePrefix = 'plp_',
    modelDesignId = 1,
    output = tempdir(),
    intermediatesDir = file.path(tempdir(), 'plp-prot'), 
    outputFormat = "html_document"
  )
  
  testthat::expect_true(file.exists(file.path(tempdir(), 'main.html')))
  # now remove the file
  file.remove(file.path(tempdir(), 'main.html'))
  
})


