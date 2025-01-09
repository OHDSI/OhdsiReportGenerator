#' generatePresentation
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
#' @param subsetId Optional a subset ID for the cohort method/characterization and prediction results
#' @param outcomeId The cohort definition id for the outcome
#' @param comparatorId The cohort method comparator cohort id
#' @param covariateIds A vector of covariateIds to include in the characterization
#' @param friendlyNames a data.frame with friendly name conversions
#' @param details a list with the studyPeriod and restrictions 
#' @param title A title for the presentation
#' @param lead The name of the presentor
#' @param date The date of the presentation
#' @param backgroundText a character with any background text
#' @param evaluationText a list of bullet points for the evaluation 
#' @param outputLocation The file location and name to save the protocol 
#' @param outputName The name of the html protocol that is created
#' @param intermediateDir The work directory for quarto
#' @return
#' An named R list with the elements 'standard' and 'source'
#'
#' @export
#' 
generatePresentation <- function(
    server,
    username,
    password,
    dbms,
    resultsSchema = NULL,
    targetId,
    subsetId = NULL,
    outcomeId,
    comparatorId,
    covariateIds = NULL,
    friendlyNames = list(
      targetName = "target cohort",
      comparatorName = "comparator cohort",
      indicationName = "indication cohort",
      outcomeName = "outcome name"
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
    outputLocation = getwd(),
    outputName = paste0('presentation_', gsub(':', '_',gsub(' ','_',as.character(date()))),'.html'),
    intermediateDir = tempdir()
){
  
  templateLoc <- system.file(
    'templates', 
    package = "ReportGenerator"
    )
  
  if(!dir.exists(file.path(intermediateDir, 'presentation'))){
    dir.create(file.path(intermediateDir, 'presentation'), recursive = T)
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
    dir.create(file.path(intermediateDir, 'presentation', 'img'), recursive = T)
  }
  imgOfInt <- dir(file.path(templateLoc, 'img'))
  file.copy(
    from = file.path(templateLoc, 'img', imgOfInt), 
    to = file.path(file.path(intermediateDir, 'presentation', 'img'), imgOfInt)
  )
  
  quarto::quarto_render(
    input = file.path(intermediateDir, 'presentation', "assure_study_presentation.qmd"), 
    execute_params = list(
      server = server,
      username = username,
      password = password,
      dbms = dbms,
      resultsSchema = resultsSchema,
      targetId = targetId,
      subsetId = subsetId,
      outcomeId = outcomeId,
      comparatorId = comparatorId,
      covariateIds = covariateIds,
      friendlyNames = friendlyNames,
      title = title,
      lead = lead,
      date = date,
      details = details,
      evaluationText = evaluationText
    )
  )
  
  # now move html output to output location
  if(!dir.exists(outputLocation)){
    dir.create(outputLocation, recursive = T)
  }
  file.copy(
    from = file.path(intermediateDir, 'presentation', 'assure_study_presentation.html'), 
    to = file.path(outputLocation, outputName)
      )
  
  return(file.path(outputLocation, outputName))
}




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
#' @param subsetId Optional a subset ID for the cohort method/characterization and prediction results
#' @param includeIndication Whether an indication was used in this study
#' @param outcomeIds The cohort definition id for the outcome
#' @param comparatorIds The cohort method comparator cohort id
#' @param covariateIds A vector of covariateIds to include in the characterization
#' @param friendlyNames a data.frame with friendly name conversions
#' @param details a list with the studyPeriod and restrictions 
#' @param title A title for the presentation
#' @param lead The name of the presentor
#' @param date The date of the presentation
#' @param backgroundText a character with any background text
#' @param evaluationText a list of bullet points for the evaluation 
#' @param outputLocation The file location and name to save the protocol 
#' @param outputName The name of the html protocol that is created
#' @param intermediateDir The work directory for quarto
#' @return
#' An named R list with the elements 'standard' and 'source'
#'
#' @export
#' 
generatePresentationMultiple <- function(
    server,
    username,
    password,
    dbms,
    resultsSchema = NULL,
    targetId,
    subsetId = NULL,
    includeIndication = TRUE,
    outcomeIds,
    comparatorIds,
    covariateIds = NULL,
    friendlyNames = list(
      targetName = "target cohort",
      comparatorNames = c("comparator cohort 1", "comparator cohort 2"),
      indicationName = "indication cohort",
      outcomeNames = c("outcome name 1", "outcome name 2")
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
    outputLocation = getwd(),
    outputName = paste0('presentation_', gsub(':', '_',gsub(' ','_',as.character(date()))),'.html'),
    intermediateDir = tempdir()
){
  
  # calling random functions used in quarto doc 
  # as otherwise check fails
  pointless <- reactable::JS('')
  pointless <- ggpubr::bgcolor('red')
  
  templateLoc <- system.file(
    'templates', 
    package = "ReportGenerator"
  )
  
  if(!dir.exists(file.path(intermediateDir, 'presentation'))){
    dir.create(file.path(intermediateDir, 'presentation'), recursive = T)
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
    dir.create(file.path(intermediateDir, 'presentation', 'img'), recursive = T)
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
      subsetId = subsetId,
      includeIndication = includeIndication,
      outcomeIds = outcomeIds,
      comparatorIds = comparatorIds,
      covariateIds = covariateIds,
      friendlyNames = friendlyNames,
      title = title,
      lead = lead,
      date = date,
      details = details,
      evaluationText = evaluationText
    )
  )
  
  # now move html output to output location
  if(!dir.exists(outputLocation)){
    dir.create(outputLocation, recursive = T)
  }
  file.copy(
    from = file.path(intermediateDir, 'presentation', 'assure_study_presentation_multiple.html'), 
    to = file.path(outputLocation, outputName)
  )
  
  return(file.path(outputLocation, outputName))
}