CREATE INDEX IF NOT EXISTS cg_cc_db ON @schema.@cg_table_prefixcohort_count(database_id);
ANALYZE @schema.@cg_table_prefixcohort_count;

CREATE INDEX IF NOT EXISTS cg_cd_subset ON @schema.@cg_table_prefixcohort_definition(subset_definition_id);
ANALYZE @schema.@cg_table_prefixcohort_definition;
