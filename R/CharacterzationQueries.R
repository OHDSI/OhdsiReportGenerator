
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
#'  \item{targetName the target cohort name}
#'  \item{targetId the target cohort unique identifier}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome unique identifier}
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
  
  sql <- 'select 
    d.cdm_source_abbreviation as database_name, 
    cg1.cohort_name as target_name,
    i.target_cohort_definition_id as target_id,
    cg2.cohort_name as outcome_name,
    i.outcome_cohort_definition_id as outcome_id, 
    
    i.clean_window,
    i.subgroup_name,
    i.age_group_name,
    i.gender_name,
    i.start_year,
    i.tar_start_with,
    i.tar_start_offset,
    i.tar_end_with,
    i.tar_end_offset,
    
    i.persons_at_risk_pe,
    i.persons_at_risk,
    i.person_days_pe,
    i.person_days,
    i.person_outcomes_pe,
    i.person_outcomes,
    i.outcomes_pe,
    i.outcomes,
    i.incidence_proportion_p100p,
    i.incidence_rate_p100py
    
    from 
    (select od.outcome_cohort_definition_id, od.clean_window, agd.age_group_name, 
    tad.tar_start_with, tad.tar_start_offset, tad.tar_end_with, tad.tar_end_offset,
    sd.subgroup_name, i.*
  from @schema.@ci_table_prefixINCIDENCE_SUMMARY i
  join @schema.@ci_table_prefixOUTCOME_DEF 
  od on i.outcome_id = od.outcome_id
    and i.ref_id = od.ref_id
  join @schema.@ci_table_prefixTAR_DEF tad on i.tar_id = tad.tar_id
    and i.ref_id = tad.ref_id
  join @schema.@ci_table_prefixSUBGROUP_DEF sd on i.subgroup_id = sd.subgroup_id
    and i.ref_id = sd.ref_id
  left join @schema.@ci_table_prefixAGE_GROUP_DEF agd on i.age_group_id = agd.age_group_id
    and i.ref_id = agd.ref_id
 ) i
    inner join @schema.@database_table_name d
    on d.database_id = i.database_id
    
    inner join @schema.@cg_table_prefixcohort_definition cg1 
    on cg1.cohort_definition_id = i.target_cohort_definition_id
    
    inner join @schema.@cg_table_prefixcohort_definition cg2
    on cg2.cohort_definition_id = i.outcome_cohort_definition_id
    
    where 
    1 = 1
    {@use_target}?{ and target_cohort_definition_id in (@target_id)}
    {@use_outcome}?{ and outcome_cohort_definition_id in (@outcome_id)}
    ;'
  
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
  
  result$incidenceProportionP100p[is.na(result$incidenceProportionP100p)] <- result$outcomes[is.na(result$incidenceProportionP100p)]/result$personsAtRisk[is.na(result$incidenceProportionP100p)]*100
  result$incidenceProportionP100p[is.na(result$incidenceProportionP100p)] <- 0
  result$incidenceRateP100py[is.na(result$incidenceRateP100py)] <- result$outcomes[is.na(result$incidenceRateP100py)]/(result$personDays[is.na(result$incidenceRateP100py)]/365)*100
  result$incidenceRateP100py[is.na(result$incidenceRateP100py)] <- 0
  result[is.na(result)] <- 'Any'
  result <- unique(result)
  
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
  sql <- "SELECT 
          d.CDM_SOURCE_ABBREVIATION as database_name,
          target_cohorts.cohort_name as target_name,
          tte.target_cohort_definition_id as target_id,
          outcome_cohorts.cohort_name as outcome_name,
          tte.outcome_cohort_definition_id as outcome_id,
          tte.outcome_type,
          tte.target_outcome_type,
          tte.time_to_event,
          tte.num_events,
          tte.time_scale
           
          FROM @schema.@c_table_prefixTIME_TO_EVENT tte
          inner join @schema.@database_table d
          on tte.database_id = d.database_id

           inner join @schema.@cg_table_prefixcohort_definition target_cohorts
           on target_cohorts.cohort_definition_id = tte.TARGET_COHORT_DEFINITION_ID

           inner join @schema.@cg_table_prefixcohort_definition outcome_cohorts
           on outcome_cohorts.cohort_definition_id = tte.OUTCOME_COHORT_DEFINITION_ID
           
          where 1 = 1
          {@use_target}?{ and tte.TARGET_COHORT_DEFINITION_ID in (@target_id)}
          {@use_outcome}?{ and tte.OUTCOME_COHORT_DEFINITION_ID in (@outcome_id)}

           
          ;"
  
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
  sql <- "SELECT 
          d.CDM_SOURCE_ABBREVIATION as database_name,
          target_cohorts.cohort_name as target_name,
          dr.target_cohort_definition_id as target_id,
          outcome_cohorts.cohort_name as outcome_name,
          dr.outcome_cohort_definition_id as outcome_id,
          dr.dechallenge_stop_interval,
          dr.dechallenge_evaluation_window,
          dr.num_exposure_eras,
          dr.num_persons_exposed,
          dr.num_cases,
          dr.dechallenge_attempt,
          dr.dechallenge_fail,
          dr.dechallenge_success,
          dr.rechallenge_attempt,
          dr.rechallenge_fail,
          dr.rechallenge_success,
          dr.pct_dechallenge_attempt,
          dr.pct_dechallenge_fail,
          dr.pct_dechallenge_success,
          dr.pct_rechallenge_attempt,
          dr.pct_rechallenge_fail,
          dr.pct_rechallenge_success
          
          FROM @schema.@c_table_prefixDECHALLENGE_RECHALLENGE dr 
          inner join @schema.@database_table d
          on dr.database_id = d.database_id
          
           inner join @schema.@cg_table_prefixcohort_definition target_cohorts
           on target_cohorts.cohort_definition_id = dr.TARGET_COHORT_DEFINITION_ID

           inner join @schema.@cg_table_prefixcohort_definition outcome_cohorts
           on outcome_cohorts.cohort_definition_id = dr.OUTCOME_COHORT_DEFINITION_ID
           
          where 1 = 1
          {@use_target}?{ and dr.TARGET_COHORT_DEFINITION_ID in (@target_id)}
          {@use_outcome}?{ and dr.OUTCOME_COHORT_DEFINITION_ID in (@outcome_id)}

           
          ;"
  
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
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{targetName the target cohort name}
#'  \item{targetId the target cohort unique identifier}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome unique identifier}
#'  \item{rowCount the number of entries in the cohort}
#'  \item{personCount the number of people in the cohort}
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
#' tc <- getTargetCounts(
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
    targetIds = NULL,
    outcomeIds = NULL
){
  
  sql <- "
  select distinct
  targets.database_name,
  target_cohorts.cohort_name as target_name,
  targets.target_id,
  outcome_cohorts.cohort_name as outcome_name,
  targets.outcome_id,
  case when excludes.row_count is NULL then targets.row_count else
  targets.row_count - excludes.row_count end as row_count,
  case when excludes.person_count is NULL then targets.person_count
  else targets.person_count - excludes.person_count end as person_count,
  targets.min_prior_observation,
  targets.outcome_washout_days
  
  from
  
  (select 
  d.CDM_SOURCE_ABBREVIATION as database_name,
  cc.target_cohort_ID as target_id,
  s2.outcome_cohort_id as outcome_id,
  cc.row_count,
  cc.person_count,
  cc.min_prior_observation,
  s2.outcome_washout_days

  from 
  @schema.@c_table_prefixcohort_counts cc
  inner join
  @schema.@database_table_name d
  on cc.database_id = d.database_id
  
  inner join
(
select distinct 
tcd.target_cohort_id,
tcd.outcome_cohort_id,
ts.outcome_washout_days

from
@schema.@c_table_prefixsettings ts
inner join
@schema.@c_table_prefixcohort_details tcd
on ts.setting_id = tcd.setting_id
and ts.database_id = tcd.database_id

where tcd.outcome_cohort_id != 0
{@use_target}?{ and tcd.target_cohort_id in (@target_id)}
{@use_outcome}?{ and tcd.outcome_cohort_id in (@outcome_id)}
) s2

on  
cc.target_cohort_id = s2.target_cohort_id

  where 
    cc.COHORT_TYPE in ('Target')
  {@use_target}?{ and cc.TARGET_COHORT_ID in (@target_id)}
    ) targets
    
    left join
 
  (select 
  d.CDM_SOURCE_ABBREVIATION as database_name,
  cc.target_cohort_ID as target_id,
  cc.outcome_cohort_ID as outcome_id,
  cc.row_count as row_count,
  cc.person_count as person_count,
  cc.min_prior_observation,
  cc.outcome_washout_days

  from 
  @schema.@c_table_prefixcohort_counts cc
  inner join
  @schema.@database_table_name d
  on cc.database_id = d.database_id

  where 
  cc.COHORT_TYPE in ('Exclude')
  {@use_target}?{ and cc.TARGET_COHORT_ID in (@target_id)}
  {@use_outcome}?{ and cc.outcome_COHORT_ID in (@outcome_id)}
   
  ) excludes
  
  on targets.database_name = excludes.database_name
  and targets.target_id = excludes.target_id
  and targets.min_prior_observation = excludes.min_prior_observation
  
  inner join @schema.@cg_table_prefixcohort_definition target_cohorts
    on target_cohorts.cohort_definition_id = targets.target_id
    
  left join @schema.@cg_table_prefixcohort_definition outcome_cohorts
    on outcome_cohorts.cohort_definition_id = targets.outcome_id
  
  ;"
  
 result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    target_id = paste0(targetIds, collapse = ','),
    use_target = !is.null(targetIds),
    outcome_id = paste0(outcomeIds, collapse = ','),
    use_outcome = !is.null(outcomeIds),
    c_table_prefix = cTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table_name = databaseTable
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
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
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
    outcomeIds = NULL
){
  
  sql <- "
  select 
  d.CDM_SOURCE_ABBREVIATION as database_name,
  target_cohorts.cohort_name as target_name,
  cc.target_cohort_ID as target_id,
  outcome_cohorts.cohort_name as outcome_name,
  cc.outcome_cohort_ID as outcome_id,
  cc.ROW_COUNT,
  cc.PERSON_COUNT,
  cc.min_prior_observation,
  cc.outcome_washout_days,
  cc.RISK_WINDOW_START,
  cc.RISK_WINDOW_END,
  cc.START_ANCHOR,
  cc.END_ANCHOR

  from 
  
  @schema.@c_table_prefixcohort_counts cc
  inner join
  @schema.@database_table d
  on cc.database_id = d.database_id

  inner join 
  @schema.@cg_table_prefixcohort_definition target_cohorts
  on target_cohorts.cohort_definition_id = cc.target_cohort_ID
    
  inner join 
  @schema.@cg_table_prefixcohort_definition outcome_cohorts
  on outcome_cohorts.cohort_definition_id = cc.outcome_cohort_ID
  
    where 
    cc.COHORT_TYPE in ('Cases')
    {@use_target}?{ and cc.TARGET_COHORT_ID in (@target_id)}
    {@use_outcome}?{ and cc.OUTCOME_COHORT_ID in (@outcome_id)}
    
  ;"
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    c_table_prefix = cTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable,
    target_id = paste0(targetIds, collapse = ','),
    use_target = !is.null(targetIds),
    outcome_id = paste0(outcomeIds, collapse = ','),
    use_outcome = !is.null(outcomeIds)
  )
  
  return(result)
}


