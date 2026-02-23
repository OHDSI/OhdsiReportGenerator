--@include_indication
--@indication_id
SELECT dmd.cdm_source_abbreviation database_name
	,a.description AS analysis_description
	,c1.cohort_name AS target_name
	,c2.cohort_name AS comparator_name
	,NULL AS nesting_name
	,{@include_outcome}?{c3.cohort_name AS outcome_name
	,} {@include_covariate_name}?{c.covariate_name
	,} tab.*
FROM @schema.@cm_table_prefix@table AS tab {@include_covariate_name}?{
JOIN @schema.@cm_table_prefixcovariate c ON tab.covariate_id = c.covariate_id
	AND tab.analysis_id = c.analysis_id
	AND tab.database_id = c.database_id }
INNER JOIN @schema.@cg_table_prefixcohort_definition AS c1 ON c1.cohort_definition_id = tab.target_id
INNER JOIN @schema.@cg_table_prefixcohort_definition AS c2 ON c2.cohort_definition_id = tab.comparator_id {@include_outcome}?{
INNER JOIN @schema.@cg_table_prefixcohort_definition AS c3 ON c3.cohort_definition_id = tab.outcome_id }
INNER JOIN @schema.@cm_table_prefixanalysis AS a ON a.analysis_id = tab.analysis_id
INNER JOIN @schema.@database_table AS dmd ON dmd.database_id = tab.database_id
WHERE 1 = 1 {@include_target}?{and tab.target_id IN (@target_id) } {@include_outcome}?{and tab.outcome_id IN (@outcome_id) } {@include_comparator}?{and tab.comparator_id IN (@comparator_id) } {@include_database}?{and tab.database_id IN (@database_id) } {@include_analyses}?{and tab.analysis_id IN (@analysis_id) };
