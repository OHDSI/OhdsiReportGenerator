#' Extract the cohort definition details
#' @description
#' This function extracts all cohort definitions for the targets of interest.
#'
#' @details
#' Specify the connectionHandler, the schema and the target cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cgTablePrefix
#' @template targetIds
#' @family Cohorts
#' @return
#' Returns a data.frame with the cohort details
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cohortDef <- getCohortDefinitions(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getCohortDefinitions <- function(
    connectionHandler,
    schema,
    cgTablePrefix = 'cg_',
    targetIds = NULL
){
  sql <- SqlRender::readSql(system.file(
    "sql/sql_server/cohort/getCohortDefinitions.sql",
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))

  result <- connectionHandler$queryDb(
    sql = sql,
    schema = resultDatabaseSettings$schema,
    cg_table_prefix = resultDatabaseSettings$cgTablePrefix
  )
  
  return(result)
}

#' Extract the cohort parents and children cohorts (cohorts derieved from the parent cohort)
#' @description
#' This function lets you split the cohort data.frame into the parents and the children per parent.
#'
#' @details
#' Finds the parent cohorts and children cohorts
#'
#' @param cohort The data.frame extracted using `getCohortDefinitions()` 
#' @family Cohorts
#' @return
#' Returns a list containing parents: a named vector of all the parent cohorts and cohortList: a list 
#' the same length as the parent vector with the first element containing all the children
#' of the first parent cohort, the second element containing the children of the second parent, etc.
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cohortDef <- getCohortDefinitions(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
#' parents <- processCohorts(cohortDef)
#' 
processCohorts <- function(cohort){
  
  parentCodes <- unique(cohort$subsetParent)
  
  cohortList <- list()
  for(parentCode in parentCodes){
    cohortList[[length(cohortList)+1]] <- cohort %>% 
      dplyr::filter(.data$subsetParent == !! parentCode)
  }
  names(cohortList) <- parentCodes
  
  names(parentCodes) <- sapply(parentCodes, 
                               function(x){
                                 cohort$cohortName[cohort$cohortDefinitionId == x]
                                 }
                               )
  
  return(
    list(
      parents = parentCodes,
      cohortList = cohortList
    )
  )
}

# TODO - find which analyses each cohort is used and whether target or outcome


#' Extract the cohort subset definition details
#' @description
#' This function extracts all cohort subset definitions for the subsets of interest.
#'
#' @details
#' Specify the connectionHandler, the schema and the subset IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cgTablePrefix
#' @param subsetIds A vector of subset cohort ids or NULL
#' @family Cohorts
#' @return
#' Returns a data.frame with the cohort subset details
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' subsetDef <- getCohortSubsetDefinitions(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getCohortSubsetDefinitions <- function(
    connectionHandler,
    schema,
    cgTablePrefix = 'cg_',
    subsetIds = NULL
){
  
  sql <- SqlRender::readSql(system.file(
    "sql/sql_server/cohort/getCohortSubsetDefinitions.sql",
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  result <- tryCatch({connectionHandler$queryDb(
    sql = sql, 
    schema = schema,
    cg_table_prefix = cgTablePrefix,
    use_subsets = !is.null(subsetIds),
    subset_id = paste0(subsetIds, collapse = ',')
  )}, 
  error = function(e){print(e); return(NULL)}
  )
  
  return(result)
}



#' Extract the cohort inclusion stats
#' @description
#' This function extracts all cohort inclusion stats for the cohorts of interest.
#'
#' @details
#' Specify the connectionHandler, the schema and the cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cgTablePrefix
#' @template databaseTable
#' @param cohortIds Optionally a list of cohortIds to restrict to
#' @family Cohorts
#' @return
#' Returns a data.frame with the cohort inclusion stats
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cohortInclsuionsStats <- getCohortInclusionStats(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getCohortInclusionStats <- function(
    connectionHandler,
    schema,
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    cohortIds = NULL
) {
  
  sql <- SqlRender::readSql(system.file(
    "sql/sql_server/cohort/getCohortInclusionStats.sql",
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable,
    use_cohort_id = !is.null(cohortIds),
    cohort_definition_ids = paste0(cohortIds, collapse = ',')
  )
  
  return(result)
}



#' Extract the cohort inclusion rules
#' @description
#' This function extracts all cohort inclusion rules for the cohorts of interest.
#'
#' @details
#' Specify the connectionHandler, the schema and the cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cgTablePrefix
#' @param cohortIds Optionally a list of cohortIds to restrict to
#' @family Cohorts
#' @return
#' Returns a data.frame with the cohort inclusion rules
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cohortInclsuionsRules <- getCohortInclusionRules(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getCohortInclusionRules <- function(
    connectionHandler,
    schema,
    cgTablePrefix = 'cg_',
    cohortIds = NULL
) {
  
  sql <- SqlRender::readSql(system.file(
    "sql/sql_server/cohort/getCohortInclusionRules.sql",
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cg_table_prefix = cgTablePrefix,
    use_cohort_id = !is.null(cohortIds),
    cohort_definition_ids = paste0(cohortIds, collapse = ',')
  )
  
  return(result)
}



#' Extract the cohort inclusion summary
#' @description
#' This function extracts all cohort inclusion summary for the cohorts of interest.
#'
#' @details
#' Specify the connectionHandler, the schema and the cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cgTablePrefix
#' @template databaseTable
#' @param cohortIds Optionally a list of cohortIds to restrict to
#' @family Cohorts
#' @return
#' Returns a data.frame with the cohort inclusion rules
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cohortInclsuionsSummary <- getCohortInclusionSummary(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getCohortInclusionSummary <- function(
    connectionHandler,
    schema,
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    cohortIds = NULL
) {
  
  sql <- SqlRender::readSql(system.file(
    "sql/sql_server/cohort/getCohortInclusionSummary.sql",
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable,
    use_cohort_id = !is.null(cohortIds),
    cohort_definition_ids = paste0(cohortIds, collapse = ',')
  )
  
  return(result)
}




#' Extract the cohort meta
#' @description
#' This function extracts all cohort meta for the cohorts of interest.
#'
#' @details
#' Specify the connectionHandler, the schema and the cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cgTablePrefix
#' @template databaseTable
#' @param cohortIds Optionally a list of cohortIds to restrict to
#' @family Cohorts
#' @return
#' Returns a data.frame with the cohort inclusion rules
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cohortMeta <- getCohortMeta(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getCohortMeta <- function(
    connectionHandler,
    schema,
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    cohortIds = NULL
) {
  
  sql <- SqlRender::readSql(system.file(
    "sql/sql_server/cohort/getCohortMeta.sql",
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable,
    use_cohort_id = !is.null(cohortIds),
    cohort_definition_ids = paste0(cohortIds, collapse = ',')
  )
  
  return(result)
}




#' Extract the cohort counds
#' @description
#' This function extracts all cohort counts for the cohorts of interest.
#'
#' @details
#' Specify the connectionHandler, the schema and the cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cgTablePrefix
#' @template databaseTable
#' @param cohortIds Optionally a list of cohortIds to restrict to
#' @family Cohorts
#' @return
#' Returns a data.frame with the cohort inclusion rules
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cohortMeta <- getCohortCounts(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getCohortCounts <- function(
    connectionHandler,
    schema,
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    cohortIds = NULL
) {
  
  sql <- SqlRender::readSql(system.file(
    "sql/sql_server/cohort/getCohortCounts.sql",
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable,
    use_cohort_id = !is.null(cohortIds),
    cohort_definition_ids = paste0(cohortIds, collapse = ',')
  )
  
  return(result)
}
