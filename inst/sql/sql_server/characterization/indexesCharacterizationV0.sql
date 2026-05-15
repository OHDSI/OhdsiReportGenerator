CREATE INDEX IF NOT EXISTS c_cc_t_o ON @schema.@c_table_prefixcohort_counts(target_cohort_id, outcome_cohort_id);
ANALYZE @schema.@c_table_prefixcohort_counts;

CREATE INDEX IF NOT EXISTS c_cd_cohort_type_idx ON @schema.@c_table_prefixcohort_details(cohort_type);
CREATE INDEX IF NOT EXISTS c_cd_cohort_type_outcome_idx ON @schema.@c_table_prefixcohort_details(cohort_type, outcome_cohort_id);
CREATE INDEX IF NOT EXISTS c_cd_cohort_type_target_idx ON @schema.@c_table_prefixcohort_details(cohort_type, target_cohort_id);
CREATE INDEX IF NOT EXISTS c_cd_outcome_type_target ON @schema.@c_table_prefixcohort_details(outcome_cohort_id, cohort_type, target_cohort_id);
CREATE INDEX IF NOT EXISTS c_cohort_details_idx ON @schema.@c_table_prefixcohort_details(database_id, setting_id, cohort_type, target_cohort_id, outcome_cohort_id);
ANALYZE @schema.@c_table_prefixcohort_details;

CREATE INDEX IF NOT EXISTS c_cr_db_set_cov_an ON @schema.@c_table_prefixcovariate_ref(database_id, setting_id, covariate_id, analysis_id);
ANALYZE @schema.@c_table_prefixcovariate_ref;

CREATE INDEX IF NOT EXISTS c_c_tid_type ON @schema.@c_table_prefixcovariates(target_cohort_id, cohort_type);
ANALYZE @schema.@c_table_prefixcovariates;

CREATE INDEX IF NOT EXISTS c_dr_outcome_target_db ON @schema.@c_table_prefixdechallenge_rechallenge(outcome_cohort_definition_id, target_cohort_definition_id, database_id);
CREATE INDEX IF NOT EXISTS c_dr_target_outcome_db ON @schema.@c_table_prefixdechallenge_rechallenge(target_cohort_definition_id, outcome_cohort_definition_id, database_id);
ANALYZE @schema.@c_table_prefixdechallenge_rechallenge;

CREATE INDEX IF NOT EXISTS c_dfcs_outcome_target_db_options ON @schema.@c_table_prefixrechallenge_fail_case_series(outcome_cohort_definition_id, target_cohort_definition_id, database_id, dechallenge_stop_interval, dechallenge_evaluation_window);
CREATE INDEX IF NOT EXISTS c_dfcs_target_outcome_db ON @schema.@c_table_prefixrechallenge_fail_case_series(target_cohort_definition_id, outcome_cohort_definition_id, database_id);
ANALYZE @schema.@c_table_prefixrechallenge_fail_case_series;

CREATE INDEX IF NOT EXISTS c_tte_outcome_target ON @schema.@c_table_prefixtime_to_event(outcome_cohort_definition_id, target_cohort_definition_id);
CREATE INDEX IF NOT EXISTS c_tte_outcome_target_db ON @schema.@c_table_prefixtime_to_event(outcome_cohort_definition_id, target_cohort_definition_id, database_id);
CREATE INDEX IF NOT EXISTS c_tte_target ON @schema.@c_table_prefixtime_to_event(target_cohort_definition_id);
CREATE INDEX IF NOT EXISTS c_tte_target_outcome ON @schema.@c_table_prefixtime_to_event(target_cohort_definition_id, outcome_cohort_definition_id);
ANALYZE @schema.@c_table_prefixtime_to_event;