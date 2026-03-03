SELECT cd.*,
  csd.json as subset_definition_json,
  ctd.template_name,
  ctd.template_sql,
  ctd.json as template_json

FROM @schema.@cg_table_prefixCOHORT_DEFINITION cd
left join
@schema.@cg_table_prefixcohort_subset_definition csd
on cd.subset_definition_id = csd.subset_definition_id

left join @schema.@cg_table_prefixcohort_template_link ctl
ON ctl.cohort_definition_id = cd.cohort_definition_id

left join @schema.@cg_table_prefixcohort_template_definition ctd
ON ctl.template_definition_id = ctd.template_definition_id

{@restrict_to_targets}?{ where cd.cohort_definition_id in (@target_ids)}
;
