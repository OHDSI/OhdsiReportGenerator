SELECT 
'Meta' AS database_name,
0 AS database_id,
target.cohort_name AS target_name,
ts.target_id AS target_cohort_id,
ts.min_prior_observation,
ts.limit_to_first_in_n_days,
ts.nesting_cohort_id,
nesting.cohort_name AS nesting_name,
ts.min_age,	
ts.max_age,
ts.study_start,	
ts.study_end,	
ts.gender_concept_ids,

outcome.cohort_name AS outcome_name,
cs.outcome_id as outcome_cohort_id,
cs.outcome_washout_days,
cs.risk_window_start,
cs.start_anchor,
cs.risk_window_end,
cs.end_anchor,

cov.covariate_id,	
cr.covariate_name,

sum(cov.non_case_count_value) AS target_count_value,	
sum(cov.case_count_value) AS case_count_value,	
min(cov.non_case_min_value) AS target_min_value,	
min(cov.case_min_value) AS case_min_value,	
max(cov.non_case_max_value) AS target_max_value,	
max(cov.case_max_value) AS case_max_value,	
avg(cov.standardized_mean_difference) AS smd,
avg(ABS(cov.standardized_mean_difference)) AS abs_smd,
COUNT(*) AS num_dbs,
SUM(CASE WHEN cov.standardized_mean_difference > 0 THEN 1 ELSE 0 END) as pos_dbs,
SUM(CASE WHEN cov.standardized_mean_difference < 0 THEN 1 ELSE 0 END) as neg_dbs

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
  
INNER JOIN @schema.@cg_table_prefixcohort_definition target
ON target.cohort_definition_id = ts.target_id
    
INNER JOIN @schema.@cg_table_prefixcohort_definition outcome
ON outcome.cohort_definition_id = cs.outcome_id

LEFT JOIN @schema.@cg_table_prefixcohort_definition nesting
ON nesting.cohort_definition_id = ts.nesting_cohort_id

-- add wheres here
WHERE 1=1
{@use_characterization_target}?{AND ts.characterization_target_id IN (@characterization_target_id)}
{@use_characterization_case}?{AND cs.characterization_case_id IN (@characterization_case_id)}
{@use_outcome}?{AND cs.outcome_id IN (@outcome_id)}
{@use_outcome_washout}?{AND cs.outcome_washout_days IN (@outcome_washout)}
{@use_analysis}?{AND cr.analysis_id IN (@analysis_ids)}
{@use_risk_window_start}?{AND cs.risk_window_start IN (@risk_window_start)}  
{@use_risk_window_end}?{AND cs.risk_window_end IN (@risk_window_end)}
{@use_start_anchor}?{AND cs.start_anchor IN (@start_anchor)}
{@use_end_anchor}?{AND cs.end_anchor IN (@end_anchor)}

GROUP BY
target.cohort_name,
ts.target_id,
ts.min_prior_observation,
ts.limit_to_first_in_n_days,
ts.nesting_cohort_id,
nesting.cohort_name,
ts.min_age,	
ts.max_age,
ts.study_start,	
ts.study_end,	
ts.gender_concept_ids,
outcome.cohort_name,
cs.outcome_id,
cs.outcome_washout_days,
cs.risk_window_start,
cs.start_anchor,
cs.risk_window_end,
cs.end_anchor,
cov.covariate_id,	
cr.covariate_name
;
