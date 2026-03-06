select 
  d.cdm_source_abbreviation as database_name,
  d.database_id,
  target_cohorts.cohort_name as target_name,
  ts.target_id as target_id,
  outcome_cohorts.cohort_name as outcome_name,
  cs.outcome_id as outcome_id,
  a.n as row_count,
  a.n as person_count,
  ts.min_prior_observation,
  ts.limit_to_first_in_n_days,
  cs.outcome_washout_days,
  cs.risk_window_start,
  cs.risk_window_end,
  cs.start_anchor,
  cs.end_anchor

FROM @schema.@c_table_prefixattrition a

INNER JOIN @schema.@database_table d
ON a.database_id = d.database_id
   
INNER JOIN @schema.@c_table_prefixcase_settings cs
ON cs.setting_id = a.setting_id
AND cs.database_id = a.database_id
AND cs.characterization_case_id*10+1 = a.cohort_definition_id
AND a.attr_reason = 'Cases'

INNER JOIN @schema.@cg_table_prefixcohort_definition outcome_cohorts
ON outcome_cohorts.cohort_definition_id = cs.outcome_id

INNER JOIN @schema.@c_table_prefixtarget_settings ts
ON ts.setting_id = cs.setting_id
AND ts.database_id = cs.database_id
AND ts.characterization_target_id = cs.characterization_target_id

INNER JOIN @schema.@cg_table_prefixcohort_definition target_cohorts
ON target_cohorts.cohort_definition_id = ts.target_id
  
WHERE 1 = 1
{@use_target}?{ AND ts.target_id IN (@target_id)}
{@use_outcome}?{ AND cs.outcome_id IN (@outcome_id)}
{@use_database}?{ AND d.database_id IN (@database_id)}
  
{@use_risk_window_start}?{ AND cs.risk_window_start IN (@risk_window_start)}  
{@use_risk_window_end}?{ AND cs.risk_window_end IN (@risk_window_end)}
{@use_start_anchor}?{ AND cs.start_anchor IN (@start_anchor)}
{@use_end_anchor}?{ AND cs.end_anchor IN (@end_anchor)}