#' Extract aggregate statistics of binary feature analysis IDs of interest for cases
#' @description
#' This function extracts the feature extraction results for cases corresponding to specified target and outcome cohorts.
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
#' @param analysisIds The feature extraction analysis ID of interest (e.g., 201 is condition)
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
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
#' \item{covariateId the id of the feature}
#' \item{covariateName the name of the feature}
#' \item{sumValue the number of cases who have the feature value of 1}
#' \item{averageValue the mean feature value}
#' } 
#' 
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cbf <- getCaseBinaryFeatures(
#' connectionHandler = connectionHandler, 
#' schema = 'main'
#' )
#' 
getCaseBinaryFeatures <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    outcomeIds = NULL,
    analysisIds = c(3) # c(8507, 8532)
){
  
  # get sex distributions
  sql <-  
    "select 
d.CDM_SOURCE_ABBREVIATION as database_name,
target.cohort_name as target_name,
cd.TARGET_COHORT_ID,
outcome.cohort_name as outcome_name,
cd.Outcome_COHORT_ID,
s.min_prior_observation,
s.outcome_washout_days,
s.RISK_WINDOW_START,
s.RISK_WINDOW_END,
s.START_ANCHOR,
s.END_ANCHOR,
coi.covariate_id,
coi.covariate_name,
c.sum_value,
c.average_value

from @schema.@c_table_prefixCOVARIATES c
 inner join
(
select * from @schema.@c_table_prefixCOVARIATE_REF 
  where analysis_id in (@analysis_ids)
) coi

on 
c.database_id = coi.database_id and
c.setting_id = coi.setting_id and
c.covariate_id = coi.covariate_id

inner join
@schema.@c_table_prefixCOHORT_DETAILS cd

on cd.TARGET_COHORT_ID = c.TARGET_COHORT_ID
and cd.OUTCOME_COHORT_ID = c.OUTCOME_COHORT_ID
and cd.COHORT_TYPE = c.COHORT_TYPE
and cd.database_id = c.database_id 
and cd.setting_id = c.setting_id 

inner join
@schema.@database_table d
on 
c.database_id = d.database_id

inner join @schema.@c_table_prefixsettings s
on s.setting_id = c.setting_id
and s.database_id = c.database_id

  inner join 
  @schema.@cg_table_prefixcohort_definition target
  on target.cohort_definition_id = cd.target_cohort_ID
    
  inner join 
  @schema.@cg_table_prefixcohort_definition outcome
  on outcome.cohort_definition_id = cd.outcome_cohort_ID
  
where 
cd.COHORT_TYPE in ('Cases')
{@use_target}?{ and c.TARGET_COHORT_ID in (@target_id)}
{@use_outcome}?{ and c.OUTCOME_COHORT_ID in (@outcome_id)}
;
"

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
  analysis_ids = paste0(analysisIds, collapse = ',')
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
  
  ageData <- getCaseBinaryFeatures(
    connectionHandler = connectionHandler, 
    schema = schema, 
    cTablePrefix = cTablePrefix,
    cgTablePrefix = cgTablePrefix,
    targetIds = targetId, 
    outcomeIds = outcomeId, 
    analysisIds = analysisIds
  )
  ageDataT <- getTargetBinaryFeatures(
    connectionHandler = connectionHandler, 
    schema = schema, 
    cTablePrefix = cTablePrefix,
    cgTablePrefix = cgTablePrefix,
    targetIds = targetId, 
    outcomeIds = outcomeId, 
    analysisIds = analysisIds
  )
  
  countT <- getTargetCounts(
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
        "minPriorObservation",
        "outcomeWashoutDays",
        "personCount"
      ), 
      by = c("databaseName", 'minPriorObservation', 'outcomeWashoutDays'),
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
    cohortType = "Target",
    averageValue = .data$sumValue/.data$personCount
  )
  
  ageData <- ageData %>% 
    dplyr::mutate(
    cohortType = "Cases"
  )
  
  allData <- rbind(ageData, ageDataT[,colnames(ageData)])
  
