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
#' @family {Characterization}
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  } 
#' 
#' @export
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

# TODO add code to find parents and children
