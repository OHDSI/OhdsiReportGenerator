SELECT
cc.cohort_id,
cd.cohort_name,
cc.cohort_entries,
cc.cohort_subjects,
dt.cdm_source_name as database_name,
dt.database_id

FROM @schema.@cg_table_prefixCOHORT_COUNT cc

INNER JOIN @schema.@database_table dt
ON cc.database_id = dt.database_id

INNER JOIN @schema.@cg_table_prefixCOHORT_DEFINITION cd
ON cd.cohort_definition_id = cc.cohort_id

{@use_cohort_id}?{ WHERE cc.cohort_id in (@cohort_definition_ids)}
;
