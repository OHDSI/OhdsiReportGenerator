SELECT 
	cat.database_id,
	dt.cdm_source_name as database_name,
	cat.cohort_definition_id, 
	cat.mode_id, 
	cat.cohort_entry, 
	cat.rule_sequence,
	COALESCE(cit.name, 'cohort entry') rule_name,
	cat.person_count
FROM @schema.@cg_table_prefixcohort_attrition cat
INNER JOIN @schema.@database_table dt ON cat.database_id = dt.database_id
LEFT JOIN @schema.@cg_table_prefixcohort_inclusion cit ON 
  cat.cohort_definition_id = cit.cohort_definition_id AND
  cat.rule_sequence = cit.rule_sequence
{@use_cohort_id}?{ WHERE cat.cohort_definition_id in (@cohort_definition_ids)}
order by 
    cat.database_id,
	cat.cohort_definition_id,
	cat.mode_id,
	cat.rule_sequence
;