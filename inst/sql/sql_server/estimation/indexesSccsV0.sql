CREATE INDEX IF NOT EXISTS sccs_get_target_index_covariate ON @schema.@sccs_table_prefixcovariate(exposures_outcome_set_id, database_id, analysis_id, covariate_id, era_id);
ANALYZE @schema.@sccs_table_prefixcovariate;

CREATE INDEX IF NOT EXISTS sccs_get_target_index ON @schema.@sccs_table_prefixresult(exposures_outcome_set_id, database_id, analysis_id, covariate_id);
ANALYZE @schema.@sccs_table_prefixresult;