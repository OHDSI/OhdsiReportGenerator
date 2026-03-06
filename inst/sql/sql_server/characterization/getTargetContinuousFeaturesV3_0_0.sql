SELECT
d.cdm_source_abbreviation AS database_name,
t.database_id,
target.cohort_name AS target_name,
ts.target_id AS target_cohort_id,
ts.min_prior_observation,
ts.limit_to_first_in_n_days,
cr.covariate_name,
t.covariate_id,
t.count_value,
t.min_value,
t.max_value,
t.average_value,
t.standard_deviation,
t.median_value,
t.p_10_value,
t.p_25_value,
t.p_75_value,
t.p_90_value
 
FROM @schema.@c_table_prefixtarget_covariates_continuous t
INNER JOIN @schema.@c_table_prefixcovariate_ref cr
ON t.database_id = cr.database_id
AND t.setting_id = cr.setting_id
AND t.covariate_id = cr.covariate_id

INNER JOIN @schema.@c_table_prefixtarget_settings ts
ON t.database_id = ts.database_id
AND t.setting_id = ts.setting_id
AND t.characterization_target_id = ts.characterization_target_id

INNER JOIN @schema.@database_table d
ON t.database_id = d.database_id

INNER JOIN @schema.@cg_table_prefixcohort_definition target
ON target.cohort_definition_id = ts.target_id

WHERE 1 = 1
{@use_target}?{AND ts.target_id in (@target_id)}
{@use_database}?{AND c.database_id in (@database_id)}
{@use_analysis}?{AND cr.analysis_id in (@analysis_ids)}
;