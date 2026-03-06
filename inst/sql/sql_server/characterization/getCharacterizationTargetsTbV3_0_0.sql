SELECT 
cg.cohort_name, 
ts.target_id AS cohort_definition_id,
'databaseComparator' AS type, 
1 AS value

FROM @schema.@c_table_prefixtarget_settings ts 
INNER JOIN @schema.@cg_table_prefixcohort_definition cg
ON ts.target_id = cg.cohort_definition_id

GROUP BY 
cg.cohort_name, 
ts.target_id
;
