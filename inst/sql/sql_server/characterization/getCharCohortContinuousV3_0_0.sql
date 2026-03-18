SELECT
  ts.target_id as cohort_id,
  --cd.cohort_name,
  d.CDM_SOURCE_ABBREVIATION as database_name,
  ref.covariate_name, 
  ts.min_prior_observation,
  ts.limit_to_first_in_n_days,
  cov.*

FROM @schema.@c_table_prefixtarget_covariates_continuous cov 
INNER JOIN @schema.@c_table_prefixcovariate_ref ref
ON cov.covariate_id = ref.covariate_id
AND cov.setting_id = ref.setting_id
AND cov.database_id = ref.database_id
    
INNER JOIN @schema.@c_table_prefixtarget_settings ts 
ON cov.setting_id = ts.setting_id
AND cov.database_id = ts.database_id
AND cov.characterization_target_id = ts.characterization_target_id
    
INNER JOIN @schema.@database_meta_table d 
ON ts.database_id = d.database_id

WHERE 1=1    
{@use_targets}?{AND ts.target_id in (@target_ids)}
{@use_databases}?{AND cov.database_id in (@database_ids)}          
;
