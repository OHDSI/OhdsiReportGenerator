# @file SccQueries.R
#
# Copyright 2026 Observational Health Data Sciences and Informatics
#
# This file is part of OhdsiReportGenerator
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' Quote and join values for use in an SQL IN clause
#' @param values A vector of character values
#' @return A single comma separated and quoted string
.sccQuoteLiterals <- function(values) {
  if (is.null(values) || length(values) == 0) {
    return("''")
  }
  values <- gsub("'", "''", as.character(values))
  return(paste0("'", values, "'", collapse = ","))
}

#' Extract the self controlled cohort analysis settings
#'
#' @details
#' Returns the analysis settings used by the SelfControlledCohort analyses
#'
#' @template connectionHandler
#' @template schema
#' @template sccTablePrefix
#' @family SelfControlledCohort
#' @return
#' A data.frame with the analysis settings
#' @export
getSccAnalysisSettings <- function(
    connectionHandler,
    schema,
    sccTablePrefix = 'scc_'
) {
  sql <- "
    SELECT
      analysis_id,
      description,
      settings
    FROM @schema.@scc_table_prefixanalysis_setting
    ORDER BY analysis_id
    ;
  "
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    scc_table_prefix = sccTablePrefix
  )
  return(result)
}

#' Extract the targets (exposure cohorts) used in the self controlled cohort analyses
#'
#' @details
#' Returns the distinct exposure cohorts (targets) that have self controlled
#' cohort results for exposure-outcome pairs of interest (i.e. pairs that are
#' not negative controls)
#'
#' @template connectionHandler
#' @template schema
#' @template sccTablePrefix
#' @template cgTablePrefix
#' @param analysisIds A vector of analysis ids to restrict the targets to
#' @family SelfControlledCohort
#' @return
#' A data.frame with the columns cohortDefinitionId and cohortName
#' @export
getSccTargets <- function(
    connectionHandler,
    schema,
    sccTablePrefix = 'scc_',
    cgTablePrefix = 'cg_',
    analysisIds = NULL
) {
  sql <- "
    SELECT DISTINCT
      cg.cohort_definition_id,
      cg.cohort_name
    FROM @schema.@scc_table_prefixoutcome_exposure oex
    INNER JOIN @schema.@cg_table_prefixcohort_definition cg
      ON cg.cohort_definition_id = oex.target_cohort_id
    WHERE oex.true_effect_size IS NULL
    {@restrict_analysis}?{
      AND EXISTS (
        SELECT 1 FROM @schema.@scc_table_prefixresult sr
        WHERE sr.target_cohort_id = oex.target_cohort_id
          AND sr.outcome_cohort_id = oex.outcome_cohort_id
          AND sr.analysis_id IN (@analysis_ids)
      )
    }
    ORDER BY cg.cohort_name
    ;
  "
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    scc_table_prefix = sccTablePrefix,
    cg_table_prefix = cgTablePrefix,
    analysis_ids = paste(analysisIds, collapse = ','),
    restrict_analysis = !is.null(analysisIds)
  )
  return(result)
}

#' Extract the outcomes used in the self controlled cohort analyses
#'
#' @details
#' Returns the distinct outcome cohorts that have self controlled cohort
#' results for exposure-outcome pairs of interest (i.e. pairs that are not
#' negative controls)
#'
#' @template connectionHandler
#' @template schema
#' @template sccTablePrefix
#' @template cgTablePrefix
#' @param analysisIds A vector of analysis ids to restrict the outcomes to
#' @param targetIds A vector of target cohort ids to restrict the outcomes to
#' @family SelfControlledCohort
#' @return
#' A data.frame with the columns cohortDefinitionId and cohortName
#' @export
getSccOutcomes <- function(
    connectionHandler,
    schema,
    sccTablePrefix = 'scc_',
    cgTablePrefix = 'cg_',
    analysisIds = NULL,
    targetIds = NULL
) {
  sql <- "
    SELECT DISTINCT
      cg.cohort_definition_id,
      cg.cohort_name
    FROM @schema.@scc_table_prefixoutcome_exposure oex
    INNER JOIN @schema.@cg_table_prefixcohort_definition cg
      ON cg.cohort_definition_id = oex.outcome_cohort_id
    WHERE oex.true_effect_size IS NULL
    {@restrict_target}?{ AND oex.target_cohort_id IN (@target_ids)}
    {@restrict_analysis}?{
      AND EXISTS (
        SELECT 1 FROM @schema.@scc_table_prefixresult sr
        WHERE sr.target_cohort_id = oex.target_cohort_id
          AND sr.outcome_cohort_id = oex.outcome_cohort_id
          AND sr.analysis_id IN (@analysis_ids)
      )
    }
    ORDER BY cg.cohort_name
    ;
  "
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    scc_table_prefix = sccTablePrefix,
    cg_table_prefix = cgTablePrefix,
    target_ids = paste(targetIds, collapse = ','),
    restrict_target = !is.null(targetIds),
    analysis_ids = paste(analysisIds, collapse = ','),
    restrict_analysis = !is.null(analysisIds)
  )
  return(result)
}