return(allData)
}

# add get Target - need to calculate from target and exclude
#' Extract aggregate statistics of binary feature analysis IDs of interest for targets
#' @description
#' This function extracts the feature extraction results for targets corresponding to specified target and outcome cohorts.
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
#' @param analysisIds The feature extraction analysis ID of interest (e.g., 201 is condition)
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{targetName the target cohort name}
#'  \item{targetId the target cohort unique identifier}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome unique identifier}
#'  \item{minPriorObservation the minimum required observation days prior to index for an entry}
#'  \item{outcomeWashoutDays patients with the outcome occurring within this number of days prior to index are excluded (NA means no exclusion)}
#'  \item{covariateId the id of the feature}
#'  \item{covariateName the name of the feature}
#'  \item{sumValue the number of target patients who have the feature value of 1 (minus those excluded due to having the outcome prior)}
#'  \item{rawSum the number of target patients who have the feature value of 1 (ignoring exclusions)}
#'  \item{rawAverage the fraction of target patients who have the feature value of 1 (ignoring exclusions)}
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
#' schema = 'main'
#' )
#' 
getTargetBinaryFeatures <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    outcomeIds = NULL,
    analysisIds = c(3) # c(8507, 8532)
){
  
  sql <-  
    "
select 
d.CDM_SOURCE_ABBREVIATION as database_name,
target.cohort_name as target_name,
t.TARGET_COHORT_ID,
outcome.cohort_name as outcome_name,
t.Outcome_COHORT_ID,
t.min_prior_observation,
t.outcome_washout_days,
t.covariate_id,
t.covariate_name,
case when e.sum_value is NULL then t.sum_value
else t.sum_value - e.sum_value end as sum_value,
t.sum_value as raw_sum,
t.average_value as raw_average
 
FROM 

(select 
c.database_id,
cd.TARGET_COHORT_ID,
s2.Outcome_COHORT_ID,
s.min_prior_observation,
s2.outcome_washout_days,
coi.covariate_id,
coi.covariate_name,
c.sum_value,
c.average_value

from @schema.@c_table_prefixCOVARIATES c
 inner join
(
select * from @schema.@c_table_prefixCOVARIATE_REF 
  where analysis_id in (@analysis_ids)
) coi

on 
c.database_id = coi.database_id and
c.setting_id = coi.setting_id and
c.covariate_id = coi.covariate_id

inner join
@schema.@c_table_prefixCOHORT_DETAILS cd

on cd.TARGET_COHORT_ID = c.TARGET_COHORT_ID
and cd.OUTCOME_COHORT_ID = c.OUTCOME_COHORT_ID
and cd.COHORT_TYPE = c.COHORT_TYPE
and cd.database_id = c.database_id 
and cd.setting_id = c.setting_id 

inner join @schema.@c_table_prefixsettings s
on s.setting_id = c.setting_id
and s.database_id = c.database_id

inner join
(
select distinct 
tcd.target_cohort_id,
tcd.outcome_cohort_id,
ts.outcome_washout_days

from
@schema.@c_table_prefixsettings ts
inner join
@schema.@c_table_prefixcohort_details tcd
on ts.setting_id = tcd.setting_id
and ts.database_id = tcd.database_id

where tcd.outcome_cohort_id != 0
{@use_target}?{ and tcd.target_cohort_id in (@target_id)}
{@use_outcome}?{ and tcd.outcome_cohort_id in (@outcome_id)}
) s2
on cd.target_cohort_id = s2.target_cohort_id

where 
cd.COHORT_TYPE = 'Target'
{@use_target}?{ and c.TARGET_COHORT_ID in (@target_id)}
) t

left join

( select 
  c.database_id,
  cd.TARGET_COHORT_ID,
  cd.Outcome_COHORT_ID,
  s.min_prior_observation,
  s.outcome_washout_days,
  coi.covariate_id,
  coi.covariate_name,
  c.sum_value
  
  from 
  @schema.@c_table_prefixCOHORT_DETAILS cd
  
  inner join 
  @schema.@c_table_prefixCOVARIATES c
  on 
  cd.TARGET_COHORT_ID = c.TARGET_COHORT_ID
  and cd.OUTCOME_COHORT_ID = c.OUTCOME_COHORT_ID
  and cd.COHORT_TYPE = c.COHORT_TYPE
  and cd.database_id = c.database_id 
  and cd.setting_id = c.setting_id 
  
  inner join
  (select * from @schema.@c_table_prefixCOVARIATE_REF 
    where analysis_id in (@analysis_ids)
  ) coi
  on 
  c.database_id = coi.database_id
  and c.setting_id = coi.setting_id
  and c.covariate_id = coi.covariate_id
  
  inner join 
  @schema.@c_table_prefixsettings s
  on 
  s.setting_id = c.setting_id
  and s.database_id = c.database_id
  
  where 
  cd.COHORT_TYPE = 'Exclude'
  {@use_target}?{ and c.TARGET_COHORT_ID in (@target_id)}
  {@use_outcome}?{ and c.OUTCOME_COHORT_ID in (@outcome_id)}
) e

on 
t.database_id = e.database_id 
and t.TARGET_COHORT_ID = e.TARGET_COHORT_ID
and t.outcome_COHORT_ID = e.outcome_COHORT_ID
and t.min_prior_observation = e.min_prior_observation
and t.outcome_washout_days = e.outcome_washout_days
and t.covariate_name = e.covariate_name
and t.covariate_id = e.covariate_id

  inner join
  @schema.@database_table d
  on 
  t.database_id = d.database_id

  inner join 
  @schema.@cg_table_prefixcohort_definition target
  on 
  target.cohort_definition_id = t.target_cohort_ID
    
  inner join 
  @schema.@cg_table_prefixcohort_definition outcome
  on 
  outcome.cohort_definition_id = t.outcome_cohort_ID

;
"

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
  analysis_ids = paste0(analysisIds, collapse = ',')
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
#' @param analysisIds The feature extraction analysis ID of interest (e.g., 201 is condition)
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
    analysisIds = c(3) # TODO enable this to be NULL?
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
  
  caseCounts <- getCaseCounts(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix,
    cgTablePrefix = cgTablePrefix,
    databaseTable = databaseTable,
    targetIds = targetId,
    outcomeIds = outcomeId
  )
  
  targetCounts <- getTargetCounts(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix,
    cgTablePrefix = cgTablePrefix,
    databaseTable = databaseTable,
    targetIds = targetId,
    outcomeIds = outcomeId
  )
    
  caseFeatures <- getCaseBinaryFeatures(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix,
    cgTablePrefix = cgTablePrefix,
    databaseTable = databaseTable,
    targetIds = targetId,
    outcomeIds = outcomeId,
    analysisIds = analysisIds
  )
  
  targetFeatures <- getTargetBinaryFeatures(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix,
    cgTablePrefix = cgTablePrefix,
    databaseTable = databaseTable,
    targetIds = targetId,
    outcomeIds = outcomeId,
    analysisIds = analysisIds
  )
  
  result <- processBinaryRiskFactorFeatures(
    caseCounts = caseCounts,
    targetCounts = targetCounts,
    caseFeatures = caseFeatures,
    targetFeatures = targetFeatures
  )

return(result)
}


