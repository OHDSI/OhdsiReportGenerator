SELECT 
cg.cohort_name, 
ts.target_id AS cohort_definition_id,
'caseSeries' AS type, 
1 AS value

FROM @schema.@c_table_prefixtarget_settings ts 

INNER JOIN

(SELECT 
characterization_target_id
FROM @schema.@c_table_prefixcase_settings cs 
WHERE 
cs.runtype IN ('case-series', 'risk-factor,case-series')
GROUP BY characterization_target_id
) cs_ts

ON ts.characterization_target_id = cs_ts.characterization_target_id  

INNER JOIN @schema.@cg_table_prefixcohort_definition cg
ON ts.target_id = cg.cohort_definition_id

GROUP BY 
cg.cohort_name,
ts.target_id
;
