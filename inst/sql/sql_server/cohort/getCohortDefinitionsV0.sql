SELECT cd.*,
  csd.json as subset_json
FROM @schema.@cg_table_prefixCOHORT_DEFINITION cd
left join
@schema.@cg_table_prefixcohort_subset_definition csd
on cd.subset_definition_id = csd.subset_definition_id
;
