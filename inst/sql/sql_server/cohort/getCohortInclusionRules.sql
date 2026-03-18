SELECT
ci.cohort_definition_id,
cd.cohort_name,
ci.rule_sequence,
ci.name as rule_name

FROM @schema.@cg_table_prefixCOHORT_INCLUSION ci
INNER JOIN @schema.@cg_table_prefixCOHORT_DEFINITION cd
ON cd.cohort_definition_id = ci.cohort_definition_id

{@use_cohort_id}?{ WHERE cd.cohort_definition_id in (@cohort_definition_ids)}
;
