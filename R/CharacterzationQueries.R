.getCVersion <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_'
){
  majorVersion <- 0 # Default to v0
  minorVersion <- 0
  tryCatch(
    {
      sql <- "SELECT version_number from @schema.@c_table_prefixpackage_version;"
      
      pkversion <- connectionHandler$queryDb(
        sql = sql,
        schema = schema,
        c_table_prefix = cTablePrefix
      ) %>%
        dplyr::pull(.data$versionNumber) %>%
        dplyr::first()
      
      majorVersion = strsplit(x = pkversion, split = '\\.')[[1]][1]
      minorVersion = strsplit(x = pkversion, split = '\\.')[[1]][2]
 
    },
    error = function(e) {
      # Do nothing - most likely the migration table does not exist so assume
      # v0
    }
  )
  
  if(majorVersion >= 3){
    version <- '3_0_0'
  } else{
    version <- '0'
  }
  
  return(version)
}


.getCIVersion <- function(
    connectionHandler,
    schema,
    ciTablePrefix = 'ci_'
){
  version <- 0 
  
  tryCatch(
    {
      sql <- "SELECT version_number from @schema.@ci_table_prefixpackage_version');"
      
      pkversion <- connectionHandler$queryDb(
        sql = sql,
        schema = schema,
        ci_table_prefix = ciTablePrefix
      ) %>%
        dplyr::pull(.data$versionNumber) %>%
        dplyr::first()
      
      majorVersion = strsplit(x = pkversion, split = '\\.')[[1]][1]
      minorVersion = strsplit(x = pkversion, split = '\\.')[[1]][2]
      
    },
    error = function(e) {
      # Do nothing - most likely the migration table does not exist so assume
      # v0
    }
  )
  
  return(version)
}

# the actual package version to display
.getCPackageVersion <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_'
){

  version <- '0.0.0'
  tryCatch(
    {
      sql <- "SELECT version_number from @schema.@c_table_prefixpackage_version');"
      
      version <- connectionHandler$queryDb(
        sql = sql,
        schema = schema,
        c_table_prefix = cTablePrefix
      ) %>%
        dplyr::pull(.data$versionNumber) %>%
        dplyr::first()
      
    },
    error = function(e) {
      # Do nothing - most likely the migration table does not exist so assume
      # v0
    }
  )

  return(version)
}


