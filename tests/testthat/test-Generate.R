
test_that("generateFullReport", {
  
  #if skipQuarto skip this on CRAN
  if(skipQuarto){
    testthat::skip_on_cran()
  }
  
  savLoc <- file.path(tempdir(), 'example2')
  if(!dir.exists(savLoc)){
    dir.create(savLoc)
  }
  
  generateFullReport(
    server = conDet$server(),
    username = conDet$user(),
    password = conDet$password(),
    dbms = conDet$dbms,
    resultsSchema = schema,
    
    targetId = 1,
    outcomeIds = 3,
    comparatorIds = 2,
    indicationIds = NULL,
    restrictTargetToIndications = FALSE,
    cohortNames = c('target','outcome','comp'),
    cohortIds = c(1,3,2),
    includeCI = TRUE,
    includeCharacterization = TRUE,
    includeCohortMethod = TRUE,
    includeSccs = FALSE,
    includePrediction = FALSE,
    webAPI = NULL, 
    authMethod = NULL, 
    outputLocation = savLoc,
    outputName = paste0('full_report_', gsub(':', '_',gsub(' ','_',as.character(date()))),'.html'),
    intermediateDir = tempdir()
  )
  
  # ensure report is generated
  testthat::expect_true(length(dir(savLoc, pattern = '.html', full.names = TRUE)) > 0)
  
  # clean up and remove file
  file.remove(dir(savLoc, pattern = '.html', full.names = TRUE))
  
})