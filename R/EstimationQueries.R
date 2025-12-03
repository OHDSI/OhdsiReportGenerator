# cohort method

#' A function to extract the targets found in cohort method
#'
#' @details
#' Specify the connectionHandler, the schema and the prefixes
#'
#' @template connectionHandler
#' @template schema
#' @template cmTablePrefix
#' @template cgTablePrefix
#' @family Estimation
#' 
#' @return
#' A data.frame with the cohort method target cohort ids and names.
#'
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cohorts <- getCmTargets(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getCmTargets <- function(
    connectionHandler,
    schema,
    cmTablePrefix = 'cm_',
    cgTablePrefix = 'cg_'
){
  
  sql <- "SELECT distinct 
    cd.cohort_name,
    tc.target_id as cohort_definition_id, 
    'cohortMethod' as type,
    1 as value

       FROM
      
      @schema.@cm_table_prefixtarget_comparator as tc
          
      inner join @schema.@cg_table_prefixcohort_definition cd
      
      on tc.target_id = cd.cohort_definition_id
      ;"
  
  targets <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cm_table_prefix = cmTablePrefix,
    cg_table_prefix = cgTablePrefix
  ) %>%
    tidyr::pivot_wider(
      id_cols = c("cohortName", "cohortDefinitionId"), 
      names_from = "type", 
      values_from = c("value")
    )
  
  return(targets)
  
}