#' A function to extarct the targets found in characterization
#'
#' @details
#' Specify the connectionHandler, the schema and the prefixes
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @param printTimes Print the time it takes to run each query
#' @param useTte whether to determine what cohorts are used in time to event
#' @param useDcrc whether to determine what cohorts are used in dechal-rechal
#' @param useRf whether to determine what cohorts are used in risk factor
#' @param useTb whether to determine what cohorts are used in target baseline
#' @param useCs whether to determine what cohorts are used in case-series
#' 
#' @family Characterization
#' 
#' @return
#' A data.frame with the characterization target cohort ids, names and which characterization analyses the cohorts are used in.
#'
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cohorts <- getCharacterizationTargets(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getCharacterizationTargets <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    printTimes = FALSE,
    useTte = TRUE,
    useDcrc = TRUE,
    useRf = TRUE,
    useTb = TRUE,
    useCs = TRUE
){
  
  cVersion <- .getCVersion(
      connectionHandler = connectionHandler,
      schema = schema,
      cTablePrefix = cTablePrefix
    )

  
  first <- Sys.time()
  
  tteData <- data.frame()
  if(useTte){ 
    start <- Sys.time()
    
    # check tte normalized table with target_cohort_definition_id exists or return NULL if it does not
    normExists <- tryCatch({
      connectionHandler$queryDb(
        sql = "select * from @schema.@c_table_prefixtime_to_event_targets limit 1;",
        schema = schema,
        c_table_prefix = cTablePrefix
      )
    }, error = function(e){
      return(NULL)
      })
    
    tableOrView <- ifelse(
      is.null(normExists),
      "(select distinct target_cohort_definition_id from @schema.@c_table_prefixtime_to_event)",
      "@schema.@c_table_prefixtime_to_event_targets"
    )
    
    tteData <- tryCatch({connectionHandler$queryDb(
      sql = paste0("
      select 
           cg.cohort_name,
           tte.target_cohort_definition_id as cohort_definition_id,
           'timeToEvent' as type,
           1 as value
        from ",tableOrView," tte
        inner join 
        @schema.@cg_table_prefixcohort_definition cg
        on tte.target_cohort_definition_id = cg.cohort_definition_id
    ;"),
      schema = schema,
      cg_table_prefix = cgTablePrefix,
      c_table_prefix = cTablePrefix
    )}, error = function(e){warning(e); return(NULL)})
    
    end <- Sys.time()
    if(printTimes){
      print(paste0('extracting time_to_event targets: ', (end-start), ' ', units((end-start))))
    }
  }
  
  
  dcrcData  <- data.frame()
  if(useDcrc){
    start <- Sys.time()
    
    sql <- SqlRender::readSql(system.file(
      paste0("sql/sql_server/characterization/getCharacterizationTargetsDcrc.sql"),
      package = "OhdsiReportGenerator",
      mustWork = TRUE
    ))
    
    dcrcData <- tryCatch({connectionHandler$queryDb(
      sql = sql,
      schema = schema,
      cg_table_prefix = cgTablePrefix,
      c_table_prefix = cTablePrefix
    )}, error = function(e){warning(e); return(NULL)})
    
    end <- Sys.time()
    if(printTimes){
      print(paste0('extracting dechallenge_rechallenge targets: ',  (end-start), ' ', units((end-start))))
    }
  }
  
  rfData  <- data.frame()
  if(useRf){
    start <- Sys.time()
    
    sql <- SqlRender::readSql(system.file(
      paste0("sql/sql_server/characterization/getCharacterizationTargetsRfV", cVersion, ".sql"),
      package = "OhdsiReportGenerator",
      mustWork = TRUE
    ))
    
    rfData <- tryCatch({connectionHandler$queryDb(
      sql = sql,
      schema = schema,
      cg_table_prefix = cgTablePrefix,
      c_table_prefix = cTablePrefix
    )}, error = function(e){warning(e); return(NULL)})
    
    end <- Sys.time()
    
    if(printTimes){
      print(paste0('extracting risk factor targets: ',  (end-start), ' ', units((end-start))))
    }
    
  }
  
  tbData  <- data.frame()
  if(useTb){

    start <- Sys.time()
    
    sql <- SqlRender::readSql(system.file(
      paste0("sql/sql_server/characterization/getCharacterizationTargetsTbV", cVersion, ".sql"),
      package = "OhdsiReportGenerator",
      mustWork = TRUE
    ))
    
    tbData <- tryCatch({connectionHandler$queryDb(
      sql = sql,
      schema = schema,
      cg_table_prefix = cgTablePrefix,
      c_table_prefix = cTablePrefix
    )}, error = function(e){warning(e); return(NULL)})
    
    end <- Sys.time()
    
    if(printTimes){
      print(paste0('extracting target baseline targets: ',  (end-start), ' ', units((end-start))))
    }
 
  }
  
  csData  <- data.frame()
  if(useCs){
    start <- Sys.time()
    
    if(file.exists(system.file(
      paste0("sql/sql_server/characterization/getCharacterizationTargetsCsV", cVersion, ".sql"),
      package = "OhdsiReportGenerator"
    ))){
      
      sql <- SqlRender::readSql(system.file(
        paste0("sql/sql_server/characterization/getCharacterizationTargetsCsV", cVersion, ".sql"),
        package = "OhdsiReportGenerator",
        mustWork = TRUE
      ))
      
      csData <- tryCatch({connectionHandler$queryDb(
        sql = sql,
        schema = schema,
        cg_table_prefix = cgTablePrefix,
        c_table_prefix = cTablePrefix
      )}, error = function(e){warning(e); return(NULL)})
      
      end <- Sys.time()
      
      if(printTimes){
        print(paste0('extracting case series targets: ',  (end-start), ' ', units((end-start))))
      }
    }
    
  }
  
  start <- Sys.time()
  
  targets <- rbind(tteData, dcrcData, rfData, tbData, csData)
  if(is.null(targets)){
    message('No target data')
    end <- Sys.time()
    print(paste0('-- all extracting characterization targets took: ',  (end-first), ' ', units((end-first))))
    return(NULL)
  }
  
  targets <- targets %>%
    tidyr::pivot_wider(
      id_cols = c("cohortName", "cohortDefinitionId"), 
      names_from = "type", 
      values_from = c("value"), 
      values_fill = 0
    )
  
  end <- Sys.time()
  
  if(printTimes){
    print(paste0('pivoting data took: ',  (end-start), ' ', units((end-start))))
  }
  
  start <- Sys.time()
  # add missing types with 0 values
  colnameTypes <- c('timeToEvent','dechalRechal','riskFactors','databaseComparator') 
  
  if(sum(colnameTypes %in% colnames(targets)) != 4){
    missingCols <- colnameTypes[!colnameTypes %in% colnames(targets)]
    for(missingCol in missingCols){
      targets[missingCol] <- 0
    }
  }
  

  # pre V3
  if(!"caseSeries" %in% colnames(targets)){
    targets$caseSeries <- targets$riskFactors
  }
  
  # Add redundant columns - these are dep on each other
  targets$cohortComparator <- targets$databaseComparator
  
  end <- Sys.time()
  
  if(printTimes){
    print(paste0('processing characterization target details: ', (end-start), ' ', units((end-start))))
  }
  
  print(paste0('-- all extracting characterization targets took: ',  (end-first), ' ', units((end-first))))
  
  return(targets)
}


#' A function to extract the outcomes found in characterization
#'
#' @details
#' Specify the connectionHandler, the schema and the prefixes
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @template targetId
#' @param printTimes Print the time it takes to run each query
#' @param useDcrc look for outcome in dechal-rechal results
#' @param useTte look for outcome in time-to-event results
#' @param useRf look for outcome in risk-factor results
#' @param useCs look for outcome in case series results
#' 
#' @family Characterization
#' 
#' @return
#' A data.frame with the characterization outcome cohort ids, names and which characterization analyses the cohorts are used in.
#'
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cohorts <- getCharacterizationOutcomes(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getCharacterizationOutcomes <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    targetId = NULL,
    printTimes = FALSE,
    useDcrc = TRUE,
    useTte = TRUE,
    useRf = TRUE,
    useCs = TRUE
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  firstStart <- Sys.time()
  
  # first check each table
  
  tteData <- data.frame()
  if(useTte){ # if user wants time to event see whether there are results
    start <- Sys.time()
    
    sql <- SqlRender::readSql(system.file(
      paste0("sql/sql_server/characterization/getCharacterizationOutcomesTte.sql"),
      package = "OhdsiReportGenerator",
      mustWork = TRUE
    ))
    
    tteData <- tryCatch({connectionHandler$queryDb(
      sql = sql,
      schema = schema,
      cg_table_prefix = cgTablePrefix,
      c_table_prefix = cTablePrefix,
      use_target = !is.null(targetId),
      target_ids = paste0(targetId, collapse = ',')
    )}, error = function(e){warning(e); return(NULL)})
    
    end <- Sys.time()
    if(printTimes){
      print(paste0('extracting time_to_event outcomes: ', (end-start), ' ', units((end-start))))
    }
  }
  
  dcrcData <- data.frame()
  if(useDcrc){ # if user wants dechal see whether there are results
    start <- Sys.time()
    
    sql <- SqlRender::readSql(system.file(
      paste0("sql/sql_server/characterization/getCharacterizationOutcomesDcrc.sql"),
      package = "OhdsiReportGenerator",
      mustWork = TRUE
    ))
    
    dcrcData <- tryCatch({connectionHandler$queryDb(
      sql = sql,
      schema = schema,
      cg_table_prefix = cgTablePrefix,
      c_table_prefix = cTablePrefix,
      use_target = !is.null(targetId),
      target_ids = paste0(targetId, collapse = ',')
    )}, error = function(e){warning(e); return(NULL)})
    
    end <- Sys.time()
    if(printTimes){
      print(paste0('extracting dechallenge_rechallenge outcomes: ', (end-start), ' ', units((end-start))))
    }
  }
  
  rfData <- data.frame()
  if(useRf){ # if user wants risk factors see whether there are results
    start <- Sys.time()
    
    sql <- SqlRender::readSql(system.file(
      paste0("sql/sql_server/characterization/getCharacterizationOutcomesRfV", cVersion, ".sql"),
      package = "OhdsiReportGenerator",
      mustWork = TRUE
    ))
    
    rfData <- tryCatch({connectionHandler$queryDb(
      sql = sql,
      schema = schema,
      cg_table_prefix = cgTablePrefix,
      c_table_prefix = cTablePrefix,
      use_target = !is.null(targetId),
      target_ids = paste0(targetId, collapse = ',')
    )}, error = function(e){warning(e); return(NULL)})
    
    end <- Sys.time()
    if(printTimes){
      print(paste0('extracting risk factor outcomes: ', (end-start), ' ', units((end-start))))
    }
  }
  
  csData <- data.frame()
  if(useCs){
    
    if(file.exists(
      system.file(
        paste0("sql/sql_server/characterization/getCharacterizationOutcomesCsV", cVersion, ".sql"),
        package = "OhdsiReportGenerator"
      )
    )){
      start <- Sys.time()
      
      sql <- SqlRender::readSql(system.file(
        paste0("sql/sql_server/characterization/getCharacterizationOutcomesCsV", cVersion, ".sql"),
        package = "OhdsiReportGenerator",
        mustWork = TRUE
      ))
      
      csData <- tryCatch({connectionHandler$queryDb(
        sql = sql,
        schema = schema,
        cg_table_prefix = cgTablePrefix,
        c_table_prefix = cTablePrefix,
        use_target = !is.null(targetId),
        target_ids = paste0(targetId, collapse = ',')
      )}, error = function(e){warning(e); return(NULL)})
      
      end <- Sys.time()
      if(printTimes){
        print(paste0('extracting case series outcomes: ', (end-start), ' ', units((end-start))))
      }
    }
  }
  
  
  start <- Sys.time()
  
  if(cVersion == 0 & nrow(rfData) > 0){
    csData <- rfData
    csData$type <- 'caseSeries'
  }
  
  outcomes <- rbind(tteData, dcrcData, rfData, csData) 
  
  if(is.null(outcomes)){
    end <- Sys.time()
    message('No outcomes found')
    print(paste0('Extracting characterization outcomes took: ', (end-firstStart), ' ', units((end-firstStart))))
    return(NULL)
  }
  
  outcomes <- outcomes %>%
    tidyr::pivot_wider(
      id_cols = c("cohortName", "cohortDefinitionId"), 
      names_from = "type", 
      values_from = c("value"), 
      values_fill = 0
    )
  
  end <- Sys.time()
  if(printTimes){
    print(paste0('pivoting characterization outcome cohort details: ', (end-start), ' ', units((end-start))))
  }
  
  
  start <- Sys.time()
  
  # add missing types with 0 values
  colnameTypes <- c('timeToEvent','dechalRechal','riskFactors', 'caseSeries') 
  if(sum(colnameTypes %in% colnames(outcomes)) != 4){
    missingCols <- colnameTypes[!colnameTypes %in% colnames(outcomes)]
    for(missingCol in missingCols){
      outcomes[missingCol] <- 0
    }
  }
  
  # get case series tar: risk_window_start/risk_window_end/start_anchor/end_anchor and outcome_washout_days
  
  if(useRf | useCs){
    
    sql <- SqlRender::readSql(system.file(
      paste0("sql/sql_server/characterization/getCharacterizationOutcomesTarsV", cVersion, ".sql"),
      package = "OhdsiReportGenerator"
    ))
    
    outcomeDetails <- tryCatch({connectionHandler$queryDb( 
      sql = sql,
      schema = schema,
      c_table_prefix = cTablePrefix,
      use_target = !is.null(targetId),
      target_ids = paste0(targetId, collapse = ',')
    ) %>% 
        dplyr::rowwise() %>%
        dplyr::mutate(
          tarName = paste0('(',.data$startAnchor, ' + ',.data$riskWindowStart , ') - (',
                           .data$endAnchor, ' + ',.data$riskWindowEnd , ')'),
          tarString = paste0(.data$riskWindowStart, '/',.data$startAnchor , '/',
                             .data$riskWindowEnd, '/',.data$endAnchor )
        ) %>%
        dplyr::select("cohortDefinitionId", "tarName", "tarString", "outcomeWashoutDays") %>%
        dplyr::group_by(.data$cohortDefinitionId) %>%
        dplyr::summarise(
          tarNames = paste0(unique(.data$tarName), collapse = ':'),
          tarStrings = paste0(unique(.data$tarString), collapse = ':'),
          outcomeWashoutDays = paste0(unique(.data$outcomeWashoutDays), collapse = ':')
        )}, error = function(e){NULL})
    
    if(!is.null(outcomeDetails)){
      outcomes <- merge(
        x = outcomes,
        y = outcomeDetails, 
        by = 'cohortDefinitionId'
      )
    }
    
  }
  
  end <- Sys.time()
  if(printTimes){
    print(paste0('processing characterization outcomes and adding tars/washout: ', (end-start), ' ', units((end-start))))
  }
  
  print(paste0('Extracting characterization outcomes took: ', (end-firstStart), ' ', units((end-firstStart))))
  
  return(outcomes)
  
}


#' A function to extract the targets found in incidence
#'
#' @details
#' Specify the connectionHandler, the schema and the prefixes
#'
#' @template connectionHandler
#' @template schema
#' @template ciTablePrefix
#' @template cgTablePrefix
#' @family Characterization
#' 
#' @return
#' A data.frame with the incidence target cohort ids and names
#'
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cohorts <- getIncidenceTargets(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getIncidenceTargets <- function(
    connectionHandler,
    schema,
    ciTablePrefix = 'ci_',
    cgTablePrefix = 'cg_'
){
  
  ciVersion <- .getCIVersion(
      connectionHandler = connectionHandler,
      ciTablePrefix = ciTablePrefix
      )
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getIncidenceTargetsV", ciVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  targets <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cg_table_prefix = cgTablePrefix,
    ci_table_prefix = ciTablePrefix
  ) %>%
    tidyr::pivot_wider(
      id_cols = c("cohortName", "cohortDefinitionId"), 
      names_from = "type", 
      values_from = c("value")
    )
  
  return(targets)
  
}


#' A function to extract the outcomes found in incidence
#'
#' @details
#' Specify the connectionHandler, the schema and the prefixes
#'
#' @template connectionHandler
#' @template schema
#' @template ciTablePrefix
#' @template cgTablePrefix
#' @template targetId
#' @family Characterization
#' 
#' @return
#' A data.frame with the incidence outcome cohort ids and names
#'
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' outcomes <- getIncidenceOutcomes(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getIncidenceOutcomes <- function(
    connectionHandler,
    schema,
    ciTablePrefix = 'ci_',
    cgTablePrefix = 'cg_',
    targetId = NULL
){
  
  ciVersion <- .getCIVersion(
    connectionHandler = connectionHandler,
    ciTablePrefix = ciTablePrefix
  )
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getIncidenceOutcomesV", ciVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  outcomes <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cg_table_prefix = cgTablePrefix,
    ci_table_prefix = ciTablePrefix,
    use_target = !is.null(targetId),
    target_id = paste0(targetId, collapse = ',')
  ) %>%
    tidyr::pivot_wider(
      id_cols = c("cohortName", "cohortDefinitionId"), 
      names_from = "type", 
      values_from = c("value")
    )
  
  return(outcomes)
  
}

