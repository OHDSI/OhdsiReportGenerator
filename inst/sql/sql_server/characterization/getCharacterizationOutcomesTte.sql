select cg.cohort_name, tte.outcome_cohort_definition_id as cohort_definition_id,
             'timeToEvent' as type, 1 as value
             from @schema.@c_table_prefixtime_to_event tte inner join
                   @schema.@cg_table_prefixcohort_definition cg
  
              on tte.outcome_cohort_definition_id = cg.cohort_definition_id
 
              {@use_target}?{where tte.target_cohort_definition_id in (@target_ids)}
              group by cg.cohort_name, tte.outcome_cohort_definition_id
      ;