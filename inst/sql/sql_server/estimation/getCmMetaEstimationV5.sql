SELECT ev.evidence_synthesis_description AS database_name
	,r.analysis_id
	,a.description
	,c1.cohort_name AS target_name
	,r.target_id
	,c2.cohort_name AS comparator_name
	,r.comparator_id
	,NULL AS indication_name
	,0 AS indication_id
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
	,NULL as pi_95_lb
	,NULL as r.pi_95_ub
	,NULL as calibrated_pi_95_lb
	,NULL as calibrated_pi_95_ub
	,unblind.tau
	,unblind.i_2
FROM @schema.@es_table_prefixcm_result AS r
INNER JOIN @schema.@cm_table_prefixtarget_comparator_outcome AS tco ON r.target_id = tco.target_id
	AND r.comparator_id = tco.comparator_id
	AND r.outcome_id = tco.outcome_id
INNER JOIN @schema.@es_table_prefixcm_diagnostics_summary AS unblind ON r.analysis_id = unblind.analysis_id
	AND r.target_id = unblind.target_id
	AND r.comparator_id = unblind.comparator_id
	AND r.outcome_id = unblind.outcome_id
INNER JOIN @schema.@cg_table_prefixcohort_definition AS c1 ON c1.cohort_definition_id = r.target_id
INNER JOIN @schema.@cg_table_prefixcohort_definition AS c2 ON c2.cohort_definition_id = r.comparator_id
INNER JOIN @schema.@cg_table_prefixcohort_definition AS c3 ON c3.cohort_definition_id = r.outcome_id
INNER JOIN @schema.@cm_table_prefixanalysis AS a ON a.analysis_id = r.analysis_id
INNER JOIN @schema.@es_table_prefixanalysis AS ev ON ev.evidence_synthesis_analysis_id = r.evidence_synthesis_analysis_id
WHERE r.calibrated_rr != 0
	AND tco.outcome_of_interest = 1
	AND unblind.unblind = 1 {@include_target}?{and r.target_id IN (@target_id) } {@include_outcome}?{and r.outcome_id IN (@outcome_id) } {@include_comparator}?{and r.comparator_id IN (@comparator_id) };
