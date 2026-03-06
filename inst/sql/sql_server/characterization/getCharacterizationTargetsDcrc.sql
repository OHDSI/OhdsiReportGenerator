select 
      cg.cohort_name,
      dr.target_cohort_definition_id as cohort_definition_id,
      'dechalRechal' as type,
      1 as value
      
      from (select distinct target_cohort_definition_id from @schema.@c_table_prefixdechallenge_rechallenge) dr
      inner join 
      @schema.@cg_table_prefixcohort_definition cg
      on dr.target_cohort_definition_id = cg.cohort_definition_id
    ;