# cohort method

#' Extract the cohort method results 
#' @description
#' This function extracts the single database cohort method estimates for results that can be unblinded and have a calibrated RR
#'
#' @details
#' Specify the connectionHandler, the schema and the target/comparator/outcome cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cmTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetIds
#' @template outcomeIds
#' @template comparatorIds
#' @family Estimation
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{analysisId the analysis design unique identifier}
#'  \item{description the analysis design description}
#'  \item{targetName the target cohort name}
#'  \item{targetId the target cohort unique identifier}
#'  \item{comparatorName the comparator cohort name}
#'  \item{comparatorId the comparator cohort unique identifier}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome unique identifier}
#'  \item{calibratedRr the calibrated relative risk}
#'  \item{calibratedRrCi95Lb the calibrated relative risk 95 percent confidence interval lower bound}
#'  \item{calibratedRrCi95Ub the calibrated relative risk 95 percent confidence interval upper bound}
#'  \item{calibratedP the two sided calibrated p value}
#'  \item{calibratedOneSidedP the one sided calibrated p value}
#'  \item{calibratedLogRr the calibrated relative risk logged}
#'  \item{calibratedSeLogRr the standard error of the calibrated relative risk logged}
#'  \item{targetSubjects the number of people in the target cohort}
#'  \item{comparatorSubjects the number of people in the comparator cohort}
#'  \item{targetDays the total number of days at risk across the target cohort people}
#'  \item{comparatorDays the total number of days at risk across the comparator cohort people}
#'  \item{targetOutcomes the total number of outcomes occuring during the time at risk for the target cohort people}
#'  \item{comparatorOutcomes the total number of outcomes occuring during the time at risk for the comparator cohort people}
#'  \item{targetEstimator ...}
#'  } 
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cmEst <- getCMEstimation(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   targetIds = 1,
#'   outcomeIds = 3
#' )
#' 
getCMEstimation <- function(
    connectionHandler,
    schema,
    cmTablePrefix = 'cm_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    outcomeIds = NULL,
    comparatorIds = NULL
){
  

  sql <- "select 
  db.cdm_source_abbreviation as database_name, 
  r.analysis_id, 
  a.description,
  
  c1.cohort_name as target_name,
  r.target_id,
  c2.cohort_name as comparator_name,
  r.comparator_id, 
  c3.cohort_name as outcome_name,
  r.outcome_id, 
  
  case when COALESCE(unblind.unblind, 0) = 0 then NULL else r.calibrated_rr end calibrated_rr, 
  case when COALESCE(unblind.unblind, 0) = 0 then NULL else r.calibrated_ci_95_lb end calibrated_ci_95_lb, 
  case when COALESCE(unblind.unblind, 0) = 0 then NULL else r.calibrated_ci_95_ub end calibrated_ci_95_ub, 
  case when COALESCE(unblind.unblind, 0) = 0 then NULL else r.calibrated_p end calibrated_p, 
  case when COALESCE(unblind.unblind, 0) = 0 then NULL else r.calibrated_one_sided_p end calibrated_one_sided_p,
  case when COALESCE(unblind.unblind, 0) = 0 then NULL else r.calibrated_log_rr end calibrated_log_rr, 
  case when COALESCE(unblind.unblind, 0) = 0 then NULL else r.calibrated_se_log_rr end calibrated_se_log_rr,
  
  r.target_subjects,
  r.comparator_subjects,
  r.target_days,
  r.comparator_days,
  r.target_outcomes,
  r.comparator_outcomes,
  
  r.target_estimator
  
  from 
   @schema.@cm_table_prefixresult as r
   inner join 
   @schema.@cm_table_prefixtarget_comparator_outcome as tco
   on 
   r.target_id = tco.target_id and 
   r.comparator_id = tco.comparator_id and 
   r.outcome_id = tco.outcome_id
   
   inner join
   
   @schema.@cm_table_prefixdiagnostics_summary as unblind
   on
   r.analysis_id = unblind.analysis_id and 
   r.target_id = unblind.target_id and 
   r.comparator_id = unblind.comparator_id and 
   r.outcome_id = unblind.outcome_id and 
   r.database_id = unblind.database_id
   
   inner join
   @schema.@database_table as db
   on db.database_id = r.database_id
   
   inner join
   @schema.@cg_table_prefixcohort_definition as c1
   on c1.cohort_definition_id = r.target_id
   
   inner join
   @schema.@cg_table_prefixcohort_definition as c2
   on c2.cohort_definition_id = r.comparator_id
   
   inner join
   @schema.@cg_table_prefixcohort_definition as c3
   on c3.cohort_definition_id = r.outcome_id
   
   inner join
   @schema.@cm_table_prefixanalysis as a
   on a.analysis_id = r.analysis_id
   
   where 
   tco.outcome_of_interest = 1
   {@restrict_target} ? { and r.target_id in (@target_id)}
   {@restrict_outcome} ? {and r.outcome_id in (@outcome_id)}
   {@restrict_comparator} ? { and r.comparator_id in (@comparator_id)}
  ;"
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    database_table = databaseTable,
    cm_table_prefix = cmTablePrefix,
    cg_table_prefix = cgTablePrefix,
    outcome_id = paste0(outcomeIds, collapse = ','),
    restrict_outcome = !is.null(outcomeIds),
    target_id = paste0(targetIds, collapse = ','),
    restrict_target = !is.null(targetIds),
    comparator_id = paste(comparatorIds, collapse = ','),
    restrict_comparator = !is.null(comparatorIds)
  )
  
  return(result)
}

