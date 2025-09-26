#' generateSummaryPredictionReport
#'
#' @description
#' Generates a summary report for a given targets and outcomes
#'
#' @details
#' Specify the connection handler to the result database, the schema name
#' and the cohortId of interest to generate a html report summarizing the
#' performance of prediction models in the database.
#' 
#' @param connectionHandler The connection handler to the results database
#' @param schema The result database schema
#' @param targetIds The target cohort IDs of interest
#' @param outcomeIds The outcome cohort IDs of interest
#' @param plpTablePrefix The prediction table prefix
#' @param databaseTablePrefix The database table name e.g., database_meta_data
#' @param cgTablePrefix The cohort generator table prefix
#' @param outputFolder The folder name where file will be save to
#' @param outputFileName The file name of the saved report
#' @param intermediatesDir The work directory for rmarkdown
#' @param overwrite whether to overwrite any existing file at the outputFolder/outputFileName
#' 
#' @return
#' A html file is created with the summary report
#' 
#' @family Reporting
#'
#' @export
#' 
generateSummaryPredictionReport <- function(
    connectionHandler,
    schema,
    targetIds = NULL,
    outcomeIds = NULL,
    plpTablePrefix = 'plp_',
    databaseTablePrefix = '',
    cgTablePrefix = 'cg_',
    outputFolder,
    outputFileName = 'plp-summary.html',
    intermediatesDir = file.path(tempdir(), 'plp-prot'),
    overwrite = FALSE
){
  
  templateLoc <- system.file(
    'templates',
    'summary-templates', 
    package = "OhdsiReportGenerator"
  )
  
  if(!dir.exists(file.path(intermediatesDir,'prediction-summary','prediction-questions'))){
    dir.create(file.path(intermediatesDir,'prediction-summary','prediction-questions'), recursive = TRUE)
  }
  
  filesOfInt <- c(
    dir(templateLoc, pattern = '.qmd', recursive = TRUE)
  )
  file.copy(
    from = file.path(templateLoc, filesOfInt), 
    to = file.path(file.path(intermediatesDir, 'prediction-summary'), filesOfInt), 
    overwrite = TRUE
  )

  quarto::quarto_render(
    input = file.path(intermediatesDir,'prediction-summary', 'prediction-summary.qmd'), 
    execute_params = list(
      dbms = connectionHandler$connectionDetails$dbms,
      server = connectionHandler$connectionDetails$server(),
      username = connectionHandler$connectionDetails$user(),
      password = connectionHandler$connectionDetails$password(),
      schema = schema,
      targetIds = targetIds,
      outcomeIds = outcomeIds,
      plpTablePrefix = plpTablePrefix,
      databaseTablePrefix = databaseTablePrefix,
      cgTablePrefix = cgTablePrefix
    )
  )
  
  if(!dir.exists(outputFolder)){
    dir.create(outputFolder, recursive = TRUE)
  }
  file.copy(
    from = file.path(intermediatesDir, 'prediction-summary', 'prediction-summary.html'), 
    to = file.path(outputFolder, outputFileName), 
    overwrite = overwrite
  )
  
  
}
