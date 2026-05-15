SELECT db.cdm_source_abbreviation AS database_name
	,db.database_id
	,r.analysis_id
	,a.description
	,tc.target_comparator_id
	,c1.cohort_name AS target_name
	,tc.target_id
	,c2.cohort_name AS comparator_name
	,tc.comparator_id
	,c4.cohort_name AS indication_name
	,ISNULL(tc.nesting_cohort_id,0) AS indication_id
	,c3.cohort_name AS outcome_name
	,r.outcome_id
	,CASE 
		WHEN COALESCE(unblind.unblind, 0) = 0
			THEN NULL
		ELSE r.calibrated_rr
		END calibrated_rr
	,CASE 
		WHEN COALESCE(unblind.unblind, 0) = 0
			THEN NULL
		ELSE r.calibrated_ci_95_lb
		END calibrated_ci_95_lb
	,CASE 
		WHEN COALESCE(unblind.unblind, 0) = 0
			THEN NULL
		ELSE r.calibrated_ci_95_ub
		END calibrated_ci_95_ub
	,CASE 
		WHEN COALESCE(unblind.unblind, 0) = 0
			THEN NULL
		ELSE r.calibrated_p
		END calibrated_p
	,CASE 
		WHEN COALESCE(unblind.unblind, 0) = 0
			THEN NULL
		ELSE r.calibrated_one_sided_p
		END calibrated_one_sided_p
	,CASE 
		WHEN COALESCE(unblind.unblind, 0) = 0
			THEN NULL
		ELSE r.calibrated_log_rr
		END calibrated_log_rr
	,CASE 
		WHEN COALESCE(unblind.unblind, 0) = 0
			THEN NULL
		ELSE r.calibrated_se_log_rr
		END calibrated_se_log_rr
	,r.target_subjects
	,r.comparator_subjects
	,r.target_days
	,r.comparator_days
	,r.target_outcomes
	,r.comparator_outcomes
	,unblind.unblind
	,unblind.unblind_for_evidence_synthesis
	,r.target_estimator
FROM @schema.@cm_table_prefixtarget_comparator tc
INNER JOIN @schema.@cm_table_prefixresult AS r ON tc.target_comparator_id = r.target_comparator_id
INNER JOIN @schema.@cm_table_prefixtarget_comparator_outcome AS tco ON tco.target_comparator_id = r.target_comparator_id
    AND tco.outcome_id = r.outcome_id
INNER JOIN @schema.@cm_table_prefixdiagnostics_summary AS unblind ON r.analysis_id = unblind.analysis_id
	AND r.target_comparator_id = unblind.target_comparator_id
	AND r.outcome_id = unblind.outcome_id
	AND r.database_id = unblind.database_id
INNER JOIN @schema.@database_table AS db ON db.database_id = r.database_id
INNER JOIN @schema.@cg_table_prefixcohort_definition AS c1 ON c1.cohort_definition_id = tc.target_id
INNER JOIN @schema.@cg_table_prefixcohort_definition AS c2 ON c2.cohort_definition_id = tc.comparator_id
INNER JOIN @schema.@cg_table_prefixcohort_definition AS c3 ON c3.cohort_definition_id = r.outcome_id
LEFT JOIN @schema.@cg_table_prefixcohort_definition AS c4 ON c4.cohort_definition_id = tc.nesting_cohort_id
INNER JOIN @schema.@cm_table_prefixanalysis AS a ON a.analysis_id = r.analysis_id
WHERE tco.outcome_of_interest = 1 
{@restrict_target} ? { AND tc.target_id IN (@target_id) } 
{@restrict_outcome} ? {AND r.outcome_id IN (@outcome_id) } 
{@restrict_comparator} ? {AND tc.comparator_id IN (@comparator_id) }
{@restrict_indication} ? {AND ISNULL(tc.nesting_cohort_id,0) IN (@indication_id) }
;
