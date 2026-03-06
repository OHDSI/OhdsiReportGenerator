SELECT 
cg.cohort_name, 
ts.target_id AS cohort_definition_id,
'caseSeries' AS type, 
1 AS value

FROM @schema.@c_table_prefixcase_settings cs 
INNER JOIN @schema.@cg_table_prefixcohort_definition cg
ON cs.outcome_id = cg.cohort_definition_id

INNER JOIN @schema.@c_table_prefixtarget_settings ts 
ON cs.characterization_target_id = ts.characterization_target_id 

WHERE cs.runtype ~* 'case-series'

GROUP BY 
cg.cohort_name, 
ts.target_id
;
