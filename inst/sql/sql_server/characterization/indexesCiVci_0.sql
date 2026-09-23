CREATE INDEX IF NOT EXISTS ci_incidence_summary_idx ON @schema.@ci_table_prefixincidence_summary (database_id, target_cohort_definition_id, tar_id, subgroup_id, outcome_id, age_group_id, gender_id);
CREATE INDEX IF NOT EXISTS ci_get_outcome_summary_tid_oid ON @schema.@ci_table_prefixincidence_summary(target_cohort_definition_id,outcome_id);
CREATE INDEX IF NOT EXISTS ci_incidence_year_age_gender_idx ON @schema.@ci_table_prefixincidence_summary (start_year, age_group_id, gender_id);
CREATE INDEX IF NOT EXISTS ci_i_ref_out ON @schema.@ci_table_prefixincidence_summary(ref_id, outcome_id);
CREATE INDEX IF NOT EXISTS ci_i_tar_ref_out ON @schema.@ci_table_prefixincidence_summary(target_cohort_definition_id,ref_id, outcome_id);
ANALYZE @schema.@ci_table_prefixincidence_summary;

CREATE INDEX IF NOT EXISTS ci_get_outcome_def ON @schema.@ci_table_prefixoutcome_def(outcome_cohort_definition_id);
CREATE INDEX IF NOT EXISTS ci_od_out_ref_oid ON @schema.@ci_table_prefixoutcome_def(outcome_cohort_definition_id,ref_id, outcome_id);
ANALYZE @schema.@ci_table_prefixoutcome_def;

CREATE INDEX IF NOT EXISTS ci_td_ref_tar ON @schema.@ci_table_prefixTAR_DEF(ref_id, tar_id);
ANALYZE @schema.@ci_table_prefixTAR_DEF;

CREATE INDEX IF NOT EXISTS ci_sd_ref_sub ON @schema.@ci_table_prefixSUBGROUP_DEF(ref_id, subgroup_id);
ANALYZE @schema.@ci_table_prefixSUBGROUP_DEF;

CREATE INDEX IF NOT EXISTS ci_agd_ref_age ON @schema.@ci_table_prefixAGE_GROUP_DEF(ref_id, age_group_id);
ANALYZE @schema.@ci_table_prefixAGE_GROUP_DEF;
