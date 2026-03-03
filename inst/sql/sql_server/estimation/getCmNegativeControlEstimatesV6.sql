SELECT cmr.*
	,cmtco.true_effect_size effect_size
	,ds.ease
FROM @schema.@cm_table_prefixresult cmr
INNER JOIN @schema.@cm_table_prefixtarget_comparator tc ON cmr.target_comparator_id = tc.target_comparator_id
INNER JOIN @schema.@cm_table_prefixtarget_comparator_outcome cmtco ON cmr.target_comparator_id = cmtco.target_comparator_id
	AND cmr.outcome_id = cmtco.outcome_id
INNER JOIN @schema.@cm_table_prefixdiagnostics_summary ds ON ds.target_comparator_id = cmr.target_comparator_id
	AND ds.analysis_id = cmr.analysis_id
	AND ds.database_id = cmr.database_id
	AND ds.outcome_id = cmr.outcome_id
WHERE cmtco.outcome_of_interest != 1 {@exclude_positive_controls}?{AND cmtco.true_effect_size = 1 } {@use_target}?{AND tc.target_id IN (@target_ids) } {@use_comparator}?{AND tc.comparator_id IN (@comparator_ids) } {@use_indication}?{AND tc.nesting_cohort_id IN (@indication_ids) }:{and tc.nesting_cohort_id IS NULL} {@use_analysis}?{AND cmr.analysis_id IN (@analysis_ids) } {@use_database}?{AND cmr.database_id IN (@database_ids) };
