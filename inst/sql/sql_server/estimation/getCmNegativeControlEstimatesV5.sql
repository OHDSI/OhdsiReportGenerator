--@use_indication
--@indication_id

SELECT cmr.*
	,cmtco.true_effect_size effect_size
	,ds.ease
FROM @schema.@cm_table_prefixresult cmr
INNER JOIN @schema.@cm_table_prefixtarget_comparator_outcome cmtco ON cmr.target_id = cmtco.target_id
	AND cmr.comparator_id = cmtco.comparator_id
	AND cmr.outcome_id = cmtco.outcome_id
INNER JOIN @schema.@cm_table_prefixdiagnostics_summary ds ON ds.target_id = cmr.target_id
	AND ds.comparator_id = cmr.comparator_id
	AND ds.analysis_id = cmr.analysis_id
	AND ds.database_id = cmr.database_id
	AND ds.outcome_id = cmr.outcome_id
WHERE cmtco.outcome_of_interest != 1 {@exclude_positive_controls}?{AND cmtco.true_effect_size = 1 } {@use_target}?{AND cmr.target_id IN (@target_ids) } {@use_comparator}?{AND cmr.comparator_id IN (@comparator_ids) } {@use_analysis}?{AND cmr.analysis_id IN (@analysis_ids) } {@use_database}?{AND cmr.database_id IN (@database_ids) };