#' A function to extract the outcomes found in cohort method
#'
#' @details
#' Specify the connectionHandler, the schema and the prefixes
#'
#' @template connectionHandler
#' @template schema
#' @template cmTablePrefix
#' @template cgTablePrefix
#' @template targetId
#' @family Estimation
#' 
#' @return
#' A data.frame with the cohort method outcome ids and names.
#'
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' outcomes <- getCmOutcomes(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getCmOutcomes <- function(
    connectionHandler,
    schema,
    cmTablePrefix = 'cm_',
    cgTablePrefix = 'cg_',
    targetId = NULL
){
  
  sql <- "SELECT distinct 
    cd.cohort_name,
    tco.outcome_id as cohort_definition_id, 
    'cohortMethod' as type,
    1 as value

       FROM
      
      @schema.@cm_table_prefixtarget_comparator as tc
      
      inner join 
   @schema.@cm_table_prefixtarget_comparator_outcome as tco
   on 
   tc.target_comparator_id = tco.target_comparator_id
          
      inner join @schema.@cg_table_prefixcohort_definition cd
      
      on tco.outcome_id = cd.cohort_definition_id
      
      where tco.outcome_of_interest = 1
      {@use_target}?{ and tc.target_id in (@target_id)}
      ;"
  
  outcomes <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cm_table_prefix = cmTablePrefix,
    cg_table_prefix = cgTablePrefix,
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
#'  \item{databaseId the unqiue identifier of the database}
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
#'  \item{Unblind Whether the results passed diagnostics and were unblinded}
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
  db.database_id,
  r.analysis_id, 
  a.description,
  
  c1.cohort_name as target_name,
  tc.target_id,
  c2.cohort_name as comparator_name,
  tc.comparator_id,
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
  unblind.unblind,
  r.target_estimator
  
  from @schema.@cm_table_prefixtarget_comparator tc
   inner join @schema.@cm_table_prefixresult as r ON tc.target_comparator_id = r.target_comparator_id
   inner join 
   @schema.@cm_table_prefixtarget_comparator_outcome as tco
   on 
   tco.target_comparator_id = r.target_comparator_id
   
   inner join
   
   @schema.@cm_table_prefixdiagnostics_summary as unblind
   on
   r.analysis_id = unblind.analysis_id and 
   r.target_comparator_id = unblind.target_comparator_id and 
   r.outcome_id = unblind.outcome_id and 
   r.database_id = unblind.database_id
   
   inner join
   @schema.@database_table as db
   on db.database_id = r.database_id
   
   inner join
   @schema.@cg_table_prefixcohort_definition as c1
   on c1.cohort_definition_id = tc.target_id
   
   inner join
   @schema.@cg_table_prefixcohort_definition as c2
   on c2.cohort_definition_id = tc.comparator_id
   
   inner join
   @schema.@cg_table_prefixcohort_definition as c3
   on c3.cohort_definition_id = r.outcome_id
   
   inner join
   @schema.@cm_table_prefixanalysis as a
   on a.analysis_id = r.analysis_id
   
   where 
   tco.outcome_of_interest = 1
   {@restrict_target} ? { and tc.target_id in (@target_id)}
   {@restrict_outcome} ? {and r.outcome_id in (@outcome_id)}
   {@restrict_comparator} ? { and tc.comparator_id in (@comparator_id)}
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
#' @param analysisIds An optional vector of analysisIds to filter to
#' @param databaseIds An optional vector of databaseIds to filter to
#' @family Estimation
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the name of the database}
#'  \item{databaseId the unqiue identifier of the database}
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
#'  \item{unblindForEvidenceSynthesis whether the results can be unblinded for the meta analysis.}
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
    comparatorIds = NULL,
    analysisIds = NULL,
    databaseIds = NULL
){
  
  sql <- "
    SELECT DISTINCT
      dmd.cdm_source_abbreviation database_name,
      dmd.database_id,
      cma.analysis_id,
      cma.description,
      cgcd1.cohort_name target_name,
      tc.target_id,
      cgcd2.cohort_name comparator_name,
      tc.comparator_id,
      cgcd3.cohort_name outcome_name,
      cmds.outcome_id,
      
      cmds.max_sdm,
      cmds.sdm_family_wise_min_p,
      cmds.shared_max_sdm,
      cmds.shared_sdm_family_wise_min_p,
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
      cmds.unblind_for_evidence_synthesis,
      cmds.unblind
    FROM
      @schema.@cm_table_prefixdiagnostics_summary cmds
      INNER JOIN @schema.@cm_table_prefixanalysis cma ON cmds.analysis_id = cma.analysis_id
      INNER JOIN @schema.@database_table dmd ON dmd.database_id = cmds.database_id
      INNER JOIN @schema.@cm_table_prefixtarget_comparator tc ON tc.target_comparator_id = cmds.target_comparator_id
      INNER JOIN @schema.@cg_table_prefixcohort_definition cgcd1 ON tc.target_id = cgcd1.cohort_definition_id
      INNER JOIN @schema.@cg_table_prefixcohort_definition cgcd2 ON tc.comparator_id = cgcd2.cohort_definition_id
      INNER JOIN @schema.@cg_table_prefixcohort_definition cgcd3 ON cmds.outcome_id = cgcd3.cohort_definition_id
      
      WHERE 
      cmds.database_id IS NOT NULL
      {@use_target}?{AND cgcd1.cohort_definition_id in (@targets)}
      {@use_comparator}?{AND cgcd2.cohort_definition_id in (@comparators)}
      {@use_outcome}?{AND cgcd3.cohort_definition_id in (@outcomes)}
      
      {@use_database}?{AND  cmds.database_id in (@database_ids)} 
      {@use_analysis}?{AND cmds.analysis_id in (@analysis_ids)}
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
    use_outcome = !is.null(outcomeIds),
    
    database_ids = paste0("'",databaseIds,"'", collapse = ','),
    use_database = !is.null(databaseIds),
    analysis_ids = paste0(analysisIds, collapse = ','),
    use_analysis = !is.null(analysisIds)
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
  
  result <- result %>% 
    dplyr::relocate("summaryValue", .after = "outcomeName")
  
  return(result)
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
#'  \item{unblind whether the results can be unblinded.}
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
  unblind.unblind,
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

#' Extract the cohort method table specified
#' @description
#' This function extracts the specific cohort method table.
#'
#' @details
#' Specify the connectionHandler, the schema and optionally the target/comparator/outcome/analysis/database IDs
#'
#' @template connectionHandler
#' @template schema
#' @param table The result table to extract
#' @template cmTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetIds
#' @template outcomeIds
#' @template comparatorIds
#' @param analysisIds the analysis IDs to restrict to 
#' @param databaseIds the database IDs to restrict to 
#' @family Estimation
#' @return
#' Returns a data.frame with the cohort method requested table
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cmTable <- getCmTable(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   table = 'attrition'
#' )
#' 
getCmTable <- function(
    connectionHandler,
    schema,
    table = c('attrition', 'follow_up_dist', 'interaction_result',
              'covariate_balance', 'kaplan_meier_dist', 'likelihood_profile',
              'preference_score_dist', 'propensity_model',
              'shared_covariate_balance')[1],
    cmTablePrefix = 'cm_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    targetIds = NULL,
    outcomeIds = NULL,
    comparatorIds = NULL,
    analysisIds = NULL,
    databaseIds = NULL
){
  
  # check table valid:
  if(!table %in% c('attrition', 'follow_up_dist', 'interaction_result',
                  'covariate_balance', 'kaplan_meier_dist', 'likelihood_profile',
                  'preference_score_dist', 'propensity_model',
                  'shared_covariate_balance')){
    stop('Invalid table')
  }
  
  useOutcome = !is.null(outcomeIds)
  # some tables dont have outcomeIds
  if(table %in% c('preference_score_dist', 'propensity_model',
     'shared_covariate_balance')){
    useOutcome = FALSE
  }
  
  addCovariateName <- table %in% c('shared_covariate_balance','covariate_balance')
  
  sql <- "select 
  dmd.cdm_source_abbreviation database_name,
  a.description as analysis_description,
  c1.cohort_name as target_name,
  c2.cohort_name as comparator_name,
  {@include_outcome}?{c3.cohort_name as outcome_name,}
  {@include_covariate_name}?{c.covariate_name,}
  tab.*

  from 
   @schema.@cm_table_prefix@table as tab
  
   {@include_covariate_name}?{
    JOIN @schema.@cm_table_prefixcovariate c 
    ON tab.covariate_id = c.covariate_id 
    AND tab.analysis_id = c.analysis_id 
    AND tab.database_id = c.database_id
   }

   inner join
   @schema.@cg_table_prefixcohort_definition as c1
   on c1.cohort_definition_id = tab.target_id
   
   inner join
   @schema.@cg_table_prefixcohort_definition as c2
   on c2.cohort_definition_id = tab.comparator_id
   
  {@include_outcome}?{
   inner join
   @schema.@cg_table_prefixcohort_definition as c3
   on c3.cohort_definition_id = tab.outcome_id
  }
   
   inner join
   @schema.@cm_table_prefixanalysis as a
   on a.analysis_id = tab.analysis_id
   
   inner join
   @schema.@database_table as dmd
   on dmd.database_id = tab.database_id
   
   where 
   1 = 1 
   {@include_target}?{and tab.target_id in (@target_id)}
   {@include_outcome}?{and tab.outcome_id in (@outcome_id)}
  {@include_comparator}?{and tab.comparator_id in (@comparator_id)}
  {@include_database}?{and tab.database_id in (@database_id)}
  {@include_analyses}?{and tab.analysis_id in (@analysis_id)}
  ;"
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cm_table_prefix = cmTablePrefix,
    cg_table_prefix = cgTablePrefix,
    table = table,
    target_id = paste0(targetIds, collapse = ','),
    include_target = !is.null(targetIds),
    outcome_id = paste0(outcomeIds, collapse = ','),
    include_outcome = useOutcome,
    comparator_id = paste0(comparatorIds, collapse = ','),
    include_comparator = !is.null(comparatorIds),
    database_id = paste0("'",databaseIds,"'", collapse = ','),
    include_database = !is.null(databaseIds),
    analysis_id = paste0(analysisIds, collapse = ','),
    include_analyses = !is.null(analysisIds),
    database_table = databaseTable,
    
    include_covariate_name = addCovariateName
  )
  
  
  # edit covariateName 
  ##if(addCovariateName){
  ##  result$covariateName
  ##}
  
  
  return(unique(result))
}

# add cohort and database names:

#' Extract the cohort method negative controls
#' @description
#' This function extracts the cohort method negative control table.
#'
#' @details
#' Specify the connectionHandler, the schema and optionally the target/comparator/outcome/analysis/database IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cmTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @template targetIds
#' @template comparatorIds
#' @param analysisIds the analysis IDs to restrict to 
#' @param databaseIds the database IDs to restrict to 
#' @param excludePositiveControls Whether to exclude the positive controls 
#' @family Estimation
#' @return
#' Returns a data.frame with the cohort method negative controls
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cmNc <- getCmNegativeControlEstimates(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getCmNegativeControlEstimates <- function(
  connectionHandler,
  schema,
  cmTablePrefix = 'cm_',
  cgTablePrefix = 'cg_',
  databaseTable = 'database_meta_data',
  targetIds = NULL,
  comparatorIds = NULL,
  analysisIds = NULL,
  databaseIds = NULL,
  excludePositiveControls = TRUE
){
  
  
  sql <- "
    SELECT
      cmr.*,
      cmtco.true_effect_size effect_size,
      ds.ease
    FROM @schema.@cm_table_prefixtarget_comparator tc
      INNER JOIN @schema.@cm_table_prefixresult cmr ON cmr.target_comparator_id = tc.target_comparator_id
      
      INNER JOIN @schema.@cm_table_prefixtarget_comparator_outcome cmtco 
      ON cmr.target_comparator_id = cmtco.target_comparator_id
      
     INNER JOIN @schema.@cm_table_prefixdiagnostics_summary ds
     ON ds.target_comparator_id = cmr.target_comparator_id
     AND ds.analysis_id = cmr.analysis_id
     AND ds.database_id = cmr.database_id
     AND ds.outcome_id = cmr.outcome_id
      
    WHERE
      cmtco.outcome_of_interest != 1
      {@exclude_positive_controls}?{AND cmtco.true_effect_size = 1}
      {@use_target}?{AND tc.target_id in (@target_ids)}
      {@use_comparator}?{AND tc.comparator_id in (@comparator_ids)}
      {@use_analysis}?{AND cmr.analysis_id in (@analysis_ids)}
      {@use_database}?{AND cmr.database_id in (@database_ids)}
      ;"
  
  results <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cm_table_prefix = cmTablePrefix,
    
    use_target = !is.null(targetIds),
    target_ids = paste0(targetIds, collapse = ','),
    use_comparator = !is.null(comparatorIds),
    comparator_ids = paste0(comparatorIds, collapse = ','),
    use_analysis = !is.null(analysisIds),
    analysis_ids = paste0(analysisIds, collapse = ','),
    use_database = !is.null(databaseIds),
    database_ids = paste0("'",databaseIds,"'", collapse = ','),
    exclude_positive_controls = excludePositiveControls
  )
  
  return(results)
}


#' Extract the cohort method model
#' @description
#' This function extracts the cohort method model.
#'
#' @details
#' Specify the connectionHandler, the schema and optionally the target/comparator/analysis/database IDs
#'
#' @template connectionHandler
#' @template schema
#' @template cmTablePrefix
#' @template targetId
#' @param comparatorId the comparator ID of interest
#' @param analysisId the analysis ID to restrict to 
#' @param databaseId the database ID to restrict to 
#' @family Estimation
#' @return
#' Returns a data.frame with the cohort method model
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cmModel <- getCmPropensityModel(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getCmPropensityModel <- function(
    connectionHandler, 
    schema,
    cmTablePrefix = 'cm_',
    targetId = NULL, 
    comparatorId = NULL, 
    analysisId = NULL, 
    databaseId = NULL
) {
  
  if(is.null(targetId)){
    message('Please specify targetId')
    return(NULL)
  }
  
  sql <- "
    SELECT
    cmc.covariate_id,
    cmc.covariate_name,
    cmpm.coefficient
  FROM
    (
      SELECT
        covariate_id,
        covariate_name
      FROM
        @schema.@cm_table_prefixcovariate
      WHERE
        analysis_id = @analysis_id
        AND database_id = '@database_id'
      UNION
      SELECT
      0 as covariate_id,
      'intercept' as covariate_name) cmc
    JOIN @schema.@cm_table_prefixpropensity_model cmpm 
    ON cmc.covariate_id = cmpm.covariate_id
    JOIN @schema.@cm_table_prefixtarget_comparator tc
    ON tc.target_comparator_id = cmpm.target_comparator_id
  WHERE
    tc.target_id = @target_id
    AND tc.comparator_id = @comparator_id
    AND cmpm.analysis_id = @analysis_id
    AND cmpm.database_id = '@database_id'
  "
  
  model <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    cm_table_prefix = cmTablePrefix,
    target_id = targetId,
    comparator_id = comparatorId,
    analysis_id = analysisId,
    database_id = databaseId
  )
  
  model <- model %>%
    dplyr::arrange(dplyr::desc(abs(.data$coefficient)))
  
  return(model)
}

#' A function to extract the targets found in self controlled case series
#'
#' @details
#' Specify the connectionHandler, the schema and the prefixes
#'
#' @template connectionHandler
#' @template schema
#' @template sccsTablePrefix
#' @template cgTablePrefix
#' @family Estimation
#' 
#' @return
#' A data.frame with the self controlled case series target cohort ids and names.
#'
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cohorts <- getSccsTargets(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getSccsTargets <- function(
    connectionHandler,
    schema,
    sccsTablePrefix = 'sccs_',
    cgTablePrefix = 'cg_'
){
  
  sql <- "SELECT distinct 
    cd.cohort_name,
    sc.era_id as cohort_definition_id, 
    'selfControlledCaseSeries' as type,
    1 as value

       FROM
      
      @schema.@sccs_table_prefixresult as sr
      
      INNER JOIN 
      @schema.@sccs_table_prefixcovariate sc ON (
    sc.exposures_outcome_set_id = sr.exposures_outcome_set_id AND
    sc.database_id = sr.database_id AND
    sc.analysis_id = sr.analysis_id AND
    sc.covariate_id = sr.covariate_id
  )
          
      inner join @schema.@cg_table_prefixcohort_definition cd
      
      on sc.era_id = cd.cohort_definition_id
      ;"
  
  targets <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    sccs_table_prefix = sccsTablePrefix,
    cg_table_prefix = cgTablePrefix
  ) %>%
    tidyr::pivot_wider(
      id_cols = c("cohortName", "cohortDefinitionId"), 
      names_from = "type", 
      values_from = c("value")
    )
  
  return(targets)
  
}


#' A function to extract the outcomes found in self controlled case series
#'
#' @details
#' Specify the connectionHandler, the schema and the prefixes
#'
#' @template connectionHandler
#' @template schema
#' @template sccsTablePrefix
#' @template cgTablePrefix
#' @template targetId
#' @family Estimation
#' 
#' @return
#' A data.frame with the self controlled case series outcome ids and names.
#'
#' @export
#' 
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' outcomes <- getSccsOutcomes(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getSccsOutcomes <- function(
    connectionHandler,
    schema,
    sccsTablePrefix = 'sccs_',
    cgTablePrefix = 'cg_',
    targetId = NULL
){
  
  sql <- "SELECT distinct 
    cd.cohort_name,
    eos.outcome_id as cohort_definition_id, 
    'selfControlledCaseSeries' as type,
    1 as value

       FROM
      
      @schema.@sccs_table_prefixresult as sr
      
      inner join
      
      @schema.@sccs_table_prefixexposures_outcome_set as eos
      on eos.exposures_outcome_set_id = sr.exposures_outcome_set_id
      
      inner join
      @schema.@sccs_table_prefixcovariate sc ON (
    sc.exposures_outcome_set_id = sr.exposures_outcome_set_id AND
    sc.database_id = sr.database_id AND
    sc.analysis_id = sr.analysis_id AND
    sc.covariate_id = sr.covariate_id
  )
  
  inner join
  @schema.@sccs_table_prefixexposure e ON
  (
  e.exposures_outcome_set_id = sc.exposures_outcome_set_id AND
  e.era_id = sc.era_id
  )


      inner join @schema.@cg_table_prefixcohort_definition cd
      
      on eos.outcome_id = cd.cohort_definition_id
      
      where e.true_effect_size is NULL
  {@use_target}?{ AND sc.era_id in (@target_id)}
      
      ;"
  
  outcomes <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    sccs_table_prefix = sccsTablePrefix,
    cg_table_prefix = cgTablePrefix,
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
#'  \item{databaseId the database id}
#'  \item{exposuresOutcomeSetId the exposure outcome set identifier}
#'  \item{analysisId the analysis unique identifier}
#'  \item{description an analysis description}
#'  \item{targetName the target name}
#'  \item{targetId the target cohort id}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome cohort id}
#'  \item{indicationName the indication name}
#'  \item{indicatonId the indication cohort id}
#'  \item{covariateName whether main or secondary analysis}
#'  \item{covariateId the analysis id}
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
#'  \item{calibratedOneSidedP the calibrated one sided p-value}
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
    ds.database_id,
    sr.exposures_outcome_set_id,
    sr.analysis_id,
    a.description,
    cg2.cohort_name as target_name,
    sc.era_id as target_id,
    cg1.cohort_name as outcome_name,
    eos.outcome_id,
    cg3.cohort_name as indication_name,
    eos.nesting_cohort_id as indication_id,
    sc.covariate_name,
    sc.covariate_id,
    
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
  case when COALESCE(sds.unblind, 0) = 0 then NULL else sr.calibrated_one_sided_p end calibrated_one_sided_p,
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
	
	 left join
   @schema.@cg_table_prefixcohort_definition as cg3
   on eos.nesting_cohort_id = cg3.cohort_definition_id
  
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
#'  \item{databaseId the unique identifier for the database}
#'  \item{analysisId the analysis unique identifier}
#'  \item{description an analysis description}
#'  \item{targetName the target name}
#'  \item{targetId the target cohort id}
#'  \item{outcomeName the outcome name}
#'  \item{outcomeId the outcome cohort id}
#'  \item{indicationName the indication name}
#'  \item{indicatonId the indication cohort id}
#'  \item{covariateName whether main or secondary analysis}
#'  \item{mdrr the maximum passable minimum detectable relative risk (mdrr) value.  If the mdrr is greater than this the diagnostics will fail.}
#'  \item{ease The expected absolute systematic error (ease) measures residual bias.}
#'  \item{timeTrendP (Depreciated to timeStabilityP) The p for whether the mean monthly ratio between observed and expected is no greater than 1.25.}
#'  \item{preExposureP (Depreciated) One-sided p-value for whether the rate before expore is higher than after, against the null of no difference.}
#'  \item{mdrrDiagnostic whether the mdrr (power) diagnostic passed or failed.}
#'  \item{easeDiagnostic whether the ease diagnostic passed or failed.}
#'  \item{timeStabilityP (New) The p for whether the mean monthly ratio between observed and expected exceeds the specified threshold.}
#'  \item{eventExposureLb (New) Lower bound of the 95\% CI for the pre-expososure estimate.}
#'  \item{eventExposureUb (New) Upper bound of the 95\% CI for the pre-expososure estimate.}
#'  \item{eventObservationLb (New) Lower bound of the 95\% CI for the end of observation probe estimate.}
#'  \item{eventObservationUb (New) Upper bound of the 95\% CI for the end of observation probe estimate.}
#'  \item{rareOutcomePrevalence (New) The proportion of people in the underlying population who have the outcome at least once.}
#'  \item{timeTrendDiagnostic (Depreciated) Pass / warning / fail / not evaluated classification of the time trend (unstalbe months) diagnostic.}
#'  \item{preExposureDiagnostic (Depreciated) Pass / warning / fail / not evaluated classification of the time trend (unstalbe months) diagnostic.}
#'  \item{timeStabilityDiagnostic (New) Pass / fail / not evaluated classification of the time stability diagnostic.}
#'  \item{eventExposureDiagnostic (New) Pass / fail / not evaluated classification of the event-exposure independence diagnostic.}
#'  \item{eventObservationDiagnostic (New) Pass / fail / not evaluated classification of the event-observation period dependence diagnostic.}
#'  \item{rareOutcomeDiagnostic (New) Pass / fail / not evaluated classification of the rare outcome diagnostic.}
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
  d.database_id as database_id,
  a.analysis_id,
  a.description,
  c2.cohort_name as target_name,
  cov.era_id as target_id,
  c.cohort_name as outcome_name,
  eos.outcome_id,
  cg3.cohort_name as indication_name,
  eos.nesting_cohort_id as indication_id,
  cov.covariate_name,
  ds.*
  
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
   
   left join
   @schema.@cg_table_prefixcohort_definition as cg3
   on eos.nesting_cohort_id = cg3.cohort_definition_id
   
   
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
  
  
  # restrict to columns in the output description
  columnsToInclude <- c(
    "databaseName","databaseId","analysisId","description", 
    "targetName","targetId","outcomeName","outcomeId","indicationName", 
    "indicationId","covariateName","mdrr","ease","timeTrendP","preExposureP", 
    "timeStabilityP","eventExposureLb","eventExposureUb","eventObservationLb", 
    "eventObservationUb","rareOutcomePrevalence","mdrrDiagnostic","easeDiagnostic", 
    "timeTrendDiagnostic","preExposureDiagnostic","timeStabilityDiagnostic", 
    "eventExposureDiagnostic","eventObservationDiagnostic","rareOutcomeDiagnostic",
    "unblind","unblindForEvidenceSynthesis"
    )
  
  columnsToInclude <- columnsToInclude[columnsToInclude %in% colnames(result)]
  result <- result[, columnsToInclude]
  
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
  
  result <- result %>% 
    dplyr::relocate("summaryValue", .after = "covariateName")
  
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
#'  \item{indicationName the indicationname}
#'  \item{indicationId the indication cohort id}
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
  cg3.cohort_name as indication_name,
  eos.nesting_cohort_id as indication_id,
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
   
   left join
   @schema.@cg_table_prefixcohort_definition as cg3
   on eos.nesting_cohort_id = cg3.cohort_definition_id
   
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


#' Extract the SCCS table specified
#' @description
#' This function extracts the specific cohort method table.
#'
#' @details
#' Specify the connectionHandler, the schema and optionally the target/outcome/analysis/database IDs
#'
#' @template connectionHandler
#' @template schema
#' @param table The result table to extract
#' @template sccsTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @param indicationIds The indications that the target was nested to
#' @template outcomeIds
#' @param analysisIds the analysis IDs to restrict to 
#' @param databaseIds the database IDs to restrict to 
#' @param exposureOutcomeIds the exposureOutcomeIds to restrict to
#' @param covariateIds the covariateIds to restrict to
#' @family Estimation
#' @return
#' Returns a data.frame with the cohort method requested table
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' sccsTable <- getSccsTable(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   table = 'attrition'
#' )
#' 
getSccsTable <- function(
    connectionHandler,
    schema,
    table = c('attrition', 'time_trend', 'event_dep_observation',
              'age_spanning', 'calendar_time_spanning', 'spline')[1],
    sccsTablePrefix = 'sccs_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    indicationIds = NULL,
    outcomeIds = NULL,
    analysisIds = NULL,
    databaseIds = NULL,
    exposureOutcomeIds = NULL,
    covariateIds = NULL
){
  
  # check table valid:
  if(!table %in% c('attrition', 'time_trend', 'event_dep_observation',
                   'age_spanning', 'calendar_time_spanning', 'spline')){
    stop('Invalid table')
  }
  
  # only let users use covariated for valid tables
  includeCovariates <- !is.null(covariateIds)
  if(table %in% c('time_trend', 'event_dep_observation',
                  'age_spanning', 'calendar_time_spanning',
                  'spline')){
    includeCovariates <- FALSE
  }
  
  sql <- "select 
  dmd.cdm_source_abbreviation database_name,
  a.description as analysis_description,
  c2.cohort_name as outcome_name,
  eos.outcome_id,
  c3.cohort_name as indication_name,
  eos.nesting_cohort_id,
  tab.*

  from 
   @schema.@sccs_table_prefix@table as tab

  inner join
  @schema.@sccs_table_prefixexposures_outcome_set eos
  on eos.exposures_outcome_set_id = tab.exposures_outcome_set_id
  
   inner join
   @schema.@cg_table_prefixcohort_definition as c2
   on c2.cohort_definition_id = eos.outcome_id
   
   left join
   @schema.@cg_table_prefixcohort_definition as c3
   on c3.cohort_definition_id = eos.nesting_cohort_id
   
   inner join
   @schema.@sccs_table_prefixanalysis as a
   on a.analysis_id = tab.analysis_id
   
   inner join
   @schema.@database_table as dmd
   on dmd.database_id = tab.database_id
   
   where 
   1 = 1 
  {@include_outcome}?{and eos.outcome_id in (@outcome_ids)}
  {@include_indication}?{and eos.nesting_cohort_id in (@indication_ids)}
  {@include_database}?{and tab.database_id in (@database_ids)}
  {@include_analyses}?{and tab.analysis_id in (@analysis_ids)}
  {@include_eos}?{and tab.exposures_outcome_set_id in (@exposures_outcome_set_ids)}
  {@include_covariates}?{AND tab.covariate_id in (@covariate_ids)}
  ;"
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    sccs_table_prefix = sccsTablePrefix,
    cg_table_prefix = cgTablePrefix,
    table = table,
    
    include_covariates = includeCovariates,
    covariate_ids = paste0(covariateIds, collapse = ','),
    
    outcome_ids = paste0(outcomeIds, collapse = ','),
    include_outcome = !is.null(outcomeIds),
    
    indication_ids = paste0(indicationIds, collapse = ','),
    include_indication = !is.null(indicationIds),
    
    database_ids = paste0("'",databaseIds,"'", collapse = ','),
    include_database = !is.null(databaseIds),
    
    analysis_ids = paste0(analysisIds, collapse = ','),
    include_analyses = !is.null(analysisIds),
    
    include_eos = !is.null(exposureOutcomeIds),
    exposures_outcome_set_ids = paste0(exposureOutcomeIds, collapse = ','),
    
    database_table = databaseTable
  )
  
  return(unique(result))
}

