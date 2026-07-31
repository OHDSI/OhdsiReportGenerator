SELECT DISTINCT 

cg1.subset_parent as parent_cohort_definition_id,
parent.cohort_name as parent_cohort_name,
ts.setting_id,
ts.characterization_target_id,
ts.target_id AS cohort_definition_id,
cg1.cohort_name,
ts.limit_to_first_in_n_days,
ts.min_prior_observation,
ts.nesting_cohort_id,
cg2.cohort_name as nesting_name,
ts.min_age,
ts.max_age,
ts.study_start,
ts.study_end,
ts.gender_concept_ids,
ts.time_to_event_settings AS time_to_event,
ts.dechallenge_rechallenge_settings AS dechal_rechal,
ts.target_baseline_settings AS database_comparator,
ts.target_baseline_settings AS cohort_comparator,
ts.risk_factor_settings AS risk_factors,
ts.case_series_settings AS case_series
{@add_database_details}?{
,ts.database_id
,d.cdm_source_abbreviation as database_name
}

FROM @schema.@c_table_prefixtarget_settings ts

INNER JOIN @schema.@cg_table_prefixcohort_definition cg1
ON cg1.cohort_definition_id = ts.target_id

LEFT join @schema.@cg_table_prefixcohort_definition cg2
ON cg2.cohort_definition_id = ts.nesting_cohort_ID

INNER join @schema.@cg_table_prefixcohort_definition parent
ON parent.cohort_definition_id = cg1.subset_parent

{@add_database_details}?{
  INNER JOIN @schema.@database_table d
  ON ts.database_id = d.database_id
}

WHERE 1=1
{@use_target}?{ and ts.target_id in (@target_id)}
{@use_characterization_target}?{ and ts.characterization_target_id in (@characterization_target_id)}
;


