#===========================================
# VERSION FUNCTIONS
#===========================================


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
  
  if(majorVersion >= 4){
    version <- '4_0_0'
  } else if(majorVersion >= 3){
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
      sql <- "SELECT version_number from @schema.@ci_table_prefixpackage_version;"
      
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
      sql <- "SELECT version_number from @schema.@c_table_prefixpackage_version;"
      
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


#===========================================
# LOOKUP FUNCTIONS
#===========================================


#' A function to extarct the targets settings found in characterization
#'
#' @details
#' Specify the connectionHandler, the schema and the prefixes
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @param characterizationTargetIds optional vector of characterizationTargetIds to restrict to
#' @param targetIds optional vector of targetIds to restrict to
#' @param addDatabaseDetails whether to add a databaseName and databaseId string
#' @template databaseTable
#' 
#' @family Characterization
#' 
#' @return
#' A data.frame with the characterization target cohort ids, names and inclusion criteria.
#'
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' targetCohorts <- getCharacterizationTargetSettings(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getCharacterizationTargetSettings <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    characterizationTargetIds = NULL,
    targetIds = NULL,
    addDatabaseDetails = FALSE,
    databaseTable = 'database_meta_data'
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  if(!cVersion %in% c('3_0_0', '4_0_0')){
    stop('Function not available in older characterization results tables')
  }
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getTargetSettingsV",cVersion,".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  data <- tryCatch({connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cg_table_prefix = cgTablePrefix,
    c_table_prefix = cTablePrefix,
    use_target = !is.null(targetIds),
    target_id = paste0(targetIds, collapse = ','),
    use_characterization_target = !is.null(characterizationTargetIds),
    characterization_target_id = paste0(characterizationTargetIds, collapse = ','),
    database_table = databaseTable,
    add_database_details = addDatabaseDetails
  )}, error = function(e){warning(e); return(NULL)})
  
  if(addDatabaseDetails){
    
    data <- data %>%
      dplyr::group_by(dplyr::across(-c("databaseId", "databaseName"))) %>%
      dplyr::summarise(
        databaseString = paste0(.data$databaseName, collapse = ', '),
        databaseIdString = paste0(.data$databaseId, collapse = ', ')
      )
    
  }
  
  return(data)

}


#' A function to extarct the cohort incidence targets
#'
#' @details
#' Specify the connectionHandler, the schema and the prefixes
#'
#' @template connectionHandler
#' @template schema
#' @template ciTablePrefix
#' @template cgTablePrefix
#' @param targetIds optional vector of targetIds to restrict to
#'
#' @family Characterization
#' 
#' @return
#' A data.frame with the characterization target cohort ids, names and inclusion criteria.
#'
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' targetCohorts <- getIncidenceTargetSettings(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getIncidenceTargetSettings <- function(
    connectionHandler,
    schema,
    ciTablePrefix = 'ci_',
    cgTablePrefix = 'cg_',
    targetIds = NULL
){
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getIncidenceTargetSettings.sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  data <- tryCatch({connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cg_table_prefix = cgTablePrefix,
    ci_table_prefix = ciTablePrefix,
    use_target = !is.null(targetIds),
    target_id = paste0(targetIds, collapse = ',')
  )}, error = function(e){warning(e); return(NULL)})
  
  return(data)
  
}


#' A function to extract the case settings found in characterization
#'
#' @details
#' Specify the connectionHandler, the schema and the prefixes
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @param characterizationTargetIds optional vector of characterizationTargetIds to restrict to
#' @param targetIds optional vector of targetIds to restrict to
#' @param outcomeIds optional vector of outcomeIds to restrict to
#'
#' @family Characterization
#' 
#' @return
#' A data.frame with the characterization target cohort ids, names and inclusion criteria.
#'
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' caseCohorts <- getCharacterizationCaseSettings(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getCharacterizationCaseSettings <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    characterizationTargetIds = NULL,
    targetIds = NULL,
    outcomeIds = NULL
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  if(!cVersion %in% c('3_0_0','4_0_0')){
    stop('Function not available in older characterization results tables')
  }
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getCaseSettingsV",cVersion,".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  data <- tryCatch({connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cg_table_prefix = cgTablePrefix,
    c_table_prefix = cTablePrefix,
    use_target = !is.null(targetIds),
    target_id = paste0(targetIds, collapse = ','),
    use_outcome = !is.null(outcomeIds),
    outcome_id = paste0(outcomeIds, collapse = ','),
    use_characterization_target = !is.null(characterizationTargetIds),
    characterization_target_id = paste0(characterizationTargetIds, collapse = ',')
  )}, error = function(e){warning(e); return(NULL)})
  
  return(data)
  
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
#' cohorts <- getTargetsUsedInCharacterization(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getTargetsUsedInCharacterization <- function(
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
  
  
  # keep old code for version 3_0_0 and add simple new code for v 4_0_0
  
  if(cVersion == '4_0_0'){
    
    start <- Sys.time()
    
    targets <- getTargetIdsUsedInCharacterization(
      connectionHandler = connectionHandler,
      schema = schema,
      cTablePrefix = cTablePrefix,
      cgTablePrefix = cgTablePrefix
    )
 
  } else{
    
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
      if(printTimes){
        print(paste0('-- all extracting characterization targets took: ',  (end-first), ' ', units((end-first))))
      }
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
    
  }
  
  last <- Sys.time()
  if(printTimes){
    print(paste0('-- all extracting characterization targets took: ',  (last-first), ' ', units((last-first))))
  }
  return(targets)
}