#' Extract the SCCS model table
#' @description
#' This function extracts the sccs model table.
#'
#' @details
#' Specify the connectionHandler, the schema and optionally the target/outcome/analysis/database IDs
#'
#' @template connectionHandler
#' @template schema
#' @template sccsTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @param exposureOutcomeSetIds the exposureOutcomeIds to restrict to
#' @param indicationIds The indications that the target was nested to
#' @template outcomeIds
#' @param databaseIds the database IDs to restrict to 
#' @param analysisIds the analysis IDs to restrict to 
#' @template targetIds
#' @family Estimation
#' @return
#' Returns a data.frame with the SCCS model table
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' sccsModels <- getSccsModel(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getSccsModel <- function(
    connectionHandler,
    schema,
    sccsTablePrefix = 'sccs_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    exposureOutcomeSetIds = NULL,
    indicationIds = NULL,
    outcomeIds = NULL,
    databaseIds = NULL,
    analysisIds = NULL,
    targetIds = NULL
) {
  
  sql <- "
  SELECT
  dmd.cdm_source_abbreviation as database_name,
  sc.database_id,
  a.description as analysis_description,
  sc.analysis_id,
  cd.cohort_name as target_name,
  sc.era_id as target_id,
  c2.cohort_name as outcome_name,
  eos.outcome_id,
  c3.cohort_name as indication_name,
  eos.nesting_cohort_id as indication_id,
  scr.exposures_outcome_set_id,
  
    CASE
       WHEN era.era_name IS NULL THEN sc.covariate_name
       ELSE CONCAT(sc.covariate_name, ' : ', era.era_name)
    END as covariate_name,
    scr.covariate_id, scr.rr, scr.ci_95_lb, scr.ci_95_ub
  FROM 
  
  @schema.@sccs_table_prefixcovariate_result scr
  INNER JOIN @schema.@sccs_table_prefixcovariate sc ON (
    sc.exposures_outcome_set_id = scr.exposures_outcome_set_id AND
    sc.database_id = scr.database_id AND
    sc.analysis_id = scr.analysis_id AND
    sc.covariate_id = scr.covariate_id
  )
  
  INNER JOIN
  @schema.@sccs_table_prefixexposures_outcome_set eos
  on eos.exposures_outcome_set_id = scr.exposures_outcome_set_id
  
  LEFT JOIN @schema.@cg_table_prefixcohort_definition cd 
  ON cd.cohort_definition_id = sc.era_id
  
  LEFT JOIN @schema.@sccs_table_prefixera era ON (
    era.exposures_outcome_set_id = scr.exposures_outcome_set_id AND
    era.database_id = scr.database_id AND
    era.analysis_id = scr.analysis_id AND
    era.era_id = sc.era_id
  )
  
   inner join
   @schema.@cg_table_prefixcohort_definition as c2
   on c2.cohort_definition_id = eos.outcome_id
   
   left join
   @schema.@cg_table_prefixcohort_definition as c3
   on c3.cohort_definition_id = eos.nesting_cohort_id
   
   inner join
   @schema.@sccs_table_prefixanalysis as a
   on a.analysis_id = scr.analysis_id
   
   inner join
   @schema.@database_table as dmd
   on dmd.database_id = scr.database_id

  WHERE 
  1 = 1
  {@use_databases}?{AND  scr.database_id in (@database_ids)}
  {@use_analyses}?{AND  scr.analysis_id in (@analysis_ids)}
  {@use_targets}?{AND  sc.era_id in (@target_ids)}
  {@use_eos}?{AND scr.exposures_outcome_set_id in (@exposures_outcome_set_ids)}
  {@use_outcomes}?{AND eos.outcome_id in (@outcome_ids)}
  {@use_indications}?{AND eos.nesting_id in (@indication_ids)}
  ;
  "
  
  connectionHandler$queryDb(
    sql,
    schema = schema,
    sccs_table_prefix = sccsTablePrefix,
    cg_table_prefix = cgTablePrefix,
    
    use_databases = !is.null(databaseIds),
    database_ids = paste0("'",databaseIds,"'", collapse = ','),
    
    use_analyses = !is.null(analysisIds),
    analysis_ids = paste0(analysisIds, collapse = ','),
    
    use_targets = !is.null(targetIds),
    target_ids = paste0(targetIds, collapse = ','),
    
    use_outcomes = !is.null(outcomeIds),
    outcome_ids = paste0(outcomeIds, collapse = ','),
    
    use_indications = !is.null(indicationIds),
    indication_ids = paste0(indicationIds, collapse = ','),
    
    use_eos = !is.null(exposureOutcomeSetIds),
    exposures_outcome_set_ids = paste0(exposureOutcomeSetIds, collapse = ','),
    
    database_table = databaseTable,
    
    snakeCaseToCamelCase = TRUE
    )
}



