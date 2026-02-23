SELECT 
	csat.database_id,
	dt.cdm_source_name as database_name,
	csat.cohort_definition_id, 
	csat.subset_definition_id, 
	csat.subset_parent_id, 
	csat.mode_id, 
	csat.cohort_entry, 
	csat.operator_sequence,
	COALESCE(csot.operator_name, 'cohort entry') operator_name,
	csot.operator_type,
	csat.count_value
FROM @schema.@cg_table_prefixcohort_subset_attrition csat
INNER JOIN @schema.@database_table dt ON csat.database_id = dt.database_id
LEFT JOIN @schema.@cg_table_prefixcohort_subset_operator csot ON 
  csat.subset_definition_id = csot.subset_definition_id AND
  csat.operator_sequence = csot.operator_sequence
{@use_cohort_id}?{ WHERE csat.cohort_definition_id in (@cohort_definition_ids)}
order by 
    csat.database_id,
	csat.cohort_definition_id, 
	csat.subset_definition_id, 
	csat.subset_parent_id, 
	csat.mode_id, 
	csat.operator_sequence
;
