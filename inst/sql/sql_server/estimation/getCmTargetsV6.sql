SELECT DISTINCT t.cohort_name
	,tc.target_id AS cohort_definition_id
	,'cohortMethod' AS type
	,1 AS value
FROM @schema.@cm_table_prefixtarget_comparator AS tc
INNER JOIN @schema.@cg_table_prefixcohort_definition t ON tc.target_id = t.cohort_definition_id;
