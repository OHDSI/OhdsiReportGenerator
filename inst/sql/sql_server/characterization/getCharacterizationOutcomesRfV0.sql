select cg.cohort_name, cd.outcome_cohort_id as cohort_definition_id,
            'riskFactors' as type, 1 as value
             from @schema.@c_table_prefixcohort_details cd inner join
                  @schema.@cg_table_prefixcohort_definition cg
  
              on cd.outcome_cohort_id = cg.cohort_definition_id
             
              where cd.cohort_type = 'Cases'
              {@use_target}?{and cd.target_cohort_id in (@target_ids)}
              group by cg.cohort_name, cd.outcome_cohort_id
      
      ;