select 
  {@include_names}?{d.cdm_source_abbreviation as database_name,}
  a.database_id,
  cs.characterization_case_id,
  {@include_names}?{target_cohorts.cohort_name as target_name,}
  ts.target_id as target_id,
  ts.min_prior_observation,
  ts.limit_to_first_in_n_days,
  NULL as nesting_cohort_id,
  NULL as nesting_name,
  NULL as min_age,
  NULL as max_age,
  NULL as study_start,
  NULL as study_end,
  NULL as gender_concept_ids,
  {@include_names}?{outcome_cohorts.cohort_name as outcome_name,}
  cs.outcome_id as outcome_id,
  a.n as row_count,
  a.n as person_count,
  a.n as without_excluded_person_count,
  cs.outcome_washout_days,
  cs.risk_window_start, -- not in v0
  cs.risk_window_end, -- not in v0
  cs.start_anchor, -- not in v0
  cs.end_anchor -- not in v0

FROM @schema.@c_table_prefixattrition a

{@include_names}?{
  INNER JOIN @schema.@database_table_name d
  ON a.database_id = d.database_id
}
   
INNER JOIN @schema.@c_table_prefixcase_settings cs
ON cs.setting_id = a.setting_id
AND cs.database_id = a.database_id
AND cs.characterization_case_id*10+2 = a.cohort_definition_id
AND a.attr_reason = 'Non-cases'

{@include_names}?{
  INNER JOIN @schema.@cg_table_prefixcohort_definition outcome_cohorts
  ON outcome_cohorts.cohort_definition_id = cs.outcome_id
}

INNER JOIN @schema.@c_table_prefixtarget_settings ts
ON ts.setting_id = cs.setting_id
AND ts.database_id = cs.database_id
AND ts.characterization_target_id = cs.characterization_target_id

{@include_names}?{
  INNER JOIN @schema.@cg_table_prefixcohort_definition target_cohorts
  ON target_cohorts.cohort_definition_id = ts.target_id
}
  
WHERE 1 = 1
{@use_characterization_case}?{ AND cs.characterization_case_id IN (@characterization_case_id)}
{@use_characterization_target}?{ AND ts.characterization_target_id IN (@characterization_target_id)}
{@use_outcome}?{ AND cs.outcome_id IN (@outcome_id)}
{@use_database}?{ AND a.database_id IN (@database_id)}

