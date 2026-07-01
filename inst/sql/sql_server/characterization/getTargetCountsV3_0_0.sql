SELECT 
ca.setting_id,
ca.database_id,
{@include_names}?{d.cdm_source_abbreviation as database_name,}
ts.characterization_target_id,
ts.target_id as target_id,
{@include_names}?{cg.cohort_name AS target_name,}
ts.min_prior_observation,
ts.limit_to_first_in_n_days,
max(ca.n) as n

FROM @schema.@c_table_prefixattrition ca

INNER JOIN @schema.@c_table_prefixtarget_settings ts
ON ts.setting_id = ca.setting_id
ON ts.database_id = ca.database_id
ON ts.characterization_target_id = ca.cohort_definition_id

{@include_names}?{
INNER JOIN @schema.@database_meta_table d 
ON ca.database_id = d.database_id
}
  
{@include_names}?{
INNER JOIN @schema.@cg_table_prefixcohort_definition cg
ON cg.cohort_definition_id = ts.target_id 
}

WHERE 1 = 1
{@use_targets}?{AND ts.target_id in (@target_ids)}
{@use_databases}?{AND ca.database_id in (@database_ids)}
  
GROUP BY
ca.setting_id,
ca.database_id,
{@include_names}?{d.cdm_source_abbreviation,}
ts.characterization_target_id,
ts.target_id, 
{@include_names}?{cg.cohort_name,} 
ts.min_prior_observation, 
ts.limit_to_first_in_n_days
;