#' Extract the target cohorts and where they are used in the analyses.
#' @description
#' This function extracts the target cohorts, the number of subjects/entries and where the cohort was used.
#'
#' @details
#' Specify the connectionHandler, the schema and the table prefixes
#'
#' @template connectionHandler
#' @template schema
#' @template cgTablePrefix
#' @template cTablePrefix
#' @template ciTablePrefix
#' @template cmTablePrefix
#' @template sccsTablePrefix
#' @template plpTablePrefix
#' @template databaseTable
#' @family Helpers
#' @return
#' Returns a data.frame with the columns: 
#' \itemize{
#'  \item{cohortId the number id for the target cohort}
#'  \item{cohortName the name of the cohort}
#'  \item{subsetParent the number id of the parent cohort}
#'  \item{subsetDefinitionId the number id of the subset}
#'  \item{numDatabase number of databases with the cohort}
#'  \item{databaseString all the names of the databases with the cohort}
#'  \item{databaseCount all the names of the databases with the cohort and their sizes}
#'  \item{minSubjectCount number of subjects in databases with lowest count}
#'  \item{maxSubjectCount number of subjects in databases with highest count}
#'  \item{minEntryCount number of entries in databases with lowest count}
#'  \item{maxEntryCount number of entries in databases with highest count}
#'  \item{cohortIncidence whether the cohort was used in cohort incidence}
#'  \item{databaseComparator whether the cohort was used in database comparator}
#'  \item{cohortComparator whether the cohort was used in cohort comparator}
#'  \item{dechalRechal whether the cohort was used in dechallenge rechallenge}
#'  \item{riskFactors whether the cohort was used in risk factors}
#'  \item{caseSeries whether the cohort was used in case series analysis}
#'  \item{timeToEvent whether the cohort was used in time to event}
#'  \item{prediction whether the cohort was used in prediction}
#'  \item{cohortMethod whether the cohort was used in cohort method}
#'  \item{selfControlledCaseSeries whether the cohort was used in self controlled case series}
#' }
#'
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' targetTable <- getTargetTable(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getTargetTable <- function(
  connectionHandler, 
  schema,
  cgTablePrefix = 'cg_',
  cTablePrefix = 'c_',
  ciTablePrefix = 'ci_',
  cmTablePrefix = 'cm_',
  sccsTablePrefix = 'sccs_',
  plpTablePrefix = 'plp_',
  databaseTable = 'database_meta_data'
){
  
  cohorts <- getCohortDefinitions(
    connectionHandler = connectionHandler,
    schema = schema
  ) %>%
    dplyr::select("cohortDefinitionId", "cohortName", "subsetParent", "subsetDefinitionId") %>%
    dplyr::rename(cohortId = "cohortDefinitionId")
  
  # find parents names
  parents <- cohorts %>% 
    dplyr::filter(.data$cohortId == .data$subsetParent) %>%
    dplyr::select("cohortId", "cohortName") %>%
    dplyr::rename(
      parentName = "cohortName",
      subsetParent = "cohortId"
    )
  # add the parent name to cohorts
  cohorts <- merge(cohorts, parents, by = 'subsetParent', all.x = TRUE)
  
  sql <- "select 
  dt.cdm_source_abbreviation as database_name,
  cc.*
  from @schema.@cg_prefixcohort_count cc inner join
  @schema.@database_table dt on cc.database_id = dt.database_id;"
  counts <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cg_prefix = cgTablePrefix,
    database_table = databaseTable
    ) %>% 
    dplyr::group_by(.data$cohortId) %>%
    dplyr::summarise(
      numDatabase = length(unique(.data$databaseName)),
      databaseString = paste0(unique(.data$databaseName), collapse = ', '),
      databaseIdString = paste0(unique(.data$databaseId), collapse = ', '),
      databaseStringCount = paste0(unique(paste0(.data$databaseName,' (', .data$cohortSubjects ,')')), collapse = ', '),
      minSubjectCount = min(.data$cohortSubjects, na.rm = T),
      maxSubjectCount = max(.data$cohortSubjects, na.rm = T),
      minEntryCount = max(.data$cohortEntries, na.rm = T),
      maxEntryCount = max(.data$cohortEntries, na.rm = T)
    )
  
  cohortCounts <- merge(cohorts, counts, by = 'cohortId')
  
  # now find whether it is a target for each analysis
  
  inc <- tryCatch(getIncidenceTargets(
    connectionHandler = connectionHandler,
    schema = schema,
    cgTablePrefix = cgTablePrefix,
    ciTablePrefix = ciTablePrefix
    ), error = function(e){return(NULL)})
  if(!is.null(inc)){
    cohortCounts <- merge(
      x = cohortCounts, 
      y = inc, 
      by.x = c('cohortId','cohortName'),
      by.y = c('cohortDefinitionId','cohortName'),
      all.x = T
      )
  }
  
  char <- tryCatch(getCharacterizationTargets(
    connectionHandler = connectionHandler,
    schema = schema,
    cgTablePrefix = cgTablePrefix,
    cTablePrefix = cTablePrefix
  ), error = function(e){return(NULL)})
  if(!is.null(char)){
    cohortCounts <- merge(
      x = cohortCounts, 
      y = char, 
      by.x = c('cohortId','cohortName'),
      by.y = c('cohortDefinitionId','cohortName'),
      all.x = T
    )
  }
  
  pred <- tryCatch(getPredictionTargets(
    connectionHandler = connectionHandler,
    schema = schema,
    cgTablePrefix = cgTablePrefix,
    plpTablePrefix = plpTablePrefix
  ), error = function(e){return(NULL)})
  if(!is.null(pred)){
    cohortCounts <- merge(
      x = cohortCounts, 
      y = pred, 
      by.x = c('cohortId','cohortName'),
      by.y = c('cohortDefinitionId','cohortName'),
      all.x = T
    )
  }
  
  cm <- tryCatch(getCmTargets(
    connectionHandler = connectionHandler,
    schema = schema,
    cgTablePrefix = cgTablePrefix,
    cmTablePrefix = cmTablePrefix
  ), error = function(e){return(NULL)})
  if(!is.null(cm)){
    cohortCounts <- merge(
      x = cohortCounts, 
      y = cm, 
      by.x = c('cohortId','cohortName'),
      by.y = c('cohortDefinitionId','cohortName'),
      all.x = T
    )
  }
  
  sccs <- tryCatch(getSccsTargets(
    connectionHandler = connectionHandler,
    schema = schema,
    cgTablePrefix = cgTablePrefix,
    sccsTablePrefix = sccsTablePrefix
  ), error = function(e){return(NULL)})
  if(!is.null(sccs)){
    cohortCounts <- merge(
      x = cohortCounts, 
      y = sccs, 
      by.x = c('cohortId','cohortName'),
      by.y = c('cohortDefinitionId','cohortName'),
      all.x = T
    )
  }
  
  if(sum(is.na(cohortCounts)) !=0){
    cohortCounts[is.na(cohortCounts)] <- 0
  }
  
  # add missing analyses (if they failed) with all 0 columns?
  colnameTypes <- c('timeToEvent','dechalRechal','riskFactors','databaseComparator',
                    'cohortComparator', 'caseSeries',
                    'cohortMethod', 'selfControlledCaseSeries', 'prediction',
                    'cohortIncidence') 

  if(sum(colnameTypes %in% colnames(cohortCounts)) != length(colnameTypes)){
    missingCols <- colnameTypes[!colnameTypes %in% colnames(cohortCounts)]
    for(missingCol in missingCols){
      cohortCounts[missingCol] <- 0
    }
  }
  
  # TODO: reorder columns to match docs 
  
  
  # order by names
  cohortCounts <- cohortCounts %>% 
    dplyr::arrange(.data$parentName, .data$cohortName)
  
  