# function that takes the counts and features and calculates the smd
processBinaryRiskFactorFeatures <- function(
    caseCounts = caseCounts,
    targetCounts = targetCounts,
    caseFeatures = caseFeatures,
    targetFeatures = targetFeatures
){
  
  allData <- c()
  
  # TODO:what if no cases?
  params <- unique(
    caseCounts %>% dplyr::select(
      "databaseName",
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
      .data$minPriorObservation == !!minPriorObservation &
        .data$outcomeWashoutDays == !!outcomeWashoutDays
    )
  
  nonCaseCount <- targetCount$personCount - caseCount$personCount
  
  ## now extract the features
  tempCases <- caseFeatures %>% 
    dplyr::filter(.data$databaseName == !!databaseName &
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
      )
  tempTarget <- targetFeatures %>% 
    dplyr::filter(.data$databaseName == !!databaseName &
                    .data$minPriorObservation == !!minPriorObservation &
                    .data$outcomeWashoutDays == !!outcomeWashoutDays 
    )
  
  tempData <- tempTarget %>% 
    dplyr::left_join(
      y = tempCases, 
      by = c(
        "databaseName",
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
      SMD = .data$meanDiff/sqrt((.data$std1^2 + .data$std2^2)/2),
      absSMD = abs(.data$meanDiff/sqrt((.data$std1^2 + .data$std2^2)/2))
    ) 
  
  # TODO: add smd
  
  tempData <- tempData %>% 
    dplyr::select(
    "databaseName",
    "targetName",
    "targetCohortId",
    "outcomeName",
    "outcomeCohortId",
    "minPriorObservation",
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
    "SMD",
    "absSMD"
  )
  
  allData <- rbind(allData, tempData)
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
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
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
    analysisIds = NULL
){
  
  sql <-  
    "
select 
d.CDM_SOURCE_ABBREVIATION as database_name,
target.cohort_name as target_name,
t.TARGET_COHORT_ID,
t.min_prior_observation,
t.covariate_name,
t.covariate_id,
t.count_value,
t.min_value,
t.max_value,
t.average_value,
t.standard_deviation,
t.median_value,
t.p_10_value,
t.p_25_value,
t.p_75_value,
t.p_90_value
 
FROM 

(select 
c.database_id,
cd.TARGET_COHORT_ID,
s.min_prior_observation,
coi.covariate_name,
coi.covariate_id,
c.count_value,
c.min_value,
c.max_value,
c.average_value,
c.standard_deviation,
c.median_value,
c.p_10_value,
c.p_25_value,
c.p_75_value,
c.p_90_value

from @schema.@c_table_prefixCOVARIATES_CONTINUOUS c
 inner join
(
select * from @schema.@c_table_prefixCOVARIATE_REF 
{@use_analysis}?{ where analysis_id in (@analysis_ids)}
) coi

on 
c.database_id = coi.database_id and
c.setting_id = coi.setting_id and
c.covariate_id = coi.covariate_id

inner join
@schema.@c_table_prefixCOHORT_DETAILS cd

on cd.TARGET_COHORT_ID = c.TARGET_COHORT_ID
and cd.COHORT_TYPE = c.COHORT_TYPE
and cd.database_id = c.database_id 
and cd.setting_id = c.setting_id 

inner join @schema.@c_table_prefixsettings s
on s.setting_id = c.setting_id
and s.database_id = c.database_id

where 
cd.COHORT_TYPE = 'Target'
{@use_target}?{ and c.TARGET_COHORT_ID in (@target_id)}
) t

  inner join
  @schema.@database_table d
  on 
  t.database_id = d.database_id

  inner join 
  @schema.@cg_table_prefixcohort_definition target
  on 
  target.cohort_definition_id = t.target_cohort_ID
    
;
"

result <- connectionHandler$queryDb(
  sql = sql,
  schema = schema,
  target_id = paste0(targetIds, collapse = ','),
  use_target = !is.null(targetIds),
  c_table_prefix = cTablePrefix,
  cg_table_prefix = cgTablePrefix,
  database_table = databaseTable,
  use_analysis = !is.null(analysisIds),
  analysis_ids = paste0(analysisIds, collapse = ',')
)

return(result)
}

#' Extract aggregate statistics of continuous feature analysis IDs of interest for targets
#' @description
#' This function extracts the continuous feature extraction results for cases corresponding to specified target and outcome cohorts.
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
#' @param analysisIds The feature extraction analysis ID of interest (e.g., 201 is condition)
#' @family Characterization
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{targetName the target cohort name}
#'  \item{targetId the target cohort unique identifier}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome unique identifier}
#'  \item{minPriorObservation the minimum required observation days prior to index for an entry}
#'  \item{outcomeWashoutDays patients with the outcome occurring within this number of days prior to index are excluded (NA means no exclusion)}
#'  \item{riskWindowStart the time at risk start point}
#'  \item{riskWindowEnd the time at risk end point}
#'  \item{startAnchor the time at risk start point offset}
#'  \item{endAnchor the time at risk end point offset}
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
#' } 
#' 
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' ccf <- getCaseContinuousFeatures(
#' connectionHandler = connectionHandler, 
#' schema = 'main'
#' )
#' 
getCaseContinuousFeatures <- function(
    connectionHandler,
    schema,
    cTablePrefix = 'c_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    outcomeIds = NULL,
    analysisIds = NULL
){
  
  sql <-  
    "
select 
d.CDM_SOURCE_ABBREVIATION as database_name,
target.cohort_name as target_name,
t.TARGET_COHORT_ID,
outcome.cohort_name as outcome_name,
t.Outcome_COHORT_ID,
t.min_prior_observation,
t.outcome_washout_days,
t.risk_window_start,
t.risk_window_end,
t.start_anchor,
t.end_anchor,
t.covariate_name,
t.covariate_id,
t.count_value,
t.min_value,
t.max_value,
t.average_value,
t.standard_deviation,
t.median_value,
t.p_10_value,
t.p_25_value,
t.p_75_value,
t.p_90_value
 
FROM 

(select 
c.database_id,
c.TARGET_COHORT_ID,
c.Outcome_COHORT_ID,
s.min_prior_observation,
s.outcome_washout_days,
s.risk_window_start,
s.risk_window_end,
s.start_anchor,
s.end_anchor,
coi.covariate_name,
coi.covariate_id,
c.count_value,
c.min_value,
c.max_value,
c.average_value,
c.standard_deviation,
c.median_value,
c.p_10_value,
c.p_25_value,
c.p_75_value,
c.p_90_value

from @schema.@c_table_prefixCOVARIATES_CONTINUOUS c
 inner join
(
select * from @schema.@c_table_prefixCOVARIATE_REF 
{@use_analysis}?{ where analysis_id in (@analysis_ids)}
) coi

on 
c.database_id = coi.database_id and
c.setting_id = coi.setting_id and
c.covariate_id = coi.covariate_id

inner join
@schema.@c_table_prefixCOHORT_DETAILS cd

on cd.TARGET_COHORT_ID = c.TARGET_COHORT_ID
and cd.OUTCOME_COHORT_ID = c.OUTCOME_COHORT_ID
and cd.COHORT_TYPE = c.COHORT_TYPE
and cd.database_id = c.database_id 
and cd.setting_id = c.setting_id 

inner join @schema.@c_table_prefixsettings s
on s.setting_id = c.setting_id
and s.database_id = c.database_id

where 
cd.COHORT_TYPE = 'Cases'
{@use_target}?{ and c.TARGET_COHORT_ID in (@target_id)}
{@use_outcome}?{ and c.outcome_cohort_id in (@outcome_id)}
) t

  inner join
  @schema.@database_table d
  on 
  t.database_id = d.database_id

  inner join 
  @schema.@cg_table_prefixcohort_definition target
  on 
  target.cohort_definition_id = t.target_cohort_ID
    
  inner join 
  @schema.@cg_table_prefixcohort_definition outcome
  on 
  outcome.cohort_definition_id = t.outcome_cohort_ID

;
"

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
  analysis_ids = paste0(analysisIds, collapse = ',')
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
    analysisIds = NULL
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
  
  caseFeatures <- getCaseContinuousFeatures(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix,
    cgTablePrefix = cgTablePrefix,
    databaseTable = databaseTable,
    targetIds = targetId,
    outcomeIds = outcomeId,
    analysisIds = analysisIds
  )
  
  targetFeatures <- getTargetContinuousFeatures(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = cTablePrefix,
    cgTablePrefix = cgTablePrefix,
    databaseTable = databaseTable,
    targetIds = targetId,
    analysisIds = analysisIds
  )
  
  result <- processContinuousRiskFactorFeatures(
    caseFeatures = caseFeatures,
    targetFeatures = targetFeatures
  )
  
  return(result)
}


# function that takes the counts and features and calculates the smd
processContinuousRiskFactorFeatures <- function(
    caseFeatures = caseFeatures,
    targetFeatures = targetFeatures
){
  
  # get outcomes and outcomewashout
  outcomes <- unique(caseFeatures[,c('outcomeCohortId','outcomeWashoutDays')])
  
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
            .data$outcomeWashoutDays == outcomes[i,]$outcomeWashoutDays
        ),
      
      by = c('databaseName','targetName','targetCohortId','minPriorObservation',
             'covariateName', 'covariateId'),
      all.x = TRUE
        )
    
    allData <- rbind(allData, res)
  }
  
  allData <- allData %>% dplyr::mutate(
        SMD = (.data$caseAverageValue - .data$targetAverageValue)/sqrt((.data$caseStandardDeviation^2 + .data$targetStandardDeviation^2)/2),
        absSMD = abs((.data$caseAverageValue - .data$targetAverageValue)/sqrt((.data$caseStandardDeviation^2 + .data$targetStandardDeviation^2)/2))
      ) 

  return(allData) 
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
    outcomeId = NULL
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
  
  sql <-  
    "
