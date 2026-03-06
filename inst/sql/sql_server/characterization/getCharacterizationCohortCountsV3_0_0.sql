SELECT 
ca.database_id,
d.cdm_source_abbreviation as database_name,
ts.target_id as cohort_id,
cg.cohort_name,
ts.min_prior_observation,
ts.limit_to_first_in_n_days,
max(ca.n) as N

FROM @schema.@c_table_prefixattrition ca

INNER JOIN @schema.@c_table_prefixtarget_settings ts
ON ts.characterization_target_id = ca.cohort_definition_id

INNER JOIN @schema.@database_meta_table d 
ON ca.database_id = d.database_id
  
INNER JOIN @schema.@cg_table_prefixcohort_definition cg
ON cg.cohort_definition_id = ts.target_id 

WHERE 1 = 1
{@use_targets}?{AND ts.target_id in (@target_ids)}
{@use_databases}?{AND d.database_id in (@database_ids)}
  
GROUP BY
ca.database_id, d.cdm_source_abbreviation,
ts.target_id, cg.cohort_name, 
ts.min_prior_observation, ts.limit_to_first_in_n_days
;