#' Extract the cohort incidence result
#' @description
#' This function extracts all incidence rates across databases in the results for specified target and outcome cohorts.
#'
#' @details
#' Specify the connectionHandler, the schema and the target/outcome cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template ciTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetIds
#' @template outcomeIds
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{databaseId the unique id of the database}
#'  \item{targetName the target cohort name}
#'  \item{targetId the target cohort unique identifier}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome unique identifier}
#'  \item(tar the friendly time-at-risk string)
#'  \item{cleanWindow clean windown around outcome}
#'  \item{subgroupName name for the result subgroup}
#'  \item{ageGroupName name for the result age group}
#'  \item{genderName name for the result gender group}
#'  \item{startYear name for the result start year}
#'  \item{tarStartWith time at risk start reference}
#'  \item{tarStartOffset time at risk start offset from reference}
#'  \item{tarEndWith time at risk end reference}
#'  \item{tarEndOffset time at risk end offset from reference}
#'  \item{personsAtRiskPe persons at risk per event}
#'  \item{personsAtRisk persons at risk}
#'  \item{personDaysPe person days per event}
#'  \item{personDays person days}
#'  \item{personOutcomesPe person outcome per event}
#'  \item{personOutcomes persons outcome}
#'  \item{outcomesPe number of outcome per event}
#'  \item{outcomes number of outcome}
#'  \item{incidenceProportionP100p incidence proportion per 100 persons}
#'  \item{incidenceRateP100py incidence rate per 100 person years}
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
getIncidenceRates <- function(
    connectionHandler,
    schema,
    ciTablePrefix = 'ci_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    outcomeIds = NULL
){
  
  ciVersion <- .getCIVersion(
    connectionHandler = connectionHandler,
    ciTablePrefix = ciTablePrefix
  )
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getIncidenceRatesV", ciVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    ci_table_prefix = ciTablePrefix,
    cg_table_prefix = cgTablePrefix,
    target_id = paste0(targetIds, collapse = ','),
    use_target = !is.null(targetIds),
    outcome_id = paste0(outcomeIds, collapse = ','),
    use_outcome = !is.null(outcomeIds),
    database_table_name = databaseTable
  )
  
  if(nrow(result) > 0){
    result$incidenceProportionP100p[is.na(result$incidenceProportionP100p)] <- result$outcomes[is.na(result$incidenceProportionP100p)]/result$personsAtRisk[is.na(result$incidenceProportionP100p)]*100
    result$incidenceProportionP100p[is.na(result$incidenceProportionP100p)] <- 0
    result$incidenceRateP100py[is.na(result$incidenceRateP100py)] <- result$outcomes[is.na(result$incidenceRateP100py)]/(result$personDays[is.na(result$incidenceRateP100py)]/365)*100
    result$incidenceRateP100py[is.na(result$incidenceRateP100py)] <- 0
    result[is.na(result)] <- 'Any'
    result <- unique(result)
    
    # add friendly tar
    result$tar <- paste0('( ',result$tarStartWith, ' + ', result$tarStartOffset, ' ) - ( ',
                         result$tarEndWith, ' + ', result$tarEndOffset, ' )')
  } else{
    # add tar but using other column as length 0 this just add name
    result$tar <- result$tarStartWith
  }
  
  # change the position of tar
  result <- result %>% dplyr::relocate("tar", .after = "outcomeId")
  
  return(result)
}

#' Extract the time to event result
#' @description
#' This function extracts all time to event results across databases for specified target and outcome cohorts.
#'
#' @details
#' Specify the connectionHandler, the schema and the target/outcome cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetIds
#' @template outcomeIds
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{databaseId the unique identifier of the database}
#'  \item{targetName the target cohort name}
#'  \item{targetId the target cohort unique identifier}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome unique identifier}
#'  \item{outcomeType Whether the outcome is the first or subsequent}
#'  \item{targetOutcomeType The interval that the outcome occurs}
#'  \item{timeToEvent The number of days from index}
#'  \item{numEvents The number of target cohort entries}
#'  \item{timeScale The correspondin time-scale}
#'  } 
#' 
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' tte <- getTimeToEvent(
#' connectionHandler = connectionHandler, 
#' schema = 'main'
#' )
#'  
getTimeToEvent <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    outcomeIds = NULL
){
  
  # add code here
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getTimeToEvent.sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    target_id = paste0(targetIds, collapse = ','),
    use_target = !is.null(targetIds),
    outcome_id = paste0(outcomeIds, collapse = ','),
    use_outcome = !is.null(outcomeIds),
    c_table_prefix = cTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable
  )
  
  return(result)
}

#' Extract the dechallenge rechallenge results
#' @description
#' This function extracts all dechallenge rechallenge results across databases for specified target and outcome cohorts.
#'
#' @details
#' Specify the connectionHandler, the schema and the target/outcome cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetIds
#' @template outcomeIds
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{databaseId the unique identifier of the database}
#'  \item{targetName the target cohort name}
#'  \item{targetId the target cohort unique identifier}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome unique identifier}
#'  \item{dechallengeStopInterval An integer specifying the how much time to add to the cohort_end when determining whether the event starts during cohort and ends after}
#'  \item{dechallengeEvaluationWindow A period of time evaluated for outcome recurrence after discontinuation of exposure, among patients with challenge outcomes}
#'  \item{numExposureEras Distinct number of exposure events (i.e. drug eras) in a given target cohort}
#'  \item{numPersonsExposed Distinct number of people exposed in target cohort. A person must have at least 1 day exposure to be included}
#'  \item{numCases Distinct number of persons in outcome cohort. A person must have at least 1 day of observation time to be included}
#'  \item{dechallengeAttempt Distinct count of people with observable time after discontinuation of the exposure era during which the challenge outcome occurred}
#'  \item{dechallengeFail Among people with challenge outcomes, the distinct number of people with outcomes during dechallengeEvaluationWindow}
#'  \item{dechallengeSuccess Among people with challenge outcomes, the distinct number of people without outcomes during the dechallengeEvaluationWindow}
#'  \item{rechallengeAttempt Number of people with a new exposure era after the occurrence of an outcome during a prior exposure era}
#'  \item{rechallengeFail Number of people with a new exposure era during which an outcome occurred, after the occurrence of an outcome during a prior exposure era}
#'  \item{rechallengeSuccess Number of people with a new exposure era during which an outcome did not occur, after the occurrence of an outcome during a prior exposure era}
#'  \item{pctDechallengeAttempt Percent of people with observable time after discontinuation of the exposure era during which the challenge outcome occurred}
#'  \item{pctDechallengeFail Among people with challenge outcomes, the percent of people without outcomes during the dechallengeEvaluationWindow}
#'  \item{pctDechallengeSuccess Among people with challenge outcomes, the percent of people with outcomes during dechallengeEvaluationWindow}
#'  \item{pctRechallengeAttempt Percent of people with a new exposure era after the occurrence of an outcome during a prior exposure era}
#'  \item{pctRechallengeFail Percent of people with a new exposure era during which an outcome did not occur, after the occurrence of an outcome during a prior exposure era}
#'  \item{pctRechallengeSuccess Percent of people with a new exposure era during which an outcome occurred, after the occurrence of an outcome during a prior exposure era}
#'  } 
#' 
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' dcrc <- getDechallengeRechallenge(
#' connectionHandler = connectionHandler, 
#' schema = 'main'
#' )
#' 
getDechallengeRechallenge <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    outcomeIds = NULL
){
  
  # add code here
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getDechallengeRechallenge.sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    target_id = paste0(targetIds, collapse = ','),
    use_target = !is.null(targetIds),
    outcome_id = paste0(outcomeIds, collapse = ','),
    use_outcome = !is.null(outcomeIds),
    c_table_prefix = cTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable
  )
  
  return(result)
}

#' Extract the target cohort counts result
#' @description
#' This function extracts target cohort counts across databases in the results for specified target and outcome cohorts.
#'
#' @details
#' Specify the connectionHandler, the schema and the target/outcome cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetIds
#' @template outcomeIds
#' @param databaseIds A vector of database IDs to restrict to
#' 
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{databaseId the unique identifier of the database}
#'  \item{targetName the target cohort name}
#'  \item{targetId the target cohort unique identifier}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome unique identifier}
#'  \item{rowCount the number of entries in the cohort}
#'  \item{personCount the number of people in the cohort}
#'  \item{withoutExcludedPersonCount the number of people in the target ignoring exclusions}
#'  \item{minPriorObservation the minimum required observation days prior to index for an entry}
#'  \item{outcomeWashoutDays patients with the outcome occurring within this number of days prior to index are excluded (NA means no exclusion)}
#'  } 
#' 
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' tc <- getCaseTargetCounts(
#' connectionHandler = connectionHandler, 
#' schema = 'main'
#' )
#' 
getCaseTargetCounts <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    outcomeIds = NULL,
    databaseIds = NULL
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getCaseTargetCountsV", cVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  
 result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    target_id = paste0(targetIds, collapse = ','),
    use_target = !is.null(targetIds),
    outcome_id = paste0(outcomeIds, collapse = ','),
    use_outcome = !is.null(outcomeIds),
    c_table_prefix = cTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table_name = databaseTable,
    database_id = paste0("'",databaseIds,"'", collapse = ","),
    use_database = !is.null(databaseIds)
  )
  
  return(result)
}



