SELECT 
tc.setting_id,
tc.database_id,
tc.characterization_target_id,
{@include_names}?{d.cdm_source_abbreviation as database_name,}
ts.target_id as target_id,
{@include_names}?{cg.cohort_name AS target_name,}
ts.min_prior_observation,
ts.limit_to_first_in_n_days,
tc.n_events as n

FROM @schema.@c_table_prefixtarget_counts tc

{@include_names}?{
INNER JOIN @schema.@c_table_prefixtarget_settings ts
ON ts.characterization_target_id = tc.characterization_target_id
AND ts.database_id = tc.database_id
AND ts.setting_id = tc.setting_id

INNER JOIN @schema.@database_meta_table d 
ON tc.database_id = d.database_id
  
INNER JOIN @schema.@cg_table_prefixcohort_definition cg
ON cg.cohort_definition_id = ts.target_id 
}

WHERE 1 = 1
{@use_characterization_targets}?{AND tc.characterization_target_id in (@characterization_target_ids)}
{@use_databases}?{AND tc.database_id in (@database_ids)}
  
;