# used by getTargetsUsedInCharacterization
getTargetIdsUsedInCharacterization <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_'
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  if(cVersion != '4_0_0'){
    stop('Function not available in older characterization results tables')
  }
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getTargetIds.sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  data <- tryCatch({connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cg_table_prefix = cgTablePrefix,
    c_table_prefix = cTablePrefix
  )}, error = function(e){warning(e); return(NULL)})
  
  return(data)
  
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
#' @param characterizationTargetId A vector of characterizationTargetIds to restrict to
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
#' cohorts <- getOutcomesUsedInCharacterization(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getOutcomesUsedInCharacterization <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    characterizationTargetId = NULL,
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
  
  
  # keep old code for version 3_0_0 and add simple new code for v 4_0_0
  
  if(cVersion == '4_0_0'){
    
    start <- Sys.time()
    
    
    sql <- SqlRender::readSql(system.file(
      paste0("sql/sql_server/characterization/getCharacterizationOutcomesV", cVersion, ".sql"),
      package = "OhdsiReportGenerator",
      mustWork = TRUE
    ))
    
    outcomes <- connectionHandler$queryDb(
      sql = sql,
      schema = schema,
      cg_table_prefix = cgTablePrefix,
      c_table_prefix = cTablePrefix,
      restrict_characterization_target = !is.null(characterizationTargetId),
      characterization_target_ids = paste0(characterizationTargetId, collapse = ','),
      restrict_target = !is.null(targetId),
      target_ids = paste0(targetId, collapse = ',')
    )
    
    
    # add outcome washout and tar?
    
    
    
    
  } else{
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
      use_target = !is.null(characterizationTargetId),
      target_ids = paste0(characterizationTargetId, collapse = ',')
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
      use_target = !is.null(characterizationTargetId),
      target_ids = paste0(characterizationTargetId, collapse = ',')
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
      use_target = !is.null(characterizationTargetId),
      target_ids = paste0(characterizationTargetId, collapse = ',')
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
        use_target = !is.null(characterizationTargetId),
        target_ids = paste0(characterizationTargetId, collapse = ',')
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
    if(printTimes){
      print(paste0('Extracting characterization outcomes took: ', (end-firstStart), ' ', units((end-firstStart))))
    }
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
      use_target = !is.null(characterizationTargetId),
      target_ids = paste0(characterizationTargetId, collapse = ',')
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
        by = 'cohortDefinitionId', 
        all.x = TRUE
      )
    }
    
  }
  
  end <- Sys.time()
  if(printTimes){
    print(paste0('processing characterization outcomes and adding tars/washout: ', (end-start), ' ', units((end-start))))
  }
  
  }
  
  last <- Sys.time()
  if(printTimes){
    print(paste0('Extracting characterization outcomes took: ', (last-firstStart), ' ', units((last-firstStart))))
  }
  
  return(outcomes)
  
}


