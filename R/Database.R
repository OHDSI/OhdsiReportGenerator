#' Extract the database used in the analyses
#' @description
#' This function extracts the databases and their information.
#'
#' @details
#' Specify the connectionHandler, the schema and the database table name
#'
#' @template connectionHandler
#' @template schema
#' @template databaseTable
#' @family Database
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseFullName the full name of the database}
#'  \item{databaseName the friendly name of the database}
#'  \item{cdmHolder the license holder of the database}
#'  \item{sourceDescription a description of the database}
#'  \item{sourceDocumentationReference a link to the database information document}
#'  \item{cdmEtlReference a link to the ETL document}
#'  \item{sourceReleaseDatethe release date for the source database}
#'  \item(cdmReleaseDate the release date for the database mapped to the OMOP CDM)
#'  \item{cdmVersion the OMOP CDM version of the database}
#'  \item{cdmVersionConceptId the CDM version concept ID}
#'  \item{vocabularyVersion the database's vocabulary version}
#'  \item{databaseId a unique identifier for the database}
#'  \item{maxObsPeriodEndDate the last observational period end date in the database}
#'  } 
#' 
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' ir <- getIncidenceRates(
#' connectionHandler = connectionHandler, 
#' schema = 'main'
#' )
#'
getDatabaseDetails <- function(
    connectionHandler,
    schema,
    databaseTable = 'database_meta_data'
    ){
  
  sql <- "SELECT 
  cdm_source_name as database_full_name,
  cdm_source_abbreviation as database_name,
  cdm_holder,
  source_description,
  ISNULL(source_documentation_reference,'None') as source_documentation_reference,
  ISNULL(cdm_etl_reference,'None') as cdm_etl_reference,
  source_release_date,
  cdm_release_date,
  cdm_version,
  cdm_version_concept_id,
  vocabulary_version,
  database_id,
  max_obs_period_end_date
  
  from @schema.@database_table
  ;"

  result <- connectionHandler$queryDb(
      sql = sql,
      schema = schema,
      database_table = databaseTable
    )

  return(result)
}
