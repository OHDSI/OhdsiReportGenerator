select 

 cc.setting_id,
 cc.database_id,
 cc.characterization_case_id,
 {@include_names}?{d.cdm_source_abbreviation as database_name,}
 ts.target_id as target_id,
  {@include_names}?{target_cohorts.cohort_name as target_name,}
  ts.min_prior_observation,
  ts.limit_to_first_in_n_days,
  ts.nesting_cohort_id,
  {@include_names}?{nest_cohorts.cohort_name as nesting_name,}
  ts.min_age,
  ts.max_age,
  ts.study_start,
  ts.study_end,
  ts.gender_concept_ids,
  {@include_names}?{outcome_cohorts.cohort_name as outcome_name,}
  cs.outcome_id as outcome_id,
  cc.n_events as row_count,
  cc.n_people as person_count,
  cc.n_people as without_excluded_person_count,
  cs.outcome_washout_days,
  cs.risk_window_start, -- not in v0
  cs.risk_window_end, -- not in v0
  cs.start_anchor, -- not in v0
  cs.end_anchor -- not in v0

FROM @schema.@c_table_prefixcase_counts cc

{@include_names}?{
INNER JOIN @schema.@database_table_name d
ON cc.database_id = d.database_id
}
   
INNER JOIN @schema.@c_table_prefixcase_settings cs
ON cs.setting_id = cc.setting_id
AND cs.database_id = cc.database_id
AND cs.characterization_case_id = cc.characterization_case_id
AND cc.cohort_type = 'non-cases'

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

{@include_names}?{
  LEFT JOIN @schema.@cg_table_prefixcohort_definition nest_cohorts
  ON nest_cohorts.cohort_definition_id = ts.nesting_cohort_id
}
  
WHERE 1 = 1
{@use_characterization_case}?{ AND cs.characterization_case_id IN (@characterization_case_id)}
{@use_characterization_target}?{ AND ts.characterization_target_id IN (@characterization_target_id)}
{@use_outcome}?{ AND cs.outcome_id IN (@outcome_id)}
{@use_database}?{ AND cc.database_id IN (@database_id)}
