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
  NULL as time_stability_p,
  NULL as time_stability_diagnostic,
  NULL as event_exposure_lb,
  NULL as event_exposure_ub,
  NULL as event_exposure_diagnostic,
  NULL as event_observation_lb,
  NULL as event_observation_ub,
  NULL as event_observation_diagnostic,
  NULL as rare_outcome_prevalence,
  NULL as rare_outcome_diagnostic,
  ds.ease,
  ds.ease_diagnostic,
  ds.mdrr,
  ds.mdrr_diagnostic,
  ds.unblind,
  ds.unblind_for_evidence_synthesis,
  ds.time_trend_p,
  ds.pre_exposure_p,
  ds.time_trend_diagnostic,
  ds.pre_exposure_diagnostic
  
  
  FROM @schema.@sccs_table_prefixdiagnostics_summary ds
  INNER JOIN @schema.@sccs_table_prefixexposures_outcome_set eos
  ON ds.exposures_outcome_set_id = eos.exposures_outcome_set_id
  
  INNER JOIN @schema.@cg_table_prefixcohort_definition AS c
  ON c.cohort_definition_id = eos.outcome_id
   
  INNER JOIN @schema.@database_table d
  ON d.database_id = ds.database_id
  
  INNER JOIN @schema.@sccs_table_prefixanalysis a
  ON a.analysis_id = ds.analysis_id
  
  INNER JOIN @schema.@sccs_table_prefixcovariate cov
  ON cov.covariate_id = ds.covariate_id
  AND cov.exposures_outcome_set_id = ds.exposures_outcome_set_id 
  AND cov.analysis_id = ds.analysis_id 
  AND cov.database_id = ds.database_id
  
  INNER JOIN @schema.@cg_table_prefixcohort_definition AS c2
  ON cov.era_id = c2.cohort_definition_id
   
  LEFT JOIN @schema.@cg_table_prefixcohort_definition AS cg3
  ON eos.nesting_cohort_id = cg3.cohort_definition_id
   
   WHERE 1 = 1
   {@restrict_target}?{AND c2.cohort_definition_id IN (@target_ids)}
   {@restrict_outcome}?{AND c.cohort_definition_id IN (@outcome_ids)}
  ;