#' Extract the outcome cohort counts result
#' @description
#' This function extracts outcome cohort counts across databases in the results for specified target and outcome cohorts.
#'
#' @details
#' Specify the connectionHandler, the schema and the target/outcome cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetIds
#' @template outcomeIds
#' @param databaseIds (optional) A vector of database IDs to restrict to
#' @param riskWindowStart (optional) A vector of time-at-risk risk window starts to restrict to
#' @param riskWindowEnd (optional) A vector of time-at-risk risk window ends to restrict to
#' @param startAnchor (optional) A vector of time-at-risk start anchors to restrict to
#' @param endAnchor (optional) A vector of time-at-risk end anchors to restrict to
#' 
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{databaseId the unique identifier of the database}
#'  \item{targetName the target cohort name}
#'  \item{targetId the target cohort unique identifier}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome unique identifier}
#'  \item{rowCount the number of entries in the cohort}
#'  \item{personCount the number of people in the cohort}
#'  \item{minPriorObservation the minimum required observation days prior to index for an entry}
#'  \item{outcomeWashoutDays patients with the outcome occurring within this number of days prior to index are excluded (NA means no exclusion)}
#' \item{riskWindowStart the number of days ofset the start anchor that is the start of the time-at-risk}
#' \item{startAnchor the start anchor is either the target cohort start or cohort end date}
#' \item{riskWindowEnd the number of days ofset the end anchor that is the end of the time-at-risk}
#' \item{endAnchor the end anchor is either the target cohort start or cohort end date}
#' } 
#' 
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cc <- getCaseCounts(
#' connectionHandler = connectionHandler, 
#' schema = 'main'
#' )
#' 
getCaseCounts <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    outcomeIds = NULL,
    databaseIds = NULL,
    riskWindowStart = NULL,
    riskWindowEnd = NULL,
    startAnchor = NULL,
    endAnchor = NULL
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getCaseCountsV", cVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    c_table_prefix = cTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable,
    target_id = paste0(targetIds, collapse = ','),
    use_target = !is.null(targetIds),
    outcome_id = paste0(outcomeIds, collapse = ','),
    use_outcome = !is.null(outcomeIds),
    database_id = paste0("'",databaseIds,"'", collapse = ","),
    use_database = !is.null(databaseIds),
    
    use_risk_window_start = !is.null(riskWindowStart),
    risk_window_start = paste0(riskWindowStart, collapse = ','),
    use_risk_window_end = !is.null(riskWindowEnd),
    risk_window_end = paste0(riskWindowEnd, collapse = ','),
    use_start_anchor = !is.null(startAnchor),
    start_anchor = paste0("'",startAnchor,"'", collapse = ","),
    use_end_anchor = !is.null(endAnchor),
    end_anchor = paste0("'",endAnchor,"'", collapse = ",")
  )
  
  return(result)
}


getCaseBinaryFeatures <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    outcomeIds = NULL,
    databaseIds = NULL,
    analysisIds = c(3), # c(8507, 8532)
    riskWindowStart = NULL,
    riskWindowEnd = NULL,
    startAnchor = NULL,
    endAnchor = NULL
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getCaseBinaryFeaturesV", cVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))

result <- connectionHandler$queryDb(
  sql = sql,
  schema = schema,
  target_id = paste0(targetIds, collapse = ','),
  use_target = !is.null(targetIds),
  outcome_id = paste0(outcomeIds, collapse = ','),
  use_outcome = !is.null(outcomeIds),
  c_table_prefix = cTablePrefix,
  cg_table_prefix = cgTablePrefix,
  database_table = databaseTable,
  use_analysis = !is.null(analysisIds),
  analysis_ids = paste0(analysisIds, collapse = ','),
  database_id = paste0("'",databaseIds,"'", collapse = ","),
  use_database = !is.null(databaseIds),
  
  use_risk_window_start = !is.null(riskWindowStart),
  risk_window_start = paste0(riskWindowStart, collapse = ','),
  use_risk_window_end = !is.null(riskWindowEnd),
  risk_window_end = paste0(riskWindowEnd, collapse = ','),
  use_start_anchor = !is.null(startAnchor),
  start_anchor = paste0("'",startAnchor,"'", collapse = ","),
  use_end_anchor = !is.null(endAnchor),
  end_anchor = paste0("'",endAnchor,"'", collapse = ",")
)

 return(result)
}


#' Extract the binary age groups for the cases and targets
#' @description
#' This function extracts the age group feature extraction results for cases and targets corresponding to specified target and outcome cohorts.
#'
#' @details
#' Specify the connectionHandler, the schema and the target/outcome cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetId
#' @template outcomeId
#' @param type A character of 'age' or 'sex'
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{databaseId the unique identifier of the database}
#'  \item{targetName the target cohort name}
#'  \item{targetId the target cohort unique identifier}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome unique identifier}
#'  \item{minPriorObservation the minimum required observation days prior to index for an entry}
#'  \item{outcomeWashoutDays patients with the outcome occurring within this number of days prior to index are excluded (NA means no exclusion)}
#' \item{riskWindowStart the number of days ofset the start anchor that is the start of the time-at-risk}
#' \item{startAnchor the start anchor is either the target cohort start or cohort end date}
#' \item{riskWindowEnd the number of days ofset the end anchor that is the end of the time-at-risk}
#' \item{endAnchor the end anchor is either the target cohort start or cohort end date}
#' \item{covariateName the name of the feature}
#' \item{sumValue the number of cases who have the feature value of 1}
#' \item{averageValue the mean feature value}
#' } 
#' 
#' @export
#' @examples
#' # example code
#' 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' ageData <- getCharacterizationDemographics(
#' connectionHandler = connectionHandler, 
#' schema = 'main'
#' )
#' 
getCharacterizationDemographics <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetId = NULL,
    outcomeId = NULL,
    type = 'age'
){
  
  if(type == 'age'){
    analysisIds <- 3
  } else if(type == 'sex'){
    analysisIds <- 1
  } else{
    stop('Invalid type - must be age or sex')
  }
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  if(cVersion == 0){
    
  ageData <- getCaseBinaryFeatures(
    connectionHandler = connectionHandler, 
    schema = schema, 
    cTablePrefix = cTablePrefix,
    cgTablePrefix = cgTablePrefix,
    targetIds = targetId, 
    outcomeIds = outcomeId, 
    analysisIds = analysisIds
  )
  ageDataT <- getCaseTargetBinaryFeatures(
    connectionHandler = connectionHandler, 
    schema = schema, 
    cTablePrefix = cTablePrefix,
    cgTablePrefix = cgTablePrefix,
    targetIds = targetId, 
    outcomeIds = outcomeId, 
    analysisIds = analysisIds
  )
  
  countT <- getCaseTargetCounts(
    connectionHandler = connectionHandler, 
    schema = schema, 
    cTablePrefix = cTablePrefix,
    cgTablePrefix = cgTablePrefix,
    targetIds = targetId, 
    outcomeIds = outcomeId
  )
  
  ageDataT <- ageDataT %>% 
    dplyr::inner_join(
      y = countT %>% dplyr::select(
        "databaseName",
        "databaseId",
        "minPriorObservation",
        "outcomeWashoutDays",
        "personCount"
      ), 
      by = c("databaseName","databaseId", 'minPriorObservation', 'outcomeWashoutDays'),
      relationship = "many-to-many" #fix warning
      )
  
  ageDataT <- merge(
    ageDataT,
    unique(ageData %>% dplyr::select(
    "riskWindowStart",
    "riskWindowEnd",
    "startAnchor",
    "endAnchor"
  ))
  ) %>% dplyr::mutate(
    nonCaseCount = .data$personCount,
    nonCaseAverage = .data$sumValue/.data$personCount
  )
  
  ageData <- ageData %>%
    dplyr::rename(
      caseCount = "sumValue",
      caseAverage = "averageValue"
    )
  
  
  allData <- merge(
    x = ageData, 
    y = ageDataT,
    by = c("databaseName", "databaseId", "targetName", "targetCohortId",   
           "outcomeName", "outcomeCohortId", "minPriorObservation" ,"outcomeWashoutDays",
           "riskWindowStart", "riskWindowEnd", "startAnchor", "endAnchor",          
           "covariateId", "covariateName")
    ) %>%
    dplyr::select(-dplyr::any_of(c("sumValue", "rawSum", "rawAverage", "personCount")))
  
  # adding new column to old results
  allData <- allData %>% 
    dplyr::mutate(
      limitToFirstInNDays = 99999,
      smd = NA,
      absSmd = NA
    ) 

  } else{
    
    allData <- getBinaryRiskFactors(
      connectionHandler = connectionHandler, 
      schema = schema, 
      cTablePrefix = cTablePrefix, 
      cgTablePrefix = cgTablePrefix, 
      databaseTable = databaseTable, 
      targetId = targetId, 
      outcomeId = outcomeId,  
      analysisIds = analysisIds
      )
    
  }
  
return(allData)
}


getCaseTargetBinaryFeatures <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    outcomeIds = NULL,
    databaseIds = NULL,
    analysisIds = c(3) # c(8507, 8532)
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getCaseTargetBinaryFeaturesV", cVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  

result <- connectionHandler$queryDb(
  sql = sql,
  schema = schema,
  target_id = paste0(targetIds, collapse = ','),
  use_target = !is.null(targetIds),
  outcome_id = paste0(outcomeIds, collapse = ','),
  use_outcome = !is.null(outcomeIds),
  c_table_prefix = cTablePrefix,
  cg_table_prefix = cgTablePrefix,
  database_table = databaseTable,
  use_analysis = !is.null(analysisIds),
  analysis_ids = paste0(analysisIds, collapse = ','),
  database_id = paste0("'", databaseIds, "'", collapse = ","),
  use_database = !is.null(databaseIds)
)

return(result)
}