#' Extract the self controlled cohort effect estimates per database
#'
#' @description
#' Returns the per database incidence rate ratio estimates for the selected
#' exposure (target) and outcome cohort pairs.  Effect estimates are only
#' returned for exposure-outcome pairs that have been unblinded - the blinding
#' status is taken from the UNBLIND diagnostic stored in the
#' scc_diagnostics_summary table
#'
#' @details
#' Specify the connectionHandler, the schema and the optional target/outcome/analysis
#' cohort identifiers to restrict the results
#'
#' @template connectionHandler
#' @template schema
#' @template sccTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @param analysisIds A vector of analysis ids to restrict the results to
#' @param targetIds A vector of target cohort ids to restrict the results to
#' @param outcomeIds A vector of outcome cohort ids to restrict the results to
#' @family SelfControlledCohort
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the database name}
#'  \item{databaseId the unique identifier for the database}
#'  \item{analysisId the analysis unique identifier}
#'  \item{description an analysis description}
#'  \item{targetId the target cohort id}
#'  \item{targetName the target cohort name}
#'  \item{outcomeId the outcome cohort id}
#'  \item{outcomeName the outcome cohort name}
#'  \item{rr the incidence rate ratio}
#'  \item{seLogRr the standard error of the log incidence rate ratio}
#'  \item{lb95 lower bound of the 95% confidence interval}
#'  \item{ub95 upper bound of the 95% confidence interval}
#'  \item{pValue the p value}
#'  \item{calibratedRr the empirically calibrated incidence rate ratio}
#'  \item{calibratedSeLogRr the standard error of the calibrated log incidence rate ratio}
#'  \item{calibratedLb95 lower bound of the calibrated 95% confidence interval}
#'  \item{calibratedUb95 upper bound of the calibrated 95% confidence interval}
#'  \item{calibratedPValue the calibrated p value}
#'  \item{numPersons the number of persons}
#'  \item{timeAtRiskExposed the exposed time at risk}
#'  \item{timeAtRiskUnexposed the unexposed time at risk}
#'  \item{numOutcomesExposed the number of outcomes while exposed}
#'  \item{numOutcomesUnexposed the number of outcomes while unexposed}
#'  \item{numExposures the number of exposures}
#'  \item{i2 the I squared heterogeneity statistic}
#'  \item{unblind whether the exposure-outcome pair has been unblinded in the
#'    database (effect estimates are returned as NA while blinded)}
#'  }
#' @export
getSccEstimation <- function(
    connectionHandler,
    schema,
    sccTablePrefix = 'scc_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    analysisIds = NULL,
    targetIds = NULL,
    outcomeIds = NULL
) {
  sql <- "
  SELECT
    ds.cdm_source_abbreviation as database_name,
    sr.database_id,
    sr.analysis_id,
    a.description,
    sr.target_cohort_id as target_id,
    cgt.cohort_name as target_name,
    sr.outcome_cohort_id as outcome_id,
    cgo.cohort_name as outcome_name,

    case when COALESCE(sdun.diagnostic_value, 0) = 0 then NULL else sr.rr end rr,
    case when COALESCE(sdun.diagnostic_value, 0) = 0 then NULL else sr.se_log_rr end se_log_rr,
    case when COALESCE(sdun.diagnostic_value, 0) = 0 then NULL else sr.lb_95 end lb_95,
    case when COALESCE(sdun.diagnostic_value, 0) = 0 then NULL else sr.ub_95 end ub_95,
    case when COALESCE(sdun.diagnostic_value, 0) = 0 then NULL else sr.p_value end p_value,
    case when COALESCE(sdun.diagnostic_value, 0) = 0 then NULL else sr.calibrated_rr end calibrated_rr,
    case when COALESCE(sdun.diagnostic_value, 0) = 0 then NULL else sr.calibrated_se_log_rr end calibrated_se_log_rr,
    case when COALESCE(sdun.diagnostic_value, 0) = 0 then NULL else sr.calibrated_lb_95 end calibrated_lb_95,
    case when COALESCE(sdun.diagnostic_value, 0) = 0 then NULL else sr.calibrated_ub_95 end calibrated_ub_95,
    case when COALESCE(sdun.diagnostic_value, 0) = 0 then NULL else sr.calibrated_p_value end calibrated_p_value,
    sdun.diagnostic_value as unblind,
    sr.num_persons,
    sr.time_at_risk_exposed,
    sr.time_at_risk_unexposed,
    sr.num_outcomes_exposed,
    sr.num_outcomes_unexposed,
    sr.num_exposures,
    sr.i2

  FROM @schema.@scc_table_prefixresult sr
  INNER JOIN @schema.@database_table ds
    ON sr.database_id = ds.database_id
  INNER JOIN @schema.@cg_table_prefixcohort_definition cgt
    ON cgt.cohort_definition_id = sr.target_cohort_id
  INNER JOIN @schema.@cg_table_prefixcohort_definition cgo
    ON cgo.cohort_definition_id = sr.outcome_cohort_id
  INNER JOIN @schema.@scc_table_prefixanalysis_setting a
    ON a.analysis_id = sr.analysis_id
  LEFT JOIN @schema.@scc_table_prefixdiagnostics_summary sdun ON (
    sdun.database_id = sr.database_id AND
    sdun.analysis_id = sr.analysis_id AND
    sdun.target_cohort_id = sr.target_cohort_id AND
    sdun.outcome_cohort_id = sr.outcome_cohort_id AND
    sdun.diagnostic_name = 'UNBLIND'
  )

  WHERE 1 = 1
  {@restrict_analysis}?{ AND sr.analysis_id IN (@analysis_ids)}
  {@restrict_target}?{ AND sr.target_cohort_id IN (@target_ids)}
  {@restrict_outcome}?{ AND sr.outcome_cohort_id IN (@outcome_ids)}
  ;
  "
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    scc_table_prefix = sccTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable,
    analysis_ids = paste(analysisIds, collapse = ','),
    restrict_analysis = !is.null(analysisIds),
    target_ids = paste(targetIds, collapse = ','),
    restrict_target = !is.null(targetIds),
    outcome_ids = paste(outcomeIds, collapse = ','),
    restrict_outcome = !is.null(outcomeIds)
  )
  return(result)
}