return(cohortCounts)
}



#' Extract the parent cohort details from the target table
#' @description
#' This function extracts the parents cohort details from the target table
#'
#' @details
#' Input the targetTable and this function extracts the parent cohorts and summary details about them
#'
#' @param targetTable The output from getTargetTable()
#' 
#' @family Helpers
#' @return
#' Returns a data.frame with the parent cohorts used as targets 
#'
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' targetTable <- getTargetTable(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
#' parentTable <- getParentTable(targetTable)
#' 
getParentTable <- function(
    targetTable
    ){
  
  parentTable <- targetTable %>%
    dplyr::filter(.data$cohortId == .data$subsetParent)
  
  #targetTable %>%
  childSum <- targetTable %>%
    dplyr::filter(.data$cohortId != .data$subsetParent) %>% 
    dplyr::group_by(.data$subsetParent) %>%
    dplyr::summarise(
      numChildren = length(unique(.data$cohortId)),
      minChildrenSubjectCount = min(.data$minSubjectCount),
      maxChildrenSubjectCount = max(.data$maxSubjectCount),
      anyChildrenIncidence = max(.data$cohortIncidence, na.rm = T),
      anyChildrenDatabaseComparator = max(.data$databaseComparator, na.rm = T),
      anyChildrenDechalRechal = max(.data$dechalRechal, na.rm = T),
      anyChildrenTimeToEvent = max(.data$timeToEvent, na.rm = T),
      anyChildrenRiskFactors = max(.data$riskFactors, na.rm = T),
      anyChildrenPrediction = max(.data$prediction, na.rm = T),
      anyChildrenCohortMethod = max(.data$cohortMethod, na.rm = T),
      anyChildrenSccs = max(.data$selfControlledCaseSeries, na.rm = T)
    )
  
  parentTable <- merge(parentTable, childSum, by = 'subsetParent', all.x = T)
    
  if(sum(is.na(parentTable))>0){
    parentTable[is.na(parentTable)] <- 0
  }
    
  return(parentTable)
}