#===========================================
# INCIDENCE RATE FUNCTIONS
#===========================================


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
#' cohorts <- getTargetsUsedInIncidence(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getTargetsUsedInIncidence <- function(
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
#' @param parentId the parent target cohort Id to extract outcomes for 
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
#' outcomes <- getOutcomesUsedInIncidence(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getOutcomesUsedInIncidence <- function(
    connectionHandler,
    schema,
    ciTablePrefix = 'ci_',
    cgTablePrefix = 'cg_',
    targetId = NULL,
    parentId = NULL
){
  
  if(!is.null(targetId)){
    message('Can only pick targetId or parentId - using targetId')
    parentId <- NULL
  }
  
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
    target_id = paste0(targetId, collapse = ','),
    use_parent = !is.null(parentId),
    parent_id = paste0(parentId, collapse = ',')
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
#' @param parentIds The parent cohort ids to restrict to
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
    parentIds = NULL,
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
    parent_id = paste0(parentIds, collapse = ','),
    use_parent = !is.null(parentIds),
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

#===========================================
# TIME TO EVENT FUNCTIONS
#===========================================


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
#' @param characterizationTargetIds The characterization target cohort ids of interest
#' @template outcomeIds
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{databaseId the unique identifier of the database}
#'  \item{targetName the target cohort name}
#'  \item{targetId the target cohort unique identifier}
#'  \item{limitToFirstInNDays the target cohort was restrict to first in N days}
#'  \item{minPriorObservation the target cohort was restrict to require minPriorObservation before index}
#'  \item{nestingCohortId the nesting cohort id that a target cohort subject must also be in at index}
#'  \item{nestingName the nesting cohort name that a target cohort subject must also be in at index}
#'  \item{minAge the min age of the target cohort}
#'  \item{maxAge the max age of the target cohort}
#'  \item{studyStart the earliest date of the target cohort}
#'  \item{studyEnd the latlest date of the target cohort}
#'  \item{genderConceptIds the gender concept ids restricted to}
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
    characterizationTargetIds = NULL,
    outcomeIds = NULL
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  if(cVersion == 0){
    cVersion <- '3_0_0'
  }
  
  # add code here
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getTimeToEventV",cVersion,".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    use_characterization_target = !is.null(characterizationTargetIds),
    characterization_target_id = paste0(characterizationTargetIds, collapse = ','),
    outcome_id = paste0(outcomeIds, collapse = ','),
    use_outcome = !is.null(outcomeIds),
    c_table_prefix = cTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable
  )
  
  return(result)
}

#===========================================
# DECHALLENGE-RECHALLENGE FUNCTIONS
#===========================================


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
#' @param characterizationTargetIds The characterization target cohort ids of interest
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
    characterizationTargetIds = NULL,
    outcomeIds = NULL
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  if(cVersion == 0){
    cVersion <- '3_0_0'
  }
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getDechallengeRechallengeV",cVersion,".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    use_characterization_target = !is.null(characterizationTargetIds),
    characterization_target_id = paste0(characterizationTargetIds, collapse = ','),
    outcome_id = paste0(outcomeIds, collapse = ','),
    use_outcome = !is.null(outcomeIds),
    c_table_prefix = cTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable
  )
  
  return(result)
}

#' A function to extract the failed dechallenge-rechallenge cases
#'
#' @details
#' Specify the connectionHandler, the schema and the target/outcome cohort IDs and database id
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @param characterizationTargetId The characterization target cohort id of interest
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
#'   characterizationTargetId = 1, 
#'   outcomeId = 3,
#'   databaseId = 'eunomia'
#' )
#' 
getDechallengeRechallengeFails <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    characterizationTargetId = NULL,
    outcomeId = NULL,
    databaseId = NULL,
    dechallengeStopInterval = NULL,
    dechallengeEvaluationWindow = NULL
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  if(length(characterizationTargetId) != 1){
    stop('Must specify one characterizationTargetId')
  }
  
  if(cVersion == '4_0_0'){
    columnName <- 'characterization_target_id'
  } else{
    columnName <- 'TARGET_COHORT_DEFINITION_ID'
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
    column_name = columnName,
    characterization_target_id = characterizationTargetId,
    outcome_id = outcomeId,
    database_id = databaseId,
    use_dechallenge_stop_interval = !is.null(dechallengeStopInterval),
    dechallenge_stop_interval = dechallengeStopInterval,
    use_dechallenge_evaluation_window = !is.null(dechallengeEvaluationWindow),
    dechallenge_evaluation_window = dechallengeEvaluationWindow
  )
  
  return(result)
}

#===========================================
# TARGET BASELINE FUNCTIONS
#===========================================