#' Extract the self controlled cohort meta analytic (evidence synthesis) results
#'
#' @description
#' Returns the meta analytic (evidence synthesis) effect estimates for the
#' selected exposure (target) and outcome cohort pairs.  This function reads
#' the es_scc_* tables created by running the evidence synthesis module on
#' self controlled cohort results.
#'
#' @details
#' Specify the connectionHandler, the schema and the optional target/outcome/analysis
#' cohort identifiers to restrict the results
#'
#' @template connectionHandler
#' @template schema
#' @template sccTablePrefix
#' @template cgTablePrefix
#' @template esTablePrefix
#' @param analysisIds A vector of analysis ids to restrict the results to
#' @param targetIds A vector of target cohort ids to restrict the results to
#' @param outcomeIds A vector of outcome cohort ids to restrict the results to
#' @param evidenceSynthesisAnalysisIds A vector of evidence synthesis analysis ids to restrict the results to
#' @family SelfControlledCohort
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the evidence synthesis description used as the database name}
#'  \item{databaseId the evidence synthesis analysis id}
#'  \item{analysisId the analysis unique identifier}
#'  \item{description an analysis description}
#'  \item{targetId the target cohort id}
#'  \item{targetName the target cohort name}
#'  \item{outcomeId the outcome cohort id}
#'  \item{outcomeName the outcome cohort name}
#'  \item{evidenceSynthesisAnalysisId the evidence synthesis analysis identifier}
#'  \item{rr the meta analytic incidence rate ratio}
#'  \item{seLogRr the standard error of the log incidence rate ratio}
#'  \item{ci95Lb lower bound of the 95% confidence interval}
#'  \item{ci95Ub upper bound of the 95% confidence interval}
#'  \item{p the p value}
#'  \item{calibratedRr the calibrated incidence rate ratio}
#'  \item{calibratedSeLogRr the standard error of the calibrated log incidence rate ratio}
#'  \item{calibratedCi95Lb lower bound of the calibrated 95% confidence interval}
#'  \item{calibratedCi95Ub upper bound of the calibrated 95% confidence interval}
#'  \item{calibratedP the calibrated p value}
#'  \item{numPersons the number of persons}
#'  \item{timeAtRiskExposed the exposed time at risk}
#'  \item{timeAtRiskUnexposed the unexposed time at risk}
#'  \item{numOutcomesExposed the number of outcomes while exposed}
#'  \item{numOutcomesUnexposed the number of outcomes while unexposed}
#'  \item{numExposures the number of exposures}
#'  \item{nDatabases the number of databases in the meta analysis}
#'  \item{i2 the I squared heterogeneity statistic}
#'  \item{tau the between database heterogeneity}
#'  \item{ease the expected absolute systematic error}
#'  \item{mdrr the minimum detectable relative risk}
#'  \item{unblind whether the results are unblinded}
#'  }
#' @export
getSccMetaEstimation <- function(
    connectionHandler,
    schema,
    sccTablePrefix = 'scc_',
    cgTablePrefix = 'cg_',
    esTablePrefix = 'es_',
    analysisIds = NULL,
    targetIds = NULL,
    outcomeIds = NULL,
    evidenceSynthesisAnalysisIds = NULL
) {
  sql <- "
  SELECT
    ev.evidence_synthesis_description as database_name,
    ev.evidence_synthesis_analysis_id as database_id,
    esr.analysis_id,
    a.description,
    esr.target_cohort_id as target_id,
    cgt.cohort_name as target_name,
    esr.outcome_cohort_id as outcome_id,
    cgo.cohort_name as outcome_name,
    esr.evidence_synthesis_analysis_id,

    case when COALESCE(esds.unblind, 0) = 0 then NULL else esr.rr end rr,
    case when COALESCE(esds.unblind, 0) = 0 then NULL else esr.se_log_rr end se_log_rr,
    case when COALESCE(esds.unblind, 0) = 0 then NULL else esr.ci_95_lb end ci_95_lb,
    case when COALESCE(esds.unblind, 0) = 0 then NULL else esr.ci_95_ub end ci_95_ub,
    case when COALESCE(esds.unblind, 0) = 0 then NULL else esr.p end p,
    case when COALESCE(esds.unblind, 0) = 0 then NULL else esr.calibrated_rr end calibrated_rr,
    case when COALESCE(esds.unblind, 0) = 0 then NULL else esr.calibrated_se_log_rr end calibrated_se_log_rr,
    case when COALESCE(esds.unblind, 0) = 0 then NULL else esr.calibrated_ci_95_lb end calibrated_ci_95_lb,
    case when COALESCE(esds.unblind, 0) = 0 then NULL else esr.calibrated_ci_95_ub end calibrated_ci_95_ub,
    case when COALESCE(esds.unblind, 0) = 0 then NULL else esr.calibrated_p end calibrated_p,

    esr.num_persons,
    esr.time_at_risk_exposed,
    esr.time_at_risk_unexposed,
    esr.num_outcomes_exposed,
    esr.num_outcomes_unexposed,
    esr.num_exposures,
    esr.n_databases,

    esds.i_2 as i2,
    esds.tau,
    esds.ease,
    esds.mdrr,
    esds.unblind

  FROM @schema.@es_table_prefixscc_result esr
  INNER JOIN @schema.@es_table_prefixscc_diagnostics_summary esds ON (
    esds.target_cohort_id = esr.target_cohort_id AND
    esds.outcome_cohort_id = esr.outcome_cohort_id AND
    esds.analysis_id = esr.analysis_id AND
    esds.evidence_synthesis_analysis_id = esr.evidence_synthesis_analysis_id
  )
  INNER JOIN @schema.@es_table_prefixanalysis ev
    ON ev.evidence_synthesis_analysis_id = esr.evidence_synthesis_analysis_id
  INNER JOIN @schema.@cg_table_prefixcohort_definition cgt
    ON cgt.cohort_definition_id = esr.target_cohort_id
  INNER JOIN @schema.@cg_table_prefixcohort_definition cgo
    ON cgo.cohort_definition_id = esr.outcome_cohort_id
  INNER JOIN @schema.@scc_table_prefixanalysis_setting a
    ON a.analysis_id = esr.analysis_id

  WHERE 1 = 1
  {@restrict_analysis}?{ AND esr.analysis_id IN (@analysis_ids)}
  {@restrict_target}?{ AND esr.target_cohort_id IN (@target_ids)}
  {@restrict_outcome}?{ AND esr.outcome_cohort_id IN (@outcome_ids)}
  {@restrict_es}?{ AND esr.evidence_synthesis_analysis_id IN (@es_ids)}
  ;
  "
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    scc_table_prefix = sccTablePrefix,
    cg_table_prefix = cgTablePrefix,
    es_table_prefix = esTablePrefix,
    analysis_ids = paste(analysisIds, collapse = ','),
    restrict_analysis = !is.null(analysisIds),
    target_ids = paste(targetIds, collapse = ','),
    restrict_target = !is.null(targetIds),
    outcome_ids = paste(outcomeIds, collapse = ','),
    restrict_outcome = !is.null(outcomeIds),
    es_ids = paste(evidenceSynthesisAnalysisIds, collapse = ','),
    restrict_es = !is.null(evidenceSynthesisAnalysisIds)
  )
  if (nrow(result) > 0) {
    result$databaseId <- as.character(result$databaseId)
  }
  return(result)
}

