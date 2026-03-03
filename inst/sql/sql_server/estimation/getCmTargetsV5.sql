SELECT DISTINCT cd.cohort_name
	,cr.target_id AS cohort_definition_id
	,'cohortMethod' AS type
	,1 AS value
FROM @schema.@cm_table_prefixresult AS cr
INNER JOIN @schema.@cg_table_prefixcohort_definition cd ON cr.target_id = cd.cohort_definition_id;
