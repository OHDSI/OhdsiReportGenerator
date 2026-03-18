#' Extracts the different analyses ran for each target and event cohorts
#' @description
#' This function extracts analysis ids, events cohorts, and databases per target from treatment patterns
#'
#' @details
#' Specify the connectionHandler and the schema
#'
#' @template connectionHandler
#' @template schema
#' @template tpTablePrefix
#' @family TreatmentPatterns
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName a concatinated string of all the database names ran for that analysis}
#'  \item{databaseId a concatinated string of all the database ids ran for that analysis}
#'  \item{analysisId the analysis ids for the treament patterns run}
#'  \item{targetCohortName the target cohort name}
#'  \item{targetCohortId the target cohort unique identifier}
#'  \item{eventCohortList a concatinated string of all the event cohort names ran for that target}
#'  \item{exitCohortList a concatinated string of all the exit cohort names ran for that target}
#'  }
#'
#' @export
#'
#' @examples
#' conDet <- getExampleConnectionDetails()
#'
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#'
#' cohortAnalysis <- getAnalysisCohorts(
#'   connectionHandler = connectionHandler,
#'   schema = "main"
#' )
getAnalysisCohorts <- function(
  connectionHandler,
  schema,
  tpTablePrefix = "tp_"
) {
  sql <- "SELECT
      d.CDM_SOURCE_ABBREVIATION AS database_name,
      d.database_id AS database_id,
      t.analysis_id,
      t.cohort_name,
      t.cohort_id,
      t.type
    FROM @schema.@tp_table_prefixanalysis_cohorts t
    Inner JOIN @schema.@tp_table_prefixcdm_source_info d
    ON t.analysis_id = d.analysis_id"

  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    tp_table_prefix = tpTablePrefix,
  ) 

  targets <- result %>%
    dplyr::filter(.data$type == "target") %>%
    dplyr::rename(targetCohortId = "cohortId",
                  targetCohortName = "cohortName") %>%
    dplyr::select("analysisId", "targetCohortId", "targetCohortName") %>%
    dplyr::distinct()
  
  events <- result %>%
    dplyr::filter(.data$type == "event") %>%
    dplyr::select("analysisId", "cohortId", "cohortName") %>%
    dplyr::distinct() %>%
    dplyr::group_by(.data$analysisId) %>%
    dplyr::summarise(eventCohortList = paste(.data$cohortName, collapse = ", "), .groups = "drop")
  
  exits <- result %>%
    dplyr::filter(.data$type == "exit") %>%
    dplyr::select("analysisId", "cohortId", "cohortName") %>%
    dplyr::distinct() %>%
    dplyr::group_by(.data$analysisId) %>%
    dplyr::summarise(exitCohortList = paste(.data$cohortName, collapse = ", "), .groups = "drop")
  
  databases <- result %>%
    dplyr::select("analysisId", "databaseId", "databaseName") %>%
    dplyr::distinct() %>%
    dplyr::group_by(.data$analysisId) %>%
    dplyr::summarise(
      databaseId = paste(.data$databaseId, collapse = ", "),
      databaseName = paste(.data$databaseName, collapse = ", "),
      .groups = "drop"
    )
  
  final <- targets %>%
    dplyr::left_join(events, by = "analysisId") %>%
    dplyr::left_join(exits, by = "analysisId") %>%
    dplyr::left_join(databases, by = "analysisId")
  
  return(final)
}


#' Extracts treatment pathways
#' @description
#' This function extracts results pathways for specified analysis ids and target cohorts
#'
#' @details
#' Specify the connectionHandler and the schema
#'
#' @template connectionHandler
#' @template schema
#' @template tpTablePrefix
#' @template databaseTable
#' @param age (optional) a string representing an age bucket to restrict (e.g., "0-17", "18-34", "65+")
#' @param sex (optional) A string "male" or "female" to restrict
#' @param indexYear (optional) A string with a four-digit year to restrict
#' @param analysisIds (optional) A vector of analysis ids to restrict to
#' @param databaseIds (optional) A vector of database ids to restrict to
#' @param databaseNames (optional) A vector of database Names to restrict to
#' @param targetIds (optional) A vector of target cohort ids to restrict to
#' @family TreatmentPatterns
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{databaseId the unique identifier of the database}
#'  \item{analysisId the unique identifier of a treament patterns run}
#'  \item{targetCohortName the target cohort name}
#'  \item{targetCohortId the target cohort unique identifier}
#'  \item{pathway a string representing the progression of events for a target. Use '-' to separate sequential steps and '+' for combination of events at that step}
#'  \item{freq the count of pathway occurance}
#'  \item{age the stratifyed pathways for age}
#'  \item{indexYear the stratifyed pathways for index year}
#'  \item{sex the stratifyed pathways for sex}