#' Extract the aggregate covariates for the target ids of interest
#' @description
#' This function extracts the specified covariates for the specified targets
#'
#' @details
#' Specify the connectionHandler, the schema and the target cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @param characterizationTargetIds The characterization target cohort ids of interest
#' @param analysisIds The analysisIds of the covariate to restrict results to
#' @param covariateIds The covariateIds to restict results to
#' @param conceptIds The conceptIds of the covariate to restrict results to
#' @param databaseIds The databaseIds of the covariate to restrict results to
#' @param includeNames Whether to add database and cohort names (setting to FALSE will make extraction quicker)
#' @param minThreshold (optional) The minimum average value for results to be returned
#' 
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{databaseId the unique identifier of the database}
#'  \item{targetName the target cohort name}
#'  \item{targetId the target cohort unique identifier}
#'  \item{minPriorObservation the }
#'  \item{limitToFirstINDays the }
#'  \item{covariateName the }
#'  \item{covariateId the }
#'  \item{analysisId the }
#'  \item{sumValue the }
#'  \item{averageValue the }
#'  } 
#' 
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' btb <- getBinaryTargetBaseline(
#'  connectionHandler = connectionHandler, 
#'  schema = 'main', 
#'  characterizationTargetIds = 1
#' )
#'  
getBinaryTargetBaseline <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    characterizationTargetIds = NULL,
    analysisIds = NULL,
    covariateIds = NULL,
    conceptIds = NULL,
    databaseIds = NULL,
    includeNames = TRUE,
    minThreshold = NULL
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  # add code here
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getBinaryTargetBaselineV",cVersion,".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    use_characterization_targets = !is.null(characterizationTargetIds),
    characterization_target_ids = paste0(characterizationTargetIds, collapse = ','),
    covariate_ids = paste0(covariateIds, collapse = ','),
    use_covariate = !is.null(covariateIds),
    analysis_ids = paste0(analysisIds, collapse = ','),
    use_analysis = !is.null(analysisIds),
    concept_ids = paste0(conceptIds, collapse = ','),
    use_concept = !is.null(conceptIds),
    database_ids = paste0("'",databaseIds,"'", collapse = ","),
    use_database = !is.null(databaseIds),
    c_table_prefix = cTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable,
    include_names = includeNames,
    use_threshold = !is.null(minThreshold),
    min_threshold = minThreshold
  )
  
  return(result)
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
#' @param characterizationTargetIds The characterization target ids
#' @param analysisIds The feature extraction analysis ID of interest (e.g., 201 is condition)
#' @param databaseIds (Optional) A vector of database IDs to restrict to
#' @param includeNames Whether to add database and cohort names (setting to FALSE will make extraction quicker)
#' @param minThreshold (optional) The minimum average value for results to be returned
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
#' tcf <- getContinuousTargetBaseline(
#' connectionHandler = connectionHandler, 
#' schema = 'main'
#' )
#' 
getContinuousTargetBaseline <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    characterizationTargetIds = NULL,
    analysisIds = NULL,
    databaseIds = NULL,
    includeNames = TRUE,
    minThreshold = NULL
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getContinuousTargetBaselineV", cVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    characterization_target_id = paste0(characterizationTargetIds, collapse = ','),
    use_characterization_target = !is.null(characterizationTargetIds),
    c_table_prefix = cTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable,
    use_analysis = !is.null(analysisIds),
    analysis_ids = paste0(analysisIds, collapse = ','),
    use_database = !is.null(databaseIds),
    database_id = paste0("'",databaseIds,"'", collapse = ","),
    include_names = includeNames,
    use_threshold = !is.null(minThreshold),
    min_threshold = minThreshold
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
#' @param characterizationTargetId the characterization target id
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
    characterizationTargetId = NULL,
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
    warning('This version is no longer supported')
    return(NULL)
  } else{
    
    allData <- getBinaryTargetBaseline(
      connectionHandler = connectionHandler, 
      schema = schema, 
      cTablePrefix = cTablePrefix, 
      cgTablePrefix = cgTablePrefix, 
      databaseTable = databaseTable, 
      characterizationTargetIds = characterizationTargetId, 
      analysisIds = analysisIds
    )
    
  }
  
  return(allData)
}