#' Extract the cohort method diagostic results 
#' @description
#' This function extracts the cohort method diagnostics that examine whether the analyses were sufficiently powered
#' and checks for different types of bias.
#'
#' @details
#' Specify the connectionHandler, the schema and the target/comparator/outcome cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cmTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetIds
#' @template outcomeIds
#' @template comparatorIds
#' @family Estimation
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{analysisId the analysis unique identifier}
#'  \item{description a description of the analysis}
#'  \item{targetName the target cohort name}
#'  \item{targetId the target cohort unique identifier}
#'  \item{comparatorName the comparator cohort name}
#'  \item{comparatorId the comparator cohort unique identifier}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome cohort unique identifier}
#'  \item{maxSdm max allowed standardized difference of means when comparing the target to the comparator after PS adjustment for the ballance diagnostic diagnostic to pass.}
#'  \item{sharedMaxSdm max allowed standardized difference of means when comparing the target to the comparator after PS adjustment for the ballance diagnostic diagnostic to pass.}
#'  \item{equipoise the bounds on the preference score to determine whether a subject is in equipoise.}
#'  \item{mdrr the maximum passable minimum detectable relative risk (mdrr) value.  If the mdrr is greater than this the diagnostics will fail.}
#'  \item{attritionFraction (depreciated) the minmum attrition before the diagnostics fails.}
#'  \item{ease The expected absolute systematic error (ease) measures residual bias.}
#'  \item{balanceDiagnostic whether the balance diagnostic passed or failed.}
#'  \item{sharedBalanceDiagnostic whether the shared balance diagnostic passed or failed.}
#'  \item{equipoiseDiagnostic whether the equipose diagnostic passed or failed.}
#'  \item{mdrrDiagnostic whether the mdrr (power) diagnostic passed or failed.}
#'  \item{attritionDiagnostic (depreciated) whether the attrition diagnostic passed or failed.}
#'  \item{easeDiagnostic whether the ease diagnostic passed or failed.}
#'  \item{unblind whether the results can be unblinded.}
#'  \item{summaryValue summary of diagnostics results. FAIL, PASS or number of warnings.}
#'  } 
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cmDiag <- getCmDiagnosticsData(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   targetIds = 1,
#'   outcomeIds = 3
#' )
#' 
getCmDiagnosticsData <- function(
    connectionHandler,
    schema,
    cmTablePrefix = 'cm_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    outcomeIds = NULL,
    comparatorIds = NULL
){
  
  sql <- "
    SELECT DISTINCT
      dmd.cdm_source_abbreviation database_name,
      cma.analysis_id,
      cma.description,
      cgcd1.cohort_name target_name,
      cmds.target_id,
      cgcd2.cohort_name comparator_name,
      cmds.comparator_id,
      cgcd3.cohort_name outcome_name,
      cmds.outcome_id,
      
      cmds.max_sdm,
      cmds.shared_max_sdm,
      cmds.equipoise,
      cmds.mdrr,
      cmds.attrition_fraction,
      cmds.ease,
      cmds.balance_diagnostic,
      cmds.shared_balance_diagnostic, -- added back
      cmds.equipoise_diagnostic,
      cmds.mdrr_diagnostic,
      cmds.attrition_diagnostic,
      cmds.ease_diagnostic,
      cmds.unblind
    FROM
      @schema.@cm_table_prefixdiagnostics_summary cmds
      INNER JOIN @schema.@cm_table_prefixanalysis cma ON cmds.analysis_id = cma.analysis_id
      INNER JOIN @schema.@database_table dmd ON dmd.database_id = cmds.database_id
      INNER JOIN @schema.@cg_table_prefixcohort_definition cgcd1 ON cmds.target_id = cgcd1.cohort_definition_id
      INNER JOIN @schema.@cg_table_prefixcohort_definition cgcd2 ON cmds.comparator_id = cgcd2.cohort_definition_id
      INNER JOIN @schema.@cg_table_prefixcohort_definition cgcd3 ON cmds.outcome_id = cgcd3.cohort_definition_id
      
      {@use_target | @use_outcome | @use_comparator }?{ where } 
      {@use_target}?{cgcd1.cohort_definition_id in (@targets)}
      
      {@use_target & @use_comparator}?{ and } 
      {@use_comparator}?{cgcd2.cohort_definition_id in (@comparators)}
      
      {(@use_target | @use_comparator) & @use_outcome}?{ and } 
      {@use_outcome}?{cgcd3.cohort_definition_id in (@outcomes)}
      ;
      "
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cm_table_prefix = cmTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable,
    targets = paste0(targetIds, collapse = ','),
    use_target = !is.null(targetIds),
    comparators = paste0(comparatorIds, collapse = ','),
    use_comparator = !is.null(comparatorIds),
    outcomes = paste0(outcomeIds, collapse = ','),
    use_outcome = !is.null(outcomeIds)
  )
  
  # adding percent fail for summary
  result$summaryValue <- apply(
    X = result[, grep('Diagnostic', colnames(result))], 
    MARGIN = 1, 
    FUN = function(x){
      
      if(sum(x %in% c('FAIL'))>0){
        return('Fail')
      } else if(sum(x %in% c('WARNING')) >0){
        return(sum(x %in% c('WARNING')))
      } else{
        return('Pass')
      }
    }
  )
  
  return(
    result
  )
}

