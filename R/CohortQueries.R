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
    cg_table_prefix = cgTablePrefix,
    restrict_to_targets = !is.null(targetIds),
    target_ids = paste0(targetIds, collapse = ',')
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
  
  result <- tryCatch({connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable,
    use_cohort_id = !is.null(cohortIds),
    cohort_definition_ids = paste0(cohortIds, collapse = ',')
  )}, error = function(e){
    print(e);
    return(NULL)
  })
  
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
#' @family Cohorts
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
#' @family Cohorts
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




#' Function processes the cohortDefinitions object ready for use in the main quarto report.
#'
#' @details
#' Function processes the cohortDefinitions object by adding friendly names for 
#' specified parent cohorts, determines which cohorts are nested in the specified
#' indication cohort ids and ...
#' @family Cohorts
#'
#' @param cohortDefinitions The output of `getCohortDefinitions()`
#' @param friendlyCohortIds a vector of parent cohort ids that you want to rename
#' @param friendlyCohortNames a vector of new names for the friendlyCohortIds
#' @param restrictTargetToIndications whether to restrict the results to cohorts nested in certain indications
#' @param indicationIds The indication ids of interest for restrictTargetToIndications
#'                
#' @return
#' A cohortDefinitions object with extra columns: friendlyName, 
#'
#' @export
processCohortDefinitionsForQuarto <- function(
  cohortDefinitions,
  friendlyCohortIds,
  friendlyCohortNames,
  restrictTargetToIndications,
  indicationIds
){
  
  # 1) add the friendly names 
  cohortDefinitions <- 
    merge(
      cohortDefinitions,
      data.frame(
        cohortId = friendlyCohortIds,
        friendlyName = friendlyCohortNames
      ), 
      by.x = 'subsetParent', 
      by.y = 'cohortId', 
      all.x = TRUE 
    )
  cohortDefinitions$friendlyName[is.na(cohortDefinitions$friendlyName)] <- cohortDefinitions$cohortName[is.na(cohortDefinitions$friendlyName)]
  
  # 2) add friendly subset logic text
  # add subset text for the subsetDefinitionJson
  cohortDefinitions$subsetText <- unlist(
    lapply(
      X = cohortDefinitions$subsetDefinitionJson, 
      FUN = function(x){getSubsetText(
        subsetDefinitionJson = x, 
        cohortDefinitions = cohortDefinitions
      )}
    ))
  
  # 3) add indicationOfInt if required
  if(restrictTargetToIndications){
    cohortDefinitions$indicationOfInt <- unlist(lapply(
      X = cohortDefinitions$subsetDefinitionJson, 
      FUN = function(x){
        subsetNestedInIds(subsetDefinitionJson = x, nestIds = indicationIds)
        }))
  }
  
  return(cohortDefinitions)
  
}