#===========================================
# RISK FACTOR FUNCTIONS
#===========================================


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
#' @param characterizationTargetId the characterization target id
#' @param characterizationCaseId the characterization case id
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
#'   characterizationTargetId = 1, 
#'   outcomeId = 3
#' )
#' 
getBinaryRiskFactors <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    characterizationTargetId = NULL,
    characterizationCaseId = NULL,
    outcomeId = NULL,
    databaseId = NULL,
    analysisIds = c(3), # TODO enable this to be NULL?
    riskWindowStart = NULL,
    riskWindowEnd = NULL,
    startAnchor = NULL,
    endAnchor = NULL
){
  
  if(is.null(characterizationCaseId)){
    if(is.null(characterizationTargetId)){
      stop('characterizationTargetId must be entered')
    }
    if(is.null(outcomeId)){
      stop('outcomeId must be entered')
    }
    if(length(characterizationTargetId) > 1){
      stop('Must be single characterizationTargetId')
    }
    if(length(outcomeId) > 1){
      stop('Must be single outcomeId')
    } } else{
      if(length(characterizationCaseId) > 1){
        stop('Must be single characterizationCaseId')
      }
    }
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  
  if(cVersion == 0){
    warning('This version is no longer supported')
    return(NULL)
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
      characterization_target_id = paste0(characterizationTargetId, collapse = ','),
      use_characterization_target = !is.null(characterizationTargetId),
      characterization_case_id = paste0(characterizationCaseId, collapse = ','),
      use_characterization_case = !is.null(characterizationCaseId),
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
#' @param characterizationTargetId The characterization target id
#' @param characterizationCaseId The characterization case id
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
#'   characterizationTargetId = 1, 
#'   outcomeId = 3
#' )
#' 
getContinuousRiskFactors <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    characterizationTargetId = NULL,
    characterizationCaseId = NULL,
    outcomeId = NULL,
    analysisIds = NULL,
    databaseIds = NULL,
    riskWindowStart = NULL,
    riskWindowEnd = NULL,
    startAnchor = NULL,
    endAnchor = NULL
){
  
  if(is.null(characterizationCaseId)){
    if(is.null(characterizationTargetId)){
      stop('characterizationTargetId must be entered')
    }
    if(is.null(outcomeId)){
      stop('outcomeId must be entered')
    }
    if(length(characterizationTargetId) > 1){
      stop('Must be single characterizationTargetId')
    }
    if(length(outcomeId) > 1){
      stop('Must be single outcomeId')
    } } else{
      if(length(characterizationCaseId) > 1){
        stop('Must be single characterizationCaseId')
      }
    }
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  if(cVersion == 0){
    
    warning('Result table version no longer supported')
    return(NULL)
    
  } else{
    
    sql <- SqlRender::readSql(system.file(
      paste0("sql/sql_server/characterization/getContinuousRiskFactorsV", cVersion, ".sql"),
      package = "OhdsiReportGenerator",
      mustWork = TRUE
    ))
    
    result <- connectionHandler$queryDb(
      sql = sql,
      schema = schema,
      characterization_target_id = paste0(characterizationTargetId, collapse = ','),
      use_characterization_target = !is.null(characterizationTargetId),
      characterization_case_id = paste0(characterizationCaseId, collapse = ','),
      use_characterization_case = !is.null(characterizationCaseId),
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

#===========================================
# CASE SERIES FUNCTIONS
#===========================================

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
#' @param characterizationTargetId The characterization target id to restrict results to
#' @param characterizationCaseId The characterization case id to restrict results to
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
#'   characterizationTargetId = 1, 
#'   outcomeId = 3
#' )
#' 
getBinaryCaseSeries <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    characterizationTargetId = NULL,
    characterizationCaseId = NULL,
    outcomeId = NULL,
    databaseIds = NULL,
    riskWindowStart = NULL,
    riskWindowEnd = NULL,
    startAnchor = NULL,
    endAnchor = NULL,
    conceptIds = NULL,
    minVal = NULL
){
  
  if(is.null(characterizationCaseId)){
    if(is.null(characterizationTargetId)){
      stop('characterizationTargetId must be entered')
    }
    if(is.null(outcomeId)){
      stop('outcomeId must be entered')
    }
    if(length(characterizationTargetId) > 1){
      stop('Must be single characterizationTargetId')
    }
    if(length(outcomeId) > 1){
      stop('Must be single outcomeId')
    }
  } else{
    if(length(characterizationCaseId) > 1){
      stop('Must be single characterizationCaseId')
    }
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
    use_characterization_target = !is.null(characterizationTargetId),
    characterization_target_id = paste0(characterizationTargetId, collapse = ','),
    use_characterization_case = !is.null(characterizationCaseId),
    characterization_case_id = paste0(characterizationCaseId, collapse = ','),
    use_outcome_id = !is.null(outcomeId),
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
#' @param characterizationTargetId The characterization target id to restrict results to
#' @param characterizationCaseId The characterization case id to restrict results to
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
#'   characterizationTargetId = 1, 
#'   outcomeId = 3
#' )
#' 
getContinuousCaseSeries <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    characterizationTargetId = NULL,
    characterizationCaseId = NULL,
    outcomeId = NULL,
    databaseIds = NULL,
    riskWindowStart = NULL,
    riskWindowEnd = NULL,
    startAnchor = NULL,
    endAnchor = NULL
){
  if(is.null(characterizationCaseId)){
    if(is.null(characterizationTargetId)){
      stop('characterizationTargetId must be entered')
    }
    if(is.null(outcomeId)){
      stop('outcomeId must be entered')
    }
    if(length(characterizationTargetId) > 1){
      stop('Must be single characterizationTargetId')
    }
    if(length(outcomeId) > 1){
      stop('Must be single outcomeId')
    }
  } else{
    if(length(characterizationCaseId) > 1){
      stop('Must be single characterizationCaseId')
    }
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
    use_characterization_target = !is.null(characterizationTargetId),
    characterization_target_id = paste0(characterizationTargetId, collapse = ','),
    use_characterization_case = !is.null(characterizationCaseId),
    characterization_case_id = paste0(characterizationCaseId, collapse = ','),
    use_outcome_id = !is.null(outcomeId),
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


#===========================================
# COUNT EXTRACTION FUNCTIONS
#===========================================

# this results the case+non-case counts

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
#' @param characterizationTargetIds The characterization target cohort ids of interest
#' @param characterizationCaseIds The characterization case ids of interest
#' @template outcomeIds
#' @param databaseIds A vector of database IDs to restrict to
#' @param includeNames whether to add the database names and cohort names
#' 
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{databaseId the unique identifier of the database}
#'  \item{characterizationCaseId the unique identifier of target, outcome and TAR combination}
#'  \item{targetName the target cohort name}
#'  \item{targetId the target cohort unique identifier}
#'  \item{limitToFirstInNDays target index is limited to first in N days}
#'  \item{minPriorObservation the minimum required observation days prior to index for an entry}
#'  \item{nestingCohortId the cohort id a person must be in at index}
#'  \item{nestingName the cohort name a person must be in at index}
#'  \item{minAge min age to be included at index}
#'  \item{maxAge max age to be included at index}
#'  \item{studyStart index must be on or after this date to be included}
#'  \item{studyEnd index must be on or before this date to be included}
#'  \item{genderConceptIds the gender concept ids a subject must have to be included}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome unique identifier}
#'  \item{outcomeWashoutDays patients with the outcome occurring within this number of days prior to index are excluded (NA means no exclusion)}
#'  \item{rowCount the number of entries in the cohort}
#'  \item{personCount the number of people in the cohort}
#'  \item{withoutExcludedPersonCount the number of people in the target ignoring exclusions}
#'  } 
#' 
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' tc <- getNonCaseCounts(
#' connectionHandler = connectionHandler, 
#' schema = 'main'
#' )
#' 
getNonCaseCounts <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    characterizationTargetIds = NULL,
    characterizationCaseIds = NULL,
    outcomeIds = NULL,
    databaseIds = NULL,
    includeNames = TRUE
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getNonCaseCountsV", cVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  
 result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    use_characterization_target = !is.null(characterizationTargetIds),
    characterization_target_id = paste0(characterizationTargetIds, collapse = ','),
    use_characterization_case = !is.null(characterizationCaseIds),
    characterization_case_id = paste0(characterizationCaseIds, collapse = ','),
    outcome_id = paste0(outcomeIds, collapse = ','),
    use_outcome = !is.null(outcomeIds),
    c_table_prefix = cTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table_name = databaseTable,
    database_id = paste0("'",databaseIds,"'", collapse = ","),
    use_database = !is.null(databaseIds),
    include_names = includeNames
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
#' @param characterizationTargetIds The characterization target cohort ids of interest
#' @param characterizationCaseIds The characterization case ids of interest
#' @template outcomeIds
#' @param databaseIds (optional) A vector of database IDs to restrict to
#' @param riskWindowStart (optional) A vector of time-at-risk risk window starts to restrict to
#' @param riskWindowEnd (optional) A vector of time-at-risk risk window ends to restrict to
#' @param startAnchor (optional) A vector of time-at-risk start anchors to restrict to
#' @param endAnchor (optional) A vector of time-at-risk end anchors to restrict to
#' @param includeNames whether to add the database names and cohort names
#' 
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{databaseId the unique identifier of the database}
#'  \item{characterizationCaseId the unique identifier of target, outcome and TAR combination}
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
    characterizationTargetIds = NULL,
    characterizationCaseIds = NULL,
    outcomeIds = NULL,
    databaseIds = NULL,
    riskWindowStart = NULL,
    riskWindowEnd = NULL,
    startAnchor = NULL,
    endAnchor = NULL,
    includeNames = TRUE
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
    use_characterization_target = !is.null(characterizationTargetIds),
    characterization_target_id = paste0(characterizationTargetIds, collapse = ','),
    use_characterization_case= !is.null(characterizationCaseIds),
    characterization_case_id = paste0(characterizationCaseIds, collapse = ','),
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
    end_anchor = paste0("'",endAnchor,"'", collapse = ","),
    
    include_names = includeNames
  )
  
  return(result)
}


#' Extract the target cohort counts result
#' @description
#' This function extracts target cohort counts across databases in the results for specified target.
#'
#' @details
#' Specify the connectionHandler, the schema and the characterization target IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @param characterizationTargetIds The characterization target cohort ids of interest
#' @param databaseIds (optional) A vector of database IDs to restrict to
#' @param includeNames whether to add the database names and cohort names
#' 
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{settingId the setting id}
#'  \item{databaseId the unique identifier of the database}
#'  \item{characterizationTargetId the target cohort unique identifier}
#'  \item{N the number of people in the cohort}
#' } 
#' 
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cc <- getTargetCounts(
#' connectionHandler = connectionHandler, 
#' schema = 'main'
#' )
#' 
getTargetCounts <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    characterizationTargetIds = NULL,
    databaseIds = NULL,
    includeNames = TRUE
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  # getting counts
  sql <- SqlRender::readSql(system.file(
    paste0("sql/sql_server/characterization/getTargetCountsV", cVersion, ".sql"),
    package = "OhdsiReportGenerator",
    mustWork = TRUE
  ))
  
  counts <- connectionHandler$queryDb(
    sql = sql,
    use_characterization_targets = !is.null(characterizationTargetIds),
    characterization_target_ids = paste0(characterizationTargetIds, collapse = ','),
    use_databases = !is.null(databaseIds),
    database_ids = paste0("'",databaseIds,"'", collapse = ','),
    schema = schema,
    c_table_prefix = cTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_meta_table = databaseTable,
    include_names = includeNames
  )
  
  return(counts)
  
}





#===========================================
# DATABSE/TARGET COMPARISON FUNCTIONS
#===========================================

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
#' @param characterizationTargetIds (optional) The characterization target ids
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
#' binCohort <- characterizationCompareBinary(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   characterizationTargetIds = 1, 
#'   databaseIds = 'eunomia'
#' )
#' 
characterizationCompareBinary <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_', # not used 
    databaseTable = 'database_meta_data',
    characterizationTargetIds = NULL,
    databaseIds = NULL,
    minThreshold = 0
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  if(cVersion == '0'){
    warning('No this function is not supported for version 0')
    return(NULL)
  } else{
    
    # gives an id and setting_id, database_id, characterization_target_id and n
    colHeader <- columnHeader(
      connectionHandler = connectionHandler,
      schema = schema,
      cTablePrefix = cTablePrefix,
      cgTablePrefix = cgTablePrefix,
      databaseTable = databaseTable,
      characterizationTargetIds = characterizationTargetIds,
      databaseIds = databaseIds
    )
    
    if(nrow(colHeader) == 0){
      return(NULL)
    }
    
    # extract the covariates
    tb <- getBinaryTargetBaseline(
      connectionHandler = connectionHandler,
      schema = schema,
      cTablePrefix = cTablePrefix,
      cgTablePrefix = cgTablePrefix,
      databaseTable = databaseTable,
      characterizationTargetIds = characterizationTargetIds,
      databaseIds = databaseIds,
      minThreshold = minThreshold,
      includeNames = FALSE # makes extraction quicker
      )
    
    # merge to get counts
    tb <- merge(
      x = tb, 
      y = colHeader, 
      by = c('settingId', 'databaseId', 
             'characterizationTargetId'
      ))
    
    # pivot using the id column for the name 
    tb <- pivotMultipleTargetResults(
      targetBaseline = tb, 
      pivotCols = c('sumValue', 'averageValue')
    )
      
    tb <- addSmdBinary(
      pivotedTargetBaseline = tb,
      colHeader = colHeader
      )
    
  }
  
  return(
    list(
      covariates = tb,
      covRef = colHeader
    )
  )
}



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
#' @param characterizationTargetIds (optional) The characterization target ids
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
#' binCohort <- characterizationCompareContinuous(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   characterizationTargetIds = 1, 
#'   databaseIds = 'eunomia'
#' )
#' 
characterizationCompareContinuous <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_', # not used 
    databaseTable = 'database_meta_data',
    characterizationTargetIds = NULL,
    databaseIds = NULL,
    minThreshold = 0
){
  
  cVersion <- .getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix
  )
  
  if(cVersion == '0'){
    warning('No this function is not supported for version 0')
    return(NULL)
  } else{
    
    # gives an id and setting_id, database_id, characterization_target_id and n
    colHeader <- columnHeader(
      connectionHandler = connectionHandler,
      schema = schema,
      cTablePrefix = cTablePrefix,
      cgTablePrefix = cgTablePrefix,
      databaseTable = databaseTable,
      characterizationTargetIds = characterizationTargetIds,
      databaseIds = databaseIds
    )
    
    if(nrow(colHeader) == 0){
      return(NULL)
    }
    
    # extract the covariates
    tb <- getContinuousTargetBaseline(
      connectionHandler = connectionHandler,
      schema = schema,
      cTablePrefix = cTablePrefix,
      cgTablePrefix = cgTablePrefix,
      databaseTable = databaseTable,
      characterizationTargetIds = characterizationTargetIds,
      databaseIds = databaseIds,
      minThreshold = minThreshold,
      includeNames = FALSE # makes extraction quicker
    )
    
    # merge to get counts
    tb <- merge(
      x = tb, 
      y = colHeader, 
      by = c('settingId', 'databaseId', 
             'characterizationTargetId'
      ))
    
    # pivot using the id column for the name 
    tb <- pivotMultipleTargetResults(
      targetBaseline = tb, 
      pivotCols = c('countValue', 'averageValue', 'standardDeviation', 'medianValue','minValue', 'maxValue', 'p10Value','p25Value','p75Value','p90Value')
    )
    
    tb <- addSmdContinuous(
      pivotedTargetBaseline = tb,
      colHeader = colHeader
    )
    
  }
  
  return(
    list(
      covariates = tb,
      covRef = colHeader
    )
  )
}


# get columnHeader (counts)
columnHeader <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_', # not used 
    databaseTable = 'database_meta_data',
    characterizationTargetIds = NULL,
    databaseIds = NULL
  ){
  
  # first get target cohort counts per characterizationTargetId and databaseId
  counts <- getTargetCounts(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix,
    cgTablePrefix = cgTablePrefix,
    databaseTable = databaseTable,
    characterizationTargetIds = characterizationTargetIds,
    databaseIds = databaseIds
  )
  
  # add order for targets if not NULL
  if(!is.null(characterizationTargetIds)){
    counts <- counts %>%
      dplyr::inner_join(
        data.frame(
          characterizationTargetId = c(unique(characterizationTargetIds)),
          order = 1:length(unique(characterizationTargetIds))
        ), 
        by = 'characterizationTargetId') %>%
      dplyr::arrange(dplyr::desc(-1*.data$order)) %>%
      dplyr::select(-"order")
  }
  
  colRef <- counts %>%
    dplyr::mutate(id = dplyr::row_number()) %>%
    dplyr::select("settingId", "databaseId", "characterizationTargetId", "id", "n")
  
  return(colRef)
  
}