#' Extract the cohort method meta analysis results
#' @description
#' This function extracts any meta analysis estimation results for cohort method.
#'
#' @details
#' Specify the connectionHandler, the schema and the target/comparator/outcome cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cmTablePrefix
#' @template cgTablePrefix
#' @template esTablePrefix
#' @template targetIds
#' @template outcomeIds
#' @template comparatorIds
#' @family Estimation
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{analysisId the analysis unique identifier}
#'  \item{description a description of the analysis}
#'  \item{targetName the target cohort name}
#'  \item{targetId the target cohort unique identifier}
#'  \item{comparatorName the comparator cohort name}
#'  \item{comparatorId the comparator cohort unique identifier}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome cohort unique identifier}
#'  \item{calibratedRr the calibrated relative risk}
#'  \item{calibratedRrCi95Lb the calibrated relative risk 95 percent confidence interval lower bound}
#'  \item{calibratedRrCi95Ub the calibrated relative risk 95 percent confidence interval upper bound}
#'  \item{calibratedP the two sided calibrated p value}
#'  \item{calibratedOneSidedP the one sided calibrated p value}
#'  \item{calibratedLogRr the calibrated relative risk logged}
#'  \item{calibratedSeLogRr the standard error of the calibrated relative risk logged}
#'  
#'  \item{targetSubjects the number of people in the target cohort across included database}
#'  \item{comparatorSubjects the number of people in the comparator cohort across included database}
#'  \item{targetDays the total number of days at risk across the target cohort people across included database}
#'  \item{comparatorDays the total number of days at risk across the comparator cohort people across included database}
#'  \item{targetOutcomes the total number of outcomes occuring during the time at risk for the target cohort people across included database}
#'  \item{comparatorOutcomes the total number of outcomes occuring during the time at risk for the comparator cohort people across included database}
#'  
#'  \item{nDatabases the number of databases included}
#'  } 
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cmMeta <- getCmMetaEstimation(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   targetIds = 1,
#'   outcomeIds = 3
#' )
#' 
getCmMetaEstimation <- function(
    connectionHandler,
    schema,
    cmTablePrefix = 'cm_',
    cgTablePrefix = 'cg_',
    esTablePrefix = 'es_',
    targetIds = NULL,
    outcomeIds = NULL,
    comparatorIds = NULL
){

  sql <- "select 
  ev.evidence_synthesis_description as database_name,
  r.analysis_id,
  a.description,
  c1.cohort_name as target_name,
  r.target_id, 
  c2.cohort_name as comparator_name,
  r.comparator_id,
  c3.cohort_name as outcome_name,
  r.outcome_id, 
  r.calibrated_rr, r.calibrated_ci_95_lb, r.calibrated_ci_95_ub,
  r.calibrated_p, r.calibrated_one_sided_p,
  r.calibrated_log_rr, r.calibrated_se_log_rr,
  r. target_subjects, r.comparator_subjects, r.target_days,
  r.comparator_days, r.target_outcomes, r.comparator_outcomes,
  r.n_databases

  from 
   @schema.@es_table_prefixcm_result as r
   inner join 
   @schema.@cm_table_prefixtarget_comparator_outcome as tco
   on 
   r.target_id = tco.target_id and 
   r.comparator_id = tco.comparator_id and 
   r.outcome_id = tco.outcome_id
   
   inner join
   
   @schema.@es_table_prefixcm_diagnostics_summary as unblind
   on
   r.analysis_id = unblind.analysis_id and 
   r.target_id = unblind.target_id and 
   r.comparator_id = unblind.comparator_id and 
   r.outcome_id = unblind.outcome_id 
   
   inner join
   @schema.@cg_table_prefixcohort_definition as c1
   on c1.cohort_definition_id = r.target_id
   
   inner join
   @schema.@cg_table_prefixcohort_definition as c2
   on c2.cohort_definition_id = r.comparator_id
   
   inner join
   @schema.@cg_table_prefixcohort_definition as c3
   on c3.cohort_definition_id = r.outcome_id
   
   inner join
   @schema.@cm_table_prefixanalysis as a
   on a.analysis_id = r.analysis_id
   
   inner join
   @schema.@es_table_prefixanalysis as ev
   on ev.evidence_synthesis_analysis_id = r.evidence_synthesis_analysis_id
   
   where 
   r.calibrated_rr != 0 and
   tco.outcome_of_interest = 1 and
   unblind.unblind = 1
   {@include_target}?{and r.target_id in (@target_id)}
   {@include_outcome}?{and r.outcome_id in (@outcome_id)}
   {@include_comparator}?{and r.comparator_id in (@comparator_id)}
  ;"
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cm_table_prefix = cmTablePrefix,
    cg_table_prefix = cgTablePrefix,
    es_table_prefix = esTablePrefix,
    target_id = paste0(targetIds, collapse = ','),
    include_target = !is.null(targetIds),
    outcome_id = paste0(outcomeIds, collapse = ','),
    include_outcome = !is.null(outcomeIds),
    comparator_id = paste0(comparatorIds, collapse = ','),
    include_comparator = !is.null(comparatorIds)
  )
  
  return(unique(result))
}

