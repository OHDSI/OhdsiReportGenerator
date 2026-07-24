SELECT DISTINCT
ts.setting_id,
cs.characterization_case_id,
ts.characterization_target_id,
ts.target_id,
cg1.cohort_name as target_name,
ts.limit_to_first_in_n_days,
ts.min_prior_observation,
ts.nesting_cohort_id,
cg2.cohort_name as nesting_name,
ts.min_age,
ts.max_age,
ts.study_start,
ts.study_end,
ts.gender_concept_ids,
cs.outcome_id,
cg3.cohort_name as outcome_name,
cs.outcome_washout_days,
cs.risk_window_start,
cs.start_anchor,
cs.risk_window_end,
cs.end_anchor,
cs.risk_factor_settings,
cs.case_series_settings

FROM @schema.@c_table_prefixcase_settings cs

INNER JOIN @schema.@c_table_prefixtarget_settings ts
ON cs.characterization_target_id = ts.characterization_target_id
AND cs.database_id = ts.database_id
AND cs.setting_id = ts.setting_id

INNER JOIN @schema.@cg_table_prefixcohort_definition cg1
ON cg1.cohort_definition_id = ts.target_id

INNER JOIN @schema.@cg_table_prefixcohort_definition cg3
ON cg3.cohort_definition_id = cs.outcome_id

LEFT join @schema.@cg_table_prefixcohort_definition cg2
ON cg2.cohort_definition_id = ts.nesting_cohort_ID

WHERE 1=1
{@use_target}?{ and ts.target_id in (@target_id)}
{@use_outcome}?{ and cs.outcome_id in (@outcome_id)}
{@use_characterization_target}?{ and ts.characterization_target_id in (@characterization_target_id)}
;


