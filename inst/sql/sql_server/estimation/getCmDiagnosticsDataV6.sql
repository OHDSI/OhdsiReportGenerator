SELECT DISTINCT dmd.cdm_source_abbreviation database_name
	,dmd.database_id
	,cma.analysis_id
	,cma.description
	,cgcd1.cohort_name target_name
	,tc.target_id
	,cgcd2.cohort_name comparator_name
	,tc.comparator_id
	,cgcd4.cohort_name indication_name
	,ISNULL(tc.nesting_cohort_id,0) indication_id
	,cgcd3.cohort_name outcome_name
	,cmds.outcome_id
	,cmds.max_sdm
	,cmds.sdm_family_wise_min_p
	,cmds.shared_max_sdm
	,cmds.shared_sdm_family_wise_min_p
	,cmds.equipoise
	,cmds.mdrr
	,cmds.attrition_fraction
	,cmds.ease
	,cmds.balance_diagnostic
	,cmds.shared_balance_diagnostic
	,-- added back
	cmds.equipoise_diagnostic
	,cmds.mdrr_diagnostic
	,cmds.attrition_diagnostic
	,cmds.ease_diagnostic
	,cmds.unblind_for_evidence_synthesis
	,cmds.unblind
FROM @schema.@cm_table_prefixdiagnostics_summary cmds
INNER JOIN @schema.@cm_table_prefixanalysis cma ON cmds.analysis_id = cma.analysis_id
INNER JOIN @schema.@database_table dmd ON dmd.database_id = cmds.database_id
INNER JOIN @schema.@cm_table_prefixtarget_comparator tc ON tc.target_comparator_id = cmds.target_comparator_id
INNER JOIN @schema.@cg_table_prefixcohort_definition cgcd1 ON tc.target_id = cgcd1.cohort_definition_id
INNER JOIN @schema.@cg_table_prefixcohort_definition cgcd2 ON tc.comparator_id = cgcd2.cohort_definition_id
INNER JOIN @schema.@cg_table_prefixcohort_definition cgcd3 ON cmds.outcome_id = cgcd3.cohort_definition_id
LEFT JOIN @schema.@cg_table_prefixcohort_definition cgcd4 ON tc.nesting_cohort_id = cgcd4.cohort_definition_id
WHERE cmds.database_id IS NOT NULL 
{@use_target}?{AND cgcd1.cohort_definition_id IN (@targets) } 
{@use_comparator}?{AND cgcd2.cohort_definition_id IN (@comparators) } 
{@use_outcome}?{AND cgcd3.cohort_definition_id IN (@outcomes) } 
{@use_indication} ? {AND ISNULL(tc.nesting_cohort_id,0) IN (@indication_ids) }
{@use_database}?{AND cmds.database_id IN (@database_ids) } 
{@use_analysis}?{AND cmds.analysis_id IN (@analysis_ids) }
;
