SELECT ev.evidence_synthesis_description AS database_name
	,r.analysis_id
	,a.description
	,c1.cohort_name AS target_name
	,tc.target_id
	,c2.cohort_name AS comparator_name
	,tc.comparator_id
	,c4.cohort_name AS indication_name
	,tc.nesting_cohort_id AS indication_id
	,c3.cohort_name AS outcome_name
	,r.outcome_id
	,r.calibrated_rr
	,r.calibrated_ci_95_lb
	,r.calibrated_ci_95_ub
	,r.calibrated_p
	,{@include_one_sided_p}?{r.calibrated_one_sided_p
	,} r.calibrated_log_rr
	,r.calibrated_se_log_rr
	,r.target_subjects
	,r.comparator_subjects
	,r.target_days
	,r.comparator_days
	,r.target_outcomes
	,r.comparator_outcomes
	,unblind.unblind
	,r.n_databases
	,r.pi_95_lb
	,r.pi_95_ub
	,r.calibrated_pi_95_lb
	,r.calibrated_pi_95_ub
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
	AND unblind.unblind = 1 {@include_target}?{and tc.target_id IN (@target_id) } {@include_outcome}?{and r.outcome_id IN (@outcome_id) } {@include_comparator}?{and tc.comparator_id IN (@comparator_id) };
