SELECT DISTINCT cd.cohort_name
	,cr.outcome_id AS cohort_definition_id
	,'cohortMethod' AS type
	,1 AS value
FROM @schema.@cm_table_prefixresult AS cr
INNER JOIN @schema.@cm_table_prefixtarget_comparator_outcome AS tco ON cr.target_id = tco.target_id
	AND cr.comparator_id = tco.comparator_id
	AND cr.outcome_id = tco.outcome_id
INNER JOIN @schema.@cg_table_prefixcohort_definition cd ON cr.outcome_id = cd.cohort_definition_id
WHERE tco.outcome_of_interest = 1 {@use_target}?{
	AND cr.target_id IN (@target_id) };