#' Extract the self controlled case series (sccs) results 
#' @description
#' This function extracts the single database sccs estimates
#'
#' @details
#' Specify the connectionHandler, the schema and the target/outcome cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template sccsTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetIds
#' @template outcomeIds
#' @family Estimation
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the database name}
#'  \item{analysisId the analysis unique identifier}
#'  \item{description an analysis description}
#'  \item{targetName the target name}
#'  \item{targetId the target cohort id}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome cohort id}
#'  \item{covariateName whether main or secondary analysis}
#'  \item{outcomeSubjects The number of subjects with at least one outcome.}
#'  \item{outcomeEvents The number of outcome events.}
#'  \item{outcomeObservationPeriods The number of observation periods containing at least one outcome.}
#'  \item{covariateSubjects The number of subjects having the covariate.}
#'  \item{covariateDays The total covariate time in days.}
#'  \item{covariateEras The number of continuous eras of the covariate.}
#'  \item{covariateOutcomes The number of outcomes observed during the covariate time.}
#'  \item{observedDays The number of days subjects were observed.}
#'  \item{rr the relative risk}
#'  \item{ci95Lb the lower bound of the 95 percent confidence interval for the relative risk}
#'  \item{ci95Ub the upper bound of the 95 percent confidence interval for the relative risk}
#'  \item{p the p-value for the relative risk}
#'  \item{logRr the log of the relative risk}
#'  \item{seLogRr the standard error or the log of the relative risk}
#'  \item{calibratedRr the calibrated relative risk}
#'  \item{calibratedCi95Lb the lower bound of the 95 percent confidence interval for the calibrated relative risk}
#'  \item{calibratedCi95Ub the upper bound of the 95 percent confidence interval for the calibrated relative risk}
#'  \item{calibratedP the calibrated p-value}
#'  \item{calibratedLogRr the calibrated log of the relative risk}
#'  \item{calibratedSeLogRr the calibrated log of the relative risk standard error}
#'  \item{llr The log of the likelihood ratio (of the MLE vs the null hypothesis of no effect).}
#'  \item{mdrr The minimum detectable relative risk.}
#'  \item{unblind Whether the results can be unblinded}
#'  } 
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' sccsEst <- getSccsEstimation(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   targetIds = 1,
#'   outcomeIds = 3
#' )
#' 
getSccsEstimation <- function(
    connectionHandler,
    schema,
    sccsTablePrefix = 'sccs_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    outcomeIds = NULL
) {

  sql <- "
  SELECT
  
    ds.cdm_source_abbreviation as database_name,
    sr.analysis_id,
    a.description,
    cg2.cohort_name as target_name,
    sc.era_id as target_id,
    cg1.cohort_name as outcome_name,
    eos.outcome_id,
    sc.covariate_name,
    
  sr.outcome_subjects,
  sr.outcome_events,
  sr.outcome_observation_periods,
  sr.covariate_subjects, 
  sr.covariate_days,
  sr.covariate_eras,
  sr.covariate_outcomes,
  sr.observed_days,

  case when COALESCE(sds.unblind, 0) = 0 then NULL else sr.rr end rr,
  case when COALESCE(sds.unblind, 0) = 0 then NULL else sr.ci_95_lb end ci_95_lb,
  case when COALESCE(sds.unblind, 0) = 0 then NULL else sr.ci_95_ub end ci_95_ub,
  case when COALESCE(sds.unblind, 0) = 0 then NULL else sr.p end p,
  case when COALESCE(sds.unblind, 0) = 0 then NULL else sr.log_rr end log_rr,
  case when COALESCE(sds.unblind, 0) = 0 then NULL else sr.se_log_rr end se_log_rr,
  case when COALESCE(sds.unblind, 0) = 0 then NULL else sr.calibrated_rr end calibrated_rr,
  case when COALESCE(sds.unblind, 0) = 0 then NULL else sr.calibrated_ci_95_lb end calibrated_ci_95_lb,
  case when COALESCE(sds.unblind, 0) = 0 then NULL else sr.calibrated_ci_95_ub end calibrated_ci_95_ub,
  case when COALESCE(sds.unblind, 0) = 0 then NULL else sr.calibrated_p end calibrated_p,
  case when COALESCE(sds.unblind, 0) = 0 then NULL else sr.calibrated_log_rr end calibrated_log_rr,
  case when COALESCE(sds.unblind, 0) = 0 then NULL else sr.calibrated_se_log_rr end calibrated_se_log_rr,
  
  case when COALESCE(sds.unblind, 0) = 0 then NULL else sr.llr end llr,


    sds.mdrr,
  --sds.ease,
  --sds.time_trend_p,
  --sds.pre_exposure_p,
  --sds.mdrr_diagnostic,
  --sds.ease_diagnostic,
  --sds.time_trend_diagnostic,
  --sds.pre_exposure_diagnostic,
  sds.unblind
  
  FROM @schema.@sccs_table_prefixresult sr
  INNER JOIN 
  @schema.@database_table ds 
  ON sr.database_id = ds.database_id
  INNER JOIN 
  @schema.@sccs_table_prefixdiagnostics_summary sds ON (
    sds.exposures_outcome_set_id = sr.exposures_outcome_set_id AND
    sds.database_id = sr.database_id AND
    sds.analysis_id = sr.analysis_id AND
    sds.covariate_id = sr.covariate_id
  )
  INNER JOIN 
  @schema.@sccs_table_prefixcovariate sc ON (
    sc.exposures_outcome_set_id = sr.exposures_outcome_set_id AND
    sc.database_id = sr.database_id AND
    sc.analysis_id = sr.analysis_id AND
    sc.covariate_id = sr.covariate_id
  )
  INNER JOIN @schema.@sccs_table_prefixexposures_outcome_set eos
  ON 
  eos.exposures_outcome_set_id = sr.exposures_outcome_set_id
  INNER JOIN
  @schema.@sccs_table_prefixanalysis a
  on a.analysis_id = sr.analysis_id
  
  inner join 
  @schema.@cg_table_prefixcohort_definition cg1
	on cg1.cohort_definition_id = eos.outcome_id
	
	inner join 
  @schema.@cg_table_prefixcohort_definition cg2
	on cg2.cohort_definition_id = sc.era_id
  
  WHERE
  1 = 1 
  {@restrict_outcome}?{ and eos.outcome_id IN (@outcome_ids)}
  {@restrict_target}?{ and sc.era_id IN (@exposure_ids)}
  ;
  "
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    database_table = databaseTable,
    sccs_table_prefix = sccsTablePrefix,
    cg_table_prefix = cgTablePrefix,
    #database_ids = paste(quoteLiterals(databaseIds), collapse = ','),
    #analysis_ids = paste(analysisIds, collapse = ','),
    outcome_ids = paste(outcomeIds, collapse = ','),
    restrict_outcome = !is.null(outcomeIds),
    exposure_ids = paste(targetIds, collapse = ','),
    restrict_target = !is.null(targetIds)
  )
  
  return(result)
}

