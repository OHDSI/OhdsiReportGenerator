SELECT ev.evidence_synthesis_description AS database_name
	,r.analysis_id
	,a.description
	,c1.cohort_name AS target_name
	,tc.target_id
	,c2.cohort_name AS comparator_name
	,tc.comparator_id
	,c4.cohort_name AS indication_name
	,ISNULL(tc.nesting_cohort_id,0) AS indication_id
	,c3.cohort_name AS outcome_name
	,r.outcome_id
	,CASE WHEN unblind.unblind = 1 THEN r.calibrated_rr ELSE NULL END calibrated_rr
	,CASE WHEN unblind.unblind = 1 THEN r.calibrated_ci_95_lb ELSE NULL END calibrated_ci_95_lb
	,CASE WHEN unblind.unblind = 1 THEN r.calibrated_ci_95_ub ELSE NULL END calibrated_ci_95_ub
	,CASE WHEN unblind.unblind = 1 THEN r.calibrated_p ELSE NULL END calibrated_p
	{@include_one_sided_p}?{,CASE WHEN unblind.unblind = 1 THEN r.calibrated_one_sided_p ELSE NULL END calibrated_one_sided_p}
	,CASE WHEN unblind.unblind = 1 THEN r.calibrated_log_rr ELSE NULL END calibrated_log_rr
	,CASE WHEN unblind.unblind = 1 THEN r.calibrated_se_log_rr ELSE NULL END calibrated_se_log_rr
	,CASE WHEN unblind.unblind = 1 THEN r.target_subjects ELSE NULL END target_subjects
	,CASE WHEN unblind.unblind = 1 THEN r.comparator_subjects ELSE NULL END comparator_subjects
	,CASE WHEN unblind.unblind = 1 THEN r.target_days ELSE NULL END target_days
	,CASE WHEN unblind.unblind = 1 THEN r.comparator_days ELSE NULL END comparator_days
	,CASE WHEN unblind.unblind = 1 THEN r.target_outcomes ELSE NULL END target_outcomes
	,CASE WHEN unblind.unblind = 1 THEN r.comparator_outcomes ELSE NULL END comparator_outcomes
	,unblind.unblind
	,r.n_databases
	,CASE WHEN unblind.unblind = 1 THEN r.pi_95_lb ELSE NULL END pi_95_lb
	,CASE WHEN unblind.unblind = 1 THEN r.pi_95_ub ELSE NULL END pi_95_ub
	,CASE WHEN unblind.unblind = 1 THEN r.calibrated_pi_95_lb ELSE NULL END calibrated_pi_95_lb
	,CASE WHEN unblind.unblind = 1 THEN r.calibrated_pi_95_ub ELSE NULL END calibrated_pi_95_ub
	,unblind.tau
	,unblind.i_2
	
FROM @schema.@es_table_prefixcm_result AS r
INNER JOIN @schema.@cm_table_prefixtarget_comparator AS tc ON r.target_comparator_id = tc.target_comparator_id
INNER JOIN @schema.@cm_table_prefixtarget_comparator_outcome AS tco ON r.target_comparator_id = tco.target_comparator_id
	AND r.outcome_id = tco.outcome_id
INNER JOIN @schema.@es_table_prefixcm_diagnostics_summary AS unblind ON r.analysis_id = unblind.analysis_id
	AND r.target_comparator_id = unblind.target_comparator_id
	AND r.outcome_id = unblind.outcome_id
INNER JOIN @schema.@cg_table_prefixcohort_definition AS c1 ON c1.cohort_definition_id = tc.target_id
INNER JOIN @schema.@cg_table_prefixcohort_definition AS c2 ON c2.cohort_definition_id = tc.comparator_id
INNER JOIN @schema.@cg_table_prefixcohort_definition AS c3 ON c3.cohort_definition_id = r.outcome_id
LEFT JOIN @schema.@cg_table_prefixcohort_definition AS c4 ON c4.cohort_definition_id = tc.nesting_cohort_id
INNER JOIN @schema.@cm_table_prefixanalysis AS a ON a.analysis_id = r.analysis_id
INNER JOIN @schema.@es_table_prefixanalysis AS ev ON ev.evidence_synthesis_analysis_id = r.evidence_synthesis_analysis_id
WHERE r.calibrated_rr != 0
	AND tco.outcome_of_interest = 1
	{@include_target}?{AND tc.target_id IN (@target_id) } 
	{@include_outcome}?{AND r.outcome_id IN (@outcome_id) } 
	{@include_comparator}?{AND tc.comparator_id IN (@comparator_id) }
	{@include_indication} ? {AND ISNULL(tc.nesting_cohort_id,0) IN (@indication_id) }
	;