#' Function to figure out the target, comparator, outcome and indication ids of interest
#' for the quarto report based on the user inputs
#'
#' @details
#' This function finds the targets, comparators, indications and outcomes of interest based
#' on the user inputs for quarto report generation.
#' @family Cohorts
#'
#' @template connectionHandler
#' @template schema
#' @param cohortDefinitions The output of `processCohortDefinitionsForQuarto()`
#' @param targetId a parent target id
#' @param outcomeIds a vector of outcome ids
#' @param comparatorIds NULL or a vector of comparator parent ids
#' @param restrictTargetToIndications whether to restrict the target ids to cohorts nested in indicationIds
#' @param indicationIds The indication ids of interest for restrictTargetToIndications
#' @param includeCohortMethod If TRUE, when comparatorIds is NULL all comparators included in CohortMethod are included in the report
#'                
#' @return
#' A list of targetIdsOfInterest that is a vector of cohortIds that are targets of interest to include in the report,
#' comparatorIds a vector of cohortIds that are comparators, 
#' comparatorIdsOfInterest a vector of cohortIds that are comparators of interest, 
#' outcomeIdsOfInterest  a vector of cohortIds that are outcomes of interest and
#' indicationIdsOfInterest  a vector of cohortIds that are indications of interest.
#'
#' @export
restrictCohortDefinitionsForQuarto <- function(
    connectionHandler,
    schema,
    cohortDefinitions,
    targetId, # from param
    outcomeIds, # from param
    comparatorIds, # from param
    restrictTargetToIndications,
    indicationIds, # from param
    includeCohortMethod
    ){
  
  # if not restrictTargetToIndications then include all children
  #==================
  # TARGETS
  #==================
  if(restrictTargetToIndications){
    
    targetsOfInterest <- cohortDefinitions %>%
      dplyr::filter(
        ((.data$subsetParent %in% !!targetId) & .data$indicationOfInt) 
      )
    
  } else{
    
    # take all children of targetId
    targetsOfInterest <- cohortDefinitions %>%
      dplyr::filter(
        .data$subsetParent %in% !!targetId
      )
    
  }
  
  targetIdsOfInterest <- targetsOfInterest$cohortDefinitionId
  

  #==================
  # COMPARATORS
  #==================
# if comparators is NULL then include all that are found in CM in results
if(is.null(comparatorIds)){
  if(includeCohortMethod){
    newComps <- getCmDiagnosticsData(
      connectionHandler = connectionHandler,
      schema = schema, 
      targetIds = targetIdsOfInterest, 
      outcomeIds = outcomeIds
    )
    
    # get all the parents
    comparatorIds <- unique(cohortDefinitions$subsetParent[cohortDefinitions$cohortDefinitionId %in% unique(newComps$comparatorId)])
    
  }
}
  
  if(restrictTargetToIndications){
    
    comparatorOfInterest <- cohortDefinitions %>%
      dplyr::filter(
        ((.data$subsetParent %in% !!comparatorIds) & .data$indicationOfInt)
      ) 
    
  } else{
    
    # take all children of targetId
    comparatorOfInterest <- cohortDefinitions %>%
      dplyr::filter(
        .data$subsetParent %in% !!comparatorIds
      )
  }

comparatorIdsOfInterest <-  comparatorOfInterest$cohortDefinitionId

#==================
# OUTCOMES
#==================
outcomeOfInterest <- cohortDefinitions %>%
  dplyr::filter(
    (.data$cohortDefinitionId %in% !!outcomeIds)
  )
outcomeIdsOfInterest <- outcomeOfInterest$cohortDefinitionId

#==================
# INDICATIONS - take the children of all indication ids
#==================
if(is.numeric(indicationIds)){
  indicationOfInterest <- cohortDefinitions %>%
    dplyr::filter(
      (.data$subsetParent %in% !!indicationIds)
    )
  indicationIdsOfInterest <- indicationOfInterest$cohortDefinitionId
} else{
  indicationIdsOfInterest <- NULL
}


return(
  list(
    targetIdsOfInterest = targetIdsOfInterest,
    comparatorIds = comparatorIds,
    comparatorIdsOfInterest = comparatorIdsOfInterest,
    outcomeIdsOfInterest = outcomeIdsOfInterest,
    indicationIdsOfInterest = indicationIdsOfInterest
  )
)
}


subsetNestedInIds <- function(subsetDefinitionJson = NULL, nestIds){ 
  if(is.na(subsetDefinitionJson)){
    return(FALSE)
  }
  if(is.null(subsetDefinitionJson)){
    return(FALSE)
  }
  
  sub <- ParallelLogger::convertJsonToSettings(as.character(subsetDefinitionJson))
  result <- any(unlist(lapply(sub$subsetOperators, function(x){
    
    if(x$subsetType == "CohortSubsetOperator"){
      if(!x$negate){
        return(any(x$cohortIds %in% nestIds))
      }
    } 
    return(FALSE)
    
  })))
  
}