SELECT 
cov.database_id,
 d.CDM_SOURCE_ABBREVIATION as database_name,
 target.cohort_name as target_name,
cov.TARGET_COHORT_ID,
outcome.cohort_name as outcome_name,
cov.Outcome_COHORT_ID,
  case 
  when cov.cohort_type = 'CasesBefore' then 'Before'
  when cov.cohort_type = 'CasesBetween' then 'During'
  when cov.cohort_type = 'CasesAfter' then 'After'
  end as type, 
  cr.covariate_name, 
  cr.covariate_id, 
  s.min_prior_observation, 
  s.outcome_washout_days,
  s.case_post_outcome_duration, 
  s.case_pre_target_duration,
  s.risk_window_start,
  s.start_anchor,
  s.risk_window_end,
  s.end_anchor,
  cov.sum_value, 
  cov.average_value 
          from
          @schema.@c_table_prefixcovariates cov
          inner join  @schema.@c_table_prefixcovariate_ref cr
          on cov.setting_id = cr.setting_id and 
          cov.database_id = cr.database_id and 
          cov.covariate_id = cr.covariate_id
          
          inner join @schema.@c_table_prefixsettings s
          on cov.setting_id = s.setting_id
          and cov.database_id = s.database_id
          
            inner join
  @schema.@database_table d
  on 
  cov.database_id = d.database_id
  
    inner join 
  @schema.@cg_table_prefixcohort_definition target
  on 
  target.cohort_definition_id = cov.target_cohort_ID
    
  inner join 
  @schema.@cg_table_prefixcohort_definition outcome
  on 
  outcome.cohort_definition_id = cov.outcome_cohort_ID

          where cov.target_cohort_id = @target_id
          and cov.outcome_cohort_id = @outcome_id
          and cov.cohort_type in ('CasesBetween','CasesAfter','CasesBefore')
          and cr.analysis_id in (109, 110, 217, 218, 305, 417, 418, 505, 605, 713, 805, 926, 927)
