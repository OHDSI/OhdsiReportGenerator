context("PredictionReport")

test_that("create prediction report", {
  
  skip('skip prediction report due to odd linux error')
  
  testthat::expect_true(!file.exists(file.path(tempdir(), 'main.html')))
  
  createPredictionReport(
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