#' Extract aggregate statistics of binary feature analysis IDs of interest for targets (ignoring excluding people with prior outcome)
#' @description
#' This function extracts the feature extraction results for targets corresponding to specified target
#'  but does not exclude any patients with the outcome during the outcome washout (so it agnostic to the outcome of interest).
#'
#' @details
#' Specify the connectionHandler, the schema and the target cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetId
#' @param databaseIds (optional) A vector of database ids to restrict to
#' @param analysisIds (optional) The feature extraction analysis ID of interest (e.g., 201 is condition)
#' @param conceptIds (optional) The feature extraction concept ID of interest to restrict to
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{databaseId the unique identifier of the database}
#'  \item{targetName the target cohort name}
#'  \item{targetId the target cohort unique identifier}
#'  \item{minPriorObservation the minimum required observation days prior to index for an entry}
#'  \item{covariateId the id of the feature}
#'  \item{covariateName the name of the feature}
#'  \item{sumValue the number of target patients who have the feature value of 1 (target patients are restricted to first occurrence and require min prior obervation days)}
#'  \item{averageAvalue the fraction of target patients who have the feature value of 1 (target patients are restricted to first occurrence and require min prior obervation days)}
#' } 
#' 
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' tbf <- getTargetBinaryFeatures (
#' connectionHandler = connectionHandler, 
#' schema = 'main',
#' targetId = 1
#' )
#' 
getTargetBinaryFeatures <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetId = NULL,
    databaseIds = NULL,
    analysisIds = NULL,
    conceptIds = NULL
){
  
  if(length(targetId) != 1){
    stop('targetId must be a single value')
  }
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getTargetBinaryFeaturesV", cVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))

result <- connectionHandler$queryDb(
  sql = sql,
  schema = schema,
  target_id = targetId,
  c_table_prefix = cTablePrefix,
  cg_table_prefix = cgTablePrefix,
  database_table = databaseTable,
  use_analysis = !is.null(analysisIds),
  analysis_ids = paste0(analysisIds, collapse = ','),
  database_id = paste0("'", databaseIds, "'", collapse = ","),
  use_database = !is.null(databaseIds),
  use_concepts = !is.null(conceptIds),
  concept_ids = paste0(conceptIds, collapse = ',')
)

return(result)
}

#' A function to extract non-case and case binary characterization results
#'
#' @details
#' Specify the connectionHandler, the schema and the target/outcome cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetId
#' @template outcomeId
#' @param databaseId The database ID to restrict results to
#' @param analysisIds The feature extraction analysis ID of interest (e.g., 201 is condition)
#' @param riskWindowStart (optional) A vector of time-at-risk risk window starts to restrict to
#' @param riskWindowEnd (optional) A vector of time-at-risk risk window ends to restrict to
#' @param startAnchor (optional) A vector of time-at-risk start anchors to restrict to
#' @param endAnchor (optional) A vector of time-at-risk end anchors to restrict to

#' @family Characterization
#' 
#' @return
#' A data.frame with the characterization results for the cases and non-cases
#'
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' rf <- getBinaryRiskFactors(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   targetId = 1, 
#'   outcomeId = 3
#' )
#' 
getBinaryRiskFactors <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetId = NULL,
    outcomeId = NULL,
    databaseId = NULL,
    analysisIds = c(3), # TODO enable this to be NULL?
    riskWindowStart = NULL,
    riskWindowEnd = NULL,
    startAnchor = NULL,
    endAnchor = NULL
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )

  
  if(cVersion == 0){
    if(is.null(targetId)){
      stop('targetId must be entered')
    }
    if(length(targetId) > 1){
      stop('Must be single targetId')
    }
    if(is.null(outcomeId)){
      stop('outcomeId must be entered')
    }
    if(length(outcomeId) > 1){
      stop('Must be single outcomeId')
    }
  # this is the case counts per target, min prior obs,outcome,TAR, and outcome washout
  caseCounts <- getCaseCounts(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix,
    cgTablePrefix = cgTablePrefix,
    databaseTable = databaseTable,
    targetIds = targetId,
    outcomeIds = outcomeId,
    databaseIds = databaseId,
    riskWindowStart = riskWindowStart,
    riskWindowEnd = riskWindowEnd,
    startAnchor = startAnchor,
    endAnchor = endAnchor
  )
  
  # target counts are agnostic to TAR
  # this gets the target and subtracts the excluded per min prior obs and outcome washout
  targetCounts <- getCaseTargetCounts(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix,
    cgTablePrefix = cgTablePrefix,
    databaseTable = databaseTable,
    targetIds = targetId,
    outcomeIds = outcomeId,
    databaseIds = databaseId
  )
    
  # gets the case features per target, min prior obs,outcome,TAR, and outcome washout
  caseFeatures <- getCaseBinaryFeatures(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix,
    cgTablePrefix = cgTablePrefix,
    databaseTable = databaseTable,
    targetIds = targetId,
    outcomeIds = outcomeId,
    databaseIds = databaseId,
    analysisIds = analysisIds,
    riskWindowStart = riskWindowStart,
    riskWindowEnd = riskWindowEnd,
    startAnchor = startAnchor,
    endAnchor = endAnchor
  )
  
  targetFeatures <- getCaseTargetBinaryFeatures(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix,
    cgTablePrefix = cgTablePrefix,
    databaseTable = databaseTable,
    targetIds = targetId,
    outcomeIds = outcomeId,
    databaseIds = databaseId,
    analysisIds = analysisIds
  )
  
  result <- processBinaryRiskFactorFeatures(
    caseCounts = caseCounts,
    targetCounts = targetCounts,
    caseFeatures = caseFeatures,
    targetFeatures = targetFeatures
  )
  } else{
    
    sql <- SqlRender::readSql(system.file(
      paste0("sql/sql_server/characterization/getBinaryRiskFactorsV", cVersion, ".sql"),
      package = "OhdsiReportGenerator",
      mustWork = TRUE
    ))
    
    # restrict by restrictToFirstInNDays, minPriorObseration, outcomeWashoutDays and TAR?
    result <- connectionHandler$queryDb(
      sql = sql,
      schema = schema,
      target_id = paste0(targetId, collapse = ','),
      use_target = !is.null(targetId),
      outcome_id = paste0(outcomeId, collapse = ','),
      use_outcome = !is.null(outcomeId),
      c_table_prefix = cTablePrefix,
      cg_table_prefix = cgTablePrefix,
      database_table = databaseTable,
      use_analysis = !is.null(analysisIds),
      analysis_ids = paste0(analysisIds, collapse = ','),
      use_database = !is.null(databaseId),
      database_id = paste0("'",databaseId,"'", collapse = ",")
    )
    
    
  }

return(result)
}


# function that takes the counts and features and calculates the smd
processBinaryRiskFactorFeatures <- function(
    caseCounts = caseCounts,
    targetCounts = targetCounts,
    caseFeatures = caseFeatures,
    targetFeatures = targetFeatures
){
  
  if(nrow(targetCounts) == 0 | nrow(caseCounts) == 0){
    warning('No targets or outcomes')
    return(NULL)
  }
  
  allData <- c()
  
  # TODO:what if no cases?
  params <- unique(
    caseCounts %>% dplyr::select(
      "databaseName",
      "databaseId",
      "minPriorObservation",
      "outcomeWashoutDays",
      "riskWindowStart",
      "riskWindowEnd",
      "startAnchor",
      "endAnchor"
    )
  )
  
  # for each database/TAR/minPriorObservation/outcomeWashoutDays
  for(i in 1:nrow(params)){
    databaseName <- params$databaseName[i]
    databaseId <- params$databaseId[i]
    minPriorObservation <- params$minPriorObservation[i]
    outcomeWashoutDays <- params$outcomeWashoutDays[i]
    riskWindowStart <- params$riskWindowStart[i]
    riskWindowEnd <- params$riskWindowEnd[i]
    startAnchor <- params$startAnchor[i]
    endAnchor <- params$endAnchor[i]
  ## extract the case count and target count to get non-case count
  caseCount <- caseCounts %>% 
    dplyr::filter(
      .data$databaseName == !!databaseName &
      .data$databaseId == !!databaseId &
      .data$minPriorObservation == !!minPriorObservation &
        .data$outcomeWashoutDays == !!outcomeWashoutDays &
        .data$riskWindowStart == !!riskWindowStart &
        .data$riskWindowEnd == !!riskWindowEnd &
        .data$startAnchor == !!startAnchor &
        .data$endAnchor == !!endAnchor
    )
  
  targetCount <- targetCounts %>% 
    dplyr::filter(
      .data$databaseName == !!databaseName &
      .data$databaseId == !!databaseId &
      .data$minPriorObservation == !!minPriorObservation &
        .data$outcomeWashoutDays == !!outcomeWashoutDays
    )
  
  if(nrow(targetCount) > 0 & nrow(caseCount) > 0){
  
  if(caseCount$personCount > 0 & targetCount$personCount > 0){
    # only run this if the cases is >= min cell count
    nonCaseCount <- targetCount$personCount - caseCount$personCount

  ## now extract the features
  tempCases <- caseFeatures %>% 
    dplyr::filter(.data$databaseName == !!databaseName &
                    .data$databaseId == !!databaseId &
                    .data$minPriorObservation == !!minPriorObservation &
                    .data$outcomeWashoutDays == !!outcomeWashoutDays &
                    .data$riskWindowStart == !!riskWindowStart &
                    .data$riskWindowEnd == !!riskWindowEnd &
                    .data$startAnchor == !!startAnchor &
                    .data$endAnchor == !!endAnchor
                    ) %>%
    dplyr::rename(
      caseCount = "sumValue", 
      caseAverage = "averageValue"
      ) %>%
    dplyr::filter( # remove the censored counts
      .data$caseCount >= 0
    )
  
  
  tempTarget <- targetFeatures %>% 
    dplyr::filter(.data$databaseName == !!databaseName &
                    .data$databaseId == !!databaseId &
                    .data$minPriorObservation == !!minPriorObservation &
                    .data$outcomeWashoutDays == !!outcomeWashoutDays 
    ) %>%
    dplyr::filter( # remove the censored counts
      .data$sumValue >= 0
    )
  
  tempData <- tempTarget %>% 
    dplyr::left_join(
      y = tempCases, 
      by = c(
        "databaseName",
        "databaseId",
        "targetName",
        "targetCohortId",
        "outcomeName",
        "outcomeCohortId",
        "minPriorObservation",
        "outcomeWashoutDays",
        "covariateName",
        "covariateId")
      ) %>%
    tidyr::replace_na(list(
      riskWindowStart = riskWindowStart, 
      riskWindowEnd = riskWindowEnd,
      startAnchor = startAnchor,
      endAnchor = endAnchor,
      caseCount = 0,
      caseAverage = 0
      )) %>%
    dplyr::mutate(
      nonCaseCount = .data$sumValue - .data$caseCount,
      nonCaseAverage = (.data$sumValue - .data$caseCount)/!!nonCaseCount
    ) %>%
    dplyr::mutate(
      meanDiff = .data$caseAverage - .data$nonCaseAverage,
      std1 =  ifelse(!!caseCount$personCount == 0, 0 ,sqrt(((1-.data$caseAverage)^2*.data$caseCount + (-.data$caseAverage)^2*(!!caseCount$personCount - .data$caseCount))/!!caseCount$personCount)),
      std2 =  ifelse(!!nonCaseCount == 0, 0, sqrt(((1-.data$nonCaseAverage)^2*.data$nonCaseCount + (-.data$nonCaseAverage)^2*(!!nonCaseCount - .data$nonCaseCount))/!!nonCaseCount))
    ) %>% 
    dplyr::mutate(
      smd = .data$meanDiff/sqrt((.data$std1^2 + .data$std2^2)/2),
      absSmd = abs(.data$meanDiff/sqrt((.data$std1^2 + .data$std2^2)/2))
    ) 
  
  tempData <- tempData %>% 
    dplyr::mutate(
      limitToFirstInNdays = 99999
    ) %>%
    dplyr::select(
    "databaseName",
    "databaseId",
    "targetName",
    "targetCohortId",
    "outcomeName",
    "outcomeCohortId",
    "minPriorObservation",
    "limitToFirstInNdays", # added for v3 compat
    "outcomeWashoutDays",
    "riskWindowStart",
    "riskWindowEnd",
    "startAnchor",
    "endAnchor",
    "covariateName",
    "covariateId",
    "caseCount",
    "caseAverage",
    "nonCaseCount",
    "nonCaseAverage",
    "smd",
    "absSmd"
  )
  
  allData <- rbind(allData, tempData)
  }} # check for cases >= minCellCount
}
  
return(allData) 
}




