SELECT 
 database_name,
 database_id,
 target_name,
 target_cohort_id,
 min_prior_observation,
 limit_to_first_in_n_days,
 nesting_cohort_id,
 nesting_name,
 min_age,	
 max_age,
 study_start,	
 study_end,	
 gender_concept_ids,

 outcome.cohort_name AS outcome_name,
 temp.outcome_cohort_id as outcome_cohort_id,
 outcome_washout_days,
 risk_window_start,
 start_anchor,
 risk_window_end,
 end_anchor,

 covariate_id,	
 covariate_name,

 target_count_value,
 case_count_value,
 target_min_value,
 case_min_value,
 target_max_value,
 case_max_value,
 target_average_value,	
 case_average_value,
 target_median_value,	
 case_median_value,
 target_p_10_value,	
 case_p_10_value,
 target_p_25_value,	
 case_p_25_value,
 target_p_75_value,	
 case_p_75_value,
 target_p_90_value,	
 case_p_90_value,
 target_standard_deviation,	
 case_standard_deviation,

CASE WHEN (case_standard_deviation + target_standard_deviation) > 0 THEN
(case_average_value -target_average_value)/SQRT(
(case_standard_deviation + target_standard_deviation)/2
) ELSE 0 END AS smd,
ABS(
CASE WHEN (case_standard_deviation + target_standard_deviation) > 0 THEN
(case_average_value -target_average_value)/SQRT(
(case_standard_deviation + target_standard_deviation)/2
) ELSE 0 END
) AS abs_smd

FROM (
SELECT 
  d.cdm_source_abbreviation AS database_name,
  cov.database_id,
  target.cohort_name AS target_name,
  cov.target_cohort_id AS target_cohort_id,
  s.min_prior_observation,
  99999 AS limit_to_first_in_n_days,
  NULL AS nesting_cohort_id,
  NULL AS nesting_name,
  0 AS min_age,	
  999 AS max_age,
  NULL AS study_start,	
  NULL AS study_end,	
  NULL AS gender_concept_ids,

  MAX(cov.outcome_cohort_id) as outcome_cohort_id,
  MAX(s.outcome_washout_days) as outcome_washout_days,
  MAX(s.risk_window_start) as risk_window_start,
  MAX(s.start_anchor) as start_anchor,
  MAX(s.risk_window_end) as risk_window_end,
  MAX(s.end_anchor) as end_anchor,

  cov.covariate_id,	
  cr.covariate_name,
  
  --  could subtract 'Exclude'?
  MAX(CASE WHEN cohort_type = 'Target' THEN cov.count_value ELSE 0 END) AS target_count_value,
  MAX(CASE WHEN cohort_type = 'Cases' THEN cov.count_value ELSE 0 END) AS case_count_value,
  
  MAX(CASE WHEN cohort_type = 'Target' THEN cov.min_value ELSE 0 END) AS target_min_value,
  MAX(CASE WHEN cohort_type = 'Cases' THEN cov.min_value ELSE 0 END) AS case_min_value,
  
  MAX(CASE WHEN cohort_type = 'Target' THEN cov.max_value ELSE 0 END) AS target_max_value,
  MAX(CASE WHEN cohort_type = 'Cases' THEN cov.max_value ELSE 0 END) AS case_max_value,
  
  MAX(CASE WHEN cohort_type = 'Target' THEN cov.average_value ELSE 0 END) AS target_average_value,	
  MAX(CASE WHEN cohort_type = 'Cases' THEN cov.average_value ELSE 0 END) AS case_average_value,

  MAX(CASE WHEN cohort_type = 'Target' THEN cov.median_value ELSE 0 END) AS target_median_value,	
  MAX(CASE WHEN cohort_type = 'Cases' THEN cov.median_value ELSE 0 END) AS case_median_value,

  MAX(CASE WHEN cohort_type = 'Target' THEN cov.p_10_value ELSE 0 END) AS target_p_10_value,	
  MAX(CASE WHEN cohort_type = 'Cases' THEN cov.p_10_value ELSE 0 END) AS case_p_10_value,

  MAX(CASE WHEN cohort_type = 'Target' THEN cov.p_25_value ELSE 0 END) AS target_p_25_value,	
  MAX(CASE WHEN cohort_type = 'Cases' THEN cov.p_25_value ELSE 0 END) AS case_p_25_value,

  MAX(CASE WHEN cohort_type = 'Target' THEN cov.p_75_value ELSE 0 END) AS target_p_75_value,	
  MAX(CASE WHEN cohort_type = 'Cases' THEN cov.p_75_value ELSE 0 END) AS case_p_75_value,

  MAX(CASE WHEN cohort_type = 'Target' THEN cov.p_90_value ELSE 0 END) AS target_p_90_value,	
  MAX(CASE WHEN cohort_type = 'Cases' THEN cov.p_90_value ELSE 0 END) AS case_p_90_value,

  MAX(CASE WHEN cohort_type = 'Target' THEN cov.standard_deviation ELSE 0 END) AS target_standard_deviation,	
  MAX(CASE WHEN cohort_type = 'Cases' THEN cov.standard_deviation ELSE 0 END) AS case_standard_deviation


FROM @schema.@c_table_prefixcovariates_continuous cov
INNER JOIN @schema.@c_table_prefixcovariate_ref cr
ON cov.database_id = cr.database_id
AND cov.setting_id = cr.setting_id
AND cov.covariate_id = cr.covariate_id

INNER JOIN @schema.@c_table_prefixsettings s
ON cov.setting_id = s.setting_id
AND cov.database_id = s.database_id

INNER JOIN @schema.@database_table d
ON cov.database_id = d.database_id
  
INNER JOIN @schema.@cg_table_prefixcohort_definition target
ON target.cohort_definition_id = cov.target_cohort_id
    
-- add wheres here
WHERE 
cov.cohort_type in ('Target', 'Cases')
{@use_characterization_target}?{AND cov.target_cohort_id IN (@characterization_target_id)}
{@use_outcome}?{AND cov.outcome_cohort_id IN (@outcome_id,0)}

{@use_outcome_washout}?{AND (s.outcome_washout_days IN (@outcome_washout) OR s.outcome_washout_days IS NULL)}
{@use_risk_window_start}?{AND (s.risk_window_start IN (@risk_window_start) OR s.risk_window_start IS NULL)}
{@use_risk_window_end}?{AND (s.risk_window_end IN (@risk_window_end) OR s.risk_window_end IS NULL)}
{@use_start_anchor}?{AND (s.start_anchor IN (@start_anchor) OR s.start_anchor IS NULL)}
{@use_end_anchor}?{AND (s.end_anchor IN (@end_anchor) OR s.end_anchor IS NULL)}

{@use_database}?{AND d.database_id IN (@database_id)}
{@use_analysis}?{AND cr.analysis_id IN (@analysis_ids)}

GROUP BY 

  d.cdm_source_abbreviation,
  cov.database_id,
  target.cohort_name,
  cov.target_cohort_id,
  s.min_prior_observation,
  --s.outcome_washout_days,
  --s.risk_window_start,
  --s.start_anchor,
  --s.risk_window_end,
  --s.end_anchor,
  cov.covariate_id,	
  cr.covariate_name

) temp

INNER JOIN @schema.@cg_table_prefixcohort_definition outcome
ON outcome.cohort_definition_id = temp.outcome_cohort_id

;

