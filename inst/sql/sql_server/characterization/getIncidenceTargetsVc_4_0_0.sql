select distinct
  cg.cohort_name, 
  ts.target_id as cohort_definition_id,
  'cohortIncidence' as type,
  1 as value 
  
  from 
  @schema.@ci_table_prefixtarget_settings as ts
  
  inner join 
  
  @schema.@cg_table_prefixcohort_definition cg
  
  on ts.target_id = cg.cohort_definition_id
  
  WHERE
  CAST(ts.cohort_incidence_settings AS INT) = 1
  ;