#' Extract aggregate statistics of continuous feature analysis IDs of interest for targets
#' @description
#' This function extracts the continuous feature extraction results for targets corresponding to specified target cohorts.
#'
#' @details
#' Specify the connectionHandler, the schema and the target/outcome cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetIds
#' @param analysisIds The feature extraction analysis ID of interest (e.g., 201 is condition)
#' @param databaseIds (Optional) A vector of database IDs to restrict to
#'
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{databaseId the unique identifier of the database}
#'  \item{targetName the target cohort name}
#'  \item{targetId the target cohort unique identifier}
#'  \item{minPriorObservation the minimum required observation days prior to index for an entry}
#'  \item{covariateName the name of the feature}
#'  \item{covariateId the id of the feature}
#'  \item{countValue the number of cases who have the feature}
#'  \item{minValue the minimum value observed for the feature}
#'  \item{maxValue the maximum value observed for the feature}
#'  \item{averageValue the mean value observed for the feature}
#'  \item{standardDeviation the standard deviation of the value observed for the feature}
#'  \item{medianValue the median value observed for the feature}
#'  \item{p10Value the 10th percentile of the value observed for the feature}
#'  \item{p25Value the 25th percentile of the value observed for the feature}
#'  \item{p75Value the 75th percentile of the value observed for the feature}
#'  \item{p90Value the 90th percentile of the value observed for the feature}
#'  
#' } 
#' 
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' tcf <- getTargetContinuousFeatures(
#' connectionHandler = connectionHandler, 
#' schema = 'main'
#' )
#' 
getTargetContinuousFeatures <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    analysisIds = NULL,
    databaseIds = NULL
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getTargetContinuousFeaturesV", cVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
result <- connectionHandler$queryDb(
  sql = sql,
  schema = schema,
  target_id = paste0(targetIds, collapse = ','),
  use_target = !is.null(targetIds),
  c_table_prefix = cTablePrefix,
  cg_table_prefix = cgTablePrefix,
  database_table = databaseTable,
  use_analysis = !is.null(analysisIds),
  analysis_ids = paste0(analysisIds, collapse = ','),
  use_database = !is.null(databaseIds),
  database_id = paste0("'",databaseIds,"'", collapse = ",")
)

return(result)
}


getCaseContinuousFeatures <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    outcomeIds = NULL,
    analysisIds = NULL,
    databaseIds = NULL,
    riskWindowStart = NULL,
    riskWindowEnd = NULL,
    startAnchor = NULL,
    endAnchor = NULL
){
  
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getCaseContinuousFeaturesV", cVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
result <- connectionHandler$queryDb(
  sql = sql,
  schema = schema,
  target_id = paste0(targetIds, collapse = ','),
  use_target = !is.null(targetIds),
  outcome_id = paste0(outcomeIds, collapse = ','),
  use_outcome = !is.null(outcomeIds),
  c_table_prefix = cTablePrefix,
  cg_table_prefix = cgTablePrefix,
  database_table = databaseTable,
  use_analysis = !is.null(analysisIds),
  analysis_ids = paste0(analysisIds, collapse = ','),
  use_database = !is.null(databaseIds),
  database_id = paste0("'",databaseIds,"'", collapse = ","),
  
  use_risk_window_start = !is.null(riskWindowStart),
  risk_window_start = paste0(riskWindowStart, collapse = ','),
  use_risk_window_end = !is.null(riskWindowEnd),
  risk_window_end = paste0(riskWindowEnd, collapse = ','),
  use_start_anchor = !is.null(startAnchor),
  start_anchor = paste0("'",startAnchor,"'", collapse = ","),
  use_end_anchor = !is.null(endAnchor),
  end_anchor = paste0("'",endAnchor,"'", collapse = ",")
)

return(result)
}




#' A function to extract non-case and case continuous characterization results
#'
#' @details
#' Specify the connectionHandler, the schema and the target/outcome cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetId
#' @template outcomeId
#' @param analysisIds The feature extraction analysis ID of interest (e.g., 201 is condition)
#' @param databaseIds (optional) A vector of database IDs to restrict to
#' @param riskWindowStart (optional) A vector of time-at-risk risk window starts to restrict to
#' @param riskWindowEnd (optional) A vector of time-at-risk risk window ends to restrict to
#' @param startAnchor (optional) A vector of time-at-risk start anchors to restrict to
#' @param endAnchor (optional) A vector of time-at-risk end anchors to restrict to
#'
#' @family Characterization
#' 
#' @return
#' A data.frame with the characterization results for the cases and non-cases
#'
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' rf <- getContinuousRiskFactors(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   targetId = 1, 
#'   outcomeId = 3
#' )
#' 
getContinuousRiskFactors <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetId = NULL,
    outcomeId = NULL,
    analysisIds = NULL,
    databaseIds = NULL,
    riskWindowStart = NULL,
    riskWindowEnd = NULL,
    startAnchor = NULL,
    endAnchor = NULL
){
  if(is.null(targetId)){
    stop('targetId must be entered')
  }
  if(is.null(outcomeId)){
    stop('targetId must be entered')
  }
  if(length(targetId) > 1){
    stop('Must be single targetId')
  }
  if(length(outcomeId) > 1){
    stop('Must be single outcomeId')
  }
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  if(cVersion == 0){
    caseFeatures <- getCaseContinuousFeatures(
      connectionHandler = connectionHandler,
      schema = schema,
      cTablePrefix = cTablePrefix,
      cgTablePrefix = cgTablePrefix,
      databaseTable = databaseTable,
      targetIds = targetId,
      outcomeIds = outcomeId,
      analysisIds = analysisIds,
      databaseIds = databaseIds,
      riskWindowStart = riskWindowStart,
      riskWindowEnd = riskWindowEnd,
      startAnchor = startAnchor,
      endAnchor = endAnchor
    )
    
    targetFeatures <- getTargetContinuousFeatures(
      connectionHandler = connectionHandler,
      schema = schema,
      cTablePrefix = cTablePrefix,
      cgTablePrefix = cgTablePrefix,
      databaseTable = databaseTable,
      targetIds = targetId,
      analysisIds = analysisIds,
      databaseIds = databaseIds
    )
    
    result <- processContinuousRiskFactorFeatures(
      caseFeatures = caseFeatures,
      targetFeatures = targetFeatures
    )
  } else{
    
    sql <- SqlRender::readSql(system.file(
      paste0("sql/sql_server/characterization/getContinuousRiskFactorsV", cVersion, ".sql"),
      package = "OhdsiReportGenerator",
      mustWork = TRUE
    ))
    
    result <- connectionHandler$queryDb(
      sql = sql,
      schema = schema,
      target_id = paste0(targetId, collapse = ','),
      use_target = !is.null(targetId),
      outcome_id = paste0(outcomeId, collapse = ','),
      use_outcome = !is.null(outcomeId),
      c_table_prefix = cTablePrefix,
      cg_table_prefix = cgTablePrefix,
      database_table = databaseTable,
      use_analysis = !is.null(analysisIds),
      analysis_ids = paste0(analysisIds, collapse = ','),
      use_database = !is.null(databaseIds),
      database_id = paste0("'",databaseIds,"'", collapse = ","),
      
      use_risk_window_start = !is.null(riskWindowStart),
      risk_window_start = paste0(riskWindowStart, collapse = ','),
      use_risk_window_end = !is.null(riskWindowEnd),
      risk_window_end = paste0(riskWindowEnd, collapse = ','),
      use_start_anchor = !is.null(startAnchor),
      start_anchor = paste0("'",startAnchor,"'", collapse = ","),
      use_end_anchor = !is.null(endAnchor),
      end_anchor = paste0("'",endAnchor,"'", collapse = ",")
    )
    
  }
  
  return(result)
}


