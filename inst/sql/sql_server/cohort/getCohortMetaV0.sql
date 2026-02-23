SELECT
cg.cohort_id,
cg.cohort_name,
cg.generation_status,
cg.start_time,
cg.end_time,
dt.cdm_source_name as database_name,
dt.database_id

FROM @schema.@cg_table_prefixCOHORT_GENERATION cg
INNER JOIN @schema.@database_table dt
ON cg.database_id = dt.database_id

{@use_cohort_id}?{ WHERE cg.cohort_id in (@cohort_definition_ids)}
;
