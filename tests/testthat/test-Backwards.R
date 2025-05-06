context("Generate")

test_that("generatePresentationMultiple old works", {
  
  savLoc <- file.path(tempdir(), 'example_old')
  if(!dir.exists(savLoc)){
    dir.create(savLoc)
  }
  
  # should have a warning
  testthat::expect_warning(generatePresentationMultiple(
    server = conDet$server(),
    username = conDet$user(),
    password = conDet$password(),
    dbms = conDet$dbms,
    resultsSchema = schema,
    
    targetId = 1,
    targetName = 'target', 
    
    outcomeIds = 3,
    outcomeNames = 'outcome', 
    
    comparatorIds = 2, 
    comparatorNames = 'comp', 
    
    title = '', 
    
    lead = 'add name',
    date = as.character(Sys.Date()),
    
    covariateIds = NULL,
    details = list(
      studyPeriod = 'All Time',
      restrictions = "Age - None"
    ),
    evaluationText = '',
    outputLocation = savLoc,
    outputName = paste0('presentation_', gsub(':', '_',gsub(' ','_',as.character(date()))),'.html')
  ))
  
  # ensure report is generated
  testthat::expect_true(length(dir(savLoc, pattern = '.html', full.names = TRUE)) > 0)
 
  # clean up and remove file
  file.remove(dir(savLoc, pattern = '.html', full.names = TRUE))
   
})