#' Extract the self controlled case series (sccs) diagostic results 
#' @description
#' This function extracts the sccs diagnostics that examine whether the analyses were sufficiently powered
#' and checks for different types of bias.
#'
#' @details
#' Specify the connectionHandler, the schema and the target/outcome cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template sccsTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetIds
#' @template outcomeIds
#' @family Estimation
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the database name}
#'  \item{analysisId the analysis unique identifier}
#'  \item{description an analysis description}
#'  \item{targetName the target name}
#'  \item{targetId the target cohort id}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome cohort id}
#'  \item{covariateName whether main or secondary analysis}
#'  \item{mdrr the maximum passable minimum detectable relative risk (mdrr) value.  If the mdrr is greater than this the diagnostics will fail.}
#'  \item{ease The expected absolute systematic error (ease) measures residual bias.}
#'  \item{timeTrendP The p for whether the mean monthly ratio between observed and expected is no greater than 1.25.}
#'  \item{preExposureP One-sided p-value for whether the rate before expore is higher than after, against the null of no difference.}
#'  \item{mdrrDiagnostic whether the mdrr (power) diagnostic passed or failed.}
#'  \item{easeDiagnostic whether the ease diagnostic passed or failed.}
#'  \item{timeTrendDiagnostic Pass / warning / fail / not evaluated classification of the time trend (unstalbe months) diagnostic.}
#'  \item{preExposureDiagnostic Pass / warning / fail / not evaluated classification of the time trend (unstalbe months) diagnostic.}
#'  \item{unblind whether the results can be unblinded.}
#'  \item{unblindForEvidenceSynthesis whether the results can be unblinded for the meta analysis.}
#'  \item{summaryValue summary of diagnostics results. FAIL, PASS or number of warnings.}
#'  } 
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' sccsDiag <- getSccsDiagnosticsData(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   targetIds = 1,
#'   outcomeIds = 3
#' )
#' 
getSccsDiagnosticsData <- function(
    connectionHandler,
    schema,
    sccsTablePrefix = 'sccs_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    outcomeIds = NULL
) {

  sql <- "
  SELECT 
  d.cdm_source_abbreviation as database_name,
  a.analysis_id,
  a.description,
  c2.cohort_name as target_name,
  cov.era_id as target_id,
  c.cohort_name as outcome_name,
  eos.outcome_id,
  cov.covariate_name,
  ds.mdrr,
  ds.ease,
  ds.time_trend_p,
  ds.pre_exposure_p,
  ds.mdrr_diagnostic,
  ds.ease_diagnostic,
  ds.time_trend_diagnostic,
  ds.pre_exposure_diagnostic,
  ds.unblind,
  ds.unblind_for_evidence_synthesis
  
  FROM @schema.@sccs_table_prefixdiagnostics_summary ds
            inner join
  @schema.@sccs_table_prefixexposures_outcome_set eos
  on ds.exposures_outcome_set_id = eos.exposures_outcome_set_id
     inner join
   @schema.@cg_table_prefixcohort_definition as c
   on c.cohort_definition_id = eos.outcome_id
   
   INNER JOIN
  @schema.@database_table d
  on d.database_id = ds.database_id
  
  INNER JOIN
  @schema.@sccs_table_prefixanalysis a
  on a.analysis_id = ds.analysis_id
  
  INNER JOIN
  @schema.@sccs_table_prefixcovariate cov
  on cov.covariate_id = ds.covariate_id and 
  cov.exposures_outcome_set_id = ds.exposures_outcome_set_id and
  cov.analysis_id = ds.analysis_id and
  cov.database_id = ds.database_id
  
   inner join
   @schema.@cg_table_prefixcohort_definition as c2
   on cov.era_id = c2.cohort_definition_id
   
   
   where
   1 = 1
   {@restrict_target}?{and c2.cohort_definition_id in (@target_ids)}
   {@restrict_outcome}?{and c.cohort_definition_id in (@outcome_ids)}
  ;
  "
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cg_table_prefix = 'cg_',
    sccs_table_prefix = 'sccs_',
    database_table = 'database_meta_data',
    target_ids = paste0(targetIds, collapse = ','),
    restrict_target = !is.null(targetIds),
    outcome_ids = paste0(outcomeIds, collapse = ','),
    restrict_outcome = !is.null(outcomeIds)
  )
  
  #result <- result %>% 
  #  dplyr::select(-c("analysisId","exposuresOutcomeSetId","databaseId","covariateId"))
  
  result$summaryValue <- apply(
    X = result[, grep('Diagnostic', colnames(result))], 
    MARGIN = 1, 
    FUN = function(x){
      
      if(sum(x %in% c('FAIL'))>0){
        return('Fail')
      } else if(sum(x %in% c('WARNING')) >0){
        return(sum(x %in% c('WARNING'), na.rm = TRUE))
      } else{
        return('Pass')
      }
    }
  )
  return(result)  
  
}

