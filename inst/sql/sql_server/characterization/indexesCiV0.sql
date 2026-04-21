CREATE INDEX IF NOT EXISTS ci_incidence_summary_idx ON @schema.@ci_table_prefixincidence_summary (database_id, target_cohort_definition_id, tar_id, subgroup_id, outcome_id, age_group_id, gender_id);
CREATE INDEX IF NOT EXISTS ci_get_outcome_summary_tid_oid ON @schema.@ci_table_prefixincidence_summary(target_cohort_definition_id,outcome_id);
CREATE INDEX IF NOT EXISTS ci_incidence_year_age_gender_idx ON @schema.@ci_table_prefixincidence_summary (start_year, age_group_id, gender_id);
ANALYZE @schema.@ci_table_prefixincidence_summary;

CREATE INDEX IF NOT EXISTS ci_get_outcome_def ON @schema.@ci_table_prefixoutcome_def(outcome_cohort_definition_id);
ANALYZE @schema.@ci_table_prefixoutcome_def;