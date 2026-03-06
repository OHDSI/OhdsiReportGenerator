SELECT 
cc.database_id,
d.CDM_SOURCE_ABBREVIATION as database_name,
cc.target_cohort_id as cohort_id,
cg.cohort_name,
cc.min_prior_observation,
99999 as limit_to_first_in_n_days,
max(cc.person_count) as N
  
FROM @schema.@c_table_prefixcohort_counts cc
  
INNER JOIN @schema.@database_meta_table d 
ON cc.database_id = d.database_id
  
INNER JOIN @schema.@cg_table_prefixcohort_definition cg
ON cg.cohort_definition_id = cc.target_cohort_id 
  
WHERE cc.cohort_type = 'Target'
{@use_targets}?{AND cc.target_cohort_id in (@target_ids)}
{@use_databases}?{AND cc.database_id in (@database_ids)}
  
GROUP BY
cc.database_id, d.CDM_SOURCE_ABBREVIATION,
cc.target_cohort_id, cg.cohort_name, cc.min_prior_observation
;