#' Extract the self controlled case series (sccs) meta analysis results
#' @description
#' This function extracts any meta analysis estimation results for sccs.
#'
#' @details
#' Specify the connectionHandler, the schema and the targetoutcome cohort IDs
#'
#' @template connectionHandler
#' @template schema
#' @template sccsTablePrefix
#' @template cgTablePrefix
#' @template esTablePrefix
#' @template targetIds
#' @template outcomeIds
#' @family Estimation
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  #'  \item{databaseName the database name}
#'  \item{analysisId the analysis unique identifier}
#'  \item{description an analysis description}
#'  \item{targetName the target name}
#'  \item{targetId the target cohort id}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome cohort id}
#'  \item{covariateName whether main or secondary analysis}
#'  \item{outcomeSubjects The number of subjects with at least one outcome.}
#'  \item{outcomeEvents The number of outcome events.}
#'  \item{outcomeObservationPeriods The number of observation periods containing at least one outcome.}
#'  \item{covariateSubjects The number of subjects having the covariate.}
#'  \item{covariateDays The total covariate time in days.}
#'  \item{covariateEras The number of continuous eras of the covariate.}
#'  \item{covariateOutcomes The number of outcomes observed during the covariate time.}
#'  \item{observedDays The number of days subjects were observed.}
#'  \item{calibratedRr the calibrated relative risk}
#'  \item{calibratedCi95Lb the lower bound of the 95 percent confidence interval for the calibrated relative risk}
#'  \item{calibratedCi95Ub the upper bound of the 95 percent confidence interval for the calibrated relative risk}
#'  \item{calibratedP the calibrated p-value}
#'  \item{calibratedOneSidedP the calibrated one sided p-value}
#'  \item{calibratedLogRr the calibrated log of the relative risk}
#'  \item{calibratedSeLogRr the calibrated log of the relative risk standard error}
#'  \item{nDatabases The number of databases included in the estimate.}
#'  } 
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' sccsMeta <- getSccsMetaEstimation(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   targetIds = 1,
#'   outcomeIds = 3
#' )
#' 
getSccsMetaEstimation <- function(
    connectionHandler,
    schema,
    sccsTablePrefix = 'sccs_',
    cgTablePrefix = 'cg_',
    esTablePrefix = 'es_',
    targetIds = NULL,
    outcomeIds = NULL
) {

  sql <- "select distinct
    ev.evidence_synthesis_description as database_name, 
    r.analysis_id, 
    a.description,
  c1.cohort_name as target_name,
  cov.era_id as target_id, 
  c3.cohort_name as outcome_name,
  eos.outcome_id,
  cov.covariate_name,

  r.outcome_subjects,
  r.outcome_events,
  r.outcome_observation_periods,
  r.covariate_subjects,
  r.covariate_days,
  r.covariate_eras,
  r.covariate_outcomes,
  r.observed_days,
  
  r.calibrated_rr, 
  r.calibrated_ci_95_lb, 
  r.calibrated_ci_95_ub,  
  r.calibrated_p,
  r.calibrated_one_sided_p,
  r.calibrated_log_rr, 
  r.calibrated_se_log_rr,
  
  r.n_databases
  
  from 
   @schema.@es_table_prefixsccs_result as r
   inner join 
   @schema.@sccs_table_prefixexposures_outcome_set as eos
   on 
   r.exposures_outcome_set_id = eos.exposures_outcome_set_id
   
   inner join
   @schema.@sccs_table_prefixcovariate as cov
   on 
   r.covariate_id = cov.covariate_id and
   r.analysis_id = cov.analysis_id and
   r.exposures_outcome_set_id = cov.exposures_outcome_set_id
   
   inner join
   @schema.@sccs_table_prefixexposure as ex
   on 
   ex.era_id = cov.era_id and
   ex.exposures_outcome_set_id = cov.exposures_outcome_set_id
   
   inner join
   
   @schema.@es_table_prefixsccs_diagnostics_summary as unblind
   on
   r.analysis_id = unblind.analysis_id and 
   r.exposures_outcome_set_id = unblind.exposures_outcome_set_id and 
   r.covariate_id = unblind.covariate_id and
   r.evidence_synthesis_analysis_id = unblind.evidence_synthesis_analysis_id
   
   inner join
   @schema.@cg_table_prefixcohort_definition as c1
   on c1.cohort_definition_id = cov.era_id

   inner join
   @schema.@cg_table_prefixcohort_definition as c3
   on c3.cohort_definition_id = eos.outcome_id
   
   inner join
   @schema.@sccs_table_prefixanalysis as a
   on a.analysis_id = r.analysis_id
   
   inner join
   @schema.@es_table_prefixanalysis as ev
   on ev.evidence_synthesis_analysis_id = r.evidence_synthesis_analysis_id
   
   where 
   r.calibrated_rr != 0 and
   --ex.true_effect_size != 1 and
   cov.covariate_name in ('Main', 'Second dose') and
   unblind.unblind = 1
   {@include_target}?{and cov.era_id in (@target_id)}
   {@include_outcome}?{and eos.outcome_id in(@outcome_id)}
  ;"  
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    sccs_table_prefix = sccsTablePrefix,
    cg_table_prefix = cgTablePrefix,
    es_table_prefix = esTablePrefix,
    target_id = paste0(targetIds, collapse = ','),
    include_target = !is.null(targetIds),
    outcome_id = paste0(outcomeIds, collapse = ','),
    include_outcome = !is.null(outcomeIds)
  )
  
  return(result)
}