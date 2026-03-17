SELECT 
d.cdm_source_abbreviation AS database_name,
cov.database_id,
target.cohort_name AS target_name,
ts.target_id AS target_cohort_id,
outcome.cohort_name AS outcome_name,
cs.outcome_id as outcome_cohort_id,

ts.min_prior_observation,
ts.limit_to_first_in_n_days,

cs.outcome_washout_days,
cs.risk_window_start,
cs.start_anchor,
cs.risk_window_end,
cs.end_anchor,

cov.covariate_id,	
cr.covariate_name,

cov.non_case_count_value AS target_count_value,	
cov.case_count_value,	
cov.non_case_min_value AS target_min_value,	
cov.case_min_value,	
cov.non_case_max_value AS target_max_value,	
cov.case_max_value,	
cov.non_case_average_value AS target_average_value,	
cov.case_average_value,	
cov.non_case_median_value AS target_median_value,	
cov.case_median_value,
cov.non_case_p_10_value AS target_p_10_value,	
cov.case_p_10_value,
cov.non_case_p_25_value AS target_p_25_value,	
cov.case_p_25_value,	
cov.non_case_p_75_value AS target_p_75_value,	
cov.case_p_75_value,
cov.non_case_p_90_value AS target_p_90_value,	
cov.case_p_90_value,	
cov.non_case_standard_deviation AS target_standard_deviation,	
cov.case_standard_deviation,
cov.standardized_mean_difference AS smd,
ABS(cov.standardized_mean_difference) AS abs_smd


FROM @schema.@c_table_prefixrisk_factor_covariates_continuous cov
INNER JOIN @schema.@c_table_prefixcovariate_ref cr
ON cov.database_id = cr.database_id
AND cov.setting_id = cr.setting_id
AND cov.covariate_id = cr.covariate_id

INNER JOIN @schema.@c_table_prefixcase_settings cs
ON cov.characterization_case_id = cs.characterization_case_id
AND cov.setting_id = cs.setting_id
AND cov.database_id = cs.database_id

INNER JOIN @schema.@c_table_prefixtarget_settings ts
ON ts.characterization_target_id = cs.characterization_target_id
AND ts.setting_id = cs.setting_id
AND ts.database_id = cs.database_id
          
INNER JOIN @schema.@database_table d
ON cov.database_id = d.database_id
  
INNER JOIN @schema.@cg_table_prefixcohort_definition target
ON target.cohort_definition_id = ts.target_id
    
INNER JOIN @schema.@cg_table_prefixcohort_definition outcome
ON outcome.cohort_definition_id = cs.outcome_id

-- add wheres here
WHERE 1=1
{@use_target}?{AND ts.target_id IN (@target_id)}
{@use_outcome}?{AND cs.outcome_id IN (@outcome_id)}
{@use_database}?{AND d.database_id IN (@database_id)}
{@use_analysis}?{AND cr.analysis_id IN (@analysis_ids)}
{@use_risk_window_start}?{AND cs.risk_window_start IN (@risk_window_start)}  
{@use_risk_window_end}?{AND cs.risk_window_end IN (@risk_window_end)}
{@use_start_anchor}?{AND cs.start_anchor IN (@start_anchor)}
{@use_end_anchor}?{AND cs.end_anchor IN (@end_anchor)}
;
