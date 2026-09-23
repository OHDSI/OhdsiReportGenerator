select distinct
  cg.cohort_name, 
  c.outcome_cohort_definition_id as cohort_definition_id,
  'cohortIncidence' as type,
  1 as value 
  
  from 
  @schema.@ci_table_prefixoutcome_def as c
  
  inner join 
  
  @schema.@cg_table_prefixcohort_definition cg
  
  on c.outcome_cohort_definition_id = cg.cohort_definition_id
  
  {@use_target}?{ 
    inner join 
    (select distinct outcome_id from @schema.@ci_table_prefixincidence_summary isum
    INNER JOIN @schema.@ci_table_prefixtarget_settings ts
    ON ts.characterization_target_id = isum.characterization_target_id
    where ts.target_id in (@target_id)) temp
    on temp.outcome_id = c.outcome_id
  }
  
  {@use_characterization_target}?{ 
    inner join 
    (select distinct outcome_id from @schema.@ci_table_prefixincidence_summary isum
    where isum.characterization_target_id in (@characterization_target_id)) temp
    on temp.outcome_id = c.outcome_id
  }
  
    {@use_parent}?{ 
    inner join 
    (select distinct outcome_id from @schema.@ci_table_prefixincidence_summary isum
    INNER JOIN @schema.@ci_table_prefixtarget_settings ts
    ON ts.characterization_target_id = isum.characterization_target_id
    INNER JOIN @schema.@cg_table_prefixcohort_definition cg1
    ON cg1.cohort_definition_id = ts.target_id
    where cg1.subset_parent in (@parent_id)) temp
    on temp.outcome_id = c.outcome_id
  }
  
  ;