#' Extract the outcome cohorts and where they are used in the analyses.
#' @description
#' This function extracts the outcome cohorts, the number of subjects/entries and where the cohort was used.
#'
#' @details
#' Specify the connectionHandler, the schema and the table prefixes
#'
#' @template connectionHandler
#' @template schema
#' @template cgTablePrefix
#' @template cTablePrefix
#' @template ciTablePrefix
#' @template cmTablePrefix
#' @template sccsTablePrefix
#' @template plpTablePrefix
#' @template databaseTable
#' @template targetId
#' @family Helpers
#' @return
#' Returns a data.frame with the columns: 
#' \itemize{
#'  \item{cohortId the number id for the target cohort}
#'  \item{cohortName the name of the cohort}
#'  \item{subsetParent the number id of the parent cohort}
#'  \item{subsetDefinitionId the number id of the subset}
#'  \item{numDatabase number of databases with the cohort}
#'  \item{databaseString all the names of the databases with the cohort}
#'  \item{databaseIdString all the ids of the databases with the cohort}
#'  \item{databaseStringCount all the names of the databases with the cohort plus their counts}
#'  \item{databaseCount all the names of the databases with the cohort and their sizes}
#'  \item{minSubjectCount number of subjects in databases with lowest count}
#'  \item{maxSubjectCount number of subjects in databases with highest count}
#'  \item{minEntryCount number of entries in databases with lowest count}
#'  \item{maxEntryCount number of entries in databases with highest count}
#'  \item{cohortIncidence whether the cohort was used in cohort incidence}
#'  \item{dechalRechal whether the cohort was used in dechallenge rechallenge}
#'  \item{riskFactors whether the cohort was used in risk factors}
#'  \item{caseSeries whether the cohort was used in case series analysis}
#'  \item{timeToEvent whether the cohort was used in time to event}
#'  \item{prediction whether the cohort was used in prediction}
#'  \item{cohortMethod whether the cohort was used in cohort method}
#'  \item{selfControlledCaseSeries whether the cohort was used in self controlled case series}
#' }
#'
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' outcomeTable <- getOutcomeTable(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getOutcomeTable <- function(
    connectionHandler, 
    schema,
    cgTablePrefix = 'cg_',
    cTablePrefix = 'c_',
    ciTablePrefix = 'ci_',
    cmTablePrefix = 'cm_',
    sccsTablePrefix = 'sccs_',
    plpTablePrefix = 'plp_',
    databaseTable = 'database_meta_data',
    targetId = NULL
){
  
  cohorts <- getCohortDefinitions(
    connectionHandler = connectionHandler,
    schema = schema
  ) %>%
    dplyr::select("cohortDefinitionId", "cohortName", "subsetParent", "subsetDefinitionId") %>%
    dplyr::rename(cohortId = "cohortDefinitionId")
  
  # find parents names
  parents <- cohorts %>% 
    dplyr::filter(.data$cohortId == .data$subsetParent) %>%
    dplyr::select("cohortId", "cohortName") %>%
    dplyr::rename(
      parentName = "cohortName",
      subsetParent = "cohortId"
    )
  # add the parent name to cohorts
  cohorts <- merge(cohorts, parents, by = 'subsetParent', all.x = TRUE)
  
  sql <- "select 
  dt.cdm_source_abbreviation as database_name,
  cc.*
  from @schema.@cg_prefixcohort_count cc inner join
  @schema.@database_table dt on cc.database_id = dt.database_id;"
  counts <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cg_prefix = cgTablePrefix,
    database_table = databaseTable
  ) %>% 
    dplyr::group_by(.data$cohortId) %>%
    dplyr::summarise(
      numDatabase = length(unique(.data$databaseName)),
      databaseString = paste0(unique(.data$databaseName), collapse = ', '),
      databaseIdString = paste0(unique(.data$databaseId), collapse = ', '),
      databaseStringCount = paste0(unique(paste0(.data$databaseName,' (', .data$cohortSubjects ,')')), collapse = ', '),
      minSubjectCount = min(.data$cohortSubjects, na.rm = T),
      maxSubjectCount = max(.data$cohortSubjects, na.rm = T),
      minEntryCount = max(.data$cohortEntries, na.rm = T),
      maxEntryCount = max(.data$cohortEntries, na.rm = T)
    )
  
  cohortCounts <- merge(cohorts, counts, by = 'cohortId')
  
  # now find whether it is a target for each analysis
  
  inc <- tryCatch(getIncidenceOutcomes(
    connectionHandler = connectionHandler,
    schema = schema,
    cgTablePrefix = cgTablePrefix,
    ciTablePrefix = ciTablePrefix, 
    targetId = targetId
  ), error = function(e){return(NULL)})
  if(!is.null(inc)){
    cohortCounts <- merge(
      x = cohortCounts, 
      y = inc, 
      by.x = c('cohortId','cohortName'),
      by.y = c('cohortDefinitionId','cohortName'),
      all.x = T
    )
  }
  
  char <- tryCatch(getCharacterizationOutcomes(
    connectionHandler = connectionHandler,
    schema = schema,
    cgTablePrefix = cgTablePrefix,
    cTablePrefix = cTablePrefix, 
    targetId = targetId
  ), error = function(e){return(NULL)})
  if(!is.null(char)){
    cohortCounts <- merge(
      x = cohortCounts, 
      y = char, 
      by.x = c('cohortId','cohortName'),
      by.y = c('cohortDefinitionId','cohortName'),
      all.x = T
    )
  }
  
  pred <- tryCatch(getPredictionOutcomes(
    connectionHandler = connectionHandler,
    schema = schema,
    cgTablePrefix = cgTablePrefix,
    plpTablePrefix = plpTablePrefix, 
    targetId = targetId
  ), error = function(e){return(NULL)})
  if(!is.null(pred)){
    cohortCounts <- merge(
      x = cohortCounts, 
      y = pred, 
      by.x = c('cohortId','cohortName'),
      by.y = c('cohortDefinitionId','cohortName'),
      all.x = T
    )
  }
  
  cm <- tryCatch(getCmOutcomes(
    connectionHandler = connectionHandler,
    schema = schema,
    cgTablePrefix = cgTablePrefix,
    cmTablePrefix = cmTablePrefix, 
    targetId = targetId
  ), error = function(e){return(NULL)})
  if(!is.null(cm)){
    cohortCounts <- merge(
      x = cohortCounts, 
      y = cm, 
      by.x = c('cohortId','cohortName'),
      by.y = c('cohortDefinitionId','cohortName'),
      all.x = T
    )
  }
  
  sccs <- tryCatch(getSccsOutcomes(
    connectionHandler = connectionHandler,
    schema = schema,
    cgTablePrefix = cgTablePrefix,
    sccsTablePrefix = sccsTablePrefix, 
    targetId = targetId
  ), error = function(e){return(NULL)})
  if(!is.null(sccs)){
    cohortCounts <- merge(
      x = cohortCounts, 
      y = sccs, 
      by.x = c('cohortId','cohortName'),
      by.y = c('cohortDefinitionId','cohortName'),
      all.x = T
    )
  }
  
  if(sum(is.na(cohortCounts)) !=0){
    cohortCounts[is.na(cohortCounts)] <- 0
  }
  
  # add missing analyses (if they failed) with all 0 columns?
  colnameTypes <- c('timeToEvent','dechalRechal','riskFactors','caseSeries',
                    'cohortMethod', 'selfControlledCaseSeries', 'prediction',
                    'cohortIncidence') 
  
  if(sum(colnameTypes %in% colnames(cohortCounts)) != length(colnameTypes)){
    missingCols <- colnameTypes[!colnameTypes %in% colnames(cohortCounts)]
    for(missingCol in missingCols){
      cohortCounts[missingCol] <- 0
    }
  }
  
  # remove columns that are 0 for all as these are not outcomes
  removeInd <- apply(cohortCounts[,colnameTypes],1, sum) == 0
  cohortCounts <- cohortCounts[!removeInd,]
  
  # TODO: reorder columns to match docs 
  
  
  # order by names
  cohortCounts <- cohortCounts %>% 
    dplyr::arrange(.data$parentName, .data$cohortName)
  
  
  return(cohortCounts)
}

