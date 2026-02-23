SELECT
cir.database_id,
dt.cdm_source_name as database_name,
cir.cohort_definition_id,
cd.cohort_name,
cir.inclusion_rule_mask,
cir.person_count,
cir.mode_id

FROM @schema.@cg_table_prefixCOHORT_INC_RESULT cir

INNER JOIN @schema.@database_table dt
ON cir.database_id = dt.database_id

INNER JOIN @schema.@cg_table_prefixcohort_definition cd
ON cir.cohort_definition_id = cd.cohort_definition_id

{@use_cohort_id}?{ where cir.cohort_definition_id in (@cohort_definition_ids)}
;
