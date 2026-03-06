SELECT 
 d.CDM_SOURCE_ABBREVIATION AS database_name,
 d.database_id,
 target.cohort_name AS target_name,
 ts.target_id AS target_cohort_id,
 outcome.cohort_name AS outcome_name,
 s.outcome_id AS outcome_cohort_id,
 
  cr.covariate_name, 
  cr.covariate_id, 
  ts.min_prior_observation, 
  ts.limit_to_first_in_n_days,
  s.outcome_washout_days,
  cs.case_post_outcome_duration, 
  cs.case_pre_target_duration,
  s.risk_window_start,
  s.start_anchor,
  s.risk_window_end,
  s.end_anchor,
  cov.before_sum_value AS sum_value_before, 
  cov.before_average_value AS average_value_before,
  cov.during_sum_value AS sum_value_during, 
  cov.during_average_value AS average_value_during,
  cov.after_sum_value AS sum_value_after, 
  cov.after_average_value AS average_value_after

FROM @schema.@c_table_prefixcase_series_covariates cov
INNER JOIN @schema.@c_table_prefixcovariate_ref cr
ON cov.setting_id = cr.setting_id
AND cov.database_id = cr.database_id 
AND cov.covariate_id = cr.covariate_id

INNER JOIN @schema.@c_table_prefixcase_series_settings cs
ON cs.setting_id = cov.setting_id

INNER JOIN @schema.@c_table_prefixcase_settings s
ON cov.characterization_case_id = s.characterization_case_id
AND cov.setting_id = s.setting_id
AND cov.database_id = s.database_id

INNER JOIN @schema.@c_table_prefixtarget_settings ts
ON ts.characterization_target_id = s.characterization_target_id
AND ts.setting_id = s.setting_id
AND ts.database_id = s.database_id
          
INNER JOIN @schema.@database_table d
ON cov.database_id = d.database_id
  
INNER JOIN @schema.@cg_table_prefixcohort_definition target
ON target.cohort_definition_id = ts.target_id
    
INNER JOIN @schema.@cg_table_prefixcohort_definition outcome
ON outcome.cohort_definition_id = s.outcome_id

WHERE ts.target_id = @target_id
AND s.outcome_id = @outcome_id
{@use_database}?{AND cov.database_id in (@database_ids)}
{@use_risk_window_start}?{AND s.risk_window_start = @risk_window_start}
{@use_risk_window_end}?{AND s.risk_window_end = @risk_window_end}
{@use_start_anchor}?{AND s.start_anchor = '@start_anchor'}
{@use_end_anchor}?{AND s.end_anchor = '@end_anchor'}
{@use_concepts}?{AND cr.concept_id in (@concept_ids)} 
{@use_min_val}?{
AND (cov.before_average_value >= @min_val 
OR cov.during_average_value >= @min_val
OR cov.after_average_value >= @min_val)
} 
;