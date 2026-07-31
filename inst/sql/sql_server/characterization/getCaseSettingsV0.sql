SELECT DISTINCT
'madeup' AS setting_id,
0 AS characterization_case_id,
cd.target_cohort_id as characterization_target_id,
cd.target_cohort_id AS target_id,
cg1.cohort_name as target_name,
99999 AS limit_to_first_in_n_days,
s.min_prior_observation,
NULL AS nesting_cohort_id,
NULL AS nesting_name,
0 AS min_age,
999 AS max_age,
NULL AS study_start,
NULL AS study_end,
NULL AS gender_concept_ids,
cd.outcome_cohort_id AS outcome_id,
cg3.cohort_name as outcome_name,
s.outcome_washout_days,
s.risk_window_start,
s.start_anchor,
s.risk_window_end,
s.end_anchor,
1 AS risk_factor_settings,
1 AS case_series_settings

FROM @schema.@c_table_prefixcohort_details cd

INNER JOIN @schema.@c_table_prefixsettings s
ON cd.database_id = s.database_id
AND cd.setting_id = s.setting_id

INNER JOIN @schema.@cg_table_prefixcohort_definition cg1
ON cg1.cohort_definition_id = cd.target_cohort_id

INNER JOIN @schema.@cg_table_prefixcohort_definition cg3
ON cg3.cohort_definition_id = cd.outcome_cohort_id

WHERE cd.cohort_type = 'Cases'
{@use_target}?{ and cd.target_cohort_id in (@target_id)}
{@use_outcome}?{ and cd.outcome_cohort_id in (@outcome_id)}
{@use_characterization_target}?{ and cd.target_cohort_id in (@characterization_target_id)}
;


