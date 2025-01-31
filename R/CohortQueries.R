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
#' Returns a data.frame with the columns:
#' \itemize{
#'  } 
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
  
  sql <- 'select * 
  from @schema.@cg_table_prefixcohort_definition
  {@use_targets}?{where cohort_definition_id in (@target_id)}
  ;'
  
  result <- connectionHandler$queryDb(
    sql = sql, 
    schema = schema,
    cg_table_prefix = cgTablePrefix,
    use_targets = !is.null(targetIds),
    target_id = paste0(targetIds, collapse = ',')
  )
  
  return(result)
}

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


# Code below doesnt work as the table doesnt exist?
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
