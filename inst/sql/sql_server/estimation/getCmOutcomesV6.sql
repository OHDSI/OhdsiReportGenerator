SELECT DISTINCT cd.cohort_name
	,tco.outcome_id AS cohort_definition_id
	,'cohortMethod' AS type
	,1 AS value
FROM @schema.@cm_table_prefixtarget_comparator AS tc
INNER JOIN @schema.@cm_table_prefixtarget_comparator_outcome AS tco ON tc.target_comparator_id = tco.target_comparator_id
INNER JOIN @schema.@cg_table_prefixcohort_definition cd ON tco.outcome_id = cd.cohort_definition_id
WHERE tco.outcome_of_interest = 1 {@use_target}?{
	AND tc.target_id IN (@target_id) };
