SELECT 
cg.cohort_name, 
ts.target_id AS cohort_definition_id,
'riskFactors' AS type, 
1 AS value

FROM @schema.@c_table_prefixcase_settings cs 

INNER JOIN @schema.@c_table_prefixtarget_settings ts 
ON cs.characterization_target_id = ts.characterization_target_id 

INNER JOIN @schema.@cg_table_prefixcohort_definition cg
ON ts.target_id = cg.cohort_definition_id

WHERE 
cs.runtype = 'risk-factor' OR cs.runtype = 'risk-factor,case-series'

GROUP BY 
cg.cohort_name, 
ts.target_id
;
