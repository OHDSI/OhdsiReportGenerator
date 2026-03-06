select distinct
  cg.cohort_name, 
  ci.outcome_cohort_definition_id as cohort_definition_id,
  'cohortIncidence' as type,
  1 as value 
  
  from 
  @schema.@ci_table_prefixoutcome_def as ci
  
  inner join 
  
  @schema.@cg_table_prefixcohort_definition cg
  
  on ci.outcome_cohort_definition_id = cg.cohort_definition_id
  
  {@use_target}?{ 
    inner join 
    (select distinct outcome_id from @schema.@ci_table_prefixincidence_summary
    where target_cohort_definition_id in (@target_id)) temp
    on temp.outcome_id = ci.outcome_id
  }
  
  ;