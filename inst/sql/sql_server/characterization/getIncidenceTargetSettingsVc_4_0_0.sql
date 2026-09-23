select distinct

cg.subset_parent as parent_cohort_definition_id,
parent.cohort_name as parent_cohort_name,
ts.setting_id AS setting_id,
ts.characterization_target_id AS characterization_target_id,
ts.target_id AS cohort_definition_id,
cg.cohort_name,
ts.limit_to_first_in_n_days,
ts.min_prior_observation,
ts.nesting_cohort_id,
ts.nesting_name,
ts.min_age,
ts.max_age,
ts.study_start,
ts.study_end,
ts.gender_concept_ids,
0 AS time_to_event,
0 AS dechal_rechal,
0 AS database_comparator,
0 AS cohort_comparator,
0 AS risk_factors,
0 AS case_series,
ts.cohort_incidence_settings as cohort_incidence
  
  from @schema.@ci_table_prefixtarget_setting as ts
  
  inner join @schema.@cg_table_prefixcohort_definition cg
  on ts.target_id = cg.cohort_definition_id
  
  INNER join @schema.@cg_table_prefixcohort_definition parent
  ON parent.cohort_definition_id = cg.subset_parent

WHERE 
CAST(ts.cohort_incidence_settings AS INT) = 1
{@use_characterization_target}?{AND ts.characterization_target_id in (@characterization_target_id)}
{@use_target}?{AND ts.target_id in (@target_id)}
;