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
