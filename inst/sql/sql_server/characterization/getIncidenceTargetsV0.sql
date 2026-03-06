select distinct
  cg.cohort_name, 
  ci.target_cohort_definition_id as cohort_definition_id,
  'cohortIncidence' as type,
  1 as value 
  
  from 
  @schema.@ci_table_prefixtarget_def as ci
  
  inner join 
  
  @schema.@cg_table_prefixcohort_definition cg
  
  on ci.target_cohort_definition_id = cg.cohort_definition_id
  
  ;