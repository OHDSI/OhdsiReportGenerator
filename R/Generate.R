#' generatePresentationMultiple
#'
#' @description
#' Generates a presentation from a Strategus result
#'
#' @details
#' Specify the connection details to the result database and the schema name
#' to generate a presentation.
#' 
#' @param server The server containing the result database
#' @param username The username for an account that can access the result database
#' @param password The password for an account that can access the result database
#' @param dbms The dbms used to access the result database
#' @param resultsSchema The result database schema
#' @param targetId The cohort definition id for the target cohort
#' @param targetName A friendly name for the target cohort
#' @param cmSubsetId Optional a subset ID for the cohort method/prediction results
#' @param sccsSubsetId Optional a subset ID for the SCCS and characterization results 
#' @param indicationName A name for the indication if used or NULL
#' @param outcomeIds The cohort definition id for the outcome
#' @param outcomeNames Friendly names for the outcomes
#' @param comparatorIds The cohort method comparator cohort id
#' @param comparatorNames Friendly names for the comparators
#' @param covariateIds A vector of covariateIds to include in the characterization
#' @param details a list with the studyPeriod and restrictions 
#' @param title A title for the presentation
#' @param lead The name of the presentor
#' @param date The date of the presentation
#' @param backgroundText a character with any background text
#' @param evaluationText a list of bullet points for the evaluation 
#' @param outputLocation The file location and name to save the protocol 
#' @param outputName The name of the html protocol that is created
#' @param intermediateDir The work directory for quarto
#' 
#' @return
#' An named R list with the elements 'standard' and 'source'
#' 
#' @family Reporting
#'
#' @export
#' 
generatePresentationMultiple <- function(
    server,
    username,
    password,
    dbms,
    resultsSchema = NULL,
    targetId = 1,
    targetName = "target cohort",
    cmSubsetId = 2,
    sccsSubsetId = NULL,
    indicationName = NULL,
    outcomeIds = 3,
    outcomeNames = 'outcome cohort',
    comparatorIds = c(2,4),
    comparatorNames = c("comparator cohort 1", "comparator cohort 2"),
    covariateIds = NULL,
    details = list(
      studyPeriod = 'All Time',
      restrictions = "Age - None"
    ),
    title = 'ASSURE 001 ...',
    lead = 'add name',
    date = Sys.Date(),
    backgroundText = '',
    evaluationText = '',
    outputLocation,
    outputName = paste0('presentation_', gsub(':', '_',gsub(' ','_',as.character(date()))),'.html'),
    intermediateDir = tempdir()
){
  
  if(missing(outputLocation)){
    stop('Must enter location for outputLocation')
  }
  
  # calling random functions used in quarto doc 
  # as otherwise check fails
  pointless <- ggpubr::bgcolor('red')
  
  templateLoc <- system.file(
    'templates', 
    package = "OhdsiReportGenerator"
  )
  
  if(!dir.exists(file.path(intermediateDir, 'presentation'))){
    dir.create(file.path(intermediateDir, 'presentation'), recursive = TRUE)
  }
  
  filesOfInt <- c(
    dir(templateLoc, pattern = '.Rmd'),
    dir(templateLoc, pattern = '.qmd'),
    dir(templateLoc, pattern = '.scss')
  )
  
  file.copy(
    from = file.path(templateLoc, filesOfInt), 
    to = file.path(file.path(intermediateDir, 'presentation'), filesOfInt)
  )
  
  # move img folder
  if(!dir.exists(file.path(intermediateDir, 'presentation', 'img'))){
    dir.create(file.path(intermediateDir, 'presentation', 'img'), recursive = TRUE)
  }
  imgOfInt <- dir(file.path(templateLoc, 'img'))
  file.copy(
    from = file.path(templateLoc, 'img', imgOfInt), 
    to = file.path(file.path(intermediateDir, 'presentation', 'img'), imgOfInt)
  )
  
  quarto::quarto_render(
    input = file.path(intermediateDir, 'presentation', "assure_study_presentation_multiple.qmd"), 
    execute_params = list(
      server = server,
      username = username,
      password = password,
      dbms = dbms,
      resultsSchema = resultsSchema,
      targetId = targetId,
      targetName = targetName,
      cmSubsetId = cmSubsetId,
      sccsSubsetId = sccsSubsetId,
      indicationName = indicationName,
      outcomeIds = outcomeIds,
      outcomeNames = outcomeNames,
      comparatorIds = comparatorIds,
      comparatorNames = comparatorNames,
      covariateIds = covariateIds,
      title = title,
      lead = lead,
      date = date,
      details = details,
      evaluationText = evaluationText
    )
  )
  
  # now move html output to output location
  if(!dir.exists(outputLocation)){
    dir.create(outputLocation, recursive = TRUE)
  }
  file.copy(
    from = file.path(intermediateDir, 'presentation', 'assure_study_presentation_multiple.html'), 
    to = file.path(outputLocation, outputName)
  )
  
  return(file.path(outputLocation, outputName))
}