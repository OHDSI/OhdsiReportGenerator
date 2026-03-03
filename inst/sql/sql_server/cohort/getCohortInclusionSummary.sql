SELECT
css.cohort_definition_id,
cd.cohort_name,
css.base_count,
css.final_count,
css.mode_id,
dt.cdm_source_name as database_name,
dt.database_id

FROM @schema.@cg_table_prefixCOHORT_SUMMARY_STATS css

INNER JOIN @schema.@database_table dt
ON css.database_id = dt.database_id

INNER JOIN @schema.@cg_table_prefixCOHORT_DEFINITION cd
ON cd.cohort_definition_id = css.cohort_definition_id

{@use_cohort_id}?{ WHERE css.cohort_definition_id in (@cohort_definition_ids)}
;
