SELECT 
cg.cohort_name, 
cs.outcome_id AS cohort_definition_id,
'riskFactors' AS type, 
1 AS value

FROM @schema.@c_table_prefixcase_settings cs 
INNER JOIN @schema.@cg_table_prefixcohort_definition cg
ON cs.outcome_id = cg.cohort_definition_id

{@use_target}?{
INNER JOIN @schema.@c_table_prefixtarget_settings ts 
ON cs.characterization_target_id = ts.characterization_target_id 
WHERE ts.target_id in (@target_ids)
}
GROUP BY 
cg.cohort_name, 
cs.outcome_id
;