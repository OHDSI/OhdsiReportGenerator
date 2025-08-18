#' createPredictionReport
#'
#' @description
#' Generates a report for a given prediction model design
#'
#' @details
#' Specify the connection handler to the result database, the schema name
#' and the modelDesignId of interest to generate a html report summarizing the
#' performance of models developed across databases.
#' 
#' @param connectionHandler The connection handler to the results database
#' @param schema The result database schema
#' @param plpTablePrefix The prediction table prefix
#' @param databaseTablePrefix The database table name e.g., database_meta_data
#' @param cgTablePrefix The cohort generator table prefix
#' @param modelDesignId The model design ID of interest
#' @param output The folder name where main.html will be save to
#' @param intermediatesDir The work directory for rmarkdown
#' @param outputFormat the type of outcome html_document or html_fragment
#' 
#' @return
#' An named R list with the elements 'standard' and 'source'
#' 
#' @family Reporting
#'
#' @export
#' 
createPredictionReport <- function(
    connectionHandler, 
    schema,
    plpTablePrefix,
    databaseTablePrefix = plpTablePrefix,
    cgTablePrefix = plpTablePrefix,
    modelDesignId,
    output,
    intermediatesDir = file.path(tempdir(), 'plp-prot'),
    outputFormat = "html_document" # NULL
){
  
  protocolLoc <- system.file(
    'templates',
    'patient-level-prediction-document', 
    "main.Rmd", 
    package = "OhdsiReportGenerator"
    )
  
  if(!dir.exists(intermediatesDir)){
    dir.create(intermediatesDir)
  }
  
  rmarkdown::render(
    output_format = outputFormat,
    input = protocolLoc, 
    intermediates_dir = intermediatesDir,
    output_dir = output, 
    params = list(
      connectionHandler = connectionHandler,
      resultSchema = schema, 
      myTableAppend = plpTablePrefix,
      modelDesignIds = modelDesignId,
      databaseTableAppend = databaseTablePrefix,
      cohortTableAppend = cgTablePrefix
    )
  )
  
  
}
