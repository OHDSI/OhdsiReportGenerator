SELECT
 ref.covariate_name,
 ref.covariate_id,
 ts.min_prior_observation,
 ts.limit_to_first_in_n_days,
 ts.target_id as cohort_id,
 cov.database_id,
 cov.sum_value,
 cov.average_value

FROM @schema.@c_table_prefixtarget_covariates cov 
INNER JOIN @schema.@c_table_prefixcovariate_ref ref
ON cov.covariate_id = ref.covariate_id
AND cov.setting_id = ref.setting_id
AND cov.database_id = ref.database_id

INNER JOIN @schema.@c_table_prefixtarget_settings ts
ON ts.database_id = cov.database_id
AND ts.setting_id = cov.setting_id
AND ts.characterization_target_id = cov.characterization_target_id

WHERE abs(cov.average_value) >= @min_threshold
{@use_targets}?{AND ts.target_id IN (@target_ids) }
{@use_databases}?{AND cov.database_id IN (@database_ids)}
;