#' Function that converts a subsetDefinitionJson into text description
#'
#' @details
#' The function takes a subsetDefinitionJson and converts it into friendly text describing the 
#' subset logic
#' @family Cohorts
#'
#' @param subsetDefinitionJson The subset logic json
#' @param cohortDefinitions A data.frame with the columns cohortDefinitionId, cohortName and optionally friendlyName that will
#'                          be used to know the friendly cohort name for any subsetting that nests in other cohorts
#'                
#' 
#' @return
#' A text string describing the subsetting 
#'
#' @export
getSubsetText <- function(subsetDefinitionJson, cohortDefinitions){
  
  if(is.null(subsetDefinitionJson)){
    return('')
  } 
  if(is.na(subsetDefinitionJson)){
    return('')
  }
  
  text <- paste0(unlist(lapply(X = ParallelLogger::convertJsonToSettings(subsetDefinitionJson)$subsetOperators, 
                       FUN = function(subsetOperator){
                         getSubsetOperatorsText(
                           subsetOperator = subsetOperator, 
                           cohortDefinitions = cohortDefinitions
                         )
                       }
                         )), 
         collapse = ' ')
  
  return(text)
}

# a helper for getSubsetText
getSubsetOperatorsText <- function(subsetOperator, cohortDefinitions){
  
  if(is.null(cohortDefinitions$friendlyName)){
    cohortDefinitions$friendlyName <- cohortDefinitions$cohortName
  }
  
  if(subsetOperator$subsetType == "CohortSubsetOperator"){
    
    if(sum(cohortDefinitions$cohortDefinitionId %in% subsetOperator$cohortIds) != 0){
      name <- cohortDefinitions$friendlyName[cohortDefinitions$cohortDefinitionId %in% subsetOperator$cohortIds]
    } else{
      name <- paste('id', subsetOperator$cohortIds)
    }
    
    txt <- paste0(ifelse(subsetOperator$negate, 'Not in','In'), ' cohorts ', 
                  paste0(name,
                         collapse = ifelse(subsetOperator$cohortCombinationOperator == 'all', ' and ', ' or ')
                  ))
    return(paste0(txt, '.'))
  }
  
  if(subsetOperator$subsetType == "DemographicSubsetOperator"){
    gender <- ''
    if(sum(c(8507,8532) %in% subsetOperator$gender) == 2){
      gender = ''
    } else if( 8507 %in% subsetOperator$gender){
      gender = 'Resticted to males.'
    } else if( 8532 %in% subsetOperator$gender){
      gender = 'Resticted to females.'
    }
    return(paste0('Aged between ', subsetOperator$ageMin, ' to ', subsetOperator$ageMax, '.', 
                  gender
    ))
  }
  
  if(subsetOperator$subsetType == "LimitSubsetOperator"){
    txt <- ''
    joiner <- ' and '
    if(!is.null(subsetOperator$calendarStartDate)){
      txt <-  paste0(txt,paste0(
        'Restict to exposures occurring after ', subsetOperator$calendarStartDate, 
        ifelse(!is.null(subsetOperator$calendarEndDate), paste0(joiner,' before ', subsetOperator$calendarEndDate), '')
      ))
    } else{
      if(!is.null(subsetOperator$calendarEndDate)){
        txt <-  paste0(txt,paste0('Restict to exposures occurring before ', subsetOperator$calendarEndDate))
      }
    }
    
    if(subsetOperator$priorTime > 0){
      txt <- paste0(txt, ifelse(txt == '', 'Requiring ',paste0(joiner, ' requiring ')) , subsetOperator$priorTime, ' days observation prior to index')
    }
    
    if(subsetOperator$followUpTime > 0){
      txt <- paste0(txt, ifelse(txt == '', 'Requiring ',paste0(joiner, ' requiring ')), subsetOperator$followUpTime, ' days follow up post index')
    }
    
    if(subsetOperator$limitTo == 'firstEver'){
      txt <- paste0(txt, ifelse(txt == '', 'Limit ', ' and limit '), 'to first exposure')
    }
    
    txt <- paste0(txt, '.')
    return(txt)
  }
  
}