#' Extract the SCCS negative controls
#' @description
#' This function extracts the sccs negative controls.
#'
#' @details
#' Specify the connectionHandler, the schema and optionally the target/outcome/analysis/database IDs
#'
#' @template connectionHandler
#' @template schema
#' @template sccsTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @param databaseIds the database IDs to restrict to 
#' @param exposuresOutcomeSetIds the exposureOutcomeIds to restrict to
#' @param indicationIds The indications that the target was nested to
#' @template outcomeIds
#' @template targetIds
#' @param analysisIds the analysis IDs to restrict to 
#' @param covariateIds the covariate IDs to restrict to 
#' @param covariateAnalysisIds the covariate analysis IDs to restrict to 
#' @family Estimation
#' @return
#' Returns a data.frame with the SCCS negative controls
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' sccsNcs <- getSccsNegativeControlEstimates(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getSccsNegativeControlEstimates <- function(
    connectionHandler,
    schema,
    sccsTablePrefix = 'sccs_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    databaseIds = NULL,
    exposuresOutcomeSetIds = NULL,
    indicationIds = NULL,
    outcomeIds  = NULL,
    targetIds  = NULL, #  eraId,
    analysisIds  = NULL,
    covariateIds  = NULL, # needed?
    covariateAnalysisIds  = NULL # needed?
) {
  
  sql <- "
  SELECT 
  c.exposures_outcome_set_id,
  eos.nesting_cohort_id as indication_id,
  c1.cohort_name as indication_name,
  c.era_id as target_id,
  c2.cohort_name as target_name,
  outcome_id as outcome_id,
  c3.cohort_name as outcome_name,
  db.database_id as database_id,
  db.cdm_source_abbreviation as database_name,
  a.description as analysis_description,
  r.ci_95_lb, 
  r.ci_95_ub, 
  r.log_rr, 
  r.se_log_rr, 
  r.calibrated_ci_95_lb, 
  r.calibrated_ci_95_ub, 
  r.calibrated_log_rr,
  r.calibrated_se_log_rr, 
  e.true_effect_size,
  ds.ease
  
  FROM 
  @schema.@sccs_table_prefixresult r
  INNER JOIN
   @schema.@sccs_table_prefixexposure e
   on r.exposures_outcome_set_id = e.exposures_outcome_set_id

   INNER JOIN 
   @schema.@sccs_table_prefixcovariate c
   on e.era_id = c.era_id 
   and e.exposures_outcome_set_id = c.exposures_outcome_set_id
   and c.database_id = r.database_id
   and c.analysis_id = r.analysis_id
   and c.covariate_id = r.covariate_id
   
   INNER JOIN  
   @schema.@sccs_table_prefixexposures_outcome_set eos
   on eos.exposures_outcome_set_id = r.exposures_outcome_set_id
   
   left join
   @schema.@cg_table_prefixcohort_definition as c2
   on c2.cohort_definition_id = e.era_id
   
   left join
   @schema.@cg_table_prefixcohort_definition as c3
   on c3.cohort_definition_id = eos.outcome_id
   
   left join
   @schema.@cg_table_prefixcohort_definition as c1
   on c1.cohort_definition_id = eos.nesting_cohort_id
   
   inner join
   @schema.@sccs_table_prefixanalysis as a
   on a.analysis_id = r.analysis_id
   
   inner join
   @schema.@database_table as db
   on db.database_id = r.database_id
   
   left join
   @schema.@sccs_table_prefixdiagnostics_summary ds
   ON ds.database_id = r.database_id
   AND ds.analysis_id = r.analysis_id
   AND ds.covariate_id = r.covariate_id
   AND ds.exposures_outcome_set_id = r.exposures_outcome_set_id
  
   WHERE 
   e.true_effect_size is not NULL
  {@use_eos_id}?{AND r.exposures_outcome_set_id in (@eos_ids)}
  {@use_outcome_id}?{AND eos.outcome_id in (@outcome_ids)}
  {@use_target_id}?{AND e.era_id in (@target_ids)}
   {@use_database_id}?{AND r.database_id in (@database_ids)}
   {@use_analysis_id}?{AND r.analysis_id in (@analysis_ids)}
   {@use_covariate_id}?{AND r.covariate_id in (@covariate_ids)}
  {@use_indication_id}?{AND eos.nesting_cohort_id in (@indication_ids)}
   {@use_covariate_analysis_id}?{AND c.covariate_analysis_id in (@covariate_analysis_ids)}
  ;
  "
  
  result <- connectionHandler$queryDb(
    sql,
    schema = schema,
    sccs_table_prefix = sccsTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable,
    use_eos_id = !is.null(exposuresOutcomeSetIds),
    eos_ids = paste0(exposuresOutcomeSetIds, collapse = ','),
    use_outcome_id = !is.null(outcomeIds),
    outcome_ids = paste0(outcomeIds, collapse = ','),
    use_target_id = !is.null(targetIds),
    target_ids = paste0(targetIds, collapse = ','),
    use_database_id = !is.null(databaseIds),
    database_ids = paste0("'",databaseIds,"'", collapse = ','),
    use_analysis_id = !is.null(analysisIds),
    analysis_ids = paste0(analysisIds, collapse = ','),
    use_covariate_id = !is.null(covariateIds),
    covariate_ids = paste0(covariateIds, collapse = ','),
    use_indication_id = !is.null(indicationIds),
    indication_ids = paste0(indicationIds, collapse = ','),
    use_covariate_analysis_id = !is.null(covariateAnalysisIds),
    covariate_analysis_ids = paste0(covariateAnalysisIds, collapse = ','),
    snakeCaseToCamelCase = TRUE
  )
  

  return(result)
}

