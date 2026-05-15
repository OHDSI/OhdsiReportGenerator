CREATE INDEX IF NOT EXISTS cg_cc_db ON @schema.@cg_table_prefixcohort_count(database_id);
ANALYZE @schema.@cg_table_prefixcohort_count;

CREATE INDEX IF NOT EXISTS cg_cd_subset ON @schema.@cg_table_prefixcohort_definition(subset_definition_id);
CREATE INDEX IF NOT EXISTS cg_cd_id ON @schema.@cg_table_prefixcohort_definition(cohort_definition_id);
ANALYZE @schema.@cg_table_prefixcohort_definition;

CREATE INDEX IF NOT EXISTS cg_ctl_cdef_tdef ON @schema.@cg_table_prefixcohort_template_link(cohort_definition_id,template_definition_id);
ANALYZE @schema.@cg_table_prefixcohort_template_link;

CREATE INDEX IF NOT EXISTS cg_ctd_tdef ON @schema.@cg_table_prefixcohort_template_definition(template_definition_id);
ANALYZE @schema.@cg_table_prefixcohort_template_definition;