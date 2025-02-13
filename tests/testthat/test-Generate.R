context("Generate")

test_that("generatePresentationMultiple", {
  
  savLoc <- file.path(tempdir(), 'example')
  if(!dir.exists(savLoc)){
    dir.create(savLoc)
  }
  
  generatePresentationMultiple(
    server = conDet$server(),
    username = conDet$user(),
    password = conDet$password(),
    dbms = conDet$dbms,
    resultsSchema = schema,
    targetId = 1002,
    subsetId = NULL,
    includeIndication = F,
    outcomeIds = 3,
    comparatorIds = 2002,
    covariateIds = NULL,
    friendlyNames = list(
      targetName = "target cohort",
      comparatorNames = c("comparator cohort 1"),
      indicationName = "indication cohort",
      outcomeNames = c("outcome name 1")
    ),
    details = list(
      studyPeriod = 'All Time',
      restrictions = "Age - None"
    ),
    title = 'ASSURE 001 ...',
    lead = 'add name',
    date = Sys.Date(),
    backgroundText = '',
    evaluationText = '',
    outputLocation = savLoc,
    outputName = paste0('presentation_', gsub(':', '_',gsub(' ','_',as.character(date()))),'.html'),
    intermediateDir = tempdir()
  )
  
  # ensure report is generated
  testthat::expect_true(length(dir(savLoc, pattern = '.html', full.names = T)) > 0)
 
  # clean up and remove file
  file.remove(dir(savLoc, pattern = '.html', full.names = T))
   
})