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
  
  # to make this backward compatible for older CohortGenerator
  subsetTableMissing <- is.null(tryCatch({
    connectionHandler$queryDb(
      sql = "select * from @schema.@cg_table_prefixcohort_subset_definition;",
      schema = schema,
      cg_table_prefix = cgTablePrefix
      )
  }, error = function(e){return(NULL)}
  ))
  
  if(!subsetTableMissing){ 
    sql <- 'select cd.*, csd.json as subset_definition_json
  from @schema.@cg_table_prefixcohort_definition cd
  left join
  @schema.@cg_table_prefixcohort_subset_definition csd
  on cd.subset_definition_id = csd.subset_definition_id
  {@use_targets}?{where cd.cohort_definition_id in (@target_id)}
  ;'
  } else{
    sql <- "select *, NULL as subset_definition_json
  from @schema.@cg_table_prefixcohort_definition 
  {@use_targets}?{where cohort_definition_id in (@target_id)}
  ;"
  }
  
  result <- connectionHandler$queryDb(
    sql = sql, 
    schema = schema,
    cg_table_prefix = cgTablePrefix,
    use_targets = !is.null(targetIds),
    target_id = paste0(targetIds, collapse = ',')
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
  
  sql <- 'select * 
  from @schema.@cg_table_prefixcohort_subset_definition
  {@use_subsets}?{where subset_definition_id in (@subset_id)}
  ;'
  
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
  
  sql <- "SELECT 
  cir.database_id, 
  dt.cdm_source_name as database_name,
  cir.cohort_definition_id, 
  cd.cohort_name,
  cir.inclusion_rule_mask, 
  cir.person_count, 
  cir.mode_id
  
  FROM @schema.@cg_table_prefixCOHORT_INC_RESULT cir
  
  INNER JOIN @schema.@database_table dt
  ON cir.database_id = dt.database_id
  
  INNER JOIN @schema.@cg_table_prefixcohort_definition cd
  ON cir.cohort_definition_id = cd.cohort_definition_id
  
  {@use_cohort_id}?{ where cir.cohort_definition_id in (@cohort_definition_ids)}
  ;"
  
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
  
  sql <- "SELECT 
  ci.cohort_definition_id, 
  cd.cohort_name,
  ci.rule_sequence, 
  ci.name as rule_name
  
  FROM @schema.@cg_table_prefixCOHORT_INCLUSION ci
  INNER JOIN @schema.@cg_table_prefixCOHORT_DEFINITION cd
  ON cd.cohort_definition_id = ci.cohort_definition_id
  
  {@use_cohort_id}?{ WHERE cd.cohort_definition_id in (@cohort_definition_ids)}
  ;"
  
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
  
  sql <- "SELECT 
  css.cohort_definition_id, 
  cd.cohort_name,
  css.base_count, 
  css.final_count, 
  css.mode_id,
  dt.cdm_source_name as database_name,
  dt.database_id
  
  FROM @schema.@cg_table_prefixCOHORT_SUMMARY_STATS css
  
  INNER JOIN @schema.@database_table dt
  ON css.database_id = dt.database_id
  
  INNER JOIN @schema.@cg_table_prefixCOHORT_DEFINITION cd
  ON cd.cohort_definition_id = css.cohort_definition_id
  
  {@use_cohort_id}?{ WHERE css.cohort_definition_id in (@cohort_definition_ids)}
  ;"
  
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
  
  sql <- "SELECT 
  cg.cohort_id, 
  cg.cohort_name,
  cg.generation_status, 
  cg.start_time, 
  cg.end_time, 
  dt.cdm_source_name as database_name,
  dt.database_id
  
  FROM @schema.@cg_table_prefixCOHORT_GENERATION cg
  INNER JOIN @schema.@database_table dt
  ON cg.database_id = dt.database_id
  
  {@use_cohort_id}?{ WHERE cg.cohort_id in (@cohort_definition_ids)}
  ;"
  
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
  
  sql <- "SELECT 
  cc.cohort_id, 
  cd.cohort_name,
  cc.cohort_entries, 
  cc.cohort_subjects,
  dt.cdm_source_name as database_name,
  dt.database_id
  
  FROM @schema.@cg_table_prefixCOHORT_COUNT cc
  
  INNER JOIN @schema.@database_table dt
  ON cc.database_id = dt.database_id
  
  INNER JOIN @schema.@cg_table_prefixCOHORT_DEFINITION cd
  ON cd.cohort_definition_id = cc.cohort_id

  {@use_cohort_id}?{ WHERE cc.cohort_id in (@cohort_definition_ids)}
  ;"
  
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