pivotMultipleTargetResults <- function(
    targetBaseline, 
    pivotCols = c('sumValue', 'averageValue')
    ){
  
  #continuous
  ##pivotCols <- c('countValue', 'averageValue', 'standardDeviation', 'medianValue','minValue', 'maxValue', 'p10Value','p25Value','p75Value','p90Value')
  #binary
  ##pivotCols <- c('sumValue', 'averageValue')
    
  # pivot 
  result <- tidyr::pivot_wider(
    data = targetBaseline, 
    id_cols = c('covariateName', 'covariateId'), 
    names_from = 'id', 
    values_from = dplyr::all_of(pivotCols), 
    values_fn = mean, 
    values_fill = NA
  ) 

  return(result)
}


addSmdBinary <- function(pivotedTargetBaseline, colHeader){
  
  twoResultsWithValues <- length(grep('sumValue', colnames(pivotedTargetBaseline))) == 2
  
  if(nrow(colHeader) == 2 & twoResultsWithValues){
    pivotedTargetBaseline <- pivotedTargetBaseline %>% 
      dplyr::mutate(
        meanDiff = (.data$averageValue_1 - .data$averageValue_2),
        pooledSd = sqrt((.data$averageValue_1*(1-.data$averageValue_1) + .data$averageValue_2*(1-.data$averageValue_2))/2)
      ) %>%
      dplyr::mutate(
        smd = .data$meanDiff/dplyr::if_else(.data$pooledSd == 0, 1, .data$pooledSd)
      ) %>%
      dplyr::mutate(
        absSmd = abs(.data$smd)
      ) %>%
      dplyr::select(-"meanDiff", -"pooledSd")
  } 
  
  return(pivotedTargetBaseline)
}

addSmdContinuous <- function(pivotedTargetBaseline, colHeader){
  twoResultsWithValues <- length(grep('countValue', colnames(pivotedTargetBaseline))) == 2
  
  if(nrow(colHeader) == 2 & twoResultsWithValues){
    pivotedTargetBaseline <- pivotedTargetBaseline %>% dplyr::mutate(
      smd = (abs(.data$averageValue_1)-abs(.data$averageValue_2))/(sqrt((abs(.data$standardDeviation_1)^2 + abs(.data$standardDeviation_2)^2)/2))
    ) %>%
      dplyr::mutate(
        absSmd = abs(.data$smd)
      )
  }
  
  return(pivotedTargetBaseline)
  
}


