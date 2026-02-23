#' An internal function to determine the version of CohortGenerator is 
#' used to store results
#'
#' @details
#' Specify the connectionHandler, the schema and the prefixes. This
#' query will attempt to identify if CohortGenerator v0.x was used by 
#' inspecing the migration table. When the migration_order is >= 3
#' then v1 of CohortGenerator was used.
#'
#' @template connectionHandler
#' @template schema
#' @template cmTablePrefix
#' @family Estimation
#' 
#' @return
#' A integer with the major version number of CohortGenerator
#'
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' version <- .getCgVersion(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
.getCgVersion <- function(
    connectionHandler,
    schema,
    cgTablePrefix = 'cg_'
){
  version <- 0 # Default to v0
  tryCatch(
    {
      sql <- "
      SELECT MAX(migration_order) max_migration_order
      FROM @schema.@cg_table_prefixmigration
      ;"
      
      maxMigrationOrder <- connectionHandler$queryDb(
        sql = sql,
        schema = schema,
        cg_table_prefix = cgTablePrefix
      ) %>%
        dplyr::pull(maxMigrationOrder) %>%
        dplyr::first()
      version <- switch(
        as.character(dplyr::case_when(
          is.na(maxMigrationOrder) ~ "v0",
          maxMigrationOrder < 3 ~ "v0",
          maxMigrationOrder == 3 ~ "v1",
          maxMigrationOrder > 3 ~ "v1.1"
        )),
        "v0" = 0,
        "v1" = 1,
        "v1.1" = 1.1
      )
    },
    error = function(e) {
      # Do nothing - most likely the migration table does not exist so assume
      # CohortGenerator v0
    }
  )
  return(version)
}

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
  cgVersion <- round(
      .getCgVersion(
      connectionHandler = connectionHandler,
      schema = schema,
      cgTablePrefix = cgTablePrefix
    )
  )
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/cohort/getCohortDefinitionsV", cgVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))

  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cg_table_prefix = cgTablePrefix
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
  cgVersion <- round(
    .getCgVersion(
      connectionHandler = connectionHandler,
      schema = schema,
      cgTablePrefix = cgTablePrefix
    )
  )

  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/cohort/getCohortMetaV", cgVersion, ".sql"),
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




#' Extract the cohort counts
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



#' Get cohort attrition
#'
#' Retrieves attrition information for specified cohorts from the database.
#'
#' @param connectionHandler A connection handler object.
#' @param schema The database schema name.
#' @param cgTablePrefix Prefix for cohort generator tables. Default is 'cg_'.
#' @param databaseTable Name of the database metadata table. Default is 'database_meta_data'.
#' @param cohortIds Optional vector of cohort IDs to filter.
#' @return A tibble with attrition details for each cohort.
#' @export
getCohortAttrition <- function(
    connectionHandler,
    schema,
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    cohortIds = NULL
) {
  cgVersion <- .getCgVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cgTablePrefix = cgTablePrefix
  )

  if (cgVersion < 1.1) {
    warning("Cohort attrition information is only available for CohortGenerator v1.1 or higher.")
    return(NULL)
  }
 
  sql <- SqlRender::readSql(system.file(
    "sql/sql_server/cohort/getCohortAttrition.sql",
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

#' Get cohort subset attrition
#'
#' Retrieves attrition information for specified cohort subsets from the database.
#'
#' @param connectionHandler A connection handler object.
#' @param schema The database schema name.
#' @param cgTablePrefix Prefix for cohort generator tables. Default is 'cg_'.
#' @param databaseTable Name of the database metadata table. Default is 'database_meta_data'.
#' @param cohortIds Optional vector of cohort IDs to filter.
#' @return A tibble with attrition details for each cohort subset.
#' @export
getCohortSubsetAttrition <- function(
    connectionHandler,
    schema,
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    cohortIds = NULL
) {
  cgVersion <- .getCgVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cgTablePrefix = cgTablePrefix
  )

  if (cgVersion < 1.1) {
    warning("Cohort subset attrition information is only available for CohortGenerator v1.1 or higher.")
    return(NULL)
  }
 
  sql <- SqlRender::readSql(system.file(
    "sql/sql_server/cohort/getCohortSubsetAttrition.sql",
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
