#' A function to add indexes to the Cohort Generator results
#'
#' @details
#' Specify the connectionHandler, the schema and the prefixes
#'
#' @template connectionHandler
#' @template schema
#' @template cgTablePrefix
#' @family Indexes
#' 
#' @return
#' NULL
#'
#' @export
createCohortIndexes <- function(
    connectionHandler,
    schema,
    cgTablePrefix = 'cg_'
){
  
  cgVersion <- round(
    .getCgVersion(
      connectionHandler = connectionHandler,
      schema = schema,
      cgTablePrefix = cgTablePrefix
    )
  )
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/cohort/indexesCgV", cgVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  connectionHandler$executeSql(
    sql = sql,
    schema = schema,
    cg_table_prefix = cgTablePrefix
  )
  
  return(invisible(NULL))
  
}


#' A function to add indexes to the incidence results
#'
#' @details
#' Specify the connectionHandler, the schema and the prefixes
#'
#' @template connectionHandler
#' @template schema
#' @template ciTablePrefix
#' @family Indexes
#' 
#' @return
#' NULL
#'
#' @export
createIncidenceIndexes <- function(
    connectionHandler,
    schema,
    ciTablePrefix = 'ci_'
){
  
  ciVersion <- .getCIVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    ciTablePrefix = ciTablePrefix
  )
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/indexesCiV", ciVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  connectionHandler$executeSql(
    sql = sql,
    schema = schema,
    ci_table_prefix = ciTablePrefix
  )
    
  return(invisible(NULL))
  
}


#' A function to add indexes to the Characterization results
#'
#' @details
#' Specify the connectionHandler, the schema and the prefixes
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @family Indexes
#' 
#' @return
#' NULL
#'
#' @export
createCharacterizationIndexes <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_'
){
  
  tteVersion <- 0
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/indexesCharacterizationV", cVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  connectionHandler$executeSql(
    sql = sql,
    schema = schema,
    c_table_prefix = cTablePrefix
  )
  
  # now add the time to event optimization table
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/tteOptimizationV", tteVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  connectionHandler$executeSql(
    sql = sql,
    schema = schema,
    c_table_prefix = cTablePrefix
  )
  
  return(invisible(NULL))
  
}


#' A function to add indexes to the SCCS results
#'
#' @details
#' Specify the connectionHandler, the schema and the prefixes
#'
#' @template connectionHandler
#' @template schema
#' @template sccsTablePrefix
#' @family Indexes
#' 
#' @return
#' NULL
#'
#' @export
createSccsIndexes <- function(
    connectionHandler,
    schema,
    sccsTablePrefix = 'sccs_'
){
  
  sccsVersion <- 0
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/estimation/indexesSccsV", sccsVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  connectionHandler$executeSql(
    sql = sql,
    schema = schema,
    sccs_table_prefix = sccsTablePrefix
  )
  
  return(invisible(NULL))
  
}


# CM has no required indexes 