# function that takes the counts and features and calculates the smd
processContinuousRiskFactorFeatures <- function(
    caseFeatures = caseFeatures,
    targetFeatures = targetFeatures
){
  
  # get outcomes and outcomewashout
  outcomes <- unique(caseFeatures[,c('outcomeName','outcomeCohortId','outcomeWashoutDays',
                                     'riskWindowStart', 'riskWindowEnd', 'startAnchor', 'endAnchor')])
  
  targetFeatures <- targetFeatures %>% dplyr::rename(
    "targetCountValue" = "countValue",
    "targetMinValue" = "minValue",
    "targetMaxValue" = "maxValue",
    "targetAverageValue" = "averageValue", 
    "targetStandardDeviation" = "standardDeviation",
    "targetMedianValue" = "medianValue",
    "targetP10Value" = "p10Value",
    "targetP25Value" = "p25Value",
    "targetP75Value" = "p75Value",
    "targetP90Value" = "p90Value"
  )
  
  caseFeatures <- caseFeatures %>% dplyr::rename(
    "caseCountValue" = "countValue",
    "caseMinValue" = "minValue",
    "caseMaxValue" = "maxValue",
    "caseAverageValue" = "averageValue", 
    "caseStandardDeviation" = "standardDeviation",
    "caseMedianValue" = "medianValue",
    "caseP10Value" = "p10Value",
    "caseP25Value" = "p25Value",
    "caseP75Value" = "p75Value",
    "caseP90Value" = "p90Value"
  )
  
  if(nrow(outcomes) > 0){
    allData <- c()
    for(i in 1:nrow(outcomes)){
      
      res <- merge(
        x = targetFeatures %>% 
          dplyr::filter(
            .data$targetCohortId != outcomes[i,]$outcomeCohortId 
          ), 
        y = caseFeatures %>% 
          dplyr::filter(
            .data$outcomeCohortId == outcomes[i,]$outcomeCohortId &
              .data$outcomeWashoutDays == outcomes[i,]$outcomeWashoutDays &
              .data$riskWindowStart == outcomes[i,]$riskWindowStart &
              .data$riskWindowEnd == outcomes[i,]$riskWindowEnd &
              .data$startAnchor == outcomes[i,]$startAnchor &
              .data$endAnchor == outcomes[i,]$endAnchor
          ),
        
        by = c('databaseName','databaseId','targetName','targetCohortId','minPriorObservation',
               'covariateName', 'covariateId'),
        all.x = TRUE
      ) %>%
        tidyr::replace_na(
          list(
            outcomeCohortId = outcomes[i,]$outcomeCohortId, 
            outcomeName = outcomes[i,]$outcomeName,
            outcomeWashoutDays = outcomes[i,]$outcomeWashoutDays,
            riskWindowStart = outcomes[i,]$riskWindowStart,
            riskWindowEnd = outcomes[i,]$riskWindowEnd,
            startAnchor = outcomes[i,]$startAnchor,
            endAnchor = outcomes[i,]$endAnchor
          )
        ) %>% 
        dplyr::mutate_all(~replace(., is.na(.), 0))
      
      allData <- rbind(allData, res)
    }
  
  allData <- allData %>% dplyr::mutate(
        limitToFirstInNDays = 99999,
        smd = (.data$caseAverageValue - .data$targetAverageValue)/sqrt((.data$caseStandardDeviation^2 + .data$targetStandardDeviation^2)/2),
        absSmd = abs((.data$caseAverageValue - .data$targetAverageValue)/sqrt((.data$caseStandardDeviation^2 + .data$targetStandardDeviation^2)/2))
      ) 
  
  return(allData) 
  
  } else{
    return(NULL)
  }

}


# case series data.frame
#' A function to extract case series characterization results
#'
#' @details
#' Specify the connectionHandler, the schema and the target/outcome cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetId
#' @template outcomeId
#' @param databaseIds (optional) One or more unique identifiers for the databases
#' @param riskWindowStart (optional) A riskWindowStart to restrict to
#' @param riskWindowEnd (optional) A riskWindowEnd to restrict to
#' @param startAnchor (optional) A startAnchor to restrict to
#' @param endAnchor (optional) An endAnchor to restrict to
#' @param conceptIds (optional) An conceptIds to restrict to
#' @param minVal (optional) the minimum averageVal to extract
#' @family Characterization
#' 
#' @return
#' A data.frame with the characterization case series results
#'
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cs <- getBinaryCaseSeries(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   targetId = 1, 
#'   outcomeId = 3
#' )
#' 
getBinaryCaseSeries <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetId = NULL,
    outcomeId = NULL,
    databaseIds = NULL,
    riskWindowStart = NULL,
    riskWindowEnd = NULL,
    startAnchor = NULL,
    endAnchor = NULL,
    conceptIds = NULL,
    minVal = NULL
){
  if(is.null(targetId)){
    stop('targetId must be entered')
  }
  if(is.null(outcomeId)){
    stop('outcomeId must be entered')
  }
  if(length(targetId) > 1){
    stop('Must be single targetId')
  }
  if(length(outcomeId) > 1){
    stop('Must be single outcomeId')
  }
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getBinaryCaseSeriesV", cVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))

result <- connectionHandler$queryDb(
  sql = sql,
  schema = schema,
  target_id = paste0(targetId, collapse = ','),
  outcome_id = paste0(outcomeId, collapse = ','),
  c_table_prefix = cTablePrefix,
  cg_table_prefix = cgTablePrefix,
  database_table = databaseTable,
  use_database = !is.null(databaseIds),
  database_ids = paste0("'",databaseIds,"'", collapse = ','),
  use_risk_window_start = !is.null(riskWindowStart),
  risk_window_start = riskWindowStart,
  use_risk_window_end = !is.null(riskWindowEnd),
  risk_window_end = riskWindowEnd,
  use_start_anchor = !is.null(startAnchor),
  start_anchor = startAnchor,
  use_end_anchor = !is.null(endAnchor),
  end_anchor = endAnchor,
  use_min_val = !is.null(minVal),
  min_val = minVal,
  use_concepts = !is.null(conceptIds),
  concept_ids = paste0(conceptIds, collapse = ',')
)
  
  return(result)
}


#' A function to extract case series continuous feature characterization results
#'
#' @details
#' Specify the connectionHandler, the schema and the target/outcome cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetId
#' @template outcomeId
#' @param databaseIds (optional) One or more unique identifiers for the databases
#' @param riskWindowStart (optional) A riskWindowStart to restrict to
#' @param riskWindowEnd (optional) A riskWindowEnd to restrict to
#' @param startAnchor (optional) A startAnchor to restrict to
#' @param endAnchor (optional) An endAnchor to restrict to
#' @family Characterization
#' 
#' @return
#' A data.frame with the characterization case series results
#'
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cs <- getContinuousCaseSeries(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   targetId = 1, 
#'   outcomeId = 3
#' )
#' 
getContinuousCaseSeries <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetId = NULL,
    outcomeId = NULL,
    databaseIds = NULL,
    riskWindowStart = NULL,
    riskWindowEnd = NULL,
    startAnchor = NULL,
    endAnchor = NULL
){
  if(is.null(targetId)){
    stop('targetId must be entered')
  }
  if(is.null(outcomeId)){
    stop('targetId must be entered')
  }
  if(length(targetId) > 1){
    stop('Must be single targetId')
  }
  if(length(outcomeId) > 1){
    stop('Must be single outcomeId')
  }
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getContinuousCaseSeriesV", cVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    target_id = paste0(targetId, collapse = ','),
    outcome_id = paste0(outcomeId, collapse = ','),
    c_table_prefix = cTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable,
    use_database = !is.null(databaseIds),
    database_ids = paste0("'",databaseIds,"'", collapse = ','),
    use_risk_window_start = !is.null(riskWindowStart),
    risk_window_start = riskWindowStart,
    use_risk_window_end = !is.null(riskWindowEnd),
    risk_window_end = riskWindowEnd,
    use_start_anchor = !is.null(startAnchor),
    start_anchor = startAnchor,
    use_end_anchor = !is.null(endAnchor),
    end_anchor = endAnchor
  )
  
  return(result)
}