#' Extract the self controlled cohort diagnostic summary
#'
#' @description
#' Returns the per database diagnostic summary for the selected exposure
#' (target) and outcome cohort pairs
#'
#' @details
#' Specify the connectionHandler, the schema and the optional target/outcome/analysis
#' cohort identifiers to restrict the results
#'
#' @template connectionHandler
#' @template schema
#' @template sccTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @param analysisIds A vector of analysis ids to restrict the results to
#' @param targetIds A vector of target cohort ids to restrict the results to
#' @param outcomeIds A vector of outcome cohort ids to restrict the results to
#' @family SelfControlledCohort
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{databaseName the database name}
#'  \item{databaseId the unique identifier for the database}
#'  \item{analysisId the analysis unique identifier}
#'  \item{description an analysis description}
#'  \item{targetId the target cohort id}
#'  \item{targetName the target cohort name}
#'  \item{outcomeId the outcome cohort id}
#'  \item{outcomeName the outcome cohort name}
#'  \item{unblind whether the pair is unblinded}
#'  \item{diagnostics a list column of the diagnostic values}
#'  \item{summaryValue a summary of the diagnostic pass/fail status}
#'  }
#' @export
getSccDiagnosticsData <- function(
    connectionHandler,
    schema,
    sccTablePrefix = 'scc_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    analysisIds = NULL,
    targetIds = NULL,
    outcomeIds = NULL
) {
  sql <- "
  SELECT
    ds.cdm_source_abbreviation as database_name,
    sd.database_id,
    sd.analysis_id,
    a.description,
    sd.target_cohort_id as target_id,
    cgt.cohort_name as target_name,
    sd.outcome_cohort_id as outcome_id,
    cgo.cohort_name as outcome_name,
    sd.diagnostic_name,
    sd.diagnostic_value,
    sd.pass
  FROM @schema.@scc_table_prefixdiagnostics_summary sd
  INNER JOIN @schema.@database_table ds
    ON sd.database_id = ds.database_id
  INNER JOIN @schema.@cg_table_prefixcohort_definition cgt
    ON cgt.cohort_definition_id = sd.target_cohort_id
  INNER JOIN @schema.@cg_table_prefixcohort_definition cgo
    ON cgo.cohort_definition_id = sd.outcome_cohort_id
  INNER JOIN @schema.@scc_table_prefixanalysis_setting a
    ON a.analysis_id = sd.analysis_id
  WHERE 1 = 1
  {@restrict_analysis}?{ AND sd.analysis_id IN (@analysis_ids)}
  {@restrict_target}?{ AND sd.target_cohort_id IN (@target_ids)}
  {@restrict_outcome}?{ AND sd.outcome_cohort_id IN (@outcome_ids)}
  ;
  "

  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    scc_table_prefix = sccTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable,
    analysis_ids = paste(analysisIds, collapse = ','),
    restrict_analysis = !is.null(analysisIds),
    target_ids = paste(targetIds, collapse = ','),
    restrict_target = !is.null(targetIds),
    outcome_ids = paste(outcomeIds, collapse = ','),
    restrict_outcome = !is.null(outcomeIds)
  )

  if (nrow(result) == 0) {
    return(result)
  }

  # pivots the long diagnostic rows into wide columns while retaining the
  # pass/fail information for each diagnostic
  colLookup <- .getSccDiagnosticColLookup()

  wide <- result |>
    dplyr::group_by(
      .data$databaseId, .data$databaseName, .data$analysisId,
      .data$description, .data$targetId, .data$targetName,
      .data$outcomeId, .data$outcomeName
    ) |>
    dplyr::reframe(
      value = .data$diagnosticName,
      diagnosticValue = .data$diagnosticValue,
      passValue = .data$pass
    ) |>
    tidyr::pivot_wider(
      id_cols = c(
        "databaseId", "databaseName", "analysisId", "description",
        "targetId", "targetName", "outcomeId", "outcomeName"
      ),
      names_from = "value",
      values_from = "diagnosticValue"
    )

  for (nm in names(colLookup)) {
    if (nm %in% colnames(wide)) {
      newName <- colLookup[[nm]]
      wide <- wide |>
        dplyr::rename(!!rlang::sym(newName) := dplyr::all_of(nm))
    }
  }

  passTable <- result |>
    dplyr::group_by(
      .data$databaseId, .data$analysisId, .data$targetId, .data$outcomeId
    ) |>
    dplyr::summarise(
      nDiagnostics = dplyr::n(),
      nFail = sum(.data$pass == 0, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(summaryValue = dplyr::case_when(
      .data$nFail > 0 ~ "Fail",
      .data$nDiagnostics == 0 ~ "Pass",
      TRUE ~ "Pass"
    )) |>
    dplyr::select(
      "databaseId", "analysisId", "targetId", "outcomeId", "summaryValue"
    )

  wide <- wide |>
    dplyr::left_join(passTable, by = c("databaseId", "analysisId", "targetId", "outcomeId"))

  return(wide)
}

.getSccDiagnosticColLookup <- function() {
  return(c(
    "MDRR" = "mdrr",
    "EASE" = "ease",
    "PRE_EXPOSURE_RATE_RATIO" = "preExposureRateRatio",
    "PRE_EXPOSURE_P_VALUE" = "preExposurePValue",
    "EVENT_DEPENDENT_OBSERVATION" = "eventDependentObservation",
    "UNBLIND" = "unblind",
    "UNBLIND_FOR_CALIBRATION" = "unblindForCalibration"
  ))
}

#' Extract the self controlled cohort summary statistics for boxplots
#'
#' @description
#' Returns the distribution statistics (e.g. time at risk, time to outcome)
#' used to create boxplots for the selected exposure and outcome cohorts
#'
#' @details
#' Specify the connectionHandler, the schema and the optional stat type,
#' target/outcome/analysis identifiers to restrict the results
#'
#' @template connectionHandler
#' @template schema
#' @template sccTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @param statTypes A vector of stat types to restrict the results to
#'   (e.g. time_exposed, time_to_outcome, time_to_outcome_exposed,
#'   time_to_outcome_unexposed)
#' @param analysisIds A vector of analysis ids to restrict the results to
#' @param targetIds A vector of target cohort ids to restrict the results to
#' @param outcomeIds A vector of outcome cohort ids to restrict the results to
#' @family SelfControlledCohort
#' @return
#' Returns a data.frame with the summary statistics per database
#' @export
getSccSummaryStats <- function(
    connectionHandler,
    schema,
    sccTablePrefix = 'scc_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    statTypes = NULL,
    analysisIds = NULL,
    targetIds = NULL,
    outcomeIds = NULL
) {
  sql <- "
  SELECT
    ds.cdm_source_abbreviation as database_name,
    ss.database_id,
    ss.analysis_id,
    a.description,
    ss.target_cohort_id as target_id,
    cgt.cohort_name as target_name,
    ss.outcome_cohort_id as outcome_id,
    cgo.cohort_name as outcome_name,
    ss.stat_type,
    ss.mean,
    ss.sd,
    ss.minimum,
    ss.p10,
    ss.p25,
    ss.median,
    ss.p75,
    ss.p90,
    ss.maximum,
    ss.total
  FROM @schema.@scc_table_prefixstat ss
  INNER JOIN @schema.@database_table ds
    ON ss.database_id = ds.database_id
  INNER JOIN @schema.@cg_table_prefixcohort_definition cgt
    ON cgt.cohort_definition_id = ss.target_cohort_id
  INNER JOIN @schema.@cg_table_prefixcohort_definition cgo
    ON cgo.cohort_definition_id = ss.outcome_cohort_id
  INNER JOIN @schema.@scc_table_prefixanalysis_setting a
    ON a.analysis_id = ss.analysis_id
  WHERE 1 = 1
  {@restrict_stat}?{ AND ss.stat_type IN (@stat_types)}
  {@restrict_analysis}?{ AND ss.analysis_id IN (@analysis_ids)}
  {@restrict_target}?{ AND ss.target_cohort_id IN (@target_ids)}
  {@restrict_outcome}?{ AND ss.outcome_cohort_id IN (@outcome_ids)}
  ;
  "
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    scc_table_prefix = sccTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable,
    stat_types = .sccQuoteLiterals(statTypes),
    restrict_stat = !is.null(statTypes),
    analysis_ids = paste(analysisIds, collapse = ','),
    restrict_analysis = !is.null(analysisIds),
    target_ids = paste(targetIds, collapse = ','),
    restrict_target = !is.null(targetIds),
    outcome_ids = paste(outcomeIds, collapse = ','),
    restrict_outcome = !is.null(outcomeIds)
  )
  return(result)
}