#' Extract the SCCS time-to-event
#' @description
#' This function extracts the SCCS time-to-event.
#'
#' @details
#' Specify the connectionHandler, the schema and optionally the target/outcome/analysis/database IDs
#'
#' @template connectionHandler
#' @template schema
#' @template sccsTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @param databaseIds the database IDs to restrict to 
#' @param exposuresOutcomeSetIds the exposureOutcomeIds to restrict to
#' @param indicationIds The indications that the target was nested to
#' @template outcomeIds
#' @template targetIds
#' @param analysisIds the analysis IDs to restrict to 
#' @family Estimation
#' @return
#' Returns a data.frame with the SCCS time-to-event
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' getSccsTimeToEvent <- getSccsNegativeControlEstimates(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getSccsTimeToEvent <- function(
    connectionHandler,
    schema,
    sccsTablePrefix = 'sccs_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    databaseIds = NULL,
    exposuresOutcomeSetIds = NULL,
    indicationIds = NULL,
    outcomeIds = NULL,
    targetIds = NULL,
    analysisIds = NULL 
    # add covariateIds?
) {
  
  sql <- "
  SELECT 
  eos.nesting_cohort_id as indication_id,
  c1.cohort_name as indication_name,
  tte.era_id as target_id,
  c2.cohort_name as target_name,
  eos.outcome_id as outcome_id,
  c3.cohort_name as outcome_name,
  db.cdm_source_abbreviation as database_name,
  a.description as analysis_description,
  c.covariate_id,
  c.covariate_name,
  tte.* , 
  ds.pre_exposure_p as p
  
  FROM 
  @schema.@sccs_table_prefixtime_to_event tte
  
  inner join
  @schema.@sccs_table_prefixcovariate c
  ON c.analysis_id = tte.analysis_id
  AND c.exposures_outcome_set_id = tte.exposures_outcome_set_id
  AND c.era_id = tte.era_id
  AND c.database_id = tte.database_id
  
  inner join
  @schema.@sccs_table_prefixdiagnostics_summary ds
  ON ds.database_id = tte.database_id
  AND ds.covariate_id  = c.covariate_id 
  AND ds.analysis_id = tte.analysis_id
  AND ds.exposures_outcome_set_id = tte.exposures_outcome_set_id
  
  INNER JOIN  
   @schema.@sccs_table_prefixexposures_outcome_set eos
   on eos.exposures_outcome_set_id = tte.exposures_outcome_set_id
   
   left join
   @schema.@cg_table_prefixcohort_definition as c2
   on c2.cohort_definition_id = tte.era_id
   
   left join
   @schema.@cg_table_prefixcohort_definition as c3
   on c3.cohort_definition_id = eos.outcome_id
   
   left join
   @schema.@cg_table_prefixcohort_definition as c1
   on c1.cohort_definition_id = eos.nesting_cohort_id
   
   inner join
   @schema.@sccs_table_prefixanalysis as a
   on a.analysis_id = tte.analysis_id
   
   inner join
   @schema.@database_table as db
   on db.database_id = tte.database_id
  

  WHERE 
  1 = 1
  {@use_databases}?{ AND tte.database_id in (@database_ids) }
  {@use_targets}?{ AND tte.era_id  in (@target_ids)}
  {@use_analyses}?{ AND tte.analysis_id in (@analysis_ids)}
  {@use_eos}?{ AND tte.exposures_outcome_set_id in (@exposures_outcome_set_ids)}
  {@use_outcomes}?{ AND eos.outcome_id in (@outcome_ids)}
  {@use_indications}?{ AND eos.nesting_id in (@indication_ids)}
  ;
  "
  
  timeToEvent <- connectionHandler$queryDb(
    sql,
    schema = schema,
    sccs_table_prefix = sccsTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable,
    use_eos = !is.null(exposuresOutcomeSetIds),
    exposures_outcome_set_ids = paste0(exposuresOutcomeSetIds, collapse = ','),
    use_outcomes = !is.null(outcomeIds),
    outcome_ids = paste0(outcomeIds, collapse = ','),
    use_targets = !is.null(targetIds),
    target_ids = paste0(targetIds, collapse = ','),
    use_databases = !is.null(databaseIds),
    database_ids = paste0("'",databaseIds,"'", collapse = ','),
    use_analyses = !is.null(analysisIds),
    analysis_ids = paste0(analysisIds, collapse = ','),
    use_indications = !is.null(indicationIds),
    indication_ids = paste0(indicationIds, collapse = ','),
    snakeCaseToCamelCase = TRUE
  )
  
  return(timeToEvent)
}