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
#' @param getIncidenceInclusion Whether to check useage of the cohort in incidence
#' @param getCharacterizationInclusion Whether to check useage of the cohort in characterization
#' @param getPredictionInclusion Whether to check useage of the cohort in prediction
#' @param getCohortMethodInclusion Whether to check useage of the cohort in cohort method
#' @param getSccsInclusion Whether to check useage of the cohort in SCCS
#' @param printTimes Whether to print how long each query took 
#' @family helper
#' @return
#' Returns a data.frame with the columns: 
#' \itemize{
#'  \item{cohortId the number id for the target cohort}
#'  \item{cohortName the name of the cohort}
#'  \item{subsetParent the number id of the parent cohort}
#'  \item{subsetDefinitionId the number id of the subset}
#'  \item{subsetDefinitionJson the json of the subset}
#'  \item{subsetCohortIds the ids of any cohorts that are restricted to by the subset logic}
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
  databaseTable = 'database_meta_data',
  getIncidenceInclusion = TRUE,
  getCharacterizationInclusion = TRUE,
  getPredictionInclusion = TRUE,
  getCohortMethodInclusion = TRUE,
  getSccsInclusion = TRUE,
  printTimes = FALSE
){
  
  start <- Sys.time()
  firstStart <- start
  
  cohorts <- getCohortDefinitions(
    connectionHandler = connectionHandler,
    schema = schema
  ) %>%
    dplyr::select("cohortDefinitionId", "cohortName", "subsetParent", "subsetDefinitionId", "subsetDefinitionJson") %>%
    dplyr::rename(cohortId = "cohortDefinitionId")
  
  end <- Sys.time()
  if(printTimes){
    print(paste0('extracting target cohorts: ', (end-start), ' ', units((end-start))))
  }
  start <- Sys.time()
  
  # TODO: process subsetDefinitionJson
  cohorts$subsetCohortId <- as.double(unlist(lapply(cohorts$subsetDefinitionJson, function(json){extractSubsetCohorts(json)})))
  
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
  
  end <- Sys.time()
  if(printTimes){
    print(paste0('processing target cohorts: ', (end-start), ' ', units((end-start))))
  }
  start <- Sys.time()
  
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
      minEntryCount = min(.data$cohortEntries, na.rm = T),
      maxEntryCount = max(.data$cohortEntries, na.rm = T)
    )
  
  cohortCounts <- merge(cohorts, counts, by = 'cohortId')
  
  end <- Sys.time()
  if(printTimes){
    print(paste0('extracting target cohort counts: ', (end-start), ' ', units((end-start))))
  }
  start <- Sys.time()
  
  # now find whether it is a target for each analysis
  
  if(getIncidenceInclusion){
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
    
    end <- Sys.time()
    if(printTimes){
      print(paste0('extracting incidence targets: ', (end-start), ' ', units((end-start))))
    }
    start <- Sys.time()
    
  }
  
  if(getCharacterizationInclusion){
    char <- tryCatch(getCharacterizationTargets(
      connectionHandler = connectionHandler,
      schema = schema,
      cgTablePrefix = cgTablePrefix,
      cTablePrefix = cTablePrefix,
      printTimes = printTimes
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
    
    start <- Sys.time() # reset time if char called
  }
  
  if(getPredictionInclusion){
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
    
    end <- Sys.time()
    if(printTimes){
      print(paste0('extracting prediction target cohorts: ', (end-start), ' ', units((end-start))))
    }
    start <- Sys.time()
    
  }
  
  if(getCohortMethodInclusion){
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
    
    end <- Sys.time()
    if(printTimes){
      print(paste0('extracting cohort method target cohorts: ', (end-start), ' ', units((end-start))))
    }
    start <- Sys.time()
    
  }
  
  if(getSccsInclusion){
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
    
    end <- Sys.time()
    if(printTimes){
      print(paste0('extracting sscs target cohorts: ', (end-start), ' ', units((end-start))))
    }
    start <- Sys.time()
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
  
  end <- Sys.time()
  if(printTimes){
    print(paste0('final target cohort processing: ', (end-start), ' ', units((end-start))))
  }
  
  # report total time
  print(paste0('-- Total time for extarcting target table: ', (end-firstStart), ' ', units((end-firstStart))))
  
return(cohortCounts)
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
#' @param getIncidenceInclusion Whether to check usage of the cohort in incidence
#' @param getCharacterizationInclusion Whether to check usage of the cohort in characterization
#' @param getPredictionInclusion Whether to check usage of the cohort in prediction
#' @param getCohortMethodInclusion Whether to check usage of the cohort in cohort method
#' @param getSccsInclusion Whether to check usage of the cohort in SCCS
#' @param printTimes whether to print the time it takes to run each SQL query
#' @family helper
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
    targetId = NULL,
    getIncidenceInclusion = TRUE,
    getCharacterizationInclusion = TRUE,
    getPredictionInclusion = TRUE,
    getCohortMethodInclusion = TRUE,
    getSccsInclusion = TRUE,
    printTimes = FALSE
){
  
  start <- Sys.time()
  firstStart <- start
  
  cohorts <- getCohortDefinitions(
    connectionHandler = connectionHandler,
    schema = schema
  ) %>%
    dplyr::select("cohortDefinitionId", "cohortName", "subsetParent", "subsetDefinitionId") %>%
    dplyr::rename(cohortId = "cohortDefinitionId")
  
  end <- Sys.time()
  if(printTimes){
    print(paste0('extracting outcome cohorts: ', (end-start), ' ', units((end-start))))
  }
  start <- Sys.time()
  
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
  
  end <- Sys.time()
  if(printTimes){
    print(paste0('processing outcome parent cohorts: ', (end-start), ' ', units((end-start))))
  }
  start <- Sys.time()
  
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
  
  end <- Sys.time()
  if(printTimes){
    print(paste0('adding outcome cohort counts: ', (end-start), ' ', units((end-start))))
  }
  
  # now find whether it is a target for each analysis
  
  if(getIncidenceInclusion){
    start <- Sys.time()
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
    
    end <- Sys.time()
    if(printTimes){
      print(paste0('finding incidence outcomes: ', (end-start), ' ', units((end-start))))
    }
  }
  
  if(getCharacterizationInclusion){
    char <- tryCatch(getCharacterizationOutcomes(
      connectionHandler = connectionHandler,
      schema = schema,
      cgTablePrefix = cgTablePrefix,
      cTablePrefix = cTablePrefix, 
      targetId = targetId, 
      printTimes = printTimes
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
  }

  
  if(getPredictionInclusion){
    start <- Sys.time()
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
    
    end <- Sys.time()
    if(printTimes){
      print(paste0('extracting prediction cohorts: ', (end-start), ' ', units((end-start))))
    }
  }
  
  if(getCohortMethodInclusion){
    start <- Sys.time()
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
    
    end <- Sys.time()
    if(printTimes){
      print(paste0('extracting cohort method cohorts: ', (end-start), ' ', units((end-start))))
    }
  }
  
  if(getSccsInclusion){
    start <- Sys.time()
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
    
    end <- Sys.time()
    if(printTimes){
      print(paste0('extracting sccs cohorts: ', (end-start), ' ', units((end-start))))
    }
  }
  
  start <- Sys.time()
  
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
  
  end <- Sys.time()
  if(printTimes){
    print(paste0('final processing of outcome cohorts: ', (end-start), ' ', units((end-start))))
  }
  
  # report total time
  print(paste0('-- Total time for extarcting outcome table: ', (end-firstStart), ' ', units((end-firstStart))))
  
  return(cohortCounts)
}




extractSubsetCohorts <- function(json){
  
  if(is.na(json)){
    return("")
  }
  
  if(is.null(json)){
    return("")
  }
  
  
  subsetDefs <- lapply(json, function(x) ParallelLogger::convertJsonToSettings(x))
  
  subsetOps <- lapply(subsetDefs, function(x){
    x$subsetOperators
  })
  
  # remove name and extract cohortIds when subsetType == "CohortSubsetOperator"
  subsetUnique <- subsetOps
  subsetCohorts <- c()
  for(sind in 1:length(subsetUnique)){
    for(sind2 in 1:length(subsetUnique[[sind]])){
      if(subsetUnique[[sind]][[sind2]]$subsetType == 'CohortSubsetOperator'){
        subsetCohorts <- c(subsetCohorts,subsetUnique[[sind]][[sind2]]$cohortIds)
      }
    }
  }
  subsetCohorts <- paste0(unique(subsetCohorts), collapse = '')
  
  return(subsetCohorts)
  
}