#' Extract the negative control estimates for the self controlled cohort analyses
#'
#' @description
#' Returns the estimates for exposure-outcome pairs that are negative controls
#'
#' @details
#' Specify the connectionHandler, the schema and the target/outcome identifiers.
#' Negative controls are identified via the scc_outcome_exposure table (pairs
#' with a non missing true effect size)
#'
#' @template connectionHandler
#' @template schema
#' @template sccTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @param analysisIds A vector of analysis ids to restrict the results to
#' @param targetIds A vector of target cohort ids to restrict the results to
#' @param outcomeIds A vector of outcome cohort ids to restrict the results to
#' @param databaseIds A vector of database ids to restrict the results to
#' @family SelfControlledCohort
#' @return
#' A data.frame with the negative control estimates
#' @export
getSccNegativeControlEstimates <- function(
    connectionHandler,
    schema,
    sccTablePrefix = 'scc_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    analysisIds = NULL,
    targetIds = NULL,
    outcomeIds = NULL,
    databaseIds = NULL
) {
  sql <- "
  SELECT
    ds.cdm_source_abbreviation as database_name,
    sr.database_id,
    sr.analysis_id,
    a.description,
    sr.target_cohort_id as target_id,
    cgt.cohort_name as target_name,
    sr.outcome_cohort_id as outcome_id,
    cgo.cohort_name as outcome_name,
    oex.true_effect_size,
    sr.rr,
    sr.se_log_rr,
    sr.lb_95,
    sr.ub_95,
    sr.p_value,
    sr.calibrated_rr,
    sr.calibrated_se_log_rr,
    sr.calibrated_lb_95,
    sr.calibrated_ub_95,
    sr.calibrated_p_value
  FROM @schema.@scc_table_prefixresult sr
  INNER JOIN @schema.@scc_table_prefixoutcome_exposure oex ON (
    oex.target_cohort_id = sr.target_cohort_id AND
    oex.outcome_cohort_id = sr.outcome_cohort_id
  )
  INNER JOIN @schema.@database_table ds
    ON sr.database_id = ds.database_id
  INNER JOIN @schema.@cg_table_prefixcohort_definition cgt
    ON cgt.cohort_definition_id = sr.target_cohort_id
  INNER JOIN @schema.@cg_table_prefixcohort_definition cgo
    ON cgo.cohort_definition_id = sr.outcome_cohort_id
  INNER JOIN @schema.@scc_table_prefixanalysis_setting a
    ON a.analysis_id = sr.analysis_id
  WHERE oex.true_effect_size IS NOT NULL
  {@restrict_analysis}?{ AND sr.analysis_id IN (@analysis_ids)}
  {@restrict_target}?{ AND sr.target_cohort_id IN (@target_ids)}
  {@restrict_outcome}?{ AND sr.outcome_cohort_id IN (@outcome_ids)}
  {@restrict_database}?{ AND sr.database_id IN (@database_ids)}
  ;
  "
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    scc_table_prefix = sccTablePrefix,
    cg_table_prefix = cgTablePrefix,
    database_table = databaseTable,
    analysis_ids = paste(analysisIds, collapse = ','),
    restrict_analysis = !is.null(analysisIds),
    target_ids = paste(targetIds, collapse = ','),
    restrict_target = !is.null(targetIds),
    outcome_ids = paste(outcomeIds, collapse = ','),
    restrict_outcome = !is.null(outcomeIds),
    database_ids = .sccQuoteLiterals(databaseIds),
    restrict_database = !is.null(databaseIds)
  )
  return(result)
}
#' Extract the self controlled cohort signal discovery grid
#'
#' @description
#' Returns a table of all exposure (target) - outcome pairs with the number of
#' databases showing a potential benefit (relative risk below the benefit
#' threshold), the number of databases showing a potential risk (relative risk
#' above the risk threshold) and the meta analytic (evidence synthesis)
#' estimate for each pair.  This is the discovery grid used to explore the
#' self controlled cohort results (equivalent to the main table of the
#' legacy REWARD dashboard).
#'
#' @details
#' Specify the connectionHandler, the schema and the filters for the discovery
#' grid.  The benefit and risk counts are based on the per database self
#' controlled cohort results whereas the meta analytic columns are read from
#' the evidence synthesis (es_scc_*) results
#'
#' @template connectionHandler
#' @template schema
#' @template sccTablePrefix
#' @template cgTablePrefix
#' @template esTablePrefix
#' @param analysisIds A vector of analysis ids to restrict the results to
#' @param targetCohorts A vector of target cohort ids to restrict the results to
#' @param outcomeCohorts A vector of outcome cohort ids to restrict the results to
#' @param includeControls Whether to include negative control exposure-outcome
#'   pairs in the grid (default is to only include pairs of interest)
#' @param benefit The relative risk benefit threshold (pairs with a relative
#'   risk at or below this value in a database count as a benefit)
#' @param lowerBenefit The lower bound of the benefit relative risk range
#' @param risk The relative risk risk threshold
#' @param pValueCut The p value cut off used when counting benefits and risks
#' @param calibrated Whether to use the empirically calibrated estimates
#' @param filterByMeta Whether to restrict the returned pairs to those that
#'   show a benefit in the meta analysis
#' @param minBenefitSources The minimum number of databases that need to show
#'   a benefit for the pair to be included
#' @param maxRiskSources The maximum number of databases that can show a risk
#'   for the pair to be included
#' @param requiredDatabases A vector of database ids that must show a benefit
#'   for the pair to be included
#' @param evidenceSynthesisAnalysisIds A vector of evidence synthesis analysis
#'   ids to restrict the meta analytic columns to
#' @param orderByCol The column to order by
#' @param ascending Whether the ordering should be ascending
#' @param limit The maximum number of rows to return
#' @param offset The number of rows to skip
#' @family SelfControlledCohort
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{targetId the target cohort id}
#'  \item{targetName the target cohort name}
#'  \item{outcomeId the outcome cohort id}
#'  \item{outcomeName the outcome cohort name}
#'  \item{benefitCount the number of databases showing a benefit}
#'  \item{riskCount the number of databases showing a risk}
#'  \item{requiredBenefitCount the number of required databases showing a benefit}
#'  \item{metaRr the meta analytic relative risk}
#'  \item{metaP the meta analytic p value}
#'  \item{i2 the meta analytic I squared statistic}
#'  \item{nDatabases the number of databases in the meta analysis}
#'  }
#' @export
getSccSignals <- function(
    connectionHandler,
    schema,
    sccTablePrefix = 'scc_',
    cgTablePrefix = 'cg_',
    esTablePrefix = 'es_',
    analysisIds = NULL,
    targetCohorts = NULL,
    outcomeCohorts = NULL,
    includeControls = FALSE,
    benefit = 0.8,
    lowerBenefit = 0,
    risk = 1.25,
    pValueCut = 0.05,
    calibrated = TRUE,
    filterByMeta = FALSE,
    minBenefitSources = 1,
    maxRiskSources = NULL,
    requiredDatabases = NULL,
    evidenceSynthesisAnalysisIds = NULL,
    orderByCol = NULL,
    ascending = TRUE,
    limit = NULL,
    offset = NULL
) {

  if (is.null(maxRiskSources)) {
    maxRiskSources <- 999
  }
  hasRequired <- !is.null(requiredDatabases)

  orderBy <- ifelse(is.null(orderByCol), "", "")
  if (!is.null(orderByCol)) {
    validCols <- c(
      "targetId", "targetName", "outcomeId", "outcomeName", "benefitCount",
      "riskCount", "requiredBenefitCount", "metaRr", "metaP", "i2", "nDatabases"
    )
    if (!orderByCol %in% validCols) {
      stop(paste0("Invalid orderByCol '", orderByCol,
                  "' - must be one of: ", paste(validCols, collapse = ", ")))
    }
    orderBy <- paste0("ORDER BY ", orderByCol, " ", ifelse(ascending, "ASC", "DESC"))
  }

  sql <- "
  WITH pair_sources AS (
    SELECT
      sr.target_cohort_id,
      sr.outcome_cohort_id,
      sr.database_id,
      case when COALESCE(sdun.diagnostic_value, 0) = 0 then NULL
           else {@cal}?{sr.calibrated_rr}:{sr.rr} end AS measure_rr,
      case when COALESCE(sdun.diagnostic_value, 0) = 0 then NULL
           else {@cal}?{sr.calibrated_p_value}:{sr.p_value} end AS measure_p
    FROM @schema.@scc_table_prefixresult sr
    LEFT JOIN @schema.@scc_table_prefixdiagnostics_summary sdun ON (
      sdun.database_id = sr.database_id AND
      sdun.analysis_id = sr.analysis_id AND
      sdun.target_cohort_id = sr.target_cohort_id AND
      sdun.outcome_cohort_id = sr.outcome_cohort_id AND
      sdun.diagnostic_name = 'UNBLIND'
    )
    WHERE 1 = 1
    {@restrict_analysis}?{ AND sr.analysis_id IN (@analysis_ids)}
  ),
  benefit_t AS (
    SELECT
      target_cohort_id,
      outcome_cohort_id,
      COUNT(DISTINCT database_id) AS benefit_count
    FROM pair_sources
    WHERE measure_rr <= @benefit AND measure_rr >= @lower_benefit AND measure_p < @p_cut_value
    GROUP BY target_cohort_id, outcome_cohort_id
  ),
  risk_t AS (
    SELECT
      target_cohort_id,
      outcome_cohort_id,
      COUNT(DISTINCT database_id) AS risk_count
    FROM pair_sources
    WHERE measure_rr >= @risk AND measure_p < @p_cut_value
    GROUP BY target_cohort_id, outcome_cohort_id
  )
  {@has_required}?{
  , required_t AS (
    SELECT
      target_cohort_id,
      outcome_cohort_id,
      COUNT(DISTINCT database_id) AS required_benefit_count
    FROM pair_sources
    WHERE measure_rr <= @benefit AND measure_rr >= @lower_benefit AND measure_p < @p_cut_value
      AND database_id IN (@required_databases)
    GROUP BY target_cohort_id, outcome_cohort_id
  )
  }
  SELECT
    fr.target_cohort_id AS target_id,
    cgt.cohort_name AS target_name,
    fr.outcome_cohort_id AS outcome_id,
    cgo.cohort_name AS outcome_name,
    COALESCE(bt.benefit_count, 0) AS benefit_count,
    COALESCE(rt.risk_count, 0) AS risk_count,
    {@has_required}?{COALESCE(rq.required_benefit_count, 0) AS required_benefit_count,}
    mr.meta_rr,
    mr.meta_p,
    mr.i2,
    mr.n_databases
  FROM (
    SELECT DISTINCT rs.target_cohort_id, rs.outcome_cohort_id
    FROM @schema.@scc_table_prefixresult rs
    {@exclude_controls}?{
    INNER JOIN @schema.@scc_table_prefixoutcome_exposure oex
      ON oex.target_cohort_id = rs.target_cohort_id AND
         oex.outcome_cohort_id = rs.outcome_cohort_id
    }
    WHERE 1 = 1
    {@exclude_controls}?{ AND oex.true_effect_size IS NULL}
    {@restrict_analysis}?{ AND rs.analysis_id IN (@analysis_ids)}
  ) fr
  INNER JOIN @schema.@cg_table_prefixcohort_definition cgt
    ON cgt.cohort_definition_id = fr.target_cohort_id
  INNER JOIN @schema.@cg_table_prefixcohort_definition cgo
    ON cgo.cohort_definition_id = fr.outcome_cohort_id
  LEFT JOIN benefit_t bt ON
    bt.target_cohort_id = fr.target_cohort_id AND
    bt.outcome_cohort_id = fr.outcome_cohort_id
  LEFT JOIN risk_t rt ON
    rt.target_cohort_id = fr.target_cohort_id AND
    rt.outcome_cohort_id = fr.outcome_cohort_id
  {@has_required}?{
  LEFT JOIN required_t rq ON
    rq.target_cohort_id = fr.target_cohort_id AND
    rq.outcome_cohort_id = fr.outcome_cohort_id
  }
  LEFT JOIN (
    SELECT
      esr.target_cohort_id,
      esr.outcome_cohort_id,
      CASE WHEN COALESCE(esds.unblind, 0) = 0 THEN NULL
           ELSE {@cal}?{esr.calibrated_rr}:{esr.rr} END AS meta_rr,
      CASE WHEN COALESCE(esds.unblind, 0) = 0 THEN NULL
           ELSE {@cal}?{esr.calibrated_p}:{esr.p} END AS meta_p,
      esds.i_2 AS i2,
      esr.n_databases
    FROM @schema.@es_table_prefixscc_result esr
    INNER JOIN @schema.@es_table_prefixscc_diagnostics_summary esds ON (
      esds.target_cohort_id = esr.target_cohort_id AND
      esds.outcome_cohort_id = esr.outcome_cohort_id AND
      esds.analysis_id = esr.analysis_id AND
      esds.evidence_synthesis_analysis_id = esr.evidence_synthesis_analysis_id
    )
    WHERE 1 = 1
    {@restrict_analysis}?{ AND esr.analysis_id IN (@analysis_ids)}
    {@restrict_es}?{ AND esr.evidence_synthesis_analysis_id IN (@es_ids)}
  ) mr ON
    mr.target_cohort_id = fr.target_cohort_id AND
    mr.outcome_cohort_id = fr.outcome_cohort_id

  WHERE 1 = 1
  {@restrict_target}?{ AND cgt.cohort_definition_id IN (@target_cohorts)}
  {@restrict_outcome}?{ AND cgo.cohort_definition_id IN (@outcome_cohorts)}
  {@filter_meta}?{
    AND mr.meta_rr <= @benefit AND mr.meta_rr >= @lower_benefit
    AND mr.meta_p < @p_cut_value AND mr.meta_rr IS NOT NULL
  } : {
    AND COALESCE(bt.benefit_count, 0) >= @min_benefit_sources
    AND COALESCE(rt.risk_count, 0) <= @max_risk_sources
  }
  {@has_required}?{ AND COALESCE(rq.required_benefit_count, 0) >= @required_source_count}
  {@has_order}?{ @order_by }
  {@has_limit}?{ LIMIT @limit {@has_offset}?{ OFFSET @offset} }
  ;
  "

  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    scc_table_prefix = sccTablePrefix,
    cg_table_prefix = cgTablePrefix,
    es_table_prefix = esTablePrefix,
    cal = calibrated,
    analysis_ids = ifelse(is.null(analysisIds), "", paste(analysisIds, collapse = ",")),
    restrict_analysis = !is.null(analysisIds),
    target_cohorts = ifelse(is.null(targetCohorts), "", paste(targetCohorts, collapse = ",")),
    restrict_target = !is.null(targetCohorts),
    outcome_cohorts = ifelse(is.null(outcomeCohorts), "", paste(outcomeCohorts, collapse = ",")),
    restrict_outcome = !is.null(outcomeCohorts),
    exclude_controls = !isTRUE(includeControls),
    benefit = benefit,
    lower_benefit = lowerBenefit,
    risk = risk,
    p_cut_value = pValueCut,
    filter_meta = isTRUE(filterByMeta),
    min_benefit_sources = minBenefitSources,
    max_risk_sources = maxRiskSources,
    has_required = hasRequired,
    required_databases = ifelse(hasRequired, .sccQuoteLiterals(requiredDatabases), ""),
    required_source_count = ifelse(hasRequired, length(requiredDatabases), 0),
    es_ids = ifelse(is.null(evidenceSynthesisAnalysisIds), "", paste(evidenceSynthesisAnalysisIds, collapse = ",")),
    restrict_es = !is.null(evidenceSynthesisAnalysisIds),
    order_by = orderBy,
    has_order = nchar(orderBy) > 0,
    limit = ifelse(is.null(limit), "", limit),
    has_limit = !is.null(limit),
    offset = ifelse(is.null(offset), "", offset),
    has_offset = !is.null(offset)
  )

  return(result)
}

