CREATE INDEX IF NOT EXISTS c_ar_db_set_an_cov ON @schema.@c_table_prefixanalysis_ref(database_id, setting_id, analysis_id);
ANALYZE @schema.@c_table_prefixanalysis_ref;

CREATE INDEX IF NOT EXISTS c_cr_db_set_an ON @schema.@c_table_prefixcovariate_ref(database_id, setting_id, analysis_id, covariate_id);
ANALYZE @schema.@c_table_prefixcovariate_ref;

CREATE INDEX IF NOT EXISTS c_att_db_set_cohort ON @schema.@c_table_prefixattrition(database_id, setting_id, cohort_definition_id);
ANALYZE @schema.@c_table_prefixattrition;

CREATE INDEX IF NOT EXISTS c_ts_target ON @schema.@c_table_prefixtarget_settings(target_id);
CREATE INDEX IF NOT EXISTS c_ts_db_set_target ON @schema.@c_table_prefixtarget_settings(database_id, setting_id, characterization_target_id);
CREATE INDEX IF NOT EXISTS c_ts_char_target ON @schema.@c_table_prefixtarget_settings (characterization_target_id, target_id);
ANALYZE @schema.@c_table_prefixtarget_settings;

CREATE INDEX IF NOT EXISTS c_cs_outcome ON @schema.@c_table_prefixcase_settings(outcome_id);
CREATE INDEX IF NOT EXISTS c_cs_db_set_case ON @schema.@c_table_prefixcase_settings(database_id, setting_id, characterization_case_id);
CREATE INDEX IF NOT EXISTS c_cs_runtype_target ON @schema.@c_table_prefixcase_settings (runtype, characterization_target_id);
ANALYZE @schema.@c_table_prefixcase_settings;

CREATE INDEX IF NOT EXISTS c_tc_db_set_target ON @schema.@c_table_prefixtarget_covariates(database_id, setting_id, characterization_target_id);
CREATE INDEX IF NOT EXISTS c_tcc_db_set_target ON @schema.@c_table_prefixtarget_covariates_continuous(database_id, setting_id, characterization_target_id);
ANALYZE @schema.@c_table_prefixtarget_covariates;
ANALYZE @schema.@c_table_prefixtarget_covariates_continuous;

CREATE INDEX IF NOT EXISTS c_rfc_db_set_case ON @schema.@c_table_prefixrisk_factor_covariates(database_id, setting_id, characterization_case_id);
CREATE INDEX IF NOT EXISTS c_rfcc_db_set_case ON @schema.@c_table_prefixrisk_factor_covariates_continuous(database_id, setting_id, characterization_case_id);
ANALYZE @schema.@c_table_prefixrisk_factor_covariates;
ANALYZE @schema.@c_table_prefixrisk_factor_covariates_continuous;

CREATE INDEX IF NOT EXISTS c_csc_db_set_case ON @schema.@c_table_prefixcase_series_covariates(database_id, setting_id, characterization_case_id);
CREATE INDEX IF NOT EXISTS c_cscc_db_set_case ON @schema.@c_table_prefixcase_series_covariates_continuous(database_id, setting_id, characterization_case_id);
ANALYZE @schema.@c_table_prefixcase_series_covariates;
ANALYZE @schema.@c_table_prefixcase_series_covariates_continuous;


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
