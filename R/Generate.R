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
#' @param comparatorIds (optional) The cohort definition id for any comparator cohorts.  If NULL the report will find and include all possible comparators in the results if includeCohortMethod is TRUE. 
#' @param indicationIds The cohort definition id for any indication cohorts to show in characterization. If no indication use NULL. 
#' @param restrictTargetToIndications If you only want the results for targets that are nested by the indicationIds set this to TRUE otherwise results for all children of the targetId will be generated.
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
    indicationIds = NULL,
    restrictTargetToIndications = FALSE,
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
  
  # check ResultModelManager is installed as it is used
  # in quarto code
  rlang::check_installed("ResultModelManager")
  rlang::check_installed("htmltools")
  
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
      restrictTargetToIndications = restrictTargetToIndications,
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