#' Extract the meta analytic target-outcome pair exploration results
#'
#' @description
#' Returns a table of all exposure (target) - outcome pairs at the meta
#' analytic (evidence synthesis) level together with the counts, descriptive
#' statistics and study diagnostics.  Descriptive statistics (number of
#' outcomes / exposures etc) are returned for every pair regardless of whether
#' it passed the study diagnostics.  Pairs (evidence synthesis analyses) that
#' failed a study diagnostic are treated as blinded - their effect estimates
#' are returned as NA
#'
#' @details
#' Specify the connectionHandler, the schema and the optional target/outcome/analysis
#' cohort identifiers to restrict the results
#'
#' @template connectionHandler
#' @template schema
#' @template sccTablePrefix
#' @template cgTablePrefix
#' @template esTablePrefix
#' @param analysisIds A vector of analysis ids to restrict the results to
#' @param targetIds A vector of target cohort ids to restrict the results to
#' @param outcomeIds A vector of outcome cohort ids to restrict the results to
#' @param evidenceSynthesisAnalysisIds A vector of evidence synthesis analysis ids to restrict the results to
#' @family SelfControlledCohort
#' @return
#' Returns a data.frame with the meta analytic estimates, counts, descriptive
#' statistics and study diagnostics.  Effect estimate columns are NA for any
#' evidence synthesis analysis that failed a study diagnostic
#' @export
getSccMetaExploration <- function(
    connectionHandler,
    schema,
    sccTablePrefix = 'scc_',
    cgTablePrefix = 'cg_',
    esTablePrefix = 'es_',
    analysisIds = NULL,
    targetIds = NULL,
    outcomeIds = NULL,
    evidenceSynthesisAnalysisIds = NULL
) {
  sql <- "
  SELECT
    ev.evidence_synthesis_description as database_name,
    esr.evidence_synthesis_analysis_id,
    esr.analysis_id,
    a.description,
    esr.target_cohort_id as target_id,
    cgt.cohort_name as target_name,
    esr.outcome_cohort_id as outcome_id,
    cgo.cohort_name as outcome_name,

    esr.num_persons,
    esr.time_at_risk_exposed,
    esr.time_at_risk_unexposed,
    esr.num_outcomes_exposed,
    esr.num_outcomes_unexposed,
    esr.num_exposures,
    esr.n_databases,

    esds.mdrr,
    esds.i_2 as i2,
    esds.tau,
    esds.ease,
    esds.mdrr_diagnostic,
    esds.i_2_diagnostic as i2_diagnostic,
    esds.tau_diagnostic,
    esds.ease_diagnostic,
    esds.unblind,

    esr.rr,
    esr.ci_95_lb,
    esr.ci_95_ub,
    esr.p,
    esr.calibrated_rr,
    esr.calibrated_ci_95_lb,
    esr.calibrated_ci_95_ub,
    esr.calibrated_p

  FROM @schema.@es_table_prefixscc_result esr
  INNER JOIN @schema.@es_table_prefixscc_diagnostics_summary esds ON (
    esds.target_cohort_id = esr.target_cohort_id AND
    esds.outcome_cohort_id = esr.outcome_cohort_id AND
    esds.analysis_id = esr.analysis_id AND
    esds.evidence_synthesis_analysis_id = esr.evidence_synthesis_analysis_id
  )
  INNER JOIN @schema.@es_table_prefixanalysis ev
    ON ev.evidence_synthesis_analysis_id = esr.evidence_synthesis_analysis_id
  INNER JOIN @schema.@cg_table_prefixcohort_definition cgt
    ON cgt.cohort_definition_id = esr.target_cohort_id
  INNER JOIN @schema.@cg_table_prefixcohort_definition cgo
    ON cgo.cohort_definition_id = esr.outcome_cohort_id
  INNER JOIN @schema.@scc_table_prefixanalysis_setting a
    ON a.analysis_id = esr.analysis_id

  WHERE 1 = 1
  {@restrict_analysis}?{ AND esr.analysis_id IN (@analysis_ids)}
  {@restrict_target}?{ AND esr.target_cohort_id IN (@target_ids)}
  {@restrict_outcome}?{ AND esr.outcome_cohort_id IN (@outcome_ids)}
  {@restrict_es}?{ AND esr.evidence_synthesis_analysis_id IN (@es_ids)}
  ;
  "

  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    scc_table_prefix = sccTablePrefix,
    cg_table_prefix = cgTablePrefix,
    es_table_prefix = esTablePrefix,
    analysis_ids = ifelse(is.null(analysisIds), "", paste(analysisIds, collapse = ",")),
    restrict_analysis = !is.null(analysisIds),
    target_ids = ifelse(is.null(targetIds), "", paste(targetIds, collapse = ",")),
    restrict_target = !is.null(targetIds),
    outcome_ids = ifelse(is.null(outcomeIds), "", paste(outcomeIds, collapse = ",")),
    restrict_outcome = !is.null(outcomeIds),
    es_ids = ifelse(is.null(evidenceSynthesisAnalysisIds), "", paste(evidenceSynthesisAnalysisIds, collapse = ",")),
    restrict_es = !is.null(evidenceSynthesisAnalysisIds)
  )

  if (nrow(result) == 0) {
    return(result)
  }

  # determine the overall pass/fail status from the study diagnostics and
  # blind (mask) the effect estimates of any failed evidence synthesis
  # analysis
  statusCols <- c("mdrrDiagnostic", "i2Diagnostic", "tauDiagnostic", "easeDiagnostic")
  failed <- rep(FALSE, nrow(result))
  for (col in statusCols) {
    if (col %in% colnames(result)) {
      colFail <- !is.na(result[[col]]) &
        tolower(as.character(result[[col]])) == "fail"
      failed <- failed | colFail
    }
  }
  result$overallStatus <- ifelse(failed, "Fail", "Pass")
  result$unblind <- as.numeric(result$unblind)

  unblinded <- !is.na(result$unblind) & result$unblind == 1
  showEffect <- unblinded & !failed

  maskCols <- c(
    "rr", "ci95Lb", "ci95Ub", "p",
    "calibratedRr", "calibratedCi95Lb", "calibratedCi95Ub", "calibratedP"
  )
  for (col in maskCols) {
    if (col %in% colnames(result)) {
      result[[col]][!showEffect] <- NA
    }
  }

  return(result)
}
