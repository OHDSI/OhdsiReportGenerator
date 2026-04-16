SELECT dmd.cdm_source_abbreviation database_name
	,a.description AS analysis_description
	,c1.cohort_name AS target_name
	,c2.cohort_name AS comparator_name
	,c4.cohort_name AS nesting_name
	,{@include_outcome}?{c3.cohort_name AS outcome_name
	,} {@include_covariate_name}?{c.covariate_name
	,} tab.*
FROM @schema.@cm_table_prefix@table AS tab
INNER JOIN @schema.@cm_table_prefixtarget_comparator tc 
ON tc.target_comparator_id = tab.target_comparator_id {@include_covariate_name}?{
JOIN @schema.@cm_table_prefixcovariate c ON tab.covariate_id = c.covariate_id
	AND tab.analysis_id = c.analysis_id
	AND tab.database_id = c.database_id }
INNER JOIN @schema.@cg_table_prefixcohort_definition AS c1 ON c1.cohort_definition_id = tc.target_id
INNER JOIN @schema.@cg_table_prefixcohort_definition AS c2 ON c2.cohort_definition_id = tc.comparator_id {@include_outcome}?{
INNER JOIN @schema.@cg_table_prefixcohort_definition AS c3 ON c3.cohort_definition_id = tab.outcome_id }
LEFT JOIN @schema.@cg_table_prefixcohort_definition AS c4 ON c4.cohort_definition_id = tc.nesting_cohort_id
INNER JOIN @schema.@cm_table_prefixanalysis AS a ON a.analysis_id = tab.analysis_id
INNER JOIN @schema.@database_table AS dmd ON dmd.database_id = tab.database_id
WHERE 1 = 1 
{@include_target}?{and tc.target_id IN (@target_id) } 
{@include_outcome}?{and tab.outcome_id IN (@outcome_id) } 
{@include_indication}?{and ISNULL(tc.nesting_cohort_id,0) IN (@indication_id) }
{@include_comparator}?{and tc.comparator_id IN (@comparator_id) } 
{@include_database}?{and tab.database_id IN (@database_id) } 
{@include_analyses}?{and tab.analysis_id IN (@analysis_id) };