#' A function to extract cohort aggregate binary feature characterization results
#'
#' @details
#' Specify the connectionHandler, the schema and the target cohort ID and database id
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetIds
#' @param databaseIds (optional) One or more unique identifiers for the databases
#' @param minThreshold The minimum fraction of the cohort that must have the feature for it to be reported
#' 
#' @family Characterization
#' 
#' @return
#' A data.frame with the characterization aggregate binary features for a specific cohort and database
#'
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' binCohort <- getCharacterizationCohortBinary(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   targetIds = 1, 
#'   databaseIds = 'eunomia'
#' )
#' 
getCharacterizationCohortBinary <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_', # not used 
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    databaseIds = NULL,
    minThreshold = 0
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  # first get counts
  counts <- getCharacterizationCohortCounts(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix,
    cgTablePrefix = cgTablePrefix,
    databaseTable = databaseTable,
    targetIds = targetIds,
    databaseIds = databaseIds
  )
  
  # add order for targets
  if(!is.null(targetIds)){
    counts <- counts %>%
      dplyr::inner_join(
        data.frame(
          cohortId = c(unique(targetIds)),
          order = 1:length(unique(targetIds))
        ), 
        by = 'cohortId') %>%
      dplyr::arrange(dplyr::desc(-1*.data$order)) %>%
      dplyr::select(-"order")
  }
  
  colRef <- counts %>%
    dplyr::mutate(id = dplyr::row_number())

  if(nrow(colRef) == 0){
    return(NULL)
  }
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getCharacterizationCohortBinaryV", cVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  start <- Sys.time()
  # settings.min_characterization_mean needed?
  res <- connectionHandler$queryDb(
    sql = sql,
    use_targets = !is.null(targetIds),
    target_ids = paste0(targetIds, collapse = ','),
    use_databases = !is.null(databaseIds),
    database_ids = paste0("'",databaseIds,"'", collapse = ','),
    schema = schema,
    c_table_prefix = cTablePrefix,
    min_threshold = minThreshold
  )
  end <- Sys.time() - start 
  
  message(paste0('Extracting ', nrow(res) ,' characterization cohort rows took: ', round(end, digits = 2), ' ', units(end)))
  
  # pivot 
  res <- merge(res, colRef, by = c('cohortId','databaseId', 'minPriorObservation', 'limitToFirstInNDays'))
  
  replaceVals <- rep(list(-1*minThreshold), nrow(colRef))
  names(replaceVals) <- paste0('averageValue_', 1:nrow(colRef))
  
  # figure out the min sumVal per target/database/minobs
  replaceSumVals <- c()
  for(i in 1:nrow(colRef)){
    replaceSumVals <- c(replaceSumVals, -1*floor(minThreshold*colRef$n[i]))
  }
  replaceSumVals <- as.list(replaceSumVals)
  names(replaceSumVals) <- paste0('sumValue_', 1:nrow(colRef))
  
  res <- tidyr::pivot_wider(
    data = res, 
    id_cols = c('covariateName', 'covariateId'), 
    names_from = 'id', 
    values_from = c('sumValue', 'averageValue', 'n'), 
    values_fn = mean, 
    values_fill = NA
  ) %>%
    tidyr::replace_na(replaceVals) %>%
    tidyr::replace_na(replaceSumVals)
  
  
  # add SMD if two unique types
  # adding below check in cases when there are patients in the cohort
  # but no covariates
  twoResultsWithValues <- length(grep('sumValue', colnames(res))) == 2
    
  if(nrow(colRef) == 2 & twoResultsWithValues){
    res <- res %>% 
      dplyr::mutate(
        standardDeviation_1 = ((abs(.data$averageValue_1)-1)^2*abs(.data$sumValue_1) + (abs(.data$averageValue_1)-0)^2*(.data$n_1-abs(.data$sumValue_1)))/.data$n_1,
        standardDeviation_2 = ((abs(.data$averageValue_2)-1)^2*abs(.data$sumValue_2) + (abs(.data$averageValue_2)-0)^2*(.data$n_2-abs(.data$sumValue_2)))/.data$n_2
      ) %>%
      dplyr::mutate(
        smd = (.data$averageValue_1-.data$averageValue_2)/(sqrt((.data$standardDeviation_1^2 + .data$standardDeviation_2^2)/2))
    ) %>%
      dplyr::mutate(
        absSmd = abs(.data$smd)
      ) %>%
      dplyr::select(-"standardDeviation_1", -"standardDeviation_2")
  }
  
  # remove the ns
  res <- res %>% 
    dplyr::select(
      - colnames(res)[grep('n_', colnames(res))]
    )
  
  return(list(
    covariates = res,
    covRef = colRef
    ))
}

# function to extract continuous cohort aggregate FE
#' A function to extract cohort aggregate continuous feature characterization results
#'
#' @details
#' Specify the connectionHandler, the schema and the target cohort ID and database id
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetIds
#' @param databaseIds (optional) One or more unique identifiers for the databases
#' @param minThreshold The minimum fraction of the cohort that must have the feature for it to be reported
#' 
#' @family Characterization
#' 
#' @return
#' A data.frame with the characterization aggregate continuous features for a specific cohort and database
#'
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' conCohort <- getCharacterizationCohortContinuous(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   targetIds = 1, 
#'   databaseIds = 'eunomia'
#' )
#' 
getCharacterizationCohortContinuous <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    databaseIds = NULL,
    minThreshold = 0
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  # first get counts
  counts <- getCharacterizationCohortCounts(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix,
    cgTablePrefix = cgTablePrefix,
    databaseTable = databaseTable,
    targetIds = targetIds,
    databaseIds = databaseIds
  )
  
  # add order for targets
  if(!is.null(targetIds)){
    counts <- counts %>%
      dplyr::inner_join(
        data.frame(
          cohortId = c(unique(targetIds)),
          order = 1:length(unique(targetIds))
        ), 
        by = 'cohortId') %>%
      dplyr::arrange(dplyr::desc(-1*.data$order)) %>%
      dplyr::select(-"order")
  }
  
  colRef <- counts %>%
    dplyr::mutate(id = dplyr::row_number())
  
  if(nrow(colRef) == 0){
    return(NULL)
  }
  
  # calculate minCounts from minThreshold and N
  colRef$minCount <- colRef$n*minThreshold
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getCharCohortContinuousV", cVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  # now fetch data
start <- Sys.time()

res <- connectionHandler$queryDb(
  sql = sql,
  use_targets = !is.null(targetIds),
  target_ids = paste0(targetIds, collapse = ','),
  use_databases = !is.null(databaseIds),
  database_ids = paste0("'",databaseIds,"'", collapse = ','),
  schema = schema,
  c_table_prefix = cTablePrefix,
  database_meta_table = databaseTable
)
end <- Sys.time() - start 
message(paste0('Extracting ', nrow(res) ,' continuous characterization cohort rows took: ', round(end, digits = 2), ' ', units(end)))


# pivot 
res <- res %>%
  dplyr::inner_join(
    y = colRef,
    by = c('cohortId','databaseId', 'minPriorObservation', 'limitToFirstInNDays')
      )

# remove rows where countVal < minCount
 res <- res %>%
   dplyr::filter(
     .data$countValue >= .data$minCount
   ) %>%
   dplyr::select(
     -"minCount"
   )


  res <- tidyr::pivot_wider(
    data = res, 
    id_cols = c('covariateName', 'covariateId','minPriorObservation', 'limitToFirstInNDays'), 
    names_from = 'id', 
    values_from = c('countValue', 'averageValue', 'standardDeviation', 'medianValue','minValue', 'maxValue', 'p10Value','p25Value','p75Value','p90Value'), 
    values_fn = mean, 
    values_fill = 0
  ) 

  

# add SMD if two unique types
  # adding below to fix bug where there are a small number of people in the cohort but no covs
  twoResultsWithValues <- length(grep('countValue', colnames(res))) == 2
  
if(nrow(colRef) == 2 & twoResultsWithValues){
  res <- res %>% dplyr::mutate(
    smd = (abs(.data$averageValue_1)-abs(.data$averageValue_2))/(sqrt((abs(.data$standardDeviation_1)^2 + abs(.data$standardDeviation_2)^2)/2))
  ) %>%
    dplyr::mutate(
      absSmd = abs(.data$smd)
    )
}
  

  return(list(
    covariates = res,
    covRef = colRef
  ))
}



getCharacterizationCohortCounts <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    databaseIds = NULL
    ){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  # getting counts
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getCharacterizationCohortCountsV", cVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  counts <- connectionHandler$queryDb(
    sql = sql,
    use_targets = !is.null(targetIds),
    target_ids = paste0(targetIds, collapse = ','),
    use_databases = !is.null(databaseIds),
    database_ids = paste0("'",databaseIds,"'", collapse = ','),
    schema = schema,
    c_table_prefix = cTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_meta_table = databaseTable
  )
  
  return(counts)
  
}


#' A function to extract the failed dechallenge-rechallenge cases
#'
#' @details
#' Specify the connectionHandler, the schema and the target/outcome cohort IDs and database id
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template targetId
#' @template outcomeId
#' @param databaseId The unique identifier for the database of interest
#' @param dechallengeStopInterval (optional) The maximum number of days between the outcome start and target end for an outcome to be flagged 
#' @param dechallengeEvaluationWindow (optional) The maximum number of days after the target restarts to see whether the outcome restarts
#' 
#' @family Characterization
#' 
#' @return
#' A data.frame each failed dechallenge rechallenge exposures and outcomes
#'
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' conCohort <- getDechallengeRechallengeFails(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   targetId = 1, 
#'   outcomeId = 3,
#'   databaseId = 'eunomia'
#' )
#' 
getDechallengeRechallengeFails <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    targetId = NULL,
    outcomeId = NULL,
    databaseId = NULL,
    dechallengeStopInterval = NULL,
    dechallengeEvaluationWindow = NULL
  ){
  
  if(length(targetId) != 1){
    stop('Must specify exactly one targetId')
  }
  if(length(outcomeId) != 1){
    stop('Must specify exactly one outcomeId')
  }
  if(length(databaseId) != 1){
    stop('Must specify exactly one databaseId')
  }
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getDechallengeRechallengeFails.sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  result <- connectionHandler$queryDb(
    sql = sql, 
    schema = schema,
    c_table_prefix = cTablePrefix,
    target_id = targetId,
    outcome_id = outcomeId,
    database_id = databaseId,
    use_dechallenge_stop_interval = !is.null(dechallengeStopInterval),
    dechallenge_stop_interval = dechallengeStopInterval,
    use_dechallenge_evaluation_window = !is.null(dechallengeEvaluationWindow),
    dechallenge_evaluation_window = dechallengeEvaluationWindow
  )
  
  return(result)
}