;
"

result <- connectionHandler$queryDb(
  sql = sql,
  schema = schema,
  target_id = paste0(targetId, collapse = ','),
  outcome_id = paste0(outcomeId, collapse = ','),
  c_table_prefix = cTablePrefix,
  cg_table_prefix = cgTablePrefix,
  database_table = databaseTable
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
    outcomeId = NULL
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
  
  sql <-  
    "
SELECT 
cov.database_id,
 d.CDM_SOURCE_ABBREVIATION as database_name,
 target.cohort_name as target_name,
cov.TARGET_COHORT_ID,
outcome.cohort_name as outcome_name,
cov.Outcome_COHORT_ID,
  case 
  when cov.cohort_type = 'CasesBefore' then 'Before'
  when cov.cohort_type = 'CasesBetween' then 'During'
  when cov.cohort_type = 'CasesAfter' then 'After'
  end as type, 
  cr.covariate_name, 
  cr.covariate_id, 
  s.min_prior_observation, 
  s.outcome_washout_days,
  s.case_post_outcome_duration, 
  s.case_pre_target_duration,
  s.risk_window_start,
  s.start_anchor,
  s.risk_window_end,
  s.end_anchor,
  cov.count_value, 
  cov.min_value,
cov.max_value,
cov.average_value,
cov.standard_deviation,
cov.median_value,
cov.p_10_value,
cov.p_25_value,
cov.p_75_value,
cov.p_90_value

          from
          @schema.@c_table_prefixcovariates_continuous cov
          inner join  @schema.@c_table_prefixcovariate_ref cr
          on cov.setting_id = cr.setting_id and 
          cov.database_id = cr.database_id and 
          cov.covariate_id = cr.covariate_id
          
          inner join @schema.@c_table_prefixsettings s
          on cov.setting_id = s.setting_id
          and cov.database_id = s.database_id
          
            inner join
  @schema.@database_table d
  on 
  cov.database_id = d.database_id
  
    inner join 
  @schema.@cg_table_prefixcohort_definition target
  on 
  target.cohort_definition_id = cov.target_cohort_ID
    
  inner join 
  @schema.@cg_table_prefixcohort_definition outcome
  on 
  outcome.cohort_definition_id = cov.outcome_cohort_ID

          where cov.target_cohort_id = @target_id
          and cov.outcome_cohort_id = @outcome_id
          and cov.cohort_type in ('CasesBetween','CasesAfter','CasesBefore')
;
"
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    target_id = paste0(targetId, collapse = ','),
    outcome_id = paste0(outcomeId, collapse = ','),
    c_table_prefix = cTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable
  )
  
  return(result)
}