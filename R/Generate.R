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
#' @param dbDetails   (Optional) a data.frame with the columns:  
#' @param lead The name of the presenter 
#' @param team A vector or all the team members
#' @param trigger What triggered the request
#' @param safetyQuestion What is the general safety question
#' @param objective What is the request/objective of the work.
#' @param topline1 add a very brief executive summary for the topline slide
#' @param topline2 add estimation summary here for the topline slide
#' @param topline3 add any other statement summary here for the topline slide
#' @param date The date of the presentation
#' @param targetId The cohort definition id for the target cohort
#' @param outcomeIds The cohort definition id for the outcome
#' @param cohortNames Friendly names for any cohort used in the study
#' @param cohortIds  The corresponding Ids for the cohortNames
#' @param covariateIds A vector of covariateIds to include in the characterization
#' @param details a list with the studyPeriod and restrictions 
#' @param evaluationText a list of bullet points for the evaluation 
#' @param includeCI Whether to include the cohort incidence slides
#' @param includeCharacterization Whether to include the characterization slides
#' @param includeCM Whether to include the cohort method slides
#' @param includeSCCS Whether to include the self controlled case series slides
#' @param includePLP Whether to include the patient level prediction slides
#' @param outputLocation The file location and name to save the protocol 
#' @param outputName The name of the html protocol that is created
#' @param intermediateDir The work directory for quarto
#' @param pathToDriver Path to a folder containing the JDBC driver JAR files.
#' 
#' @return
#' An named R list with the elements 'standard' and 'source'
#' 
#' @family Reporting
#'
#' @export
#' 
generatePresentation <- function(
    server,
    username,
    password,
    dbms,
    resultsSchema = NULL,
    dbDetails = NULL,
    lead = 'add name',
    team = 'name 1 name 2',
    trigger = 'A signal was found in spontaneous reports',
    safetyQuestion = '',
    objective = '',
    topline1 = 'Very brief executive summary. You can copy-paste language from the conclusion.',
    topline2 = 'If an estimation was requested but not feasible, this should be mentioned here.',
    topline3 = 'If no estimation study was requested, this high-level summary might be skipped.',
    date = as.character(Sys.Date()),
    targetId = 1,
    outcomeIds = 3,
    cohortNames = c('target name','outcome name'),
    cohortIds = c(1,3),
    covariateIds = NULL,
    details = list(
      studyPeriod = 'All Time',
      restrictions = "Age - None"
    ),
    evaluationText = '',
    includeCI = TRUE,
    includeCharacterization = TRUE,
    includeCM = TRUE,
    includeSCCS = TRUE,
    includePLP = TRUE,
    outputLocation,
    outputName = paste0('presentation_', gsub(':', '_',gsub(' ','_',as.character(date()))),'.html'),
    intermediateDir = tempdir(),
    pathToDriver = Sys.getenv("DATABASECONNECTOR_JAR_FOLDER")
){
  
  if(missing(outputLocation)){
    stop('Must enter location for outputLocation')
  }
  
  # calling random functions used in quarto doc 
  # as otherwise check fails
  pointless <- ggpubr::bgcolor('red')
  
  templateLoc <- system.file(
    'templates','presentation', 
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
  if(!dir.exists(file.path(intermediateDir, 'presentation', 'pictures'))){
    dir.create(file.path(intermediateDir, 'presentation', 'pictures'), recursive = TRUE)
  }
  imgOfInt <- dir(file.path(templateLoc, 'pictures'))
  file.copy(
    from = file.path(templateLoc, 'pictures', imgOfInt), 
    to = file.path(file.path(intermediateDir, 'presentation', 'pictures'), imgOfInt)
  )
  
  quarto::quarto_render(
    input = file.path(intermediateDir, 'presentation', "assure_presentation.qmd"), 
    execute_params = list(
      server = server,
      username = username,
      password = password,
      dbms = dbms,
      resultsSchema = resultsSchema,
      dbDetails = dbDetails,
      lead = lead,
      team = team,
      trigger = trigger,
      safetyQuestion = safetyQuestion,
      objective = objective,
      topline1 = topline1,
      topline2 = topline2,
      topline3 = topline3,
      date = date,
      targetId = targetId,
      outcomeIds = outcomeIds,
      cohortNames = cohortNames,
      cohortIds = cohortIds,
      covariateIds = covariateIds,
      details = details,
      evaluationText = evaluationText,
      includeCI = includeCI,
      includeCharacterization = includeCharacterization,
      includeCM = includeCM,
      includeSCCS = includeSCCS,
      includePLP = includePLP,
      pathToDriver = pathToDriver
    )
  )
  
  # now move html output to output location
  if(!dir.exists(outputLocation)){
    dir.create(outputLocation, recursive = TRUE)
  }
  file.copy(
    from = file.path(intermediateDir, 'presentation', 'assure_presentation.html'), 
    to = file.path(outputLocation, outputName)
  )
  
  return(file.path(outputLocation, outputName))
}


#' generateFullReport
#'
#' @description
#' Generates a full report from a Strategus analysis
#'
#' @details
#' Specify the connection details to the result database and the schema name
#' to generate the full report.
#' 
#' @param server The server containing the result database
#' @param username The username for an account that can access the result database
#' @param password The password for an account that can access the result database
#' @param dbms The dbms used to access the result database
#' @param resultsSchema The result database schema
#' @param targetId The cohort definition id for the target cohort
#' @param outcomeIds The cohort definition id for the outcome
#' @param comparatorIds The cohort definition id for any comparator cohorts
#' @param indicationIds The cohort definition id for any indication cohorts (if no indication use '')
#' @param cohortNames Friendly names for any cohort used in the study
#' @param cohortIds  The corresponding Ids for the cohortNames
#' @param includeCI Whether to include the cohort incidence slides
#' @param includeCharacterization Whether to include the characterization slides
#' @param includeCohortMethod Whether to include the cohort method slides
#' @param includeSccs Whether to include the self controlled case series slides
#' @param includePrediction Whether to include the patient level prediction slides
#' @param webAPI The ATLAS web API to use for the characterization index breakdown (set to NULL to not include)
#' @param authMethod The authorization method for the webAPI
#' @param webApiUsername The username for the webAPI authorization
#' @param webApiPassword The password for the webAPI authorization
#' @param outputLocation The file location and name to save the protocol 
#' @param outputName The name of the html protocol that is created
#' @param intermediateDir The work directory for quarto
#' @param pathToDriver Path to a folder containing the JDBC driver JAR files.
#' 
#' @return
#' An html document containing the full results for the target, comparators, indications and outcomes specified.
#' 
#' @family Reporting
#'
#' @export
#' 
generateFullReport <- function(
    server,
    username,
    password,
    dbms,
    resultsSchema = NULL,
    targetId = 1,
    outcomeIds = 3,
    comparatorIds = 2,
    indicationIds = "",
    cohortNames = c('target name','outcome name', 'comp name'),
    cohortIds = c(1,3,2),
    includeCI = TRUE,
    includeCharacterization = TRUE,
    includeCohortMethod = TRUE,
    includeSccs = TRUE,
    includePrediction = TRUE,
    webAPI = NULL,
    authMethod = NULL,
    webApiUsername = NULL, 
    webApiPassword = NULL,
    outputLocation,
    outputName = paste0('full_report_', gsub(':', '_',gsub(' ','_',as.character(date()))),'.html'),
    intermediateDir = tempdir(),
    pathToDriver = Sys.getenv("DATABASECONNECTOR_JAR_FOLDER")
){
  
  if(missing(outputLocation)){
    stop('Must enter location for outputLocation')
  }
  
  # add code for gt?
  test <- gt::gt
  
  # add dummy code for CirceR as that is used in quarto
  # so needs to be in Description and used in the R folder
  CirceROptions <- CirceR::createGenerateOptions()
  
  templateLoc <- system.file(
    'templates','full-report', 
    package = "OhdsiReportGenerator"
  )
  
  if(!dir.exists(file.path(intermediateDir, 'full-report'))){
    dir.create(file.path(intermediateDir, 'full-report'), recursive = TRUE)
  }
  
  # add the char folder
  if(!dir.exists(file.path(intermediateDir, 'full-report', 'characterization'))){
    dir.create(file.path(intermediateDir, 'full-report','characterization'), recursive = TRUE)
  }
  
  filesOfInt <- c(
    dir(templateLoc, pattern = '.qmd', recursive = TRUE)
  )
  
  file.copy(
    from = file.path(templateLoc, filesOfInt), 
    to = file.path(file.path(intermediateDir, 'full-report'), filesOfInt)
  )
  
  quarto::quarto_render(
    input = file.path(intermediateDir, 'full-report', "main_template.qmd"), 
    execute_params = list(
      server = server,
      username = username,
      password = password,
      dbms = dbms,
      schema = resultsSchema,
      targetId = targetId,
      outcomeIds = outcomeIds,
      indicationIds = indicationIds,
      comparatorIds = comparatorIds,
      cohortIds = cohortIds,
      cohortNames = cohortNames,
      includeCI = includeCI,
      includeCharacterization = includeCharacterization,
      includeCohortMethod = includeCohortMethod,
      includeSccs = includeSccs,
      includePrediction = includePrediction,
      webAPI = webAPI,
      authMethod = authMethod,
      webApiUsername = webApiUsername, 
      webApiPassword = webApiPassword,
      pathToDriver = pathToDriver
    )
  )
  
  # now move html output to output location
  if(!dir.exists(outputLocation)){
    dir.create(outputLocation, recursive = TRUE)
  }
  file.copy(
    from = file.path(intermediateDir, 'full-report', 'main_template.html'), 
    to = file.path(outputLocation, outputName)
  )
  
  return(file.path(outputLocation, outputName))
}