#'  }
#'
#' @export
#'
#' @examples
#' conDet <- getExampleConnectionDetails()
#'
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#'
#' tp <- getTreatmentPathways(
#'   connectionHandler = connectionHandler,
#'   schema = "main"
#' )
getTreatmentPathways <- function(
  connectionHandler,
  schema,
  tpTablePrefix = "tp_",
  databaseTable = "database_meta_data",
  age = "all",
  sex = "all",
  indexYear = "all",
  analysisIds = NULL,
  databaseIds = NULL,
  databaseNames = NULL,
  targetIds = NULL
) {
  sql <- "SELECT
    d.CDM_SOURCE_ABBREVIATION AS database_name,
    t.database_id,
    t.analysis_id,
    t.target_cohort_name,
    t.target_cohort_id,
    t.freq,
    t.pathway,
    t.age,
    t.index_year,
    t.sex
  FROM @schema.@tp_table_prefixtreatment_pathways t
  INNER JOIN
  @schema.@database_table d
  ON t.database_id = d.database_id 
  WHERE
    t.age = @age AND 
    t.index_year = @index_year AND
    t.sex = @sex
    {@use_targets}?{AND t.target_cohort_id IN (@target_ids) }
    {@use_database_id}?{AND t.database_id IN (@database_id) }
    {@use_analysis}?{and t.analysis_id IN (@analysis_ids)}
    {@use_database_name}?{and d.CDM_SOURCE_ABBREVIATION IN (@database_name)}
  "

  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    tp_table_prefix = tpTablePrefix,
    database_table = databaseTable,
    use_targets = !is.null(targetIds),
    target_ids = paste0(targetIds, collapse = ","),
    use_analysis = !is.null(analysisIds),
    analysis_ids = paste0(analysisIds, collapse = ","),
    use_database_id = !is.null(databaseIds),
    database_id = paste0("'", databaseIds, "'", collapse = ","),
    use_database_name = !is.null(databaseNames),
    database_name = paste0("'", databaseNames, "'", collapse = ","),
    age = paste0("'", age, "'"),
    sex = paste0("'", sex, "'"),
    index_year = paste0("'", indexYear, "'")
  )

  return(result)
}

#' Extracts summary of event duration
#' @description
#' This function extracts results summary stats of event duration for specified analysis ids and target cohorts
#'
#' @details
#' Specify the connectionHandler, the schema, and the analysisIds
#'
#' @template connectionHandler
#' @template schema
#' @template tpTablePrefix
#' @template databaseTable
#' @param analysisIds A vector of analysis ids to restrict to
#' @param databaseIds (optional) A vector of database ids to restrict to
#' @param databaseNames (optional) A vector of database Names to restrict to
#' @param targetIds (optional) A vector of target cohort ids to restrict to
#' @family TreatmentPatterns
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{databaseId the unique identifier of the database}
#'  \item{analysisId the unique identifier of a treament patterns run}
#'  \item{targetCohortId the target cohort unique identifier}
#'  \item{targetCohortName the target cohort name}
#'  \item{eventName a string representing an events for a target. Uses '+' for combination of event cohorts}
#'  \item{rank the step number of event occurance}
#'  \item{eventCount the count of event occurance at rank}
#'  \item{durationAverage the average duration of event}
#'  \item{durationMax the maximum duration of event}
#'  \item{durationMin the minimum duration of event}
#'  \item{durationMedian the median duration of event}
#'  \item{p25Value the 25th percentile for duration of event}
#'  \item{p75Value the 75th percentile for duration of event}
#'  \item{standardDeviation the standard deviation for duration of event}
#'  }
#'
#' @export
#'
#' @examples
#' conDet <- getExampleConnectionDetails()
#'
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#'
#' ed <- getEventDuration(
#'   connectionHandler = connectionHandler,
#'   schema = "main",
#'   analysisIds = c(1)
#' )
getEventDuration <- function(
  connectionHandler,
  schema,
  analysisIds,
  tpTablePrefix = "tp_",
  databaseTable = "database_meta_data",
  databaseIds = NULL,
  databaseNames = NULL,
  targetIds = NULL
) {
  sql <- "SELECT
    d.CDM_SOURCE_ABBREVIATION AS database_name,
    t.database_id,
    t.analysis_id,
    t.target_cohort_id,
    t.target_cohort_name,
    t.event_name,
    t.line AS rank,
    t.event_count,
    t.duration_average,
    t.duration_max,
    t.duration_min,
    t.duration_median,
    t.duration_q_1 as p_25_value,
    t.duration_q_2 as p_75_value,
    t.duration_sd as standard_deviation
  FROM @schema.@tp_table_prefixsummary_event_duration t
  INNER JOIN
  @schema.@database_table d
  ON t.database_id = d.database_id 
  WHERE t.analysis_id IN (@analysis_ids)
  {@use_targets}?{AND t.target_cohort_id IN (@target_ids) }
  {@use_database_id}?{AND t.database_id IN (@database_id) }
  {@use_database_name}?{and d.CDM_SOURCE_ABBREVIATION IN (@database_name)}
  "

  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    tp_table_prefix = tpTablePrefix,
    database_table = databaseTable,
    use_targets = !is.null(targetIds),
    target_ids = paste0(targetIds, collapse = ","),
    analysis_ids = paste0(analysisIds, collapse = ","),
    use_database_id = !is.null(databaseIds),
    database_id = paste0("'", databaseIds, "'", collapse = ","),
    use_database_name = !is.null(databaseNames),
    database_name = paste0("'", databaseNames, "'", collapse = ","),
  )

  return(result)
}
