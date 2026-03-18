select cg.cohort_name, dr.outcome_cohort_definition_id as cohort_definition_id,
            'dechalRechal' as type, 1 as value
             from @schema.@c_table_prefixdechallenge_rechallenge dr inner join
                  @schema.@cg_table_prefixcohort_definition cg
  
              on dr.outcome_cohort_definition_id = cg.cohort_definition_id
 
              {@use_target}?{where dr.target_cohort_definition_id in (@target_ids)}
              group by cg.cohort_name, dr.outcome_